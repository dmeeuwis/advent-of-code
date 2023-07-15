(ns dmeeuwis.advent2018
  (:require [com.rpl.specter :as sp]
            [clojure.string :as string]))

(def x first)
(def y second)

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

(defn draw [clay xmin xmax ymin ymax]
  (let [one-dimensional
          (for [y (range ymin (inc ymax))
                x (range (- xmin 10) (inc xmax))]
            (let [p [x y]]
              (cond 
                (clay p) "#"
                (= [500 0] p) "+"
                :default ".")))]
    (mapv vec (partition (- (inc xmax) (- xmin 10)) one-dimensional))))

(defn find-bounds [points]
  (loop [p points, xmin Integer/MAX_VALUE, xmax Integer/MIN_VALUE, ymin Integer/MAX_VALUE, ymax Integer/MIN_VALUE]
    (if (empty? p)
      [xmin xmax ymin ymax]
      (recur (rest p)
             (min xmin (first (first p)))
             (max xmax (first (first p)))
             (min ymin (second (first p)))
             (max ymax (second (first p)))))))

(defn grid-get [grid pos]
  (nth (nth grid (y pos)) (x pos)))

(defn grid-set [grid pos set-val]
  (println "grid-set" pos set-val)
  (assoc grid (y pos)
       (assoc (nth grid (y pos))
              (x pos)
              set-val)))

(defn grid-replace-range [grid row start-x end-x set-val]
  (println "grid-replace-range" row start-x end-x set-val)
  (assoc grid row
       (apply assoc (get grid row)
              (interleave
                (range start-x (inc end-x))
                (repeat (- (inc end-x) start-x) set-val)))))

(defn up [p] [(x p) (dec (y p))])
(defn down [p] [(x p) (inc (y p))])
(defn left [p] [(dec (x p)) (y p)])
(defn right [p] [(inc (x p)) (y p)])

(defn find-drop [pos grid inc-fn]
  (let [next-pos [(inc-fn (x pos)) (y pos)]
        next-char (grid-get grid next-pos)]
    (cond 
      (some #(= next-char %) ["#"])
      { :type :stop :pos pos }

      (some #(= (grid-get grid (down next-pos)) %) ["." "|"])
      { :type :flow :pos next-pos }

      :default
      (recur next-pos grid inc-fn))))

; returns { :grid modified-grid :flow-points [...any downflow points] }
(defn spill [drop grid]
  (let [left-drop (find-drop drop grid dec)
        right-drop (find-drop drop grid inc)
        _ (println "Found left-drop" left-drop "right-drop" right-drop)
        _ (println "Drop chars:" (grid-get grid (:pos left-drop)) (grid-get grid (:pos right-drop)))
        flow-points (map :pos (filter #(= :flow (:type %)) [left-drop right-drop]))
        _ (println "Flow-points found as:" flow-points)
        row (get grid (x drop))]
    (if (or (= :flow (:type left-drop))
            (= :flow (:type right-drop)))
      { :grid (grid-replace-range grid (y drop) (x (:pos left-drop)) (x (:pos right-drop)) "|")
        :flow-points flow-points }
      { :grid (grid-replace-range grid (y drop) (x (:pos left-drop)) (x (:pos right-drop)) "~")
        :flow-points flow-points })))

(defn print-grid [grid]
  (doall (for [row grid] (println (string/join row)))))

(def flow-count 0)

(defn do-flow [water-positions grid bounds seen upflow]
  (println "\n\n")
  (println "======================================================================")
  (println "do-flow" flow-count water-positions upflow)

  (def flow-count (+ flow-count 1))
  (if (or (= 10700 flow-count) (= 6678 flow-count) (= 1694 flow-count))
    (print-grid grid))

  (if (empty? water-positions)
    (do
      (println "Ran out of water! Returning grid.")
      (print-grid grid)
      ; need to subtract 5 due to the first clay platform not starting until y=5, so discount first 5 | lines from source
      (println "Saw water count as" (- (count (filter #(or (= "|" %) (= "~" %)) (flatten grid))) 5))
      (println "Saw remaining count as" (count (filter #(= "~" %) (flatten grid))))
      grid)

    (let [water (first water-positions)
          down-pos (down water)
          down-char (grid-get grid [(x down-pos) (min (last bounds) (y down-pos))])
          new-seen (conj seen water)]

      (println "water is" water)
      (println "water-char is" (grid-get grid water))
      (println "down-pos is" down-pos)
      (println "down-char is" down-char)
      (println "last y is" (last bounds))
      (println "range check is" (>= (y down-pos) (last bounds)))

      (cond 

        ; if the water fall past the map, it is finished.
        (or
          (>= (y down-pos) (inc (last bounds)))
          (and (seen water) (not upflow)))
        (do
          (println "Will pass end of grid!" (y down-pos) "past last" (last bounds))
          (do-flow (rest water-positions) grid bounds new-seen false))

        (= down-char ".") 
        (do-flow (conj (rest water-positions) down-pos)
               (grid-set grid down-pos "|")
               bounds
               new-seen
               false)

        ; if hitting an existing stream, then just merge into it
        (= down-char "|")
        (do-flow (conj (rest water-positions) down-pos)
                 grid 
                 bounds
                 new-seen
                 false)

        ; if hitting clay, then spill out sideways
        (or (= down-char "#")
            (= down-char "~"))
        (let [spill-result (spill water grid)]
            (println "Saw spill result!" (spill-result :flow-points))
            ;(print-grid (spill-result :grid))
                     
            ; if no where to spill out to, then need to upflow
            (if (empty? (spill-result :flow-points))
              ; ! add min-y check here
              (do 
                (println "No flow-points found, upflowing to" (up water))
                (do-flow (conj (rest water-positions) (up water)) 
                         (spill-result :grid) 
                         bounds
                         new-seen
                         true))

              ; otherwise char was | and we can do-flow on one or two flow down points
              (do 
                (println "Flow-pounts found" (spill-result :flow-points))
                (do-flow (concat (rest water-positions) 
                                 (spill-result :flow-points)) 
                         (spill-result :grid) 
                         bounds
                         new-seen
                         false)))
        
        :default 
        grid)))))
                
(defn main[]
  (let [input (-> (first *command-line-args*)
               slurp
               (string/split #"\n")
               read-input)
        bounds (find-bounds (conj input [500 0]))
        grid (apply draw (set input) bounds)
        source-x (.indexOf (first grid) "+") ]

    (do-flow [[source-x 0]] grid bounds #{} false)))

(main)
