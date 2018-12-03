(ns dmeeuwis.advent2018
  (:require [clojure.string :as string]))

(def grid-size 1000)

(defn read-claim [s]
  (let [m (re-matches #"(#\d+) @ (\d+),(\d+): (\d+)x(\d+)" s)]
    (cond 
      (not m)
      (throw (RuntimeException. (str "Error parsing claim: " s)))

      :default
      { :id (nth m 1) :x (read-string (nth m 2)) :y (read-string (nth m 3)) :w (read-string (nth m 4)) :h (read-string (nth m 5)) })))

(defn point-to-index [point]
  (+ (* (second point) grid-size) (first point)))

(defn extract-points [claim]
  (for [x (range (claim :x) (+ (claim :x) (claim :w)))
        y (range (claim :y) (+ (claim :y) (claim :h)))]
    [x y]))

(defn draw-point [point grid]
  (assoc grid point (inc (nth grid point))))

(defn draw-claim [claim grid]
  (let [points (extract-points claim)
        points-1d (map point-to-index points)]
    (loop [p points-1d g grid]
      (if (empty? p)
        g
        (recur (rest p) (draw-point (first p) g))))))

(defn draw-board [grid cols]
  (doall
    (for [i (range 0 (count grid))]
      (if (= 0 (mod i cols))
        (print "\n" (nth grid i))
        (print (nth grid i)))))
  (println))

(defn draw-claims-on-board [claims grid]
  (if (empty? claims)
    grid

    (recur (rest claims)
           (draw-claim (first claims) grid))))

(defn check-claim [c grid]
  (println "check-claim" c (type grid))
  (let [points-2d (extract-points c)
        points-1d (map point-to-index points-2d)]
    (println "points-ed" points-2d)
    (println "points-1d" points-1d)
    (println "points-1d" (type points-1d))

    (loop [points points-1d]
      (cond 
        
        (empty? points)
        true

        (> (nth grid (first points)) 1)
        false

        (= 1 (nth grid (first points)))
        (recur (rest points))))))

(defn find-good-claims [grid claims good-claims-col]
  (cond
    (empty? claims)
    good-claims-col

    (check-claim (first claims) grid)
    (recur grid (rest claims) (conj good-claims-col (first claims)))

    :default
    (recur grid (rest claims) good-claims-col)))

(println "Overclaimed grid points: " 
  (let [all-claims (-> (first *command-line-args*)
                       (slurp)
                       (string/split #"\n")
                       (->> (map read-claim)))]

    (let [initial-grid (vec (repeat (* grid-size grid-size) 0))]
      (-> (draw-claims-on-board all-claims initial-grid)
          (find-good-claims all-claims [])))))
