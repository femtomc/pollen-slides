#lang racket

(require
  pict
  racket/file
  setup/xref
  scribble/xref
  rackunit
  racket/string
  txexpr/base
  sugar/coerce
  pollen/unstable/pygments
  pollen/unstable/typography
  pollen/decode
  pollen/file
  pollen/tag
  sugar
  txexpr
  hyphenate)

(require "src/mathjax.rkt")
(require "src/latex.rkt")
(require "src/dot.rkt")

#|
The pollen/pygments module provides a `highlight` tag function that performs syntax highlighting. To make it available in pollen source files, we re-export it here.
|#

(provide (all-defined-out) 
         highlight
         $
         $$
         document-class
         use-package
         env
         latex->ref
         latex
         inline-math->ref
         dot->ref
         dot)


#|
`show-source` converts a source file to a displayable page.
|#

(define (show-source lang path)
  `(@ ,(title path) ,(highlight lang (file->string path))))

(define (show-source-link filename)
  (define url (format "~a.html" filename))
  (code (link url filename)))

#|
`root` is the main decoder for our Pollen markup.
|#

(define exclusion-mark-attr '(decode "exclude"))
(define (root . items)
  (decode `(decoded-root ,@items)
          #:exclude-tags '(style script pre)
          #:exclude-attrs (list exclusion-mark-attr)))

#|
Tag functions used in the Pollen markup. Since I'm targeting HTML, I’ll convert my custom markup tags into standard HTML equivalents, which can then be styled with an external CSS file. (In practice, this isn't strictly necessary: web browsers don't care if you use nonstandard tags in your HTML, and I certainly don't either. But for this exercise, let’s pretend it matters.)

This “pollen.rkt” file makes variables available to the other files in the project. Thus, as we define the tag functions, we'll also define variables that will be handy when we get to the CSS. This is a rather overengineered approach for this tiny project, but on a large project, it's indispensable, because your CSS source can track the tag names in the original Pollen markup.
|#

(define code-tag 'span)
(define code-class "my-code")
(define (code . elements)
  `(,code-tag ((class ,code-class) ,exclusion-mark-attr) ,@elements))

(define dept-tag 'h3)
(define dept-class "dept")
(define (dept . elements)
  `(,dept-tag ((class ,dept-class)) ,@elements))

(define title-tag 'h1)
(define (title . elements)
  `(,title-tag ,@elements))

(define bigimage-tag 'div)
(define bigimage-class "bigimage")
(define (bigimage src)
  `(,bigimage-tag ((class ,bigimage-class)) (img ((src ,src)))))

(define extlink-class "ext")
(define (extlink url . texts)
  `(a ((href ,url)(class ,extlink-class)) ,@texts))  

(define (link url . texts)
  `(a ((href ,url)) ,@texts))

(define (gitlink repo . texts)
  `(span ((class ,code-class)) ,(apply link (format "http://github.com/~a" repo) texts)))

(define deflink-class "defined-term")
(define (deflink url . texts)
  `(span ((class ,deflink-class)) ,(apply extlink url texts)))

(define head-tag 'h2)
(define head-class "head")
(define (head . xs)
  `(,head-tag ((class ,head-class)) ,@xs))

(define subhead-tag 'h3)
(define subhead-class "subhead")
(define (subhead . xs)
  `(,subhead-tag ((class ,subhead-class)) ,@xs))

#| Works with latex.css to create theorem-like boxes. |#
(define (boxed #:class [class "theorem"] . xs)
  `(div ((class ,class)) ,@xs))

(define (lemma . xs) (apply boxed #:class "lemma" xs))
(define (theorem . xs) (apply boxed #:class "theorem" xs))
(define (definition . xs) (apply boxed #:class "definition" xs))

#|
`folded` is a nice example of how Pollen can make implementation of HTML constructs simpler, and also keep those details out of the source.

`folded` creates two elements on the page: 1) a div with arbitrary content in it that's initially hidden, and 2) a subhead above that can be clicked to show or hide the div.

Moreover, because `folded` is implemented in Racket rather than HTML, we can use a neat trick: the `gensym` function will assign a unique ID to the div we show/hide, no matter how many times we use `folded` on the page. This generated ID is then used as input to a JavaScript function (because JavaScript is the only way of messing with the page after it's loaded).
|#

(define foldable-class "foldable")

(define (foldable-subhead . xs)
  `(,subhead-tag ((class ,(string-join (list subhead-class foldable-class)))) ,@xs))

(define payload-tag 'div)
(define payload-class "payload")

(define (folded title #:open [open #f] . xs)
  (define openness (if open "block" "none"))
  (define div-name (symbol->string (gensym)))
  `(@
     ,(foldable-subhead `(a ((href ,(format "javascript:toggle_div('~a')" div-name))) ,title))
     (,payload-tag ((style ,(format "display:~a;" openness))(id ,div-name) (class ,payload-class)) ,@(detect-paragraphs xs #:force? #t))))

(define (folded-open title . xs)
  (apply folded title #:open #t xs))

(define filebox-tag 'div)
(define filebox-class "filebox")
(define filename-tag 'div)
(define filename-class "filename")
(define (filebox filename . xs)
  `(,filebox-tag ((class ,filebox-class)) (,filename-tag ((class ,filename-class) ,exclusion-mark-attr) ,(format "~a" filename)) ,@xs))

(define (filebox-highlight filename lang . xs)
  (filebox filename (apply highlight lang xs)))

#|
`docs` creates links into Racket’s online documentation. This is fiddly because it’s specific to that system.
|#

(define docs-class "docs")

(define (docs module-path export . xs-in)
  (define xref (load-collections-xref))
  (define linkname (if (null? xs-in) (list export) xs-in))
  (define tag (xref-binding->definition-tag xref (list module-path (->symbol export)) #f))
  (define-values (path url-tag) (xref-tag->path+anchor xref tag #:external-root-url "http://pkg-build.racket-lang.org/doc/"))
  `(a ((href ,(format "~a#~a" path url-tag)) (class ,docs-class)) ,@linkname))

(define item (default-tag-function 'li 'p))
(define helio (default-tag-function 'div #:class "force-helio"))

(define (easy-img cl src) `(img ((class ,cl)
                                 (src ,src))))

(define headshot (easy-img "headshot" "assets/img/mccoy8_circ.png"))

#|
quick-table produces an HTML table 
following Markdown syntax.
|#

(define (quick-table . tx-elements)
  (define rows-of-text-cells
    (let ([text-rows (filter-not whitespace? tx-elements)])
      (for/list ([text-row (in-list text-rows)])
        (for/list ([text-cell (in-list (string-split text-row "|"))])
          (string-trim text-cell)))))

  (match-define (list tr-tag td-tag th-tag) (map default-tag-function '(tr td th)))

  (define html-rows
    (match-let ([(cons header-row other-rows) rows-of-text-cells])
      (cons (map th-tag header-row)
            (for/list ([row (in-list other-rows)])
              (map td-tag row)))))

  (cons 'table (for/list ([html-row (in-list html-rows)])
                 (apply tr-tag html-row))))
