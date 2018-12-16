(def init-board '(3 7))
(def init-elfs '( { :index 0 :value 3 } {:index 1 :value 7 }))

(defn combine-recipes [recipes]
  (let [s (apply + recipes)]
    (map #(Integer/parseInt (str %)) (seq (str s)))))

(defn move-elf [elf board]
  (let [index (mod (+ (elf :index) (elf :value) 1) (count board))]
    { :index index, :value (nth board index) }))

(defn step [board elfs]
  (let [new (concat board (combine-recipes (map :value elfs)))]
    { :board new, :elfs (doall (map #(move-elf % new) elfs)) }))

(defn run-for [input]
  (println "For" input "result is" 
    (loop [board init-board, elfs init-elfs, i 0 ]
      (if (<= (+ 10 input) (count board))
        (clojure.string/join (take-last 10 (take (+ 10 input) board)))
        (let [step-out (step board elfs)]
          (recur (:board step-out) (:elfs step-out) (inc i)))))))

(run-for 9)
(run-for 5)
(run-for 18)
(run-for 2018)
(run-for 190221)
