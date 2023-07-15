(ns dmeeuwis.advent2018
  (:require [loom.alg :as alg]
             [loom.graph :as graph]))

(def input (-> *command-line-args*
               first
               slurp
               .trim
               (.replace "^" "")
               (.replace "$" "")
               seq))

(def directions {\N [0 1]
                 \E [1 0]
                 \S [0 -1]
                 \W [-1 0]})

(defn build-graph[input]
  (loop [i input, pos [0 0], branch-points '(), adjacency-list {}]
    (if
      (empty? i)
      adjacency-list

      (let [next (first i)]
        (cond
          (= \( next)
          (recur (rest i) pos (conj branch-points pos) adjacency-list)
          
          (= \| next)
          (recur (rest i) (peek branch-points) branch-points adjacency-list)

          (= \) next)
          (recur (rest i) pos (pop branch-points) adjacency-list)

          :default
          (let [move (directions (first i))
                new-pos [ (+ (first pos) (first move))
                          (+ (second pos) (second move))]]
            (recur (rest i) new-pos branch-points
                   (assoc adjacency-list pos (conj (or (adjacency-list pos) []) new-pos)))))))))

(let [adj-list (build-graph input)
      g (graph/weighted-graph adj-list)
      longest-shortest-path (alg/longest-shortest-path g [0 0])
      all-points (set (apply concat (vals adj-list)))

      all-paths (doall (map #(alg/shortest-path g [0 0] %) all-points))
      all-distances (map count all-paths)
      long-distances (filter #(>= % 1001) all-distances)]
  (println "Part 1: Longest-shortest path door count is" (dec (count longest-shortest-path)))
  (println "Part 2: All long paths count " (count long-distances)))
