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

## Motivation

**Why do we care about verification of probabilistic programs (let alone higher-order ones) at all?**

______

* Modeling and inference _is hard_ - why make it harder by allowing unsound semantics when we can afford to check?

◊img[#:style "display:block;margin-left:auto;margin-right:auto;max-width:450px;" #:src "assets/img/ttmotivation.png"]

---

* Think: tensor shape checkers for neural network specification languages (think: PyTorch, TensorFlow, Dex, etc) - what is the equivalent for probabilistic programming?

.cols[
.fifty[
◊img[#:style "display:block;margin-left:auto;margin-right:auto;max-width:300px;" #:src "assets/img/autostat.png"]
]
.fifty[
1. ***How can we be sure the automatic statistician is correct?***

2. ***What if it uses provably invalid inference algorithms?***

3. ***Would you trust an AI system without provably correct inference?***
]
]

______

* How can you be sure a static tool works for all programs without a proof?
    * Map your language to a denotational space (a mathematical space) - map transformations described by your language to reasoning principles in the denotational space.

** An (unfortunate) theme: difficult-to-describe features (automatic differentiation, probabilistic programming) map to somewhat complex categories (differentiable manifolds, quasi-Borel spaces).**

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

* The goal is not to prove everything rigorously - but to support your own understanding of the story (and encourage your own exploration).

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

Roughly, how do I sample, evaluate density at a point, get gradients with respect to parameters, and gradients with respect to density.

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

.cols[
.fifty[
◊img[#:style "display:block;margin-left:auto;margin-right:auto;max-width:300px;" #:src "assets/img/anglican_linreg.png"]
]
.fifty[
<br>

`f` denotes a measure over functions ... _what does that even mean?_
]
]

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
{rank="same"; A -> B;
B -> A;}
A -> C;
B -> B;
B -> C;
C -> A;
C -> B;
C -> C;
}

______
]
]

Informal: a _category_ is a collection of objects with arrows (called _morphisms_) between them. The arrows satisfy nice properties:

1. If an arrow goes into another arrow, the composite arrow is in the category.
2. Arrows are fully associative.
3. Each object has an identity arrow.

______

In an attempt to reach a state of child-like wonder, math/CS people draw diagrams and say "hmm, does this pattern exist in _insert mathematical space_?"

Such a pattern is typically called a _universal construction_.

---

Let's look at an example of a _universal construction_.

______

.cols[
.fifty[
### Initial object

An object `I` in a category `C` so that, for every object `X` in `C`, there is exactly one morphism `I -> X`.
]

.fifty[
### Terminal object

An object `I` in a category `C` so that, for every object `X` in `C`, there is exactly one morphism `X -> I`.
]
]

______

Let's consider the category of sets `Set`:

1. Terminal objects are any singleton set `Unit` with lone element `T`.
    * For every set `S`, there is exactly one morphism (in `Set`, one function) which maps a set to `Unit`.
    * Unique (up to isomorphism) -- because any singleton is isomorphic to any other.

2. The initial object is the empty set `{}`.
    * Why? Think about functions (again, because we are in `Set`!) as choosing subsets of Cartesian product of two sets.
    * The empty set is the only initial object in `Set`.

---

Generally, computer scientists concern themselves with _Cartesian closed categories_.

We typically like to think that our programs denote objects + transformations in some mathematical space. One might ask: how do we model function application?

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

If a category has this property, it can be used to model (denotationally) function application in programming languages.

In a moment, we'll understand this intuitively.

* Further: [(John Baez) CCCs and the ◊${\lambda}-calculus](https://golem.ph.utexas.edu/category/2006/08/cartesian_closed_categories_an_1.html)

---

______

.cols[
.thirty[
<center><h4>Internal languages</h4></center>
◊; The dot command allows usage of the dot graph language inline.
◊dot{
ep[label="Category theory"];
en[label="STLC"]
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
a -> c[label="p"];
b -> c[label="q"];
c -> cp[label="m"];
a -> cp[label="p'"];
b -> cp[label="q'"];
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
#### Morphisms
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

* **It's not important to fully understand this now.**

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

The key to understanding quasi-Borel spaces is to understand the role that ◊${\sigma}-algebras play in measure theory.

______

1. When you select a ◊${\sigma}-algebra - it is equivalent to selecting "predicates" which you can ask the probability of. If you try to ask a question "what is the probability of this event occurring" and it is not in the selected ◊${\sigma}-algebra - the predicate cannot be answered (the set is not measurable).

2. How do you assign a ◊${\sigma}-algebra to the set denoted by function type `X -> Y`? There is no ◊${\sigma}-algebra on `X -> Y` which makes function application measurable (where `apply :: (X, X -> Y) -> Y`).

______

To avoid this problem, the quasi-Borel proposal is: 

1. Let's avoid talking about ◊${\sigma}-algebras on our space `X`, and instead talk about "admissible random elements" from a well-behaved measure space ◊${\mathbb{R}} to our space. 

2. These functions are now like the predicates above -- a deterministic function on `X` is measurable _iff_ composing it with an admissible random element yields another admissible random element.

---

______

> In this paper, we take a step further and we develop a set of program logics, named PPV, for proving properties of programs written in an expressive probabilistic higher-order language with continuous distributions and operators for conditioning distributions by real-valued functions.

______

From this contribution statement, we should essentially be expecting two things:

1. A simply typed lambda calculus (STLC) whose denotational semantics are given by the category of quasi-Borel spaces `QBS`. This will be the base language.
    * `QBS` supports product objects, function objects, and is Cartesian closed - so it is "`Set`-like" and supports denotational reasoning about higher-order functions!
    * There's also a functor from the category `Meas` to `QBS`. See [A Convenient Category for Higher-Order Probability Theory](https://arxiv.org/pdf/1701.02547.pdf) (1.A)

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
data Expr =   -- Variables, builtins, and application.
                x | c | f | Expr Expr

              | <Expr, Expr> -- A product constructor.
              | Project(i, Expr) -- Product destructor.
              
              -- Pattern matching.
              | case Expr with [match(i, x_i) => Expr] over i

              -- Recursive function definitions.
              | letrec f x = Expr

              | return Expr | bind Expr Expr -- Monadic return + bind.
              
              -- Query computes a posterior from a prior + likelihood.
              | query Expr => Expr

              -- Primitives representing basic distributions.
              | Uniform(Expr, Expr) | Bern(Expr) | Gauss(Expr, Expr)
```

---

The language `HPPROG` is a typed lambda calculus with products, pattern matching, recursive function definitions, and monadic lifting/binding as well as conditioning.

1. `Product -> <Expr ,Expr>`
2. `Pattern matching -> case Expr with [match(i, x_i) => Expr] over i`
3. `Recursive function definitions -> letrec f x = Expr`
3. `Monadic lift -> return Expr` with monadic type `M[T]`.
4. `Monadic bind -> bind Expr Expr` with monadic type `M[T]`
5. `Query -> query Expr Expr` with resultant monadic type `M[T]`.

______

.cols[
.thirty[
<h4><center>Monadic bind</center></h4>
◊dot{
node [ shape="circle", style="bold, filled", fillcolor="#dddddd" ];
A -> B [label="(>>=)"];
B -> C [constraint="false", label="(>>=)"];
{rank="same";C->D[label="(>>=)"];}
}
]
.sixty[
The monadic bind operation chains together computations in the monadic context.

```haskell
-- Here, 'M' is the monad.
(>>=) :: M a -> (a -> M b) -> M b
```
]
]

______

* Handling measures with a monadic type `M[T]` is relatively standard, see: [monads of probability, measures, and valuations](https://ncatlab.org/nlab/show/monads+of+probability%2C+measures%2C+and+valuations) and [the Giry monad](https://ncatlab.org/nlab/show/Giry+monad).

---

Monadic bind (and `return`ing an inhabitant of `T` to the monadic type `M[T]`) is key to understanding how the language can support the denotational interpretation in the category `QBS`.

______

A set (also: a type `T` which indicates a set) requires _more structure_ to support measurability. In classical probability, this "more structure" is:

1. A ◊${\sigma}-algebra (see: ◊${\Sigma_\Omega} from prev. example).
2. A measure (see: ◊${M}) - e.g. a mapping from the algebra to positive extended reals which takes `{} -> 0` and is countably additive.

One way to understand the usage of monads here is allowing us to talk about computations which automatically include this "extra" structure on top of sets.

______

.cols[
.thirty[
#### Example
]

.sixty[
```haskell
f :: a -> Maybe b
g :: Maybe a
c :: Maybe b = (>==) g f
```
]]

In the monadic interpretation, a monad `M` allows programmatically specifying "computational effects" which are richer than the base types (e.g. sets) allow.

E.g. in the `Maybe` monad, the process is: map a computation over type `T` to a computation `Maybe T` which indicates that the computation may fail to return anything at all.

---

◊div[#:class "definition" #:text "PL"]{A logic for probabilistic programs.}

```haskell
-- A.k.a. terms.
data EnrE = Expr 
          | E(x, EnrE, Expr(x)) 
          | scale(EnrE, EnrE)
          | normalize(EnrE)

-- A.k.a formula.
data LogF = (EnrE = EnrE) 
          | (EnrE < EnrE)
          | Top
          | Btm
          | LogF & LogF
          | LogF => LogF
          | not LogF
          | Forall(x, T, LogF)
          | Exists(x, T, LogF)
```

---

Let's quickly look at the extended typing rules for enriched expressions.

.cols[
.fifty[
◊img[#:style "display:block;margin-left:auto;margin-right:auto;max-width:300px;" #:src "assets/img/typing_expect.png"]
<br>

◊img[#:style "display:block;margin-left:auto;margin-right:auto;max-width:300px;" #:src "assets/img/typing_scale.png"]
<br>

◊img[#:style "display:block;margin-left:auto;margin-right:auto;max-width:300px;" #:src "assets/img/typing_normalize.png"]
]

.fifty[
1. Integrating an always positive measurable function with a measure always yields a positive ◊${\mathbb{R}} number.
2. Scaling a measure by an always positive measurable function yields a measure.
3. Normalizing a measure converts it into a probability measure (which is still a measure).
]]

______

I'm using "measure" above loosely - the denotation of `M[T]` means that this is a quasi-Borel measure: an equivalence class of admissible random elements.

This fact is irrelevant to the typing - because these theorems also hold in QBS.

---

We can also quickly look at the selection of proof rules:

______

◊img[#:style "display:block;margin-left:auto;margin-right:auto;max-width:700px;" #:src "assets/img/pl_proof_rules.png"]

______

(From top-left, clockwise)

1. (?) This honestly confused me. I think this is showing that two terms are equivalent after reduction - we can conclude they are equivalent and add that to the precondition context

2. Proving that a term `t = u` implies that we can swap it in substitution for a formula ◊${\phi}.

3. If we have ◊${\psi => \phi} in the precondition, and we also have ◊${\psi}, we can conclude that we have ◊${\phi}. This is using an implication.

4. This rule allows us to add an implication.

5. This rule is a rule about axioms.

---

There's a large section where the authors essentially re-state many theorems of classical probability using the constructs of `PL`:

◊img[#:style "display:block;margin-left:auto;margin-right:auto;max-width:450px;" #:src "assets/img/prob_axioms.png"]

---

.cols[
.fifty[
#### Unary
]
.fifty[
#### Relational
]
]

______

One really nice thing: the pure/probabilistic constructions separate over the monadic constructs!

.cols[
.fifty[
◊img[#:style "display:block;margin-left:auto;margin-right:auto;max-width:400px;" #:src "assets/img/upl_rules.png"]

At a high level, the unary logic `UPL` allows singular judgements about a well-typed expression `e : T`. The relational logic deals with judgements on pairs of well-typed `HPProg` expressions.
]

.fifty[
◊img[#:style "display:block;margin-left:auto;margin-right:auto;max-width:400px;" #:src "assets/img/rpl_rules.png"]
]
]

---

#### Strengths

______

1. A nice example of a logic which allows reasoning over a language with higher-order functions and probabilistic conditioning (on real and discrete) random variables!

2. Logic rules nicely separate across monad.

3. Logic subsystems are modular. The UPL is designed to handle judgements of a certain type, similarly for the RPL.

4. Importantly -- it's a step in the right direction. More people should really be thinking about this in probabilistic programming.

---

#### Weaknesses

______

1. Base language is clunky -- you always have to setup a product variable and query via projections on that product. Hopefully this could be sugared up in some way. In short, it's not designed for writing complex, modular models.
2. I was unimpressed by the examples (with the exception of Lipschitz GVI verification), for a variety of reasons.
    * Slicing example is absolutely useless in practice. Unless the proof can be automated across different structured programs, it seems like an exercise in futility.
    * Gaussian mean learning is hardly a useful example to test a framework like this on. E.g. they coerce the program into higher-order form ... but it could easily be expressed without higher-order functions.
    * I actually did like the self-normalizing importance sampling example. I think it illustrated a principle which I would have liked to see more: relationaly judgements which are parametric over one of the expressions -- here, the result is a bound which depends on difference between empirical (e.g. sampled mean) and target (see [Chatterjee + Diaconis](https://projecteuclid.org/journals/annals-of-applied-probability/volume-28/issue-2/The-sample-size-required-in-importance-sampling/10.1214/17-AAP1326.full)).
