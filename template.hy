(require (hyml.minimal (*)))
(import (hyml.minimal (*)))

(eval-and-compile
(def template-dir "templates/")
; return / chain extended list rather than extending in-place (.extend)
(defn extend [a b] (.extend a b) a)
; should take previus variables and pass them to the next template
(defn render-template [tmpl &rest args]
  ; prefix template with dir
  (setv tmpl (+ template-dir tmpl))
  ; we want to get a recursive access to render-template and extendd-template
  ; functions to enable "extend" / blocks functionality in templates
  (setv vars (globals))
  ; pass variables from arguments
  (for [d args] (setv vars (merge-two-dicts d vars)))
  (parse-mnml `(do ~@(include tmpl)) vars)))

; to imitate jinja and mako
; ~(extend-template "layout.hyml" {"var1" "val1" "var2" "val2"})
(defmacro extend-template2 [tmpl &rest args]
  `(apply render-template (extend (extend [tmpl] args) (globals))))
