(ns dmeeuwis.advent2018
  (require [clojure.string :as str]))

(println
  (-> (first *command-line-args*)
      (slurp)
      (str/split #"\n")
      (->> (map #(Integer/parseInt %)))
      (->> (reduce +))))
