#lang racket

(provide $ $$ align)

#|
MathJax
|#

(define ($ . xs)
  `(mathjax ,(apply string-append 
                    `("$" ,@xs "$"))))

(define ($$ . xs)
  `(mathjax ,(apply string-append 
                    `("\\begin{equation}" ,@xs "\\end{equation}"))))

(define (align . xs)
  `(mathjax ,(apply string-append 
                    `("\\begin{align}" ,@xs "\\end{align}"))))
