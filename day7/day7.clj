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

(defn order-steps [all-claims all-steps]
  (loop [claims all-claims steps all-steps order ""]
      (if (empty? claims)
        (str order (first steps))

        (let [ mapped (preceed-maps claims)
               ready-steps (sort (find-not-in-map steps mapped))
               step (first ready-steps)
             ]

          (println "Claims:" claims)
          (println "Steps:" steps)
          (println "Mapped" mapped)
          (println "Ready-steps:" ready-steps)
          
          (recur (filter #(not= step (first %)) claims)
                 (disj steps step)
                 (str order step))))))


(let [all-claims (-> (first *command-line-args*)
                     (slurp)
                     (string/split #"\n")
                     (->> (map read-dep-line)))]

  (println (order-steps all-claims (set (flatten all-claims)))))
