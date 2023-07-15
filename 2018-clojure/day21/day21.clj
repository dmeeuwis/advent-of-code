(ns dmeeuwis.advent2018 
  [:require [clojure.string :as str]])

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
      (let [instruction (re-matches #"(\w+) (\d+) (\d+) (\d+)$" (first l))
            instruction-parsed (if instruction [(nth instruction 1) (Integer/parseInt (nth instruction 2))
                                                                    (Integer/parseInt (nth instruction 3))
                                                                    (Integer/parseInt (nth instruction 4))]
                                               nil)
            ip-change   (re-matches #"(#ip) (\d)" (first l))
            ip-change-parsed (if ip-change [(nth ip-change 1) (Integer/parseInt (nth ip-change 2))])]

        (recur (conj coll
                  (vec (or instruction-parsed ip-change-parsed)))
               (rest l))))))

(defn exec [R ip op]
  (let [command (first op)
        _ (if (= ip 28) (print (str "ip=" ip " " (pr-str R) " " (str/join " " op) " ")))
       result (apply (resolve (symbol command)) R (rest op))]
    (if (= ip 28) (println (pr-str result)))
    result))

(defn run-program 
  ([program]
    (run-program [0 0 0 0 0 0], 0, nil, program))

   ([R ip ip-binding program]
      (cond
        (>= ip (count program))
        R

        (= "#ip" (first (nth program ip)))
        ; special command to bind ip register
        (do (println "Binding ip to" (second (nth program ip)))
            (run-program R ip 
                   (second (nth program ip))
                   (rest program)))

        ; normal command
        :default
        (let [R2 (if ip-binding (assoc R ip-binding ip) R)
              result (exec R2 ip (nth program ip))]
           (let [ip-new (if ip-binding (get result ip-binding)  ip)]
             (recur result (inc ip-new) ip-binding 
                    program))))))

(let [program (-> (first *command-line-args*)
              slurp
              (clojure.string/split #"\n") 
              read-input)]
  (println "Program read as" (pr-str program))
  (println "Final state:" (run-program program)))
