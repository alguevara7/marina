(ns marina.core)

(defonce env (atom {}))

(defn map-keys [f m]
  (reduce-kv (fn [r k v] (assoc r (f k) v)) {} m))

(defn ^:export init!
  [js-env]

  (enable-console-print!)

  (reset! env (map-keys keyword (cljs.core/js->clj js-env)))

  ;;(marina/subscribe :window-open #(println %))

  (doseq [app (js/Application.allRunning)]
    (println "APP - " (.-title app))
    (doseq [window (.-windows app)]
      (println "\tWINDOW - >>>" (.-title window) "<<<")
      (println "\t\tROLE - " (.. window -role))
      (println "\t\tPOS - " (.. window -position -description))
      (println "\t\tSIZE - " (.. window -size -description))
      (when (re-find #".*cljs.*" (.-title window))
        (set! (.-position window) (js/Point.createFromXY 1 1))
        (set! (.-size window) (js/Size.createFromWidthHeight 1000 1000))
        )))

  (println "Focused Application" (.. (js/Application.focused) -title))
  (println "Focused Window" (.. (js/Application.focused) -focusedWindow -title))

  (println "ClojureScript initialized: " @env)

  (when (:debug-build @env)
    (set! *print-newline* true)))
