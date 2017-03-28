; Copyright (c) Paul R. Tagliamonte <tag@pault.ag>, 2013 under the terms of hy.
; Copyright (c) Marko Manninen <elonmedia@gmail.com>, 2017 under the terms of HyML.

(import [flask [Flask]])
(require [hyml.minimal [*]])
(import [hyml.minimal [*]])

(def app (Flask "__main__"))

(deffun head (fn [charset]
  `(meta :charset ~charset)))

(deffun url_for (fn [controller &optional [filename ""]]
  (% "%s/%s" (, controller filename))))

(with-decorator (app.route "/")
  (defn index [] 
    (do
      (defvar title "Hy, World!")
      (ml ~@(include "templates/index.hyml")))))
