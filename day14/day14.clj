(def init-board '(3 7))
(def init-elfs '( { :index 0 :value 3 } {:index 1 :value 7 }))

(defn combine-recipes [recipes]
  (let [s (apply + recipes)]
    (map #(Integer/parseInt (str %)) (seq (str s)))))

(defn move-elf [elf board]
  (let [index (mod (+ (elf :index) (elf :value) 1) (.size board))]
    { :index index, :value (nth board index) }))

(defn step [board elfs]
  (.addAll board (combine-recipes (map :value elfs)))
  { :board board, :elfs (doall (map #(move-elf % board) elfs)) })

(defn run-for [input]
  (println "For" input "result is" 
    (loop [board (java.util.ArrayList. init-board), elfs init-elfs]
      (if (<= (+ 10 input) (.size board))
        (clojure.string/join (take-last 10 (take (+ 10 input) board)))
        (let [step-out (step board elfs)]
          (recur (:board step-out) (:elfs step-out)))))))

(println "Step 1")
(run-for 9)
(run-for 5)
(run-for 18)
(run-for 2018)
(run-for 190221)

(defn part-two [input]
  (println "For" input "result is" 
    (loop [board (java.util.ArrayList. init-board), elfs init-elfs]
      (let [end-of-board (.subList board 
                                   (max 0 (- (.size board) (+ 10 (.length input))))
                                   (.size board))
            string (clojure.string/join end-of-board)
            search (and (not= -1 (.indexOf string input))
                        (.indexOf (clojure.string/join board) input))]
        (if (and search (not= -1 search))
          search
          (let [step-out (step board elfs)]
            (recur (:board step-out) (:elfs step-out))))))))


(println "Step 2")
(part-two "51589")
(part-two "01245")
(part-two "92510")
(part-two "59414")
(part-two "190221")
