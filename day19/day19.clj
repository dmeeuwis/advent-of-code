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

(defn read-input [lines]
  (loop [coll [], l lines]
    (if (empty? l) 
      coll
      (let [instruction (re-matches #"(\s+) (\d+) (\d+) (\d+)$" (nth l 1))
            ip-change   (re-matches #"#ip (\d)")]
        (recur (conj coll
                  (or instruction ip-change))
               (rest l))))))

(defn exec [R ip ip-binding op]
  (let [command (first op)
       result (apply (resolve (symbol command)) R (rest op))]
    (println (str "ip=" ip " [" (str/join ", " R) "] " (str/join op " ") " [" (str/join result) "]"))
    result))

(defn run-program [program]
  (loop [R [0 0 0 0 0 0], ip 0, p program]
    (cond
      (empty? p)
      R

      (= "#ip" (first p))
      ; special command to bind ip register
      (recur R ip 
                (second (first p))
                (rest p)))

         ; normal command
      (let [R2 (if ip-bound (copy-ip-in R ip-bound) R)
            result (exec R ip (first p))]
         (let [ip-new (if ip-bound (copy-ip-out R ip-bound) ip-bound)]
           (recur R2 ip-new ip-bound 
                  (rest p))))))

(let [program (-> (first *command-line-args*)
              slurp
              (clojure.string/split #"\n") 
              read-input)]
  (println "Program read as" program)
  (println "Final state:" (run-program program)))
