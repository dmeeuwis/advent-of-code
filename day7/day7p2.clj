(ns dmeeuwis.advent2018
  (:require [clojure.string :as string]))

(defn read-dep-line [line]
  (let [match (re-matches #"Step (.) must be finished before step (.) can begin." 
                        line)]
    [(match 1) (match 2)]))

(defn preceed-maps [dep-list]
  (loop [deps dep-list preceeds { }]
    (if (empty? deps)
      preceeds
      (recur (rest deps) (assoc preceeds (-> deps first second)
                                          (conj
                                            (or (preceeds (-> deps first second))
                                                [])
                                            (-> deps first first)))))))

(defn find-not-in-map [ks m]
  (loop [k ks coll []]
    (if (empty? k)
      coll

      (recur (rest k)
             (if-let [v (m (first k))]
               coll
               (conj coll (first k)))))))

(defn find-finished-job [min-time time busy-worker]
  (let [job-time (inc (- (int (.charAt (busy-worker :step) 0)) 65))]
    (if (>= time (+ (busy-worker :start) job-time min-time))
      busy-worker
      nil)))

(defn vector-rm [base rm]
  (loop [b base coll []]
    (if (empty? b)
      coll
      (recur (rest b)
             (if (some #(= (first b) %) rm)
               coll
               (conj coll (first b)))))))

(defn assign [workers steps start-time]
; (println "Starting to assign work" workers steps start-time)
  (loop [w workers, s steps, assigned []]
    (if (or (empty? w) (empty? s))
      (do
       ;(println "Assigned work!" start-time assigned)
        assigned)
      (recur (rest w) (rest s)
             (conj assigned { :worker (first w) :step (first s) :start start-time })))))

(defn in [v target]
  (cond 
    (empty? v) false
    (= target (first v)) true
    :default (recur (rest v) target)))

(defn order-steps [min-time all-claims all-steps workers]
  (loop [claims all-claims, steps all-steps, work-in-progress [], order "", time 0]
    (println "------------------------------------------------")
    (println time order steps work-in-progress)
    (println claims)
    (if (and (empty? steps) (empty? work-in-progress))
      [order (dec time)]

      (let [finished-workers (filter #(find-finished-job min-time time %) work-in-progress)
            just-completed-steps (map :step finished-workers)
            still-busy-workers (vector-rm work-in-progress finished-workers)

            adjusted-claims (filter #(not (in just-completed-steps (first %))) claims)

            mapped (preceed-maps adjusted-claims)
            ready-steps (sort (find-not-in-map steps mapped))

            available-workers (vector-rm workers (map :worker still-busy-workers))
            new-workers (assign available-workers ready-steps time)

            now-busy-workers (concat still-busy-workers new-workers)
           ]
        (println "still-busy-workers" still-busy-workers)
        (println "available workers" available-workers)
        (println "Started:" new-workers)
        (println "Finished" finished-workers)

        (recur adjusted-claims 
               (vector-rm steps (map :step new-workers))
               now-busy-workers
               (str order (string/join "" just-completed-steps))
               (inc time))))))

(let [all-claims (-> (first *command-line-args*)
                     (slurp)
                     (string/split #"\n")
                     (->> (map read-dep-line)))]

  (println (order-steps 60
                        all-claims 
                        (set (flatten all-claims))
                        [ :w1 :w2 :w3 :w4 :w5 ])))
