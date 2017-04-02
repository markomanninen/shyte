#!/usr/bin/python3
; 
; Copyright (c) Paul R. Tagliamonte <tag@pault.ag>, 2013 under the terms of hy.
; Copyright (c) Marko Manninen <elonmedia@gmail.com>, 2017 under the terms of HyML.

(import [flask [Flask session request url-for redirect]])
; render-template, ml
(require [hyml.template [*]])
; extend-template, variables-and-functions
(import [hyml.template [*]])
; route-with-methods
(require [utils [*]])
; session-inc session-handle url
(import [utils [*]])
; for html.escape
(import html)

;(def template-dir "templates/")

(def app (Flask "__main__"))

; you can use either url-for, which requires to pass (globals) dictionary
; to the render template function, or this custom function that is registered
; to the HyML variables and functions to be available on template rendering
(deffun url (fn [controller &kwargs args]
  (% "%s/%s" (, controller 
    (if (empty? args) "" 
        (+ "?"  (.join "&amp;" (list-comp (% "%s=%s" (, k v)) [[k v] (.items args)]))))))))

(deffun charset (fn [charset]
  `(meta :charset ~charset)))

; default title for templates
; use setv inside controller methods to set up different title
; and pass it to template as a dictionary variable
(defvar title "Hy, World!")

;; INDEX
(route-with-methods index "/" {} ["GET"] []
  (ml ~@(include "templates/index.hyml")))

;; USERNAME : FORM GET
(route-with-methods greeting "/<username>/" {} ["GET"] [username]
  (setv customname
    (html.escape (if (in "customname" request.args)
                     (get request.args "customname")
                     username)))
  (setv locvar {"customname" customname
                "title" (% "Hy, %s!" customname)})
  (render-template "greeting.hyml" locvar variables-and-functions))

;; MATH ADDITION
(route-with-methods addition "/<int:a>+<int:b>/" {} ["GET"] [a b]
  (setv locvar {"title" "Hy, Math Adder!" "a" a "b" b})
  (render-template "math.hyml" locvar variables-and-functions))

;; AJAX ADDITION
(route-with-methods ajaxpage "/ajaxpage/" {} ["GET"] []
  (setv locvar {"title" "Hy, MathJax Adder!"})
  (render-template "ajax.hyml" locvar variables-and-functions (globals)))

;; AJAX CALL HANDLER
(route-with-methods ajaxcall "/ajaxcall/" {} ["POST"] [a b]
  (render-template "ajax.hyml" variables-and-functions))

;; GET REQUEST
(route-with-methods req "/req/" {} ["GET"] []
  (setv locvar {"title" "Hy, Requestor!"
                "body" (if (in "body" request.args)
                           (get request.args "body")
                           "No body parameter found.")})
  (render-template "request.hyml" locvar variables-and-functions (globals)))

;; POST FORM
(route-with-methods formpage "/formpage/" {} ["GET" "POST"] []
  (setv customname
    (html.escape (if (in "customname" request.form)
                     (get request.form "customname")
                     "Visitor")))
  (setv locvar {"customname" customname
                "title" (% "Hy, %s!" customname)})
  (render-template "form.hyml" locvar variables-and-functions (globals)))

;; USER SESSION
(route-with-methods sessionpage "/session/" {} ["GET"] []
  (if (and (in "reset" request.args) (pos? (int (get request.args "reset"))))
      (do (session-handle "token" :value 0)
          (redirect "/session/"))
      (do
        (session-inc "token")
        (setv locvar {"title" "Hy, Sessioner!"
                      "body" (+ (% "<p>Token: %s</p>" (session-handle "token"))
                                "<p><a href=\"/\">&lt; Back</a></p>
                                 <p><a href=\"/session/\">Refresh?</a></p>
                                 <p><a href=\"/session/?reset=1\">Reset!</a></p>")})
        (render-template "session.hyml" locvar variables-and-functions (globals)))))
