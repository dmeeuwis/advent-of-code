(ns dmeeuwis.advent2018 
  (:require [clojure.string :as string]))

(def regex #"(\d+) players; last marble is worth (\d+) points.*")

(defn read-game [line]
  (if-let [g (re-matches regex line)]
    { :players (Integer/parseInt (g 1)) :points (Integer/parseInt (g 2)) }
    (throw (RuntimeException. (str "Couldn't match line: " line)))))

(defn circle-find-index [col curr-index index]
  (mod (+ curr-index index) (count col)))

(defn vec-set [col index item]
  (let [[before after] (split-at index col)]
    (concat before [item] after)))

(defn vec-del [col index]
  (let [[before after] (split-at index col)]
    (concat before (rest after))))

(defn print-circle-line [turn circle curr-marble]
  (print (str "[" turn "] "))
  (loop [c circle, i 0]
    (cond 
      (empty? c)
      (println)

      (= curr-marble i)
      (do
        (print (str "(" (first c) ")"))
        (recur (rest c) (inc i)))

      :default
      (do
        (print " " (first c) " ")
        (recur (rest c) (inc i))))))

(defn play-game [{ :keys [players points]}]
  (println "Playing with" players "players," points "points.")

    (loop [circle [0], turn 1, current-marble 0, current-player 0, scores { }]
     ;(print-circle-line (dec turn) circle current-marble)
      (cond
        (= (inc points) turn)
        scores
       
        (= 0 (mod turn 23))
        (let [new-index (circle-find-index circle current-marble -7)
              replacing-value (nth circle new-index) ]
          (recur
            (vec-del circle new-index)
            (inc turn)
            new-index
            (mod (inc current-player) players)
            (assoc scores current-player
                   (+ (get scores current-player 0)
                      replacing-value
                      turn))))

        :default
        (let [new-index (cond (= 1 turn) 1
                              (= 2 turn) 1
                              :default
                          (circle-find-index circle current-marble 2))
              ]
          (recur
            (vec-set circle new-index turn)
            (inc turn)
            new-index
            (mod (inc current-player) players)
            scores)))))

(let [game (-> (first *command-line-args*) slurp .trim read-game)
      scores (play-game game)]
  (println "Final scores:" scores)
  (println)
  (println "Top score:" (first (reverse (sort-by val scores)))))
