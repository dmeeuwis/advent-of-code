(ns dmeeuwis.advent2018
  (:require [clojure.string :as str]))

(def cache (atom {}))

(defn read-in-board [filepath]
  (-> filepath
      slurp
      str/split-lines
      (->> (mapv vec))))

(defn buff-board [board]
  (let [header-footer [(vec (repeat (+ 2 (count (get board 0))) "_"))]]
    (vec (concat []
                 header-footer
                 (map (fn [row] (conj (into ["_"] row) "_")) board)
                 header-footer))))

(defn print-board [board]
  (doall
    (for [v board]
      (println (str/join v)))))

(defn quad [x y board]
  (for [c (range (- y 1) (+ y 2))
        r (range (- x 1) (+ x 2))]
    (do
      (get-in board [c r]))))

(defn drop-nth [coll n]
  (concat (take n coll) (nthrest coll (inc n))))

(defn count-inst [coll target]
  (count (filter #(= target %) coll)))

(defn transform [target adjoining]
  (case target
        \. (if (>= (count-inst adjoining \|) 3) \| \.)
        \| (if (>= (count-inst adjoining \#) 3) \# \|)
        \# (if (and (>= (count-inst adjoining \#) 1)
                    (>= (count-inst adjoining \|) 1)) \# \.)))

(defn score-point [x y board]
  (let [target (get-in board [y x])
        quadrant (quad x y board)
        adjoining (drop-nth quadrant 4)]
    (let [new-value (transform target adjoining)]
      ;(println "Transformed" x y target quadrant adjoining "   ->" new-value)
      new-value)))

(defn compute-grid-step [board]
  (mapv vec
    (partition
      (- (count (first board)) 2)
      (for [y (range 1 (dec (count board)))
                 x (range 1 (dec (count (first board))))]
           (score-point x y board)))))

(defn print-n-times [n limit board]
  (do 
    (println "\n\nStep" n "at" (str (format "%3f" (* 100 (double (/ n limit)))) "%"))
    (print-board board))

  (if (> n limit)
    board
    (if (@cache board)
      ; this block should only happen once in a simulation
      (let [repeat-period (- n (@cache board))
            times-left-to-go (- 1000000000 n)
            until-final-repeat (mod times-left-to-go repeat-period)]

        (println "At step" n "saw repeat board from step" (@cache board))
        (println "Period between repeats" repeat-period)
        (println "Times left to go" times-left-to-go)
        (println "Times left to go" times-left-to-go "mod 28 =>" until-final-repeat)
        (reset! cache {})
        (recur 1 (dec until-final-repeat) (compute-grid-step (buff-board board))))
      (do 
        (swap! cache #(assoc % board n))
        (recur (inc n) limit (compute-grid-step (buff-board board)))))))

(defn count-chars [board char]
  (count (filter #(= % char) (flatten board))))

(defn run-simulation [label steps]
  (let [raw-board (read-in-board (first *command-line-args*))
        processed-board (print-n-times 0 (dec steps) raw-board)
        woods (count-chars processed-board \|)
        lumberyards (count-chars processed-board \#)]
    (println label woods "woods x" lumberyards "lumberyards gives" (* woods lumberyards))))

(run-simulation "Part 1" 10)
(reset! cache {})
(run-simulation "Part 2" 1000000000)
