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
                 (conj chars { :id (java.util.UUID/randomUUID) 
                               :type ch :attack 3 :hp 200 :x i :y col })
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

; returns the grid position of the adjacent enemy to attack; or nil.
(defn find-adjacent-pos [grid p indexed]
  (let [adj-pos (filter #(= (enemy (:type p))
                               (nth (nth grid (+ (p :y) (second %)))
                                              (+ (p :x) (first %))))
                             [ [0 -1] [-1 0] [1 0] [0 1] ])]
    (if (empty? adj-pos)
      nil
      (do
        (println "adj-pos" adj-pos p)
        (let [positions (map (fn [z] [ (+ (:x p) (first z)) 
                                       (+ (:y p) (second z))])
                             adj-pos)
              _ (println "positions" positions)
              enemies (map indexed positions)
              _ (println "enemies" enemies)
              enemies-by-hp (sort-by :hp enemies)
              _ (println "enemies-by-hp" enemies-by-hp)
              victim (first enemies-by-hp)
              _ (println "victim is" victim)]
          [(:x victim) (:y victim)])))))

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

(defn find-distances[grid queue parents]
  (if (empty? queue)
    parents

    (let [curr (peek queue)
         adjacent (all-open-adjacent grid curr)
         new-adjacent (filter #(not (contains? parents %)) adjacent)]

         (recur grid 
                (apply conj (pop queue) new-adjacent)
                (reduce #(assoc %1 %2 curr) parents new-adjacent)))))

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

(defn map-sort [grid pos-a pos-b]
  (println "map-sort" pos-a pos-b)
  (let [score (fn [x] (+ (* (second x) (count (first grid)))
                         (first x)))]
    (compare [(score (last pos-a)) (score (second pos-a))] 
             [(score (last pos-b)) (score (second pos-b))] )))

(defn find-path-from-parents [parents target start]
  ; loop through parents to find the next step on the best path
  (loop [curr target, prev nil, path (list target)]
    (if (= start curr)
      path

      (if (nil? (parents curr))
        nil ; impossible to get to target

        (recur (parents curr) curr (conj path curr))))))

(defn find-route [grid start in-range]
  (let [parents (find-distances grid 
                        (conj clojure.lang.PersistentQueue/EMPTY start)
                        {})
        paths (remove nil? (map #(find-path-from-parents parents % start) in-range))
        in-range-distances (doall (map (fn [x] [x (count x)]) paths))
        sorted-dists (sort-by second in-range-distances)
        shortest (filter #(= (second %) (second (first sorted-dists))) sorted-dists)
        _ (if (> (count shortest) 1) (println "Multiple shortest! Selecting!" shortest))
        shortest-in-reading-order (sort #(map-sort grid %1 %2) (map #(-> % first) shortest))
        ]

    (first shortest-in-reading-order)))


(defn move-player [grid players in-range player-index]
  (let [player (nth players player-index)
        route (find-route grid [(:x player) (:y player)] in-range)
        first-step (first route)] 
    (if (nil? route)
      player
      (do
        (println "Moving!" first-step player)
        (assoc player
               :x (first first-step)
               :y (second first-step))))))

(defn try-attack [grid players i]
  (let [indexed (index-by-position players)]
    (if-let [adjacent-enemy-pos (find-adjacent-pos grid (nth players i) indexed)]
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
  (println "player-action" round i (nth players i))
  (if-let [updated (try-attack grid players i)]
    updated

    ; no enemy immediately present
    (let [enemies (filter #(= (:type %) (enemy ((nth players i) :type))) players)
          in-range (find-in-range grid enemies)]

      ; if none at all in range, we've won!
      (if (empty? enemies)
        (throw (ex-info "Game won!" { :type :game-over
                 :grid grid :round round :players players :winner (nth players i) }))

        ; move!
        (let [updated-player (move-player grid players in-range i)
              updated-all (sp/setval [(sp/nthpath i)] updated-player players)]

          ; after moving, allowed to try an attack
          (if-let [move-attack (try-attack grid updated-all i)]
            move-attack
            updated-all))))))

(defn find-index [pred coll]
  (loop [i 0, c coll]
    (cond 
      (empty? c) nil
      (pred (first c)) i
      :default (recur (inc i) (rest c)))))

(defn game-round [round players, grid]
  (println "Entering round" round)
  (draw-board (draw-players-on-board grid players))

  (let [sorted-players (sort-by (fn [p] [(:y p) (:x p)]) players)
        sorted-ids (map :id sorted-players)]
    (loop [p sorted-players, ordered-ids (map :id sorted-players)]
      (if (empty? ordered-ids)
        p

        (let [rounds-map (draw-players-on-board grid p)]
          (let [i (find-index #(= (:id %) (first ordered-ids)) p)]
            (if i
              (let [updated-players (player-action round rounds-map p i)]
                (recur 
                    updated-players
                    (rest ordered-ids)))
              (recur p (rest ordered-ids)))))))))

(let [[initial-map initial-players] (-> (first *command-line-args*)
                     (slurp)
                     (string/split #"\n")
                     (read-map))]
  (println "Saw" (count initial-players) "players")
  (println "Saw map size" (count (first initial-map)) "x" (count initial-map))

  (try 
    (loop [round 0, players initial-players]
        (let [round-result (game-round round players initial-map)]
          (recur (inc round) round-result)))
        
    (catch Exception e
      (case (:type (ex-data e))
        :game-over (let [result (ex-data e)
                         _ (println "Result is" result)
                         hp-remaining (apply + (map :hp (:players result)))]
                     (draw-board (:grid result))
                     (println "In" (:round result) "rounds, hp remaining" hp-remaining
                              "so outcome is" (* (:round result) hp-remaining)))
        (throw e)))))
