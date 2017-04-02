#!/usr/bin/python3
; 
; Copyright (c) Paul R. Tagliamonte <tag@pault.ag>, 2013 under the terms of hy.
; Copyright (c) Marko Manninen <elonmedia@gmail.com>, 2017 under the terms of HyML.

(import [flask [Flask session request url-for redirect]])
; render-template, ml
(require [hyml.template [*]])
; extend-template
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
  ; indent code for pretty print. note that html code must be
  ; "perfect xml" for indent to work so if for example manually inserted
  ; html code has tags and attribute that are not correctly formed
  ; there will be an error on parsing the page. also minimized html code
  ; (omitting start and end tags, boolean attribute minimizing)
  ; does not validate according to xml specs.
  (indent (ml ~@(include "templates/index.hyml"))))

;; USERNAME : FORM GET
(route-with-methods greeting "/<username>/" {} ["GET"] [username]
  (setv customname
    (html.escape (if (in "customname" request.args)
                     (get request.args "customname")
                     username)))
  (setv locvar {"customname" customname
                "title" (% "Hy, %s!" customname)})
  (render-template "greeting.hyml" locvar))

;; MATH ADDITION
(route-with-methods addition "/<int:a>+<int:b>/" {} ["GET"] [a b]
  (setv locvar {"title" "Hy, Math Adder!" "a" a "b" b})
  (render-template "math.hyml" locvar))

;; AJAX ADDITION
(route-with-methods ajaxpage "/ajaxpage/" {} ["GET"] []
  (setv locvar {"title" "Hy, MathJax Adder!"})
  (render-template "ajax.hyml" locvar (globals)))

;; AJAX CALL HANDLER
(route-with-methods ajaxcall "/ajaxcall/" {} ["POST"] [a b]
  (render-template "ajax.hyml"))

;; GET REQUEST
(route-with-methods req "/req/" {} ["GET"] []
  (setv locvar {"title" "Hy, Requestor!"
                "body" (if (in "body" request.args)
                           (get request.args "body")
                           "No body parameter found.")})
  (render-template "request.hyml" locvar (globals)))

;; POST FORM
(route-with-methods formpage "/formpage/" {} ["GET" "POST"] []
  (setv customname
    (html.escape (if (in "customname" request.form)
                     (get request.form "customname")
                     "Visitor")))
  (setv locvar {"customname" customname
                "title" (% "Hy, %s!" customname)})
  (render-template "form.hyml" locvar (globals)))

;; USER SESSION
(route-with-methods sessionpage "/session/" {} ["GET"] []
  (if (and (in "reset" request.args) (pos? (int (get request.args "reset"))))
      (do (session-handle "token" :value 0)
          (redirect "/session/"))
      (do
        (session-inc "token")
        (setv locvar {"title" "Hy, Sessioner!"
                      ; manual html
                      "body" (+ (% "<p>Token: %s</p>" (session-handle "token"))
                                "<p><a href=\"/\">&lt; Back</a></p>
                                 <p><a href=\"/session/\">Refresh?</a></p>
                                 <p><a href=\"/session/?reset=1\">Reset!</a></p>")})
        (render-template "session.hyml" locvar (globals)))))
