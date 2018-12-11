(ns dmeeuwis.advent2018 
  (:require [clojure.string :as string]))

(import 'java.awt.image.BufferedImage 'javax.imageio.ImageIO 'java.awt.Color 'java.io.File)

(def regex #"position=<\s*(-?\d+),\s*(-?\d+)> velocity=<\s*(-?\d+),\s*(-?\d+)>")

(defn index-stars [stars]
  (loop [s stars coll { }]
    (if (empty? s) 
      coll
      (recur (rest s) 
             (assoc coll (:position (first s)) (first s))))))

(defn count-neighbours [stars-by-position]
  (loop [s (keys stars-by-position), n 0]
    (if (empty? s)
      n
      (recur
        (rest s)
        (let [p (first s)]
          (if (or (stars-by-position [ (inc (first p)) (second p) ])
                  (stars-by-position [ (dec (first p)) (second p) ])
                  (stars-by-position [ (first p) (inc (second p)) ])
                  (stars-by-position [ (first p) (dec (second p)) ]))
            (inc n)
            n))))))

(defn image-star-field [stars time]
  (let [stars-by-position (index-stars stars)
        min-x (apply min (map #(first (:position %)) stars))
        min-y (apply min (map #(second (:position %)) stars))
        max-x (apply max (map #(first (:position %)) stars))
        max-y (apply max (map #(second (:position %)) stars))
        width (- max-x min-x)
        height (- max-y min-y)

        sb (BufferedImage. width height BufferedImage/TYPE_INT_ARGB)
        draw (.getGraphics sb) ]
    (println time ": min-x" min-x "max-x" max-x "min-y" min-y "max-y" max-y "width" width "height" height)

    (.setColor draw Color/BLACK)
    (.fillRect draw 0 0 width height)

    (doall
      (for [y (range min-y (inc max-y))
            x (range min-x (inc max-x))]
        (do
          (cond
            (stars-by-position [x y])
            (do
              (.setColor draw Color/WHITE)
              (.fillRect draw (- x min-x) (- y min-y) 1 1))
            
            :default
            (do
              (.setColor draw Color/BLUE)
              (.fillRect draw (- x min-x) (- y min-y) 1 1))
            ))))
    (ImageIO/write sb "png" (File. (str "shot_" time ".png")))))

(defn time-passes [stars]
  (loop [s stars coll []]
    (if (empty? s)
      coll
      (let [p (:position (first s))
            v (:velocity (first s))]
        (recur (rest s)
               (conj coll {
                     :position [ (+ (first p) (first v))
                                 (+ (second p) (second v))]
                     :velocity (:velocity (first s)) }))))))


(defn read-star [line]
  (if-let [g (re-matches regex line)]
    { :position [ (Integer/parseInt (g 1)) (Integer/parseInt (g 2))]
      :velocity  [ (Integer/parseInt (g 3)) (Integer/parseInt (g 4))] }
    (throw (RuntimeException. (str "Couldn't match line: " line)))))

(println "Running!")
(let [stars (-> (first *command-line-args*) 
                slurp 
                (string/split #"\n")
                (->> (map read-star)))
      stars-by-time (doall (take 15000 (iterate time-passes stars)))
      indexed (doall (map index-stars stars-by-time))
      counts (doall (map count-neighbours indexed))
      best-guesses (filter #(> % 15) counts)
      best-guess-indexes (map #(.indexOf counts %) best-guesses)]

  (println "Best guesses are:" best-guesses "Indices:" best-guess-indexes)
  (doall
    (for [i (range 0 (count best-guess-indexes))]
      (image-star-field (nth stars-by-time (nth best-guess-indexes i)) (nth best-guess-indexes i)))))
