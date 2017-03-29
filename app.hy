; Copyright (c) Paul R. Tagliamonte <tag@pault.ag>, 2013 under the terms of hy.
; Copyright (c) Marko Manninen <elonmedia@gmail.com>, 2017 under the terms of HyML.

(import [flask [Flask session request]])
(require [hyml.minimal [*]])
(import [hyml.minimal [*]])
(import html)

(def template-dir "templates/")

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

; return / chain extended list rather than extending in-place (.extend)
(defn extend [a b] (.extend a b) a)

; to imitate jinja and mako
(defn extend-template [tmpl &rest args]
  (apply render-template (extend [tmpl] args)))

; should take previus variables and pass them to the next template
(defn render-template [tmpl &rest args]
  ; prefix template with dir
  (setv tmpl (+ template-dir tmpl))
  ; we want to get a recursive access to render-template and extendd-template
  ; functions to enable "extend" / blocks functionality in templates
  (setv vars (globals))
  ; pass variables from arguments
  (for [d args] (setv vars (merge-two-dicts d vars)))
  (parse-mnml `(do ~@(include tmpl)) vars))

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
  (setv vars {"customname" customname
              "title" (% "Hy, %s!" customname)})
  (render-template "greeting.hyml" vars))

;; MATH ADDITION
(route-with-methods addition "/<int:a>+<int:b>/" ["GET"] [a b]
  (setv vars {"title" "Hy, Math Adder!" "a" a "b" b})
  (render-template "math.hyml" vars))

;; AJAX ADDITION
(route-with-methods ajaxpage "/ajaxpage/" ["GET"] []
  (setv vars {"title" "Hy, MathJax Adder!"})
  (render-template "ajax.hyml" vars))

;; AJAX CALL HANDLER
(route-with-methods ajaxcall "/ajaxcall/" ["POST"] [a b]
  (render-template "ajax.hyml"))

;; GET REQUEST
(route-with-methods req "/req/" ["GET"] []
  (setv vars {"title" "Hy, Requestor!"
              "body" (if (in "body" request.args)
                         (get request.args "body")
                         "No body parameter found.")})
  (render-template "request.hyml" vars))

;; POST FORM
(route-with-methods formpage "/formpage/" ["POST"] []
  (setv customname
    (html.escape (if (in "customname" request.form)
                     (get request.form "customname")
                     "Visitor")))
  (setv vars {"customname" customname
              "title" (% "Hy, %s!" customname)})
  (render-template "form.hyml" vars))

;; USER SESSION
(route-with-methods sessionpage "/session/" ["GET"] []
  (session-inc "token")
  (setv vars {"title" "Hy, Sessioner!"
              "body" (% "Token: %s" (session-handle "token"))})
  (render-template "session.hyml" vars))
