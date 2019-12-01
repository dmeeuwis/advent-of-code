(ns dmeeuwis.advent2018
  (:require [clojure.string :as st]))

(defn distance [p1 p2]
  (+ (java.lang.Math/abs (- (first p1)  (first p2)))
     (java.lang.Math/abs (- (second p1) (second p2)))))

(defn int-to-char [i]
  (str (char (+ 97 i))))

(defn make-distance-matrix [x-range y-range points distance-max]
  (println "Points:" points)
  (let [ indexed (into {}
                   (for [i (range 0 (count points))]
                     [(nth points i) i]))]
    (println "Indexed" indexed)
    (for [y (range 0 (inc y-range))
          x (range 0 (inc x-range))]

          (let [distances-for-this-point (map (fn [z] (distance [x y] z)) points)
                total-dist (reduce + distances-for-this-point)]
              
             (if (< total-dist distance-max)
               "#"
               "_")))))

(defn print-matrix [arr x-range]
  (doseq [i (range 0 (count arr))]
    (do
      (print (nth arr i))
      (if (zero? (mod (inc i) (inc x-range)))
        (println)))))

(defn count-letters [d]
  (loop [s d counts {}]
  (if (empty? s)
    counts

    (recur (rest s)
           (assoc counts (first s) (inc (or 
                                          (counts (first s))
                                           0)))))))


(let [data (-> (first *command-line-args*) 
               slurp 
               (st/split #"\n")
               (->> (map #(vec (map (fn [y] (Integer/parseInt y)) (st/split % #",\s+")))))
               vec)
      
      x-range (apply max (map first data))
      y-range (apply max (map second data)) 
      
      distance-matrix (make-distance-matrix 
                        x-range 
                        y-range 
                        data 
                        (Integer/parseInt (second *command-line-args*))) ]

; (print-matrix distance-matrix x-range)

  (let [counts (count-letters distance-matrix) ]
    (println "Counts are:" counts)
    (println "Relevant count is:" (counts "#"))))
