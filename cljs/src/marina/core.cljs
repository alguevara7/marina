(ns marina.core)

(defonce env (atom {}))

(defn map-keys [f m]
  (reduce-kv (fn [r k v] (assoc r (f k) v)) {} m))

(defn ^:export init!
  [js-env]

  (enable-console-print!)

  (reset! env (map-keys keyword (cljs.core/js->clj js-env)))

  (doseq [app (js/Application.allRunning)]
    ;;     (println "APP - " (.-title app))
    (when (re-find #".*Terminal.*" (.-title app))
      (.on app :created (fn [event-type window] (println ">>> " event-type " -- "(.. window -roleDescription))))
      (.on app :focused (fn [event-type window] (println ">>> " event-type " -- "(.. window -roleDescription))))
      (.on app :destroyed (fn [event-type window] (println ">>> " event-type)))
      (.on app :resized (fn [event-type window] (println ">>> " event-type)))
      (.on app :moved (fn [event-type window] (println ">>> " event-type)))
      (.on app :main-window-changed (fn [event-type window] (println ">>> " event-type)))
    )

    (doseq [window (.-windows app)]
      (println "\t\tROLE - " (.. window -role) "/" (.-subrole window))
;;       (println "\t\tPOS - " (.. window -position -description))
;;       (println "\t\tSIZE - " (.. window -size -description))
      (when (re-find #".*cljs.*" (.-title window))
;;         (println (.. window -title))
;;         (set! (.-position window) (js/Point.createFromXY 1 1))
;;         (set! (.-size window) (js/Size.createFromWidthHeight 1000 1000))
        )))

;;   (println "Focused Application" (.. (js/Application.focused) -title))
;;   (println "Focused Window" (.. (js/Application.focused) -focusedWindow -title))

  (js/Application.on :launched (fn [event-type app]
                                 (println "App: " event-type " " (.. app -title))
                                 (.on app :focused (fn [event-type window] (println ">>> " event-type " -- "(.. window -roleDescription))))))

  (println "ClojureScript initialized: " @env)

  (when (:debug-build @env)
    (set! *print-newline* true)))
