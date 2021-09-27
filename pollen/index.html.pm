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
.twenty[## Agenda
]
.sixty[
______

1. Probabilistic programming - all about measures

2. Context: Simply typed lambda calculi, Cartesian closedness, etc

3. What does a "higher-order" language with measures look like?

4. What does verification look like here?

5. Why is this useful?

◊${\rightarrow} The goal is not to prove everything rigorously - but to support your own understanding of the story (and encourage your own exploration).

______

◊img[#:style "display:block;margin-left:auto;margin-right:auto;max-width:350px;" #:src "assets/img/buzz_measures.jpg"]

]]

---

.cols[
.thirty[
## Bayesian inference
]

.sixty[
______


◊$${
\ P(A | B) = \frac{\underbrace{P(B | A)}_{\text{likelihood}} \ \underbrace{P(A)}_{\text{prior}}}{\underbrace{P(B)}_{\text{evidence}}} \ \text{(Bayes' Theorem)}
}

______

]
]

A sentient being starts out with a distribution ◊${P(A)} over quantities in the world ◊${A}. 

These quantities may be correlated with other quantities ◊${B} - this is communicated by the likelihood ◊${P(B | A)}. 

When observing an instance of ◊${B}, the correlation should allow us to update our beliefs about the possibilities for ◊${A}.

◊$${\rightarrow \underbrace{P(A | B)}_{\text{posterior}}}

This is the fundamental process of Bayesian inference. 

______


To formalize this process using mathematics, we must turn to measure theory - because distributions are measures, and a conditional distribution ◊${P(A | B)} is a measure theoretic object called a [Radon-Nikodym derivative](https://en.wikipedia.org/wiki/Radon%E2%80%93Nikodym_theorem).

---

## Probabilistic programming

◊${\rightarrow} Understanding computable representions of operations on measures.

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

.cols[
.fifty[
◊dot{
rankdir=LR;
label="Can you write the CPD?"
A[label="is outlier"];
B[label="y"];
A -> B;
}
]
.fifty[
How do we handle the fact that the likelihood _is a program_?
]
]

---

## Background

Denotational semantics of probabilistic programming languages has been a hot topic (small selection) recently:

1. [Denotational Validation of Higher-Order Bayesian Inference](https://arxiv.org/pdf/1711.03219.pdf)

2. [Trace types and denotational semantics for sound programmable inference in probabilistic languages](https://dl.acm.org/doi/10.1145/3371087)

3. [A Convenient Category for Higher-Order Probability Theory](https://arxiv.org/pdf/1701.02547.pdf)

______

.cols[
.thirty[
<center><h4>Key question (?)</h4></center>
]
.sixty[
What does "higher-order" mean in the context of programs which denote measures and operations on measures?
]
]

______

---

.cols[
.thirty[
## Cats 
]
.sixty[

______

Unavoidable: we need a bit of _category theory_ for this discussion.

◊dot{
label="A category?";
rankdir=LR;
A -> A;
A -> B;
A -> C;
B -> A;
B -> B;
B -> C;
C -> A;
C -> B;
C -> C;
}

______
]
]

Informal: a _category_ is a collection of objects with arrows between them. The arrows satisfy nice properties:

1. If an arrow goes into another arrow, the composite arrow is in the category.
2. Arrows are fully associative.
3. Each object has an identity arrow.

______

In an attempt to reach a state of child-like wonder, math/CS people draw diagrams and say "hmm, does this pattern exist in _insert mathematical space_?"

Such a pattern is typically called a _universal construction_.

---

Generally, computer scientists concern themselves with _Cartesian closed categories_.

We typically like to think that our programs denote objects + transformations in some mathematical space. This gets tricky when the transformations themselves can be objects.

______


.cols[
.thirty[
### Cartesian closed categories
]
.sixty[
_Cartesian closedness_ is a property of categories.

The technical definition is:

1. Must contain the terminal object.
2. Must contain a product object for any pair of objects.
3. **Must contain an exponential for any pair of objects**.
]
]

______

If a category has this property, it can be used to model (denotationally) higher-order semantics of programming languages.

In a moment, we'll understand this intuitively.

◊${\rightarrow} Further: [(John Baez) CCCs and the ◊${\lambda}-calculus](https://golem.ph.utexas.edu/category/2006/08/cartesian_closed_categories_an_1.html)

---

______

.cols[
.thirty[
<center><h4>Internal languages</h4></center>
◊; The dot command allows usage of the dot graph language inline.
◊dot{
ep[label="Category theory"];
en[label="Lambda calculi"]
ep->en;
en->ep;
}
]
.sixty[
A key concept is the notion of _internal language_ (or _internal logic_) of a category. For `Set` (and, more generally, for any _Cartesian closed category_) - there exist simply typed lambda calculi which model the category.

When used in this context, these calculi are colloquially called internal languages.

Also: [internal logic in nLab](https://ncatlab.org/nlab/show/internal+logic)
]]

______

Consider that `Set` has a natural notion of product and co-product. Imagine what the simply typed lambda calculi equivalent would be (think about the types)?

◊; Of course, Remark.js has nice code highlighting.
```haskell
data Type = BaseType | (Type, Type) | Type + Type | Type -> Type
```

.cols[
.fifty[
◊dot{
rankdir=LR;
label="Product";
cp -> a [label="p'"];
cp -> c [label="m"];
cp -> b [label="q'"];
c -> a [label="p"];
c -> b [label="q"];
}
]
.fifty[
◊dot{
rankdir=LR;
label="Coproduct";
a -> c;
b -> c;
c -> cp;
a -> cp;
b -> cp;
}
]
]

--- 

What about the "function type" `Type -> Type`?

------

.cols[
.fifty[
◊dot{
rankdir=LR;
A -> B;
}
]
.fifty[
In category theory, a mapping between two objects is called a _morphism_.
]
]

Categories are closed under composition of morphisms, and:
1. All morphisms are fully associative.
2. For each object in the category, there is an identity morphism.

______

Thinking in types: (informally) morphisms are sort of like _an instance_ of a function type `A -> B`. 

In `Set`, for example, there are many ways to fill the type `Int -> Int` with a total function. Each such total function is a morphism from the object `Int` to `Int`.

Ergo, a function type `A -> B` is actually _a set of morphisms_ - compactly called the `HomSet(A, B)`.

______

<center style="margin-top:2rem;">Of course, shouldn't a function type be an object in <code>Set</code>? Yes, dear reader!</center>

---

What defines a function? Category theory: application!

______

.cols[
.thirty[
#### Function object
]
.sixty[
Ingredients for a _function object_ from `A` to `B`:

1. An object (which we'll call) `A => B`.
2. A morphism `eval :: (A => B) x A -> B`.

3. For any object `Z` with morphism `g :: Z x A -> B`, a unique morphism `h :: Z -> (A => B)` that factors `g` through `eval`:

<center>◊${g = \text{eval} \ \circ (\text{h} \times id)}</center>

]
]

______

Remember: the way to think about this sort of construction is as a pattern which may or may not "match" to the category in question.

◊${\rightarrow} **It's not important to fully understand this now.**

More important: understanding that there's a way to identify categories with this object, and, even more important, a way to identify when a category contains this object as a base object in the category.

---

## Back to higher-order probability

______

So, because formalization of probability theory have traditionally used `Meas` - we'd really like to use `Meas` to model higher-order probability.

But `Meas` is not Cartesian closed.

The intuition here is that the set of measurable functions from measurable A to measurable B cannot be given a measurable structure. 

1. In other words, function object in `Meas` is external to `Meas`. 

2. In the simply typed lambda calculus description, this means we can't denote the function type `Measurable A -> Measurable B` as the function object.

______

<h4><center style="margin-top:2rem;margin-bottom:2rem;">Bad: we can't reason formally about programs.</center></h4>

______

We like formal reasoning -- it gives us confidence that our manipulations are correct by math.

---

## Summary

The key is: `Meas` is not Cartesian closed, so (as computer scientists) we are unable to develop a simple typed lambda calculi representation of `Meas` as a means of formalizing higher-order probabilistic languages.

* The full proof: [Borel Structures for Function Spaces](https://projecteuclid.org/journals/illinois-journal-of-mathematics/volume-5/issue-4/Borel-structures-for-function-spaces/10.1215/ijm/1255631584.full)

______

* Let's find a Cartesian closed category which has suitable properties to represent higher-order languages with measures.

1. Unambiguously denote function types and higher-order functions.
2. Theorems we prove in the category apply to programs which denote manipulations of the categorical objects.

______

The approach taken by the previously listed papers is to study the category of _quasi-Borel spaces_ - a category recently introduced in 2017.

* [A Convenient Category for Higher-Order Probability Theory](https://arxiv.org/abs/1701.02547)
* [The semantic structure of quasi-Borel spaces](https://pps2018.luddy.indiana.edu/files/2018/01/pps18-qbs-semantic-structure.pdf)

---

.cols[
.fifty[
#### Classical probability

1. We fix a measurable space ◊${(\Omega, \Sigma_\Omega)} as the primitive sample space.

2. Observations derive from pairs ◊${(X, f)} where ◊${X} is a measurable space with sigma algebra ◊${(X, \Sigma_X)} and ◊${f} is measurable ◊${f: \Omega \rightarrow X}.

Note: `f` is measurable if the pre-image of any set in `X` is measurable.
]
.fifty[
#### Example

1. ```haskell
m :: Set{Bool x Bool} -> R
m {} = 0.0
m {(T, _)} = 0.2
m {(F, _)} = 0.3
```
Derive the measure by `M = sum $ map m col` over collections of sets.

2.  ```haskell
f :: Bool x Bool -> Bool
f a b = a || b
```

]
]

______

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


---

______

> In this paper, we take a step further and we develop a set of program logics, named PPV, for proving properties of programs written in an expressive probabilistic higher-order language with continuous distributions and operators for conditioning distributions by real-valued functions.

______

From this contribution statement, we should essentially be expecting two things:

1. A simply typed lambda calculus (STLC) whose denotational semantics are given by the category of quasi-Borel spaces `QBS`. This will be the base language.

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

---

The language `HPPROG` is a typed lambda calculus with products, pattern matching, recursive function definitions, and monadic binding.

1. `Product -> <Term ,Term>`
2. `Pattern matching -> case Term with [match(i, x_i) => Term] over i`
3. `Recursive function definitions -> letrec f x = Term`
4. `Monadic bind -> bind Term term` with monadic type `M[T]`

______

◊div[#:class "definition" #:text "Monadic type"]{
A monad is a functor from a category <code>X</code> to a category <code>Y</code>.
}

______

* Handling probability with a monadic type `M[T]` is relatively standard, see: [monads of probability, measures, and valuations](https://ncatlab.org/nlab/show/monads+of+probability%2C+measures%2C+and+valuations) and [the Giry monad](https://ncatlab.org/nlab/show/Giry+monad).
* The QBS paper develops generalizations of the Giry monad to represent the monadic `X -> QBS(X)`.
