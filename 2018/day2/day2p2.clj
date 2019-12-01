(ns dmeeuwis.advent2018
  (:require [clojure.string :as str]))

(defn find-n-char-boxes [n all-counts]
  (filter (fn [counts]
            (some (fn [v] (= n v)) (vals counts)))
          all-counts))

(defn count-chars [in]
  (loop [s (.toLowerCase in) counts {}]
    (if (= 0 (count s))
      (with-meta counts { :source in })
      (recur (rest s) (update counts 
                              (first s)
                              #(if % (inc %) 1)) ))))

(defn count-chars-different [s1 s2]
  (if (not= (count s1) (count s2))
    (throw (RuntimeException. (str "Unexpected length difference:" s1 s2))))

  (loop [diffs 0 a s1 b s2]
    (cond 
      (empty? a)
      diffs

      (= (first a) (first b))
      (recur diffs (rest a) (rest b))

      :default
      (recur (inc diffs) (rest a) (rest b)))))

(defn count-diffs [strings]
  (for [x strings
        y strings]
    { :first x :second y :diffs (count-chars-different x y) }))


(let [strings (-> (first *command-line-args*)
               (slurp)
               (str/split #"\n"))
      counts (map count-chars strings)

      two-counts (find-n-char-boxes 2 counts)
      three-counts (find-n-char-boxes 3 counts)

      two-count-strings (map #(:source (meta %)) two-counts)
      three-count-strings (map #(:source (meta %)) three-counts)
      
      valid (set (concat two-count-strings three-count-strings))]

  (println "Off-by-1 diffs:" (filter #(= 1 (:diffs %)) (count-diffs valid))))
  
