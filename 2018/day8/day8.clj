(ns dmeeuwis.advent2018 
  (:require [clojure.string :as string]))

(defn read-node-chain [data]
  (let [child-node-count (first data)
        meta-data-count (second data)
        counter (atom 2)
        children (for [i (range 0 child-node-count)]
                   (let [child (read-node-chain (drop @counter data))]
                     (reset! counter  (+ (child :size) @counter))
                     child))
        child-node-size (apply + (map :size children))]

    { :size (+ 2 meta-data-count child-node-size)
      :metadata (take meta-data-count (drop (+ 2 child-node-size) data))
      :children children }))

(defn read-metadata [node]
  (concat (:metadata node)
          (for [c (:children node)]
            (read-metadata c))))

(defn nth-or-zero [col n]
  (if (or (>= n (count col))
          (< n 0))
    0
    (nth col n)))

(defn read-value [node]
  (if (empty? (:children node))
    (apply + (:metadata node))
    (map #(read-value (nth-or-zero (:children node) %))
         (map dec (:metadata node)))))

(let [node-chain (-> (first *command-line-args*)
               (slurp)
               (string/split #"\s+")
               (->> (map #(Integer/parseInt %)))
               read-node-chain)]

  (println "Sum is" (apply + (flatten (read-metadata node-chain)))) 
  (println "Value is" (apply + (flatten (read-value node-chain)))))
