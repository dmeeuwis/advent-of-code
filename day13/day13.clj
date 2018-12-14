(ns dmeeuwis.advent2018 
  (:require [clojure.string :as string]))

(def carts #{ ">" "<" "^" "v" })
(def cart-pos-replacements { ">" "-", "<" "-", "^" "|", "v" "|" })

(def intersection-moves { :left :straight, :straight :right, :right :left })

(defn loc 
  ([grid x y]
    (nth (nth grid y) x))
  ([grid cart]
    (loc grid (:x cart) (:y cart))))

(defn go-through [dir instr]
  (case [dir instr]
       [">" :straight] ">"
       ["^" :straight] "^"
       ["<" :straight] "<"
       ["v" :straight] "v"

       [">" :left] "^"
       ["^" :left] "<"
       ["<" :left] "v"
       ["v" :left] ">"

       [">" :right] "v"
       ["^" :right] ">"
       ["<" :right] "^"
       ["v" :right] "<"))

(defn calc-dir [grid memory old-dir new-x new-y]
  (let [grid-el (loc grid new-x new-y)]
    (cond
      (and (or (= ">" old-dir) (= "<" old-dir)) 
           (= "-" grid-el))
      old-dir

      (and (= ">" old-dir) (= "/" grid-el))
      "^"

      (and (= ">" old-dir) (= "\\" grid-el))
      "v"

      (and (= "<" old-dir) (= "\\" grid-el))
      "^"

      (and (= "<" old-dir) (= "/" grid-el))
      "v"

      (and (or (= "^" old-dir) (= "v" old-dir)) (= "|" grid-el))
      old-dir

      (and (= "^" old-dir) (= "/" grid-el))
      ">"

      (and (= "^" old-dir) (= "\\" grid-el))
      "<"

      (and (= "v" old-dir) (= "/" grid-el))
      "<"

      (and (= "v" old-dir) (= "\\" grid-el))
      ">"

      (= "+" grid-el)
      (go-through old-dir memory)
     
     :default (throw (RuntimeException. (str "Could not match " old-dir " " grid-el))))))

(defn find-collisions [c others]
  (cond 
    (empty? others)
    nil

    (and (= (:x c) (:x (first others)))
         (= (:y c) (:y (first others))))
    [(:x c), (:y c)]

    :default (recur c (rest others))))

(defn move-cart [grid cart]
  (let [moved-cart
    (case (:dir cart)
            ">" (assoc cart :x (inc (:x cart))  
                            :dir (calc-dir grid (:intersect cart) (:dir cart) (inc (:x cart)) (:y cart)))
            "<" (assoc cart :x (dec (:x cart))
                            :dir (calc-dir grid (:intersect cart) (:dir cart) (dec (:x cart)) (:y cart)))
            "^" (assoc cart :y (dec (:y cart))
                            :dir (calc-dir grid (:intersect cart) (:dir cart) (:x cart) (dec (:y cart))))
            "v" (assoc cart :y (inc (:y cart))
                            :dir (calc-dir grid (:intersect cart) (:dir cart) (:x cart) (inc (:y cart)))))]

    (if (= "+" (loc grid moved-cart))
      (assoc moved-cart :intersect (intersection-moves (:intersect moved-cart)))
      moved-cart)))

(defn do-step [grid carts]
  (loop [cs carts, new-carts '(), colls []]
    (if (empty? cs)
      { :carts new-carts, :collisions colls }
      (let [moved-cart (move-cart grid (first cs))
            collisions (find-collisions moved-cart 
                                       (concat (rest cs) new-carts))]
       ;(println "Moved cart:" moved-cart)
        (recur
          (rest cs)
          (conj new-carts moved-cart)
          (if collisions 
            (concat colls collisions)
            colls))))))


(defn find-carts [grid]
  (remove nil?
    (for [y (range 0 (count grid))
          x (range 0 (count (first grid)))]
      (if (carts (loc grid x y))
        { :x x, :y y, :dir (loc grid x y) :intersect :left }))))

(defn strip-carts-from-map [grid]
  (map #(replace cart-pos-replacements %) grid))

(let [init-grid (-> (first *command-line-args*)
                    (slurp)
                    (string/split #"\n")
                    (->> (map #(string/split % #""))))
      orig-carts  (find-carts init-grid)
      grid (strip-carts-from-map init-grid)]

  (println "Starting with carts:" orig-carts)
  (println "Found collision:" 
    (loop [turn 0, carts orig-carts, steps []]
     ;(println "Step" turn)
      (let [sorted-carts (sort-by (fn [x] [(:y x) (:x x)]) carts)
            step-out (do-step grid sorted-carts)]
       ;(println "Step-out" step-out)
        (if (not= 0 (count (:collisions step-out)))
          { :turn turn :collision (:collisions step-out) }
          (recur (inc turn), (:carts step-out), (conj steps step-out)))))))
