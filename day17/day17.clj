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
  (reduce #(concat %1
              (for [x (explode (second (re-matches #".*x=([0-9\.]+).*" %2)))
                    y (explode (second (re-matches #".*y=([0-9\.]+).*" %2)))]
                [x y]))
          [] lines))

(defn draw [clay water xmin xmax ymin ymax]
  (let [water-index (reduce #(assoc %1 (:pos %2) %2) {} water)]
    (println "Water-index:" water-index)
    (doall
      (for [y (range ymin (inc ymax))
            x (range xmin (inc xmax))]
        (let [p [x y]]
          (if (= xmin x) (println))
          (cond 
            (water-index p) (print (:char (water-index p)))
            (clay p) (print "#")
            (= [500 0] p) (print "+")
            :default (print ".")))))))


(defn write-board [clay water xmin xmax ymin ymax]
  (let [water-index (reduce #(assoc %1 (:pos %2) %2) {} water)]
    (println "Water-index:" water-index)
    (doall
      (for [y (range ymin (inc ymax))
            x (range xmin (inc xmax))]
        (let [p [x y]]
          (cond 
            (water-index p) (:char (water-index p))
            (clay p) "#"
            (= [500 0] p) "+"
            :default "."))))))

(defn find-bounds [points]
  (loop [p points, xmin Integer/MAX_VALUE, xmax Integer/MIN_VALUE, ymin Integer/MAX_VALUE, ymax Integer/MIN_VALUE]
    (if (empty? p)
      [xmin xmax ymin ymax]
      (recur (rest p)
             (min xmin (first (first p)))
             (max xmax (first (first p)))
             (min ymin (second (first p)))
             (max ymax (second (first p)))))))

(defn spill [drop grid]


(defn do-flow [drop grid]
  (let [down (fn [x] [ (first x) (inc (second x))])]
    (cond
      (= "." (grid (down (:pos drop))))
      [drop (assoc drop :pos (down (:pos drop)))]   ; dripped down, now 2

      (= "|" (grid (down (:pos drop))))
      [drop]                                        ; already dripped, just return self

      (= "#" (grid (down (:pos drop))))
      (let [sp (spill drop grid)]
        (if 

(defn flow [water map]
  (let [water-index (reduce #(assoc %1 (:pos %2) %2) {} water)]
    (loop [w water, coll '()]
      (if (empty? w)
        coll
        (recur (rest w)
               (concat coll
                       (do-flow (first w)
                                water-index
                                map)))))))

(let [input (-> (first *command-line-args*)
             slurp
             (string/split #"\n")
             read-input)
      bounds (find-bounds (conj input [500 0]))]

  (println "Input:" input)
  (println "Bounds" bounds)

  (loop [water #{ { :pos [500 1], :char "|" } }] 
    (let [new-water (flow water input)]
      (println "Water:" water)
      (apply draw (set input) new-water bounds))))
