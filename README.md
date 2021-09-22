# Pollen-based presentation template

This is a convenient bundle of presentation capabilities built on top of (Markdown parsing to presentations) provided by [Remark.js](https://remarkjs.com/#1).

Everything is organized through [Pollen](https://docs.racket-lang.org/pollen/)

Provides a convenient meta-language including:

1. Compile custom LaTeX inline and embed them in the presentation.
2. Compile custom GraphViz graphs and embed them in the presentation.
3. Inline and equation rendering using MathJax.

These capabilities are provided using Racket + Pollen, see [the source folder](/src) and [pollen.rkt](pollen.rkt).

The Racket/Pollen expansion to `*.html` occurs before the Remark.js parser operates -- allowing programmable presentations built on top of Remark.

---

**Note**: the fonts are not free! Please see [Matthew Butterick's typography](https://mbtype.com/).
