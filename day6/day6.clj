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
    (for [y (range 0 (inc y-range))
          x (range 0 (inc x-range))]

          (let [distances-for-this-point (map (fn [z] [z (distance [x y] z)]) points)]
            (if (>= (.indexOf points [x y]) 0)
              (int-to-char (indexed [x y]))
              (find-shortest-distance-or-tie indexed distances-for-this-point))))))

(defn print-matrix [arr x-range]
  (doseq [i (range 0 (count arr))]
    (do
      (print (nth arr i))
      (if (zero? (mod (inc i) (inc x-range)))
        (println)))))

(defn find-edges [points x-range y-range]
  (let [positions (for [y (range 0 (inc y-range)), x (range 0 (inc x-range))] [x y])]
    (loop [p positions, edges #{}]
      (if (empty? p)
        edges

        (let [f (first p)]
          (recur (rest p)
                 (if (or 
                       (= 0 (first f))
                       (= 0 (second f))
                       (= x-range (first f))
                       (= y-range (second f)))
                   (do
                     (let [i (+ (* (second f) (inc x-range)) (first f))]
                       (conj edges (nth points i))))

                   edges)))))))

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
      
      distance-matrix (make-distance-matrix x-range y-range data) ]

; (print-matrix distance-matrix x-range)

  (let [edges (find-edges distance-matrix x-range y-range)
        counts (count-letters distance-matrix)
        live-counts (apply dissoc counts edges) 
        best (first (reverse (sort-by val live-counts)))
       ]
;   (println "Edges are:" edges)
;   (println "Counts are:" counts)
;   (println "Live Counts are:" live-counts)
    (println "Best is:" best "->" (inc (second best)))))
        
