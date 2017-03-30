; Copyright (c) Paul R. Tagliamonte <tag@pault.ag>, 2013 under the terms of hy.
; Copyright (c) Marko Manninen <elonmedia@gmail.com>, 2017 under the terms of HyML.

(import [flask [Flask session request]])
; render-template, ml
(require [hyml.template [*]])
; extend-template, variables-and-functions
(import [hyml.template [*]])
(import html)

;(def template-dir "templates/")

(def app (Flask "__main__"))

; hy.contrib.meth was remove from hy codebase, but this is a useful macro
; same as route but with an extra methods array to specify HTTP methods
; source: https://github.com/hylang/hy/blob/407a79591a42376d1add25c01514b10adfcda194/hy/contrib/meth.hy
; example:
; (route-with-methods index "/" ["GET"] [] "Hello, World!")
(defmacro route-with-methods [name path methods params &rest code]
  `(with-decorator (apply app.route [~path] {"methods" ~methods})
       (defn ~name ~params
         (do ~@code))))

(deffun charset (fn [charset]
  `(meta :charset ~charset)))

(deffun url (fn [controller &kwargs args]
  (% "%s/%s" (, controller 
    (if (empty? args) "" 
        (+ "?"  (.join "&amp;" (list-comp (% "%s=%s" (, k v)) [[k v] (.items args)]))))))))

; default title for templates
; use setv inside controller methods to set up different title
; and pass it to template as a dictionary variable
(defvar title "Hy, World!")

(defn session-get-or-set [key &optional [value None]]
   (if-not (in key session.__dict__)
           (assoc session.__dict__ key value))
    (get session.__dict__ key))

(defn session-handle [key &kwargs args]
  (if (in "value" args)
      (assoc session.__dict__ key (get args "value"))
      (if (in key session.__dict__)
          (get session.__dict__ key)
          (if (in "default" args)
               (get args "default")))))

(defn session-inc [key]
  (session-handle key :value (inc (session-get-or-set key 0))))

;; INDEX
(route-with-methods index "/" ["GET"] []
  (ml ~@(include "templates/index.hyml")))

;; USERNAME : FORM GET
(route-with-methods greeting "/<username>/" ["GET"] [username]
  (setv customname
    (html.escape (if (in "customname" request.args)
                     (get request.args "customname")
                     username)))
  (setv locvar {"customname" customname
                "title" (% "Hy, %s!" customname)})
  (render-template "greeting.hyml" locvar variables-and-functions))

;; MATH ADDITION
(route-with-methods addition "/<int:a>+<int:b>/" ["GET"] [a b]
  (setv locvar {"title" "Hy, Math Adder!" "a" a "b" b})
  (render-template "math.hyml" locvar variables-and-functions))

;; AJAX ADDITION
(route-with-methods ajaxpage "/ajaxpage/" ["GET"] []
  (setv locvar {"title" "Hy, MathJax Adder!"})
  (render-template "ajax.hyml" locvar variables-and-functions))

;; AJAX CALL HANDLER
(route-with-methods ajaxcall "/ajaxcall/" ["POST"] [a b]
  (render-template "ajax.hyml" variables-and-functions))

;; GET REQUEST
(route-with-methods req "/req/" ["GET"] []
  (setv locvar {"title" "Hy, Requestor!"
                "body" (if (in "body" request.args)
                           (get request.args "body")
                           "No body parameter found.")})
  (render-template "request.hyml" locvar variables-and-functions))

;; POST FORM
(route-with-methods formpage "/formpage/" ["GET" "POST"] []
  (setv customname
    (html.escape (if (in "customname" request.form)
                     (get request.form "customname")
                     "Visitor")))
  (setv locvar {"customname" customname
                "title" (% "Hy, %s!" customname)})
  (render-template "form.hyml" locvar variables-and-functions))

;; USER SESSION
(route-with-methods sessionpage "/session/" ["GET"] []
  (session-inc "token")
  (setv locvar {"title" "Hy, Sessioner!"
                "body" (% "Token: %s" (session-handle "token"))})
  (render-template "session.hyml" locvar variables-and-functions))
