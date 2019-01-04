(ns dmeeuwis.advent2018
  (:require [com.rpl.specter :as sp]
            [clojure.string :as string]))

(defn explode [in]
  (if (.contains in ".")
    (let [parts (clojure.string/split in #"\.\.")]
      (range (Integer/parseInt (first parts))
             (inc (Integer/parseInt (second parts)))))
    (list (Integer/parseInt in))))

(defn read-input [lines]
  (loop [coll [], l lines]
    (println (first l) coll)
    (if (empty? l) 
      coll
      (recur 
        (concat coll
          (let [x-str (second (re-matches #".*x=([0-9\.]+).*" (first l)))
                y-str (second (re-matches #".*y=([0-9\.]+).*" (first l)))]
            (for [x (explode x-str)
                  y (explode y-str)]
              [x y])))
        (rest l)))))

(defn draw [clay xmin xmax ymin ymax]
  (doall 
    (for [y (range ymin (inc ymax))
          x (range xmin (inc xmax))]
      (let [p [x y]]
        (if (= xmin x) (println))
        (cond 
          (clay p) (print "#")
          (= [500 0] p) (print "+")
          :default (print "."))))))

(defn find-bounds [points]
  (loop [p points, xmin Integer/MAX_VALUE, xmax Integer/MIN_VALUE, ymin Integer/MAX_VALUE, ymax Integer/MIN_VALUE]
    (println (first p) xmin xmax ymin ymax)
    (if (empty? p)
      [xmin xmax ymin ymax]
      (recur (rest p)
             (min xmin (first (first p)))
             (max xmax (first (first p)))
             (min ymin (second (first p)))
             (max ymax (second (first p)))))))

(let [input (-> (first *command-line-args*)
             slurp
             (string/split #"\n")
             read-input)
      bounds (find-bounds (conj input [500 0]))]
  (println "Input:" input)
  (println "Bounds" bounds)
 
  (apply draw (set input) bounds))

