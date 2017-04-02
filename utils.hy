(import [flask [session]])
; hy.contrib.meth was remove from hy codebase, but this is a useful macro
; same as route but with an extra methods array to specify HTTP methods
; source: https://github.com/hylang/hy/blob/407a79591a42376d1add25c01514b10adfcda194/hy/contrib/meth.hy
; example:
; (route-with-methods index "/" ["GET"] [] "Hello, World!")
(defmacro route-with-methods [name path defaults methods params &rest code]
  `(with-decorator (apply app.route [~path] {"methods" ~methods "defaults" ~defaults})
       (defn ~name ~params
         (do ~@code))))

(defn session-get-or-set [key &optional [value None]]
   (if-not (in key session)
           (assoc session key value))
    (get session key))

(defn session-handle [key &kwargs args]
  (if (in "value" args)
      (assoc session key (get args "value"))
      (if (in key session)
          (get session key)
          (if (in "default" args)
               (get args "default")))))

(defn session-inc [key]
  (session-handle key :value (inc (session-get-or-set key 0))))
