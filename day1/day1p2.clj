(ns dmeeuwis.advent2018
  (require [clojure.string :as str]))

(println "First repeated freq is"
  (let [numbers (-> (first *command-line-args*)
                  (slurp)
                  (str/split #"\n")
                  (->> (map #(Integer/parseInt %))))]

    (loop [n numbers seen #{ 0 } f 0]
      (let [new-freq (+ f (first n))
            new-seen (conj seen new-freq)]

        ;(println "Adding" (first n) "to" f "gives" new-freq "seen is" new-seen)

        (cond 
          (seen new-freq)
          new-freq

          (empty? (rest n))
          (recur numbers new-seen new-freq)

          :default
          (recur (rest n) new-seen new-freq))))))
