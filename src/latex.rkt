#lang racket

(provide document-class
         use-package
         env
         latex->ref
         latex
         inline-math->ref)

#|
LaTeX
|#

;;
;; This defines a simple interface to compile
;; and include PNGs from LaTeX
;;

(define (document-class #:option [option "standalone"] x)
  (string-append "\\documentclass[" x "]{" option "}"))

(define (use-package x)
  (string-append "\\usepackage{" x "}"))

(define (env x . code)
  (string-append "\\begin{" x "}"
                 (apply string-append code)
                 "\\end{" x "}"))

(define (latex->ref #:dir [dir "latex"]
                    #:ext [ext "png"]
                    #:convert [convert "-quality 90"]
                    #:css-class [css-class "latex"]
                    . code)
  (define unique-name (gensym))
  (make-directory* dir)
  (define latex (apply string-append code))
  (define path (build-path dir (~a "latex_" unique-name ".tex")))
  (define pdf-path (build-path dir (~a "latex_" unique-name ".pdf")))
  (define img-path (build-path dir (~a "latex_" unique-name "." ext)))
  (with-output-to-file path (lambda () (printf latex))
                       #:exists 'replace)
  (define latex-cmd (string-append 
                      "pdflatex "
                      "-shell-escape "
                      "-output-directory "
                      dir
                      " "
                      (path->string path)))
  (define img-cmd (string-append 
                    "convert -density 300 "
                    convert
                    " "
                    (path->string pdf-path)
                    " "
                    (path->string img-path)))
  (system latex-cmd)
  (system img-cmd)
  (path->string img-path))

(define (latex #:dir [dir "latex"]
               #:ext [ext "png"]
               #:convert [convert "-quality 90"]
               #:caption [caption ""]
               #:css-class [css-class "latex"]
               . code)
  (define img-path 
    (apply latex->ref #:dir dir
           #:ext ext
           #:convert convert
           #:css-class css-class
           code))
  `(figure ((class "latex"))
           (img ((class ,css-class) (src ,img-path)))
           (figcaption ((class "latex")) ,caption)
           )
  )

(define (inline-math->ref code) 
  (latex->ref 
    (string-append
      "\\documentclass[preview]{standalone}\n"
      "\\usepackage{amsmath}\n"
      "\\begin{document}\n$"
      code
      "$\\end{document}")))
