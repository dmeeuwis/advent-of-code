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

(defn all-open-adjacent 
  ([grid p]
   (if (contains? p :x)
     (all-open-adjacent grid (:x p) (:y p))
     (all-open-adjacent grid (first p) (second p))))

  ([grid x y]
    (doall (map (fn [p] [(+ x  (first p)) 
                  (+ y (second p))])
      (filter #(= "."
                 (nth (nth grid (+ y (second %)))
                              (+ x (first %))))
             [ [0 -1] [-1 0] [1 0] [0 1] ])))))


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
    (let [target-locs (map (fn [t] [ (:x t) (:y t)]) targets)]
      (vector-rm 
        (loop [in-range [], p targets]
          (if (empty? p)
            in-range
            (recur (concat in-range (all-open-adjacent grid (first p)))
                   (rest p))))
        target-locs))))

(defn find-route 
  ([grid start end]
   ;(println "find-route starting from" start end)
   (find-route grid start end [] #{}))

  ([grid current end path visited]
    (cond
      (= current end) ; this was a successful branch!
      (conj path current)

      (visited current) ; looped onto a point we already visisted, end this branch
      nil

      :default
      (sp/setval [sp/ALL nil?] sp/NONE
        (doall (map 
          #(find-route grid % end
                        (conj path current)
                        (conj visited current))
          (all-open-adjacent grid current)))))))

(defn map-sort [grid pos-a pos-b]
  (let [score (fn [x] (+ (* (second x) (count (first grid)))
                         (first x)))]
    (compare (score pos-a) (score pos-b))))

(defn move-to-closest [grid players in-range player-index]
  (let [player (nth players player-index)
        route-fn (partial find-route grid [(:x player) (:y player)])
        nested-all (map route-fn in-range)
        all-paths (sp/select (sp/walker vector?) nested-all)] 

    (if (empty? all-paths)
      ; if no viable move, do nothing
      (nth players player-index)

      ; otherwise do shorted, in reading order
      (let [sorted (sort-by count all-paths)
            length (count (first sorted))
            all-of-that-length (filter #(= (count %) length) all-paths) 
            first-steps (sort #(map-sort grid %1 %2) (map second all-of-that-length))]
        (let [first-step (first first-steps)]
          (assoc (nth players player-index)
                 :x (first first-step)
                 :y (second first-step)))))))

(defn vec-rm [coll pos]
  (vec (concat (subvec coll 0 pos) (subvec coll (inc pos)))))

(defn try-attack [grid players i]
  (if-let [adjacent-enemy-pos (find-adjacent grid (nth players i))]
    (let [indexed (index-by-position players)]
      (let [adjacent-enemy (indexed adjacent-enemy-pos)
            updated-enemy (attack (nth players i) adjacent-enemy)
            updated-index (.indexOf players adjacent-enemy)]
        (if (<= (:hp updated-enemy) 0)
          (do
            (println "Enemy defeated!" updated-enemy updated-index players)
            (sp/setval [(sp/nthpath updated-index)] sp/NONE players))
          (do
            (println "Enemy hit!" updated-enemy updated-index)
            (sp/setval [(sp/nthpath updated-index)] updated-enemy players)))))))

(defn player-action [round grid players i]
  (if-let [updated (try-attack grid players i)]
    updated

    ; no enemy immediately present
    (let [enemies (filter #(= (:type %) (enemy ((nth players i) :type))) players)
          in-range (find-in-range grid enemies)]

      ; if none at all in range, we've won!
      (if (empty? in-range)
        (throw (ex-info "Game won!" { :type :game-over
                 :round round :players players :winner (nth players i) }))

        ; move!
        (let [updated-player (move-to-closest grid players in-range i)
              updated-all (sp/setval [(sp/nthpath i)] updated-player players)]

          ; after moving, allowed to try an attack
          (if-let [move-attack (try-attack grid updated-all i)]
            move-attack
            updated-all))))))

(defn game-round [round players, grid]
  (println "After" round "rounds")
  (draw-board (draw-players-on-board grid players))

  (let [sorted-players (sort-by (fn [p] [(:x p) (:y p)]) players)]
    (loop [p sorted-players, i 0]
      (let [rounds-map (draw-players-on-board grid p)]
        (if (>= i (count p))
          p
          (recur 
            (player-action round rounds-map p i)
            (inc i)))))))

(let [[initial-map initial-players] (-> (first *command-line-args*)
                     (slurp)
                     (string/split #"\n")
                     (read-map))]
  (println "Saw" (count initial-players) "players")
  (println "Saw map size" (count (first initial-map)) "x" (count initial-map))

  (try 
    (loop [round 0, players initial-players]
      (println "Round" round)
        (let [round-result (game-round round players initial-map)]
          (recur (inc round) round-result)))
        
    (catch Exception e
      (case (:type (ex-data e))
        :game-over (let [result (ex-data e)
                         _ (println "Result is" result)
                         hp-remaining (apply + (map :hp (:players result)))]
                     (println "In" (dec (:round result)) "rounds, hp remaining" hp-remaining
                              "so outcome is" (* (dec (:round result)) hp-remaining)))
        (throw e)))))
