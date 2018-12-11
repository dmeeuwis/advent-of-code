(ns dmeeuwis.advent2018 
  (:require [clojure.string :as string]))

(defn power-level [x y serial]
  (-> (+ 10 x)
      (* y)
      (+ serial)
      (* (+ 10 x))
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

(defn find-grid-power [chart x y power]
  (apply + (for [xi (range x (min 301 (+ x power)))
                 yi (range y (min 301 (+ y power)))]
         (chart [xi yi]))))

(let [serial (-> (first *command-line-args*) slurp (#(.trim %)) (#(Integer/parseInt %)))]
  (let [power-chart (power-board serial)]
    (doall
      (pmap 
        (fn [power]
          (let [ power-grids (for [y (range 1 (- 301 power)), x (range 1 (- 301 power))]
                          [ [x y] (find-grid-power power-chart x y power)])
                 top (first (reverse (sort-by second power-grids)))]
       
            (println "Top grid for power:" power top)
            top))
        (range 1 301)))))
