(use 'com.rpl.specter)

(defn addr [R a b c] (assoc R c (+ (R a) (R b)))) 
(defn addi [R a b c] (assoc R c (+ (R a) b))) 
(defn mulr [R a b c] (assoc R c (* (R a) (R b)))) 
(defn muli [R a b c] (assoc R c (* (R a) b))) 
(defn banr [R a b c] (assoc R c (bit-and (R a) (R b)))) 
(defn bani [R a b c] (assoc R c (bit-and (R a) b))) 
(defn borr [R a b c] (assoc R c (bit-or (R a) (R b)))) 
(defn bori [R a b c] (assoc R c (bit-or (R a) b)))
(defn setr [R a b c] (assoc R c (R a)))
(defn seti [R a b c] (assoc R c a))
(defn eqir [R a b c] (assoc R c (if (= a (R b)) 1 0)))
(defn eqri [R a b c] (assoc R c (if (= (R a) b) 1 0)))
(defn eqrr [R a b c] (assoc R c (if (= (R a) (R b)) 1 0)))
(defn gtir [R a b c] (assoc R c (if (> a (R b)) 1 0)))
(defn gtri [R a b c] (assoc R c (if (> (R a) b) 1 0)))
(defn gtrr [R a b c] (assoc R c (if (> (R a) (R b)) 1 0)))

(def functions [addr, addi, mulr, muli, banr, bani, borr, bori, 
                setr, seti, eqir, eqri, eqrr, gtir, gtri, gtrr])

(defn fn-name [obj]
  (.substring (str obj) 5 9))

(defn read-input [lines]
  (loop [coll [], l lines]
    (if (empty? l) 
      coll
      (let [before (re-matches #"Before:\s+\[(\d+), (\d+), (\d+), (\d+)\]$" (nth l 0))
            op-code (re-matches #"(\d+) (\d+) (\d+) (\d+)$" (nth l 1))
            after (re-matches #"After:\s+\[(\d+), (\d+), (\d+), (\d+)\]$" (nth l 2))]
        (recur (conj coll
                  { :before (vec (map #(Integer/parseInt %) (rest before)))
                    :op-code  (vec (map #(Integer/parseInt %) (rest op-code)))
                    :after (vec (map #(Integer/parseInt %) (rest after))) })
               (drop 3 l))))))

(defn test-sample [s]
  (println "Testing" s)
  (let [run (fn [x] (apply x (:before s) (rest (:op-code s))))]
    (filter #(= (:after s) (run %)) functions)))

(defn possible-codes-per-name [samples]
  (loop [s samples, op-possibilities {}]
    (if (empty? s)
      op-possibilities
      (let [op (-> (first s) :op-code first)]
        (recur (rest s)
               (reduce (fn [coll n] (assoc coll op
                                           (conj (or (coll op) #{})
                                                 (fn-name n))))
                     op-possibilities
                     (test-sample (first s))))))))

(defn strip-from-sets [codes-per rm]
  (transform [ALL 1] #(disj % rm) codes-per))

(defn exec [code-book R op]
  (let [command (code-book (first op))]
    (println "Exec" command op "against" R)
    (apply (resolve (symbol command)) R (rest op))))

(let [samples (-> (first *command-line-args*)
              slurp
              (clojure.string/split #"\n") 
              (->> (filter #(not (clojure.string/blank? %))))
              read-input)]

  (let [counts
          (loop [s samples, i 0, counts []]
            (let [result (test-sample (first s))]
              (if (empty? s)
                counts
                (recur (rest s)
                       (inc i)
                       (assoc counts i (count result))))))]
    (println "Counts >=3: " (count (filter #(>= % 3) counts)))

    (let [codes-per-function (possible-codes-per-name samples)]
      (println "Functions per code:" (sort codes-per-function))

      (let [code-book
            (loop [codes-per (sort-by #(count (second %)) (seq codes-per-function))
                   known {}]
              (if (= 1 (count (second (first codes-per))))
                (let [op-code (first (first codes-per))
                      op-name (first (second (first codes-per)))]
                  (recur (-> codes-per
                             rest
                             (strip-from-sets op-name)
                             (->> (sort-by #(count (second %)))))
                         (assoc known op-code op-name)))
                known))]

         (println "Code-book:" code-book)
         (let [program (-> (second *command-line-args*)
                           slurp
                           (clojure.string/split #"\n")
                           (->> (map #(clojure.string/split % #" "))
                                (transform [ALL ALL] #(Integer/parseInt %))))]
               (println "Program is" program)
               (println "Final state:"
                 (loop [R [0 0 0 0], p program]
                   (if (empty? p)
                     R
                     (recur (exec code-book R (first p))
                            (rest p))))))))))
