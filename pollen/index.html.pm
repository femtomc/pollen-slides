#lang pollen

◊(define-meta template "template.html")

◊; Here's where the slide syntax starts.

class: center, middle

### Formal verification of higher-order probabilistic programs

◊; Pollen supports insertion of raw HTML elements using the lozenge ◊.
◊img[#:style "display:block;margin-left:auto;margin-right:auto;max-width:300px;" #:src "assets/img/bayes_cartoon.png"]

#### Presented by: McCoy!

◊; --- is a separator which indicates a new slide should begin.
---

◊; This is a small Remark.js feature -- you can use . syntax to specify blocks.
◊; So below is a convenient hack to put in columns.
.cols[
.twenty[## Agenda]
.eighty[
◊img[#:style "display:block;margin-left:auto;margin-right:auto;max-width:300px;" #:src "assets/img/buzz_measures.jpg"]

1. Probabilistic programming - all about measures

2. Context: Simply typed lambda calculi, Cartesian closedness, etc

3. What does a "higher-order" language with measures look like?

4. Return to paper - the story

5. Why is this useful?

* The goal is not to prove everything rigorously - but to support your own understanding of the story (and encourage your own exploration).

]]

---

## Probabilistic programming

* Understanding computable representions of operations on measures.

______

.cols[
.twenty[
One example representation: Gen's generative function interface
]
.eighty[

◊; Here's a fun command -- you can write raw LaTeX and the system
◊; will invoke pdflatex to compile to .png and embed.

◊latex[#:caption "A generative function."]{
◊document-class{preview}
\usepackage[outputdir=latex]{minted}
\begin{document}
\begin{minted}{julia}
@gen function generate_datum(x, prob_outlier, noise, (grad)(slope),
            (grad)(intercept))::Float64
    if @trace(bernoulli(prob_outlier), :is_outlier)
        (mu, std) = (0., 10.)
    else
        (mu, std) = (x * slope + intercept, noise)
    end
    return @trace(normal(mu, std), :y)
end
\end{minted}
\end{document}
}]]

◊; ______ indicates a horizontal line break - can use any number > 3 of _.
______

A _generative function_ is a type of computational object which supports a well-defined interface.

---

## Background

Denotational semantics of probabilistic programming languages has been a hot topic (small selection) recently:

1. [Denotational Validation of Higher-Order Bayesian Inference](https://arxiv.org/pdf/1711.03219.pdf)

2. [Trace types and denotational semantics for sound programmable inference in probabilistic languages](https://dl.acm.org/doi/10.1145/3371087)

3. [A Convenient Category for Higher-Order Probability Theory](https://arxiv.org/pdf/1701.02547.pdf)

I think the key insight driving this interest is the fact that the category of measures `Meas` _is not Cartesian closed_! 

Without proof, the basic fact is that the set of measurable functions from sets A to B with measurable structure cannot be given a measurable structure. In other words, the set of measurable functions from A to B is not an object in `Meas`.

---

Compare this to `Set` - the typical category for higher-order functional programming.

* `Set` is Cartesian closed - the set of functions from A to B is also an object in `Set`.

______

.cols[
.thirty[
◊; The dot command allows usage of the dot graph language inline.
◊dot{
ep[label="Category theory"];
en[label="Lambda calculi"]
ep->en;
en->ep;
}
]
.sixty[
A key concept here is the notion of "internal language" of a category. For `Set` (and, more generally, for any _Cartesian closed category_) - there's a simply typed lambda calculus which models the category, this calculus is called the internal language.
]]

______

Just to convince yourself of this, consider that `Set` has a natural notion of product and co-product. Imagine what the simply typed lambda calculi equivalent would be?

◊; Of course, Remark.js has nice code highlighting.
```haskell
data Type = Float | Int | (Type, Type) | Type + Type | Type -> Type
```

--- 

## Summary of affairs

The key is: `Meas` is not Cartesian closed, so (as computer scientists) we are unable a simple typed lambda calculi representation of `Meas` as a means of formalizing higher-order probabilistic languages.

* Now, a natural solution presents itself: let's find a Cartesian closed category which has suitable properties to represent higher-order languages with measures.

______

The approach taken by the previously listed papers is to study the category of _quasi-Borel spaces_ - a category recently introduced in 2017.

* [A Convenient Category for Higher-Order Probability Theory](https://arxiv.org/abs/1701.02547)
* [The semantic structure of quasi-Borel spaces](https://pps2018.luddy.indiana.edu/files/2018/01/pps18-qbs-semantic-structure.pdf)

---

◊; Below, we see usage of the MathJax syntax -- a single $ indicates
◊; inline math.
◊; By far I think this is the messiest part of the slide deck - would be good
◊; to abstract.
◊div[#:class "definition" #:text "quasi-Borel space"]{
A quasi-Borel space ◊${X} consists of an underlying set ◊${X} and a set of functions ◊${M_X \subseteq (\mathbb{R} \rightarrow X)} satisfying:

◊; Again, here I'm inserting raw HTML - an <ol> followed by <li>s.
◊ol{
    ◊li{◊${M_X} contains all constant functions.}

    ◊li{◊${M_X} is closed under composition with measurable functions. So if ◊${f : \mathbb{R} \rightarrow \mathbb{R}} is measurable and ◊${\alpha \in M_X}, then ◊${\alpha \circ f \in M_X}.}

    ◊li{◊${M_X} is closed under defining piecewise functions using functions on disjoint Borel domains. 

    So, for any partition of ◊${\mathbb{R} = \cup_{i\in\mathbb{N}} S_i} with ◊${S_i} Borel, and ◊${\{\alpha_i \in M_X\}_{i\in\mathbb{N}^\prime}}, then the piecewise function ◊${\beta(x) = \alpha_i(x)} when ◊${x \in S_i} is in the space ◊${M_X}.}
    }
}

______

---

> In this paper, we take a step further and we develop a set of program logics, named PPV, for proving properties of programs written in an expressive probabilistic higher-order language with continuous distributions and operators for conditioning distributions by real-valued functions.

______

From this contribution statement, we should essentially be expecting two things:

1. A simply typed lambda calculus (STLC) whose denotational semantics are given by a quasi-Borel space. This will be the base language.

2. A logic which quantizes over expressions in the STLC. This will be the system which reasons about programs in the base language.

---

◊; This is a special div I setup for definitions.
◊; Should likely be put into its own lozenge syntax.
◊div[#:class "definition" #:text "HPPROG"]{A higher-order language for probabilistic programming.}

```haskell
-- A set of basic types + kinds.
data BT = Unit | Bool | Nat | Real | PosReal | BT x BT | List(BT)

-- A set of types + kinds.
data T = BT | M[T] | T -> T | T x T | List(T)

-- A set of terms.
data Term =   -- Variables, builtins, and application.
                x | c | f | Term Term

              | <Term, Term> -- A product constructor.
              | Project(i, Term) -- Record type field projection.
              
              -- Pattern matching.
              | case Term with [match(i, x_i) => Term] over i

              -- Recursive function definitions.
              | letrec f x = Term

              | return Term | bind Term Term -- Monadic return + bind.
              
              -- Query computes a posterior from a prior + likelihood.
              | query Term => Term

              -- Primitives representing basic distributions.
              | Uniform(Term, Term) | Bern(Term) | Gauss(Term, Term)
```
