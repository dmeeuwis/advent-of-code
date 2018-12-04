(defn count-minutes [start-time end-time]
  (let [s (java.time.LocalDateTime/parse (clojure.string/replace start-time " " "T"))
        e (java.time.LocalDateTime/parse (clojure.string/replace end-time " " "T"))]
    (.toMinutes (java.time.Duration/between s e))))

(defn explode-minutes [start-time end-time]
  (let [s (java.time.LocalDateTime/parse (clojure.string/replace start-time " " "T"))
        e (java.time.LocalDateTime/parse (clojure.string/replace end-time " " "T"))]
    (loop [t s coll []]
      (cond
        (.equals t e)
        coll

        :default
        (recur (.plusMinutes t 1)
               (conj coll (.getMinute t)))))))


(defn read-records [input-lines]
  (loop [raw input-lines guard-log { } curr-record {}]
    (cond
      (empty? raw)
      guard-log

      (re-matches #".*begins shift.*" (first raw))
      (let [shift-start (re-matches #"\[(\d\d\d\d-\d\d-\d\d \d\d:\d\d)\] Guard #(\d+) begins shift"
                        (first raw))]
          (recur (rest raw) 
                 guard-log
                 { :start (shift-start 1) :guard (shift-start 2) } ))

      (re-matches #".*falls asleep.*" (first raw))
      (let [start-shift (re-matches #"\[(\d\d\d\d-\d\d-\d\d \d\d:\d\d)\] falls asleep"
                        (first raw))]
          (recur (rest raw)
                 guard-log
                 (assoc curr-record :start (start-shift 1))))
        

      (re-matches #".*wakes up.*" (first raw))
      (let [start-shift (re-matches #"\[(\d\d\d\d-\d\d-\d\d \d\d:\d\d)\] wakes up"
                        (first raw))
            guard (curr-record :guard)]

        (recur (rest raw)
               (assoc guard-log guard 
                      (conj (guard-log guard) 
                            (explode-minutes (curr-record :start) (start-shift 1))))
               (dissoc curr-record :start)))
      
      :default
      (throw (RuntimeException. (str "No match for input: " (first raw)))))))

(let [records (-> (first *command-line-args*) slurp (clojure.string/split #"\n") sort)
      guard-minutes (read-records records)
      guard-times (reduce-kv (fn [m k v] (assoc m k (count (flatten v))))
                             {}
                             guard-minutes)
      sleepiest-guard (first (last (sort-by val guard-times)))
      sleepiest-guard-minutes (guard-minutes sleepiest-guard)
      freqs (frequencies (flatten sleepiest-guard-minutes))
      sleepiest-minute (first (last (sort-by val freqs)))]
      
      (println "Sleepiest guard" sleepiest-guard
               "was sleepiest minute at" sleepiest-minute (type sleepiest-minute)
               "so answer is" (* (Integer/parseInt sleepiest-guard) sleepiest-minute)))
