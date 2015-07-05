(ns marina.core)

(defonce env (atom {}))

(defn map-keys [f m]
  (reduce-kv (fn [r k v] (assoc r (f k) v)) {} m))

(defn subscribe [f]
  (js/subscribe f))


(defn ^:export init!
  [js-env]

  (enable-console-print!)

  (reset! env (map-keys keyword (cljs.core/js->clj js-env)))

  (subscribe (fn [event] (println (get (cljs.core/js->clj event :keywordize-keys true) :type))))

  (println "ClojureScript initialized: " @env)

  (when (:debug-build @env)
    (set! *print-newline* true)))

