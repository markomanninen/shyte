; Copyright (c) Paul R. Tagliamonte <tag@pault.ag>, 2013 under the terms of hy.
; Copyright (c) Marko Manninen <elonmedia@gmail.com>, 2017 under the terms of HyML.

(import [flask [Flask session request]])
(require [hyml.minimal [*]])
(import [hyml.minimal [*]])

(def SECRET_KEY "development")

(def app (Flask "__main__"))

;(app.secret_key SECRET_KEY)

; hy.contrib.meth was remove from hy codebase, but this is a useful macro
; source: https://github.com/hylang/hy/blob/407a79591a42376d1add25c01514b10adfcda194/hy/contrib/meth.hy
; example:
; (route-with-methods index "/" ["GET"] []
;   (ml ~@(include "templates/index.hyml")))
(defmacro route-with-methods [name path methods params &rest code]
  "Same as route but with an extra methods array to specify HTTP methods"
  `(let [deco (apply app.route [~path]
                     {"methods" ~methods})]
     (with-decorator deco
       (defn ~name ~params
         (do ~@code)))))

; should take previus variables and pass them to next template
; or maybe parse-mnml already does this?!
(defmacro extends [tmpl vars])

(defn render-template [tmpl &optional [vars {}]]
  (parse-mnml `(do ~@(include tmpl)) vars))

(defn with-session [tmpl &optional [vars {}]]
  (render-template tmpl (merge-two-dicts {"session" session} vars)))

(defn with-request [tmpl &optional [vars {}]]
  (render-template tmpl (merge-two-dicts {"request" request} vars)))

(defn with-session-and-request [tmpl &optional [vars {}]]
  (render-template tmpl
    (merge-two-dicts {"session" session "request" request} vars)))

(deffun charset (fn [charset]
  `(meta :charset ~charset)))

(deffun url (fn [controller &optional [filename ""]]
  (% "%s/%s" (, controller filename))))

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

(with-decorator (app.route "/")
  (defn index [] 
    (ml ~@(include "templates/index.hyml"))))

(with-decorator (app.route "/<username>/")
  (defn greeting [username] 
    (do
      (setv vars {"username" username
                  "title" (% "Hy, %s!" username)})
      (render-template "templates/greeting.hyml" vars))))

(with-decorator (app.route "/<int:a>+<int:b>/")
  (defn addition [a b] 
    (do
      (setv vars {"title" "Hy, Math Adder!" "a" a "b" b})
      (render-template "templates/math.hyml" vars))))

(with-decorator (app.route "/ajaxpage/")
  (defn ajaxpage [] 
    (do
      (setv vars {"title" "Hy, MathJax Adder!"})
      (render-template "templates/ajax.hyml" vars))))

(with-decorator (app.route "/ajaxcall/")
  (defn ajaxcall [a b] 
    (do
      (render-template "templates/ajax.hyml"))))

(with-decorator (app.route "/req/")
  (defn req [] 
    (do
      (setv vars {"title" "Hy, Requestor!"
                  "body" (if (in "body" request.args)
                             (get request.args "body")
                             "No body parameter found.")})
      (with-request "templates/request.hyml" vars))))

(with-decorator (app.route "/formpage/")
  (defn formpage [] 
    (do
      (setv vars {"title" "Hy, Poster!"
                  "body" (get request.args "body")})
      (with-request "templates/form.hyml" vars))))

(with-decorator (app.route "/session/")
  (defn session [] 
    (do
      (session-inc "token")
      (setv vars {"title" "Hy, Sessioner!"
                  "body" (% "Token: %s" (session-handle "token"))})
      (with-session "templates/session.hyml" vars))))
