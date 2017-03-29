; Copyright (c) Paul R. Tagliamonte <tag@pault.ag>, 2013 under the terms of hy.
; Copyright (c) Marko Manninen <elonmedia@gmail.com>, 2017 under the terms of HyML.

(import [flask [Flask session request]])
(require [hyml.minimal [*]])
(import [hyml.minimal [*]])

(def app (Flask "__main__"))

; should take previus variables and pass them to next template
; or maybe parse-mnml already does this?!
(defmacro extends [tmpl vars])

(defn render-template [tmpl &optional [vars {}]]
  (parse-mnml `(do ~@(include tmpl)) vars))

(defn with-session [tmpl vars]
  (render-template tmpl (merge-two-dicts {"session" session} vars)))

(defn with-request [tmpl vars]
  (render-template tmpl (merge-two-dicts {"request" request} vars)))

(defn with-session-and-request [tmpl vars]
  (render-template tmpl
    (merge-two-dicts {"session" session "request" request} vars)))

(deffun charset (fn [charset]
  `(meta :charset ~charset)))

(deffun url (fn [controller &optional [filename ""]]
  (% "%s/%s" (, controller filename))))

(with-decorator (app.route "/")
  (defn index [] 
    (do
      (defvar title "Hy, World!")
      (ml ~@(include "templates/index.hyml")))))

(with-decorator (app.route "/<username>/")
  (defn greeting [username] 
    (do
      (setv vars {"username" username
                  "title" (% "Hy, %s!" username)})
      (render-template "templates/greeting.hyml" vars))))

(with-decorator (app.route "/<int:a>+<int:b>/")
  (defn addition [a b] 
    (do
      (defvar title "Hy, Math Adder!")
      (render-template "templates/math.hyml" {"a" a "b" b}))))

(with-decorator (app.route "/ajaxpage/")
  (defn ajaxpage [] 
    (do
      (defvar title "Hy, MathJax Adder!")
      (render-template "templates/ajax.hyml"))))

(with-decorator (app.route "/ajaxcall/")
  (defn ajaxcall [a b] 
    (do
      (render-template "templates/ajax.hyml"))))

(with-decorator (app.route "/request/")
  (defn request [] 
    (do
      (defvar title "Hy, Requestor!")
      (render-template "templates/request.hyml"))))

(with-decorator (app.route "/session/")
  (defn session [] 
    (do
      (defvar title "Hy, Sessioner!")
      (render-template "templates/session.hyml"))))