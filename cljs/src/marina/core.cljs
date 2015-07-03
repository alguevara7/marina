(ns marina.core)

(defonce env (atom {}))

(defn map-keys [f m]
  (reduce-kv (fn [r k v] (assoc r (f k) v)) {} m))

(defn ^:export init!
  [js-env]

  (reset! env (map-keys keyword (cljs.core/js->clj js-env)))

  (marina/subscribe :window-open #(println %))

  (enable-console-print!)
  (println "ClojureScript initialized: " @env)

  (when (:debug-build @env)
    (set! *print-newline* true)))
