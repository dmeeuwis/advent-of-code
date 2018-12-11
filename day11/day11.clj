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

(defn find-grid-power [chart x y size]
  (apply + 
    (for [yi (range y (+ y size))
          xi (range x (+ x size))]

      (or (chart [xi yi]) 0))))

(let [serial (-> (first *command-line-args*) slurp (#(.trim %)) (#(Integer/parseInt %)))
      power-chart (power-board serial)
      curr-power (atom nil)
      power-grids (pmap (fn [power]
                    (for [y (range 1 (- 301 power)), x (range 1 (- 301 power))]
                      (do
                        (if (not= @curr-power power)
                          (do
                            (reset! curr-power power)
                            (println "Now at power" power)))
                        [ [x y power] (find-grid-power power-chart x y power)])))
                    (reverse (range 3 4)))
      top (sort-by second power-grids)]
 
    (println "Top powers" (map second top))
    (println "Top grid with power" (second (first top))))
