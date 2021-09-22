<div align="center">

<h1><code>pollen-slides</code></h1>

[Example slideshow -- the slideshow is a program!](https://femtomc.github.io/pollen-slides/index.html)
</div>

---

This is a convenient bundle of presentation capabilities built on top of (Markdown parsing to presentations) provided by [Remark.js](https://remarkjs.com/#1).

Everything is organized through [Pollen](https://docs.racket-lang.org/pollen/).

Provides a convenient meta-language including:

1. Compile custom LaTeX inline and embed them in the presentation.
2. Compile custom GraphViz graphs and embed them in the presentation.
3. Inline and equation rendering using MathJax.

These capabilities are provided using Racket + Pollen, see [the source folder](/src) and [pollen.rkt](pollen.rkt).

The Racket/Pollen expansion to `*.html` occurs before the Remark.js parser operates -- allowing programmable presentations built on top of Remark.

### Dependencies

```
racket
pollen
To use LaTeX Pollen markup -- a working LaTeX distro on PATH.
To use GraphViz Pollen markup -- a working GraphViz distro on PATH.
```

If you read the code, you'll see that custom markup rendering invokes `pdflatex`, or `dot` (for graphs, for example). These commands basically require access to the binaries.

If you'd like to include your own custom rendering for other software, you might follow the `dot` example in `pollen/src`.

---

## Usage

The `pollen` sub-directory contains the configuration for Pollen, the Racket shims for LaTeX, MathJax, etc. When developing a slideshow, you'll develop in this directory -- by modifying `index.html.pm`. Pollen will expand this file to `index.html`.

To support interactive development, use `raco pollen start` in the `pollen` sub-directory. This will start a local webserver which can be used to view your presentation.

Using the `build.sh` script is a convenient way to build a new project, moving the finishing static HTML slideshow into the `/docs` sub-directory.

The repo uses the `/docs` sub-directory to host an example.

---

**Note**: the fonts are not free! Please see [Matthew Butterick's typography](https://mbtype.com/).

**Note**: Ignore the Languages content representation on GitHub -- it doesn't know how to handle Pollen markup.

---

<div align="center">
  <sub>
  <a href="https://femtomc.github.io/">
  Built with ❤️ by <strong>femtomc</strong>
  </a>
  </sub>
</div>
