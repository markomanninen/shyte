#!/usr/bin/python3
; 
; Copyright (c) Paul R. Tagliamonte <tag@pault.ag>, 2013 under the terms of hy.
; Copyright (c) Marko Manninen <elonmedia@gmail.com>, 2017 under the terms of HyML.

(import [flask [Flask session request url-for redirect]])
; extend-template, ml macros
(require [hyml.template [*]])
; render-template function
(import [hyml.template [*]])
; route macro
(require [utils [*]])
; session-get-or-set and session-handle functions
(import [utils [*]])
; for html.escape
(import html)
; babel localization
(import [flask_babel [refresh gettext :as _]])

; set up custom templates directory. default is templates/
;(import hyml.template)
;(def hyml.template.template-dir "templates/")

(def app (Flask "__main__"))

; you can use either url-for, which requires to pass (globals) dictionary
; to the render template function, or this custom function that is registered
; to the HyML variables and functions to be available on template rendering
(deffun url (fn [controller &kwargs args]
  (% "%s/%s" (, controller 
    (if (empty? args) "" 
        (+ "?"  (.join "&amp;" (list-comp (% "%s=%s" (, k v)) [[k v] (.items args)]))))))))

; one can define functions (like meta tag below) to be used on templates either 
; on application level, or on templates themselves. 
(deffun charset (fn [charset]
  `(meta :charset ~charset)))

; default title for all templates
; use setv inside controller methods to set up different title
; and pass it to template as a dictionary variable
; one should be careful to setup variable via this macro, because it will
; override variables set on template level
(defvar title "Hy, World!")

;------------------------
;; INDEX
;------------------------
(route GET ["/" "/index"]
  ; indent code for pretty print. note that html code must be
  ; "perfect xml" for indent to work so if for example manually inserted
  ; html code has tags and attribute that are not correctly formed
  ; there will be an error on parsing the page. also minimized html code
  ; (omitting start and end tags, boolean attribute minimizing)
  ; does not validate according to xml specs.
  ;(indent (ml ~@(include "templates/index.hyml"))))
  ;(assoc app.config "BABEL_DEFAULT_LOCALE" "fi")
  ;(refresh)
  (render-template "index.hyml" (globals)))


;------------------------
;; USERNAME : FORM GET
;------------------------
(route GET "/<username>/" :params [username]
  (setv customname
    (html.escape (if (in "customname" request.args)
                     (get request.args "customname")
                     username)))
  (setv locvar {"customname" customname
                "title" (% "Hy, %s!" customname)})
  (render-template "greeting.hyml" locvar))


;------------------------
;; MATH ADDITION
;------------------------
(route GET "/<int:a>+<int:b>/" :params [a b]
  (setv locvar {"title" "Hy, Math Adder!" "a" a "b" b})
  (render-template "math.hyml" locvar))


;---------------------------------------------------
;; LOCALIZATION
; pybabel extract -F babel.cfg -o messages.pot .
; pybabel init -i messages.pot -d translations -l fi
; pybabel init -i messages.pot -d translations -l en
; pybabel compile -d translations
; pybabel update -i messages.pot -d translations
;---------------------------------------------------
(route GET/POST "/language/"
  (setv lang (if (in "lang" request.form)
                 (.join "" (take 2 (html.escape (get request.form "lang"))))
                 (get app.config "BABEL_DEFAULT_LOCALE")))
  (assoc app.config "BABEL_DEFAULT_LOCALE" lang)
  (refresh)
  (setv locvar {"lang" lang})
  (render-template "lang.hyml" locvar (globals)))


;------------------------
;; AJAX ADDITION
;------------------------
(route GET "/ajaxpage/"
  (setv locvar {"title" (_ "Hy, MathJax Adder!")
                "body" `(p (a "< Back" :href "/"))})
  (render-template "ajax.hyml" locvar (globals)))


;------------------------
;; AJAX CALL HANDLER
;------------------------
(route POST "/ajaxcall/" :params [a b]
  (render-template "ajax.hyml"))


;------------------------
;; GET REQUEST
;------------------------
(route GET "/req/"
  (setv locvar {"title" (_ "Hy, Requestor!")
                "body" (if (in "body" request.args)
                           (html.escape (get request.args "body"))
                           (_ "No body parameter found."))})
  (render-template "request.hyml" locvar (globals)))


;------------------------
;; POST FORM
;------------------------
(route GET/POST "/formpage/"
  (setv customname
    (html.escape (if (in "customname" request.form)
                     (get request.form "customname")
                     "Visitor")))
  (setv locvar {"customname" customname
                "title" (% "Hy, %s!" customname)})
  (render-template "form.hyml" locvar (globals)))


;------------------------
;; USER SESSION
;------------------------
; simple session token increment
(defn session-inc [key]
  (session-handle key :value (inc (session-get-or-set key 0))))

(route GET "/session/"
  (if (and (in "reset" request.args) (pos? (int (get request.args "reset"))))
      (do (session-handle "token" :value 0)
          (redirect "/session/"))
      (do
        (session-inc "token")
        (setv locvar {"title" (_ "Hy, Sessioner!")
                      ; manual html just for demonstration
                      ; it is better idea to put code on template file
                      "body" (+ (% "<p>Token: %s</p>" (session-handle "token"))
                                "<p><a href=\"/\">&lt; "
                                (_ "Back")
                                "</a></p>
                                 <p><a href=\"/session/\">"
                                 (_ "Refresh?")
                                 "</a></p>
                                 <p><a href=\"/session/?reset=1\">"
                                 (_ "Reset!")
                                 "</a></p>")})
        (render-template "session.hyml" locvar (globals)))))
