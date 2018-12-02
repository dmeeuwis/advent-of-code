(ns dmeeuwis.advent2018
  (:require [clojure.string :as str]))

(defn find-n-char-boxes [n all-counts]
  (filter (fn [counts]
            (some (fn [v] (= n v)) (vals counts)))
          all-counts))

(defn count-chars [in]
  (loop [s (.toLowerCase in) counts {}]
    (if (= 0 (count s))
      counts
      (recur (rest s) (update counts 
                              (first s)
                              #(if % (inc %) 1)) ))))

(println "Checksum:"
  (let [strings (-> (first *command-line-args*)
                 (slurp)
                 (str/split #"\n"))
        counts (map count-chars strings)

        two-counts (find-n-char-boxes 2 counts)
        three-counts (find-n-char-boxes 3 counts)]

    (* (count two-counts) (count three-counts))))
