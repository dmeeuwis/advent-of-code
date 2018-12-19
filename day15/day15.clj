(ns dmeeuwis.advent2018
  (:require [clojure.string :as string]))

(defn read-map-line [map-line col]
  (loop [s (string/split map-line #""), line [], chars [], i 0]
    (if (empty? s)
      [line chars]
      (let [ch (first s)]
        (recur (rest s) 
               (conj line (if (or (= "G" ch) (= "E" ch)) "." ch))
               (if
                 (or (= "G" ch) (= "E" ch))
                 (conj chars { :type ch :attack 3 :hp 200 :x i :y col })
                 chars)
               (inc i))))))

(defn read-map [lines]
  (loop [l lines, map [], chars [], i 0]
    (if
      (empty? l)
        [map chars]
        (let [[map-line line-chars] (read-map-line (first l) i)]
          (recur (rest l)
                 (conj map map-line)
                 (concat chars line-chars)
                 (inc i))))))

(defn index-by-position [players]
  (loop [index {}, [p & pr] players]
    (if (empty? p)
      index
      (recur (assoc index [(:x p) (:y p)] p)
             pr))))

(defn draw-board [grid players]
  (println "Drawing grid" (pr-str grid))
  (let [index (index-by-position players)]
    (doall
      (for [y (range 0 (count (first grid)))
            x (range 0 (count (first grid)))]
        (do
          (if (= x 0)
            (println))
          (if (index [x y])
            (print (:type (index [x y])))
            (print (nth (nth grid y) x))))))))

(let [[map players] (-> (first *command-line-args*)
                     (slurp)
                     (string/split #"\n")
                     (read-map))]
  (println "Saw" (count players) "players")
  (println "Saw" (nth map 5))
  (println "Saw map size" (count (first map)) "x" (count map))
  (draw-board map players))
