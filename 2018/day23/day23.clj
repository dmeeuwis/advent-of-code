(ns dmeeuwis.advent2018
  (:require [clojure.string :as string]))


(let [lines (-> (first *command-line-args*) (slurp) (string/split #"\n"))
      pattern #"pos=<(\d+),(\d+),(\d+)>, r=(\d+)"
      nb-matches (map #(re-matches pattern %) lines)
      nanobots (doall (map #( [ [(nth % 1) (nth % 2) (nth % 3)] (nth % 4) ]) nb-matches))
     ]
  (println nanobots))
