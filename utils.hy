(import [flask [session]])

; hy.contrib.meth was remove from hy codebase, but it was a useful macro
; same as route but with an extra methods array to specify HTTP methods
; source: https://github.com/hylang/hy/blob/407a79591a42376d1add25c01514b10adfcda194/hy/contrib/meth.hy
; now defaults dictionary and multiple routes support added
(defmacro route-decorator [path methods defaults code]
  `(with-decorator
    (apply app.route [~path] {"methods" ~methods "defaults" ~defaults})
    ~code))

; example 1:
; (route-with-methods num "/num/<int:num>" {"num" 1} ["GET"] [num] (% "Number: %s" num))
; example 2, decorate method with multiple routes:
; (route-with-methods index ["/" "/index"] {} ["GET"] [] "Hello, Index!")
(defmacro route-with-methods [name paths defaults methods params &rest code]
  (if (and (coll? paths) (> (len paths) 1))
      `(route-decorator ~(first paths) ~methods ~defaults
        (route-with-methods ~name ~(list (drop 1 paths)) ~defaults ~methods ~params ~@code))
       (if (coll? paths) (setv paths (first paths)))
       `(route-decorator ~paths ~methods ~defaults
         (defn ~name ~params (do ~@code)))))

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
