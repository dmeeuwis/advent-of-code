(def input 190221)
(def start '(3 7))

(defn combine-recipes [recipes]
  (let [s (apply + recipes)]
    (seq (str s))))

(defn move-elf [elf board]
  (let [moved
    (let [index (mod (+ (elf :index) (elf :value) 1) (count board))]
      { :index index
        :value (nth board index) })]

    (println "Moved from" elf "to" moved)
    moved))

(defn step [board elves]
  (let [new (concat board (combine-recipes (map :value elves)))]
    { :board new
      :elves (doall (map #(move-elf % new) elves)) }))

(println 
  (->> '( { :index 0 :value 3 } {:index 1 :value 7 })
    #(step start)
    #(step start)))
