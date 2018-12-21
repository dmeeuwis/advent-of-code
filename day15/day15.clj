(ns dmeeuwis.advent2018
  (:require [clojure.string :as string]
            [com.rpl.specter :as sp]))

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


(defn draw-players-on-board [grid players]
  (println players)
  (loop [ng grid, p players]
    (if (empty? p)
      ng
      (recur 
        (sp/setval [(:y (first p)) (:x (first p))]
                   (:type (first p))
                   ng)
        (rest p)))))

(defn draw-board [grid]
  (doall
    (for [y (range 0 (count grid))
          x (range 0 (count (first grid)))]
      (do
        (if (= x 0)
          (println))
        (print (nth (nth grid y) x)))))
  (println))

; this assumes enemies are drawn on board
(def enemy {"G" "E", "E" "G"})
(defn find-adjacent [grid p]
  (if-let [adj-pos (first 
                      (filter #(= (enemy (:type p))
                                 (nth (nth grid (+ (p :y) (second %)))
                                              (+ (p :x) (first %))))
                             [ [0 -1] [-1 0] [1 0] [0 1] ]))]
    [ (+ (:x p) (first adj-pos)) 
      (+ (:y p) (second adj-pos))]))

(defn all-open-adjacent [grid p]
  (map #([(+ (:x p) (first %)) 
          (+ (:y p) (second %))])
    (filter #(= "."
               (nth (nth grid (+ (p :y) (second %)))
                            (+ (p :x) (first %))))
           [ [0 -1] [-1 0] [1 0] [0 1] ])))


(defn attack [attacker victim]
  (assoc victim :hp (- (:hp victim) (:attack attacker))))


(defn vector-rm [base rm] 
  (loop [b base coll []] 
    (if (empty? b)
      coll
      (recur (rest b)
             (if (some #(= (first b) %) rm) 
               coll
               (conj coll (first b)))))))


(defn find-in-range [grid targets]
  (sort 
    (let [target-locs (map #([ (:x %) (:y %)]) targets)]
      (vector-rm 
        (loop [in-range [], p targets]
          (if (empty? p)
            in-range
            (recur (concat in-range (all-open-adjacent grid (first p)))
                   (rest p))))
        target-locs))))

(defn move-to-closest [players in-range player-index]
  (assoc players player-index 
         (assoc (nth players player-index)
                :x (first (in-range :x))
                :y (first (in-range :y)))))

(defn vec-rm [coll pos]
  (vec (concat (subvec coll 0 pos) (subvec coll (inc pos)))))

(defn player-action [round grid players i]
  (let [indexed (index-by-position players)]
    ; enemy present: attack!
    (if-let [adjacent-enemy-pos (find-adjacent grid (nth players i))]
      (let [adjacent-enemy (indexed adjacent-enemy-pos)
            updated-enemy (attack (nth players i) adjacent-enemy)
            _ (println "Updated enemy to" updated-enemy)
            updated-index (.indexOf players adjacent-enemy)
            _ (println "Located enemy as" updated-index)]
        (if (<= (:hp updated-enemy) 0)
          (do
            (println "Enemy defeated!" updated-enemy updated-index players)
            (sp/setval updated-index sp/NONE players))
          (do
            (println "Enemy hit!" updated-enemy updated-index)
            (assoc (vec players) updated-index updated-enemy))))

      ; no enemy immediately present
      (let [enemies (filter #(= (:type %) (enemy ((nth players i) :type))) players)
            in-range (find-in-range grid enemies)]

        ; if none at all in range, we've won!
        (if (empty? in-range)
          (throw (ex-info "Game won!" { :type :game-over
                   :round round :players players :winner (nth players i) }))

          ; move!
          (let [updated-player (move-to-closest (nth players i) in-range)]
            (println "Player moved!" i updated-player)
            (assoc (vec players) i updated-player)))))))

(defn game-round [round players, grid]
  (let [sorted-players (sort-by (fn [p] [(:x p) (:y p)]) players)
        rounds-map (draw-players-on-board grid sorted-players)]

    (draw-board rounds-map)

    (loop [p sorted-players, i 0]
      (if (>= i (count p))
        p
        (recur 
          (player-action round rounds-map p i)
          (inc i))))))

(let [[initial-map initial-players] (-> (first *command-line-args*)
                     (slurp)
                     (string/split #"\n")
                     (read-map))]
  (println "Saw" (count initial-players) "players")
  (println "Saw map size" (count (first initial-map)) "x" (count initial-map))
  (draw-board initial-map)
  
  (try 
    (loop [round 0, players initial-players]
      (println "Round" round)
        (let [round-result (game-round round players initial-map)]
          (recur (inc round) round-result)))
        
    (catch Exception e
      (case (:type (ex-data e))
        :game-over (println "Game won" (ex-data e))
        (throw e)))))
