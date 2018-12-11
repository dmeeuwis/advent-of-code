(ns dmeeuwis.advent2018 
  (:require [clojure.string :as string]))

(defn rack-id [x]
  (+ 10 x))

(defn power-level [x y serial]
  (-> (rack-id x)
      (* y)
      (+ serial)
      (* (rack-id x))
      (#(.toString %))
      (string/reverse)
      (#(.substring % 2 3))
      (#(Integer/parseInt %))
      (- 5)
      ))

(defn power-board [serial]
  (into (sorted-map)
    (for [y (range 1 301), x (range 1 301)]
      [[x y] (power-level x y serial)]))) 

(defn find-grid-power [chart x y]
  (+ (chart [(+ x 0) (+ y 0)])
     (chart [(+ x 1) (+ y 0)])
     (chart [(+ x 2) (+ y 0)])
     (chart [(+ x 0) (+ y 1)])
     (chart [(+ x 1) (+ y 1)])
     (chart [(+ x 2) (+ y 1)])
     (chart [(+ x 0) (+ y 2)])
     (chart [(+ x 1) (+ y 2)])
     (chart [(+ x 2) (+ y 2)])))

(let [serial (-> (first *command-line-args*) slurp (#(.trim %)) (#(Integer/parseInt %)))]
  (let [power-chart (power-board serial)
        power-grids (for [y (range 1 299), x (range 1 299)]
                      [ [x y] (find-grid-power power-chart x y)])
        top (first (reverse (sort-by second power-grids)))]
 
    (println "Top grid:" top)))
