(import [flask [session]])

;-----------------------------------------
; ROUTER
; short example:
; (route GET [/ /index] code)
; max params example:
; (route GET/POST/PUT/DELETE/HEAD/OPTIONS/TRACE/CONNECT /|[/ /index] :name index :defaults {} :params [] code)
;-----------------------------------------
(eval-and-compile
  ; detach keywords and content from code expression
  (defn extract-keywords-and-expressions [code]
    (setv content [] keywords {} kwd None)
    (for [item code]
         (do ; should we add the item to the content or keywords list?
             (if-not (keyword? item)
               (if (none? kwd)
                   ; the keyword was not set, so the item must be a content
                   (.append content item)
                   ; otherwise the item is an attribute
                   (assoc keywords kwd item)))
             ; should we regard the next item as a value of the keyword?
            (setv kwd (if (keyword? item) item None))))
    ; return collected content and keywords
    (, content keywords)))

(defmacro route-decorator [path methods defaults code]
  `(with-decorator
    (apply app.route [~path] {"methods" ~methods "defaults" ~defaults})
    ~code))

; recursive route decorator for multiple paths
(defmacro route* [paths defaults methods func]
  (if (and (coll? paths) (> (len paths) 1))
      `(route-decorator ~(name (first paths)) ~methods ~defaults
        (route* ~(list (drop 1 paths)) ~defaults ~methods ~func))
      (do (setv paths (name (if (coll? paths) (first paths) paths)))
          `(route-decorator ~paths ~methods ~defaults ~func))))

; main route macro
; see methods/protocols: http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html
(defmacro route [methods paths &rest code]
  (setv (, content keywords) (extract-keywords-and-expressions code))
  ; set default values for defaults and params
  (if-not (in :defaults keywords) (assoc keywords :defaults {}))
  (if-not (in :params keywords) (assoc keywords :params []))
  ; call route* helper macro for recursive path decoration
  `(route* ~paths ~(get keywords :defaults) ~(.split methods "/")
           ~(if (in :name keywords)
                ; if name is given, lets define a function
                `(defn ~(get keywords :name) ~(get keywords :params) ~@content)
                ; otherwise just an anonymous function
                `(fn ~(get keywords :params) ~@content))))

;-----------------------------------------
; SESSION HANDLERS
;-----------------------------------------
; get session variable or set a default if not found
(defn session-get-or-set [key &optional [value None]]
   (if-not (in key session)
           (assoc session key value))
    (get session key))

; with :value key set session variable
; without value get session variable
; with default return default if key is not set
; note that this doesn't set variable however
(defn session-handle [key &kwargs args]
  (if (in "value" args)
      (assoc session key (get args "value"))
      (if (in key session)
          (get session key)
          (if (in "default" args)
               (get args "default")))))
