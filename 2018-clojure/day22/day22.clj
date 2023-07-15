(ns dmeeuwis.advent2018
  (:require [clojure.string :as string]))

(def erosion-level) 
(def geo-index) 

(defn geo-index-imp [x y depth target]
  (let [sol 
    (cond
      (and (= x 0) (= y 0))
      0

      (and (= x (first target)) (= y (second target)))
      0

      (= y 0)
      (* 16807 x)

      (= x 0)
      (* 48271 y)

      :default
      (* (erosion-level (dec x) y depth target) (erosion-level x (dec y) depth target)))]
    (comment (println "geo-index" x y target "=>" sol))
    sol))

(defn erosion-level-imp [x y depth target]
  (mod (+ (geo-index x y depth target) depth) 20183))


(def erosion-level (memoize erosion-level-imp))
(def geo-index (memoize geo-index-imp))


(defn erosion-type [level]
  (let [val (mod level 3)]
    (cond 
      (= 0 val) :rocky
      (= 1 val) :wet
      (= 2 val) :narrow)))

(def erosian-risk { :rocky 0, :wet 1, :narrow 2 })

(defn calculate-risk [depth target]
  (reduce +
    (for [i (range (inc (first target)))]
      (reduce +
        (for [j (range (inc (second target)))]
          (let [r (erosian-risk (erosion-type (erosion-level i j depth target)))]
               r))))))

(def tools {
            :rocky [ :climbing :torch ]
            :wet   [ :climbing :neither ]
            :narrow [ :torch :neither ]
            })

(defn common [l1 l2]
  (doall
    (for [e l1]
      (if (.contains l2 e)
        e))))

(defn descend [x y minutes equip depth target seen]
  (if (= [x y] target)
    (do
      (println "Saw target" x y "currently equipped" equip minutes)
      (if (= equip :torch)
        minutes
        (+ 7 minutes))) ; to equip the torch

    (let [terrain (erosion-type (erosion-level x y depth target))
          nseen (conj seen [x y])
          dirs
            (doall (for [ [dx dy] [ [-1 0] [1 0] [0 1] [0 -1] ]]
              (if (and (>= (+ dx x) 0) (>= (+ dy y) y) 
                       (<= (+ dx x) (* 2 (first target)))
                       (<= (+ dy y) (* 2 (second target)))
                       (not (contains? nseen [(+ dx x) (+ dy y)])))
                (let [target-terrain (erosion-type (erosion-level (+ dx x) (+ dy y) depth target))]
                  (println "Descending to" (+ dx x) (+ dy y))
                  (descend (+ dx x) (+ dy y)
                           (if (.contains (tools target-terrain) equip)
                             (+ minutes 1)
                             (+ minutes 7 1))
                           ; we'll need to switch to whatever is common tool between where we are, and where we are going
                           (common (tools terrain) (tools target-terrain))
                           depth target nseen)))))
          ]

          (println "From " x y "saw" dirs)
          (min dirs))))

(let [lines (-> (first *command-line-args*) (slurp) (string/split #"\n"))
      depth (-> (first lines) (string/split #" ") second Integer/parseInt)
      target-str (-> (second lines) (string/split #" ") second (string/split #","))
      target [(Integer/parseInt (first target-str)) (Integer/parseInt (second target-str))]]

  (println "Processing depth " depth " and target " target)
  (doall (for [[x y] [ [0,0] [1,0] [0,1] [1,1] [10,10] ]]
    (do
      (let [geo (geo-index x y depth target)
            ero (erosion-level x y depth target)
            typ (erosion-type ero)]
        (println x y "geo" geo "erosian-level" ero "type" typ)))))

  (println "calculate-risk:" (calculate-risk depth target))
  (println "descend: " (descend 0 0 0 :torch depth target #{})))
