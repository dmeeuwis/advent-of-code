(require '[clojure.string :as st])
(def regex #"(aA|Aa|bB|Bb|cC|Cc|dD|Dd|eE|Ee|fF|Ff|gG|Gg|hH|Hh|iI|Ii|jJ|Jj|kK|Kk|lL|Ll|mM|Mm|nN|Nn|oO|Oo|pP|Pp|qQ|Qq|rR|Rr|sS|Ss|tT|Tt|uU|Uu|vV|Vv|wW|Ww|xX|Xx|yY|Yy|zZ|Zz)")

(defn replace-run [s]
  (let [r (st/replace s regex "")]
    (if (= s r)
      r
      (recur r))))

(-> (first *command-line-args*)
    slurp
    (.trim)
    replace-run
    (.length)
    println)
