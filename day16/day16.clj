(defn addr [R a b c] (assoc R :c (+ (R a) (R b)))) 
(defn addi [R a b c] (assoc R :c (+ (R a) b))) 
(defn multr [R a b c] (assoc R :c (* (R a) (R b)))) 
(defn multi [R a b c] (assoc R :c (* (R a) b))) 
(defn banr [R a b c] (assoc R :c (bit-and (R a) (R b)))) 
(defn bani [R a b c] (assoc R :c (bit-and (R a) b))) 
(defn borr [R a b c] (assoc R :c (bit-or (R a) (R b)))) 
(defn bori [R a b c] (assoc R :c (bit-or (R a) b)))
(defn setr [R a b c] (assoc R :c (R a)))
(defn seti [R a b c] (assoc R :c (R a)))
(defn eqir [R a b c] (assoc R :c (if (= a (R b)) 0 1)))
(defn eqri [R a b c] (assoc R :c (if (= (R a) b) 0 1)))
(defn eqrr [R a b c] (assoc R :c (if (= (R a) (R b)) 0 1)))

(def functions [addr, addi, multr, multi, banr, bani, borr, bori, 
                setr, seti, eqir, eqri, eqrr])

(def match-opcode-line )
(def match-after-line )

(defn read-input [lines]
  (println "Saw" (count lines))
  (loop [coll [], l lines]
    (if (empty? l) 
      coll
      (let [before (re-matches #"Before:\s+\[(\d), (\d), (\d), (\d)\]$" (nth l 0))
            op-code (re-matches #"(\d) (\d) (\d) (\d)$" (nth l 1))
            after (re-matches #"After:\s+\[(\d), (\d), (\d), (\d)\]$" (nth l 2))]
        (recur (conj coll
                  { :before (vec (map #(Integer/parseInt %) (rest before)))
                    :op-code  (vec (map #(Integer/parseInt %) (rest op-code)))
                    :after (vec (map #(Integer/parseInt %) (rest after))) })
               (drop 3 l))))))

(println (-> (first *command-line-args*)
              slurp
              (clojure.string/split #"\n") 
              (->> (filter #(not (clojure.string/blank? %))))
              read-input))
