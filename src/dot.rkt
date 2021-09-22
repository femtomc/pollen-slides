#lang racket

(provide 
  dot->ref
  dot)

#|
GraphViz
|#

(define (not-newline? s) (not (eq? s "\n")))

;;
;; This defines a very simple Pollen interface to GraphViz
;; Requires `dot` available on $PATH.
;;

(define (dot->ref #:dir [dir "images"] 
                  #:css-class [css-class "dot"]
                  . digraph)
  (make-directory* dir)
  (define unique-name (gensym))
  (define g (string-append "digraph G {\n"
                           "rankdir=TD;\n"
                           (apply string-append digraph)
                           "\n}"))
  (define path (build-path dir (~a "dot_" unique-name ".dot")))
  (define img-path (build-path dir (~a "dot_" unique-name ".png")))
  (with-output-to-file path (lambda() (printf g))
                       #:exists 'replace)
  (define dot-cmd (string-append "dot -Tpng -Gdpi=300 "
                                 (path->string path)
                                 " > "
                                 (path->string img-path)))
  (system dot-cmd)
  (path->string img-path))

(define (dot #:dir [dir "images"] 
             #:css-class [css-class "dot"]
             . digraph)
  (define img-path 
    (apply dot->ref #:dir dir
           #:css-class css-class
           digraph))
  `(img ((class ,css-class) (src ,img-path))))
