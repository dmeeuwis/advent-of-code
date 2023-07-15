(ns dmeeuwis.advent2018 
  (:require [clojure.string :as string]))

(defn read-input [lines]
  (loop [l lines, initial-state nil, rules {}]
    (cond
      (empty? l)
      { :initial-state initial-state :rules rules }

      (= (.indexOf (first l) "initial state:") 0)
      (let [match (re-matches #"initial state: (.*)" (first l))]
        (recur (rest l) (match 1) rules))

      (= 0 (.length (.trim (first l))))
      (recur (rest l) initial-state rules)

      :default
      (let [match (re-matches #"([\.#]*) => (.)" (first l))]
        (recur (rest l) 
               initial-state 
               (assoc rules (match 1) (match 2)))))))

(defn generation [initial-state rules]
  (.toString
    (loop [i 0, state (StringBuilder. initial-state)]
      (if (= i (- (.length initial-state) 5))
        state
        (let [sub (.substring initial-state i (+ i 5))]
          (if (rules sub)
            (do
             ;(println "Matched" i sub "to" (rules sub))
              (recur (inc i) (do
                               (.setCharAt state (+ i 2) (.charAt (rules sub) 0))
                               state)))
            (do 
              ;(println "Didn't match" sub)
              (recur (inc i) (do
                               (.setCharAt state (+ i 2) \.)
                               state)))))))))

(defn sum-indexes [padding state]
  (loop [s (seq state), i (* -1 padding), sum 0]
    (if (empty? s)
      sum

    (recur (rest s) (inc i)
           (if (= \# (first s)) (+ sum i)
             sum)))))

(let [data (-> (first *command-line-args*)
               (slurp)
               (string/split #"\n")
               read-input)]

  (println "Initial state:" (:initial-state data) "\n")
  (let [pad-count 10000
        padding (apply str (repeat pad-count "."))
        initial (str padding (:initial-state data) padding)
        final (loop [i 0, state initial, last-count (sum-indexes pad-count initial) ]
                (let [count (sum-indexes pad-count state)]
                  (println i ":" (sum-indexes pad-count state) (- count last-count))
                  (if (= i 50000000000)
                    state
                    (recur (inc i) (generation state (:rules data)) count))))]
    (println final)
    (println "# Count is" (sum-indexes pad-count final))))
