(ns dmeeuwis.advent2018
  (:require [clojure.string :as string]))

(defn inte [n] 
  (Integer/parseInt n))

(defn square [n]
  (* n n))

(defn taxicab_e [p1 p2]
  (Math/sqrt (+
         (square (- (first p1) (first p2)))
         (square (- (second p1) (second p2)))
         (square (- (nth p1 2) (nth p2 2))))))


(defn taxicab [p1 p2]
  (+
     (abs (- (first p1) (first p2)))
     (abs (- (second p1) (second p2)))
     (abs (- (nth p1 2) (nth p2 2)))))

(let [lines (-> (first *command-line-args*) (slurp) (string/split #"\n"))
      pattern #"pos=<(-?\d+),(-?\d+),(-?\d+)>, r=(-?\d+)"
      nb-matches (map #(re-matches pattern %) lines)
      nanobots (map #(list [(inte (nth % 1)) (inte (nth % 2)) (inte (nth % 3))] (inte (nth % 4))) nb-matches)

      sorted (sort-by second nanobots)
      largest (last sorted)
      _ (println "largest!" largest)
      distances (doall (map #(taxicab (first largest) (first %)) nanobots))
      _ (println "distances!" distances)
      in-range (filter #(<= % (second largest)) distances)
     ]

  (println "In range:" (count in-range)))
