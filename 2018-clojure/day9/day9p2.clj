(ns dmeeuwis.advent2018 
  (:require [clojure.string :as string]))

(def regex #"(\d+) players; last marble is worth (\d+) points.*")

(defn read-game [line]
  (if-let [g (re-matches regex line)]
    { :players (Integer/parseInt (g 1)) :points (Integer/parseInt (g 2)) }
    (throw (RuntimeException. (str "Couldn't match line: " line)))))

(defn circle-find-index [col curr-index index]
  (mod (+ curr-index index) (count col)))

(defn print-circle-line [turn circle current-index]
  (print (str "[" turn "] "))
  (doseq [i (range 0 (.size circle))]
    (if (= i current-index)
      (print (str "(" (.get circle i) ")"))
      (print (str " " (.get circle i) " "))))
  (println))

(defn play-game [{ :keys [players points]}]
  (println "Playing with" players "players," points "points.")
  (let [circle (java.util.ArrayList.)]
    (.add circle 0)
    (loop [turn 1, current-marble 0, current-player 0, scores { }]
;    (print-circle-line (dec turn) circle current-marble)
      (cond
        (= (inc points) turn)
        scores
       
        (= 0 (mod turn 23))
        (let [new-index (circle-find-index circle current-marble -7)
              replacing-value (.get circle new-index) ]
          (.remove circle (int new-index))
          (recur
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
          (.add circle new-index turn)
          (recur
            (inc turn)
            new-index
            (mod (inc current-player) players)
            scores))))))

(let [game (-> (first *command-line-args*) slurp .trim read-game)
      scores (play-game game)]
  (println "Final scores:" scores)
  (println)
  (println "Top score:" (first (reverse (sort-by val scores)))))
