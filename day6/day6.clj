(ns dmeeuwis.advent2018
  (:require [clojure.string :as st]))

(defn distance [p1 p2]
  (+ (java.lang.Math/abs (- (first p1)  (first p2)))
     (java.lang.Math/abs (- (second p1) (second p2)))))

(defn int-to-char [i]
  (str (char (+ 97 i))))

(defn find-shortest-distance-or-tie [indexed points-with-distance]
  (let [ordered (sort #(compare (second %1) (second %2)) points-with-distance)
        min-distance (second (first ordered))]

    (if (= 1 (count (filter #(= min-distance (second %)) ordered)))
      (-> ordered first first indexed int-to-char)
      "_")))

(defn make-distance-matrix [x-range y-range points]
  (println "Points:" points)
  (let [ indexed (into {}
                   (for [i (range 0 (count points))]
                     [(nth points i) i]))]
    (println "Indexed" indexed)
    (for [x (range 0 (inc x-range))
          y (range 0 (inc y-range))]

          (let [distances-for-this-point (map (fn [z] [z (distance [x y] z)]) points)]
            (if (>= (.indexOf points [x y]) 0)
              (do
                (println "Saw a real point!" (indexed [x y]) [x y])
                (.toUpperCase (int-to-char (indexed [x y]))))
              (find-shortest-distance-or-tie indexed distances-for-this-point))))))

(defn print-matrix [arr x-range]
  (println "print-matrix:" (count arr) x-range)
  (doseq [i (range 0 (count arr))]
    (do
      (print (nth arr i))
      (if (zero? (mod (inc i) (inc x-range)))
        (println)))))

(let [data (-> (first *command-line-args*) 
               slurp 
               (st/split #"\n")
               (->> (map #(vec (map (fn [y] (Integer/parseInt y)) (st/split % #",\s+")))))
               vec)
      
      x-range (apply max (map first data))
      y-range (apply max (map second data)) ]

  (print-matrix
    (make-distance-matrix x-range y-range data)
    x-range))
