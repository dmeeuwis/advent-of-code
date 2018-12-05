(require '[clojure.string :as st])
(def part-one-regex #"(aA|Aa|bB|Bb|cC|Cc|dD|Dd|eE|Ee|fF|Ff|gG|Gg|hH|Hh|iI|Ii|jJ|Jj|kK|Kk|lL|Ll|mM|Mm|nN|Nn|oO|Oo|pP|Pp|qQ|Qq|rR|Rr|sS|Ss|tT|Tt|uU|Uu|vV|Vv|wW|Ww|xX|Xx|yY|Yy|zZ|Zz)")
(def part-two-regexes [ #"[aA]" #"[bB]" #"[cC]" #"[dD]" #"[eE]" #"[fF]" #"[gG]" #"[hH]" #"[iI]" #"[jJ]" #"[kK]" #"[lL]" #"[mM]" #"[nN]" #"[oO]" #"[pP]" #"[qQ]" #"[rR]" #"[sS]" #"[tT]" #"[uU]" #"[vV]" #"[wW]" #"[xX]" #"[yY]" #"[zZ]" ])

(defn replace-regex [s reg]
  (let [r (st/replace s reg "")]
    (if (= s r)
      r
      (recur r reg))))

(defn replace-run-multi [s regexes]
  (let [all-possible-removals (map #(replace-regex s %) regexes)]
    (map #(replace-regex % part-one-regex) all-possible-removals)))

(defn sizes-by-index [vectors]
  (for [i (range 0 (count vectors))]
    [i (count (nth vectors i))]))

(let [data (-> (first *command-line-args*) slurp .trim)]

  ; soln part 1
  (-> data
    (replace-regex part-one-regex)
    (.length)
    println)

; soln part 2
  (-> data
    (replace-run-multi part-two-regexes)
    sizes-by-index
    (->> (sort-by second))
      first
      println))
