#lang pollen

◊; A simple vertical line element.
.vl {
  border-left: 2px solid black;
  margin-top:2rem;
  margin-right:3rem;
  height: 15rem;
}

blockquote {
    font-style: italic;
}

◊; Basically, to allow for multi-column slides.
.cols {
    display: flex;
}

.thirty {
    flex:30%;
}

.fourty {
    flex:40%;
}

.fifty {
    flex: 50%;
}

.sixty {
    flex:60%;
}

figure.latex {
    display: inline-block;
}

img.dot {
    display: block;
    margin-left:auto;
    margin-right:auto;
    vertical-align: top;
    max-height: 130px;
    max-width:200px;
}

img.latex {
    vertical-align: top;
    max-width: 100%;
}

figcaption.latex {
    text-align: center;
    font-style: italic;
    font-size: 16px;
    margin-top:0.5rem;
    margin-bottom:0.5rem;
}

.remark-slide-content {
    font-size: 19px;
}

.remark-code { 
    font-family: julia_mono; 
    font-size: 17px;
    background: #F0F0F0;
}

.remark-inline-code { 
    font-family: julia_mono; 
    font-size: 17px;
    background: #F0F0F0;
}

body { 
    font-family: 'Droid Serif'; 
}

h1, h2, h3 {
    font-family: 'Yanone Kaffeesatz';
    font-weight: normal;
}

ol {
    margin-left:3rem;
    max-width: 80%;
}

li::marker {
    font-family: concourse_index;
    font-style: normal;
}

li {
    margin-top: 0.7rem;
}

.theorem {
    display: block;
    font-style: italic;
}

.theorem:before {
    content: "Theorem. ";
    font-weight: bold;
    font-style: normal;
}

.theorem[text]:before {
    content: "Theorem (" attr(text) ") ";
}

.definition {
    display: block;
    font-style: italic;
}

.definition:before {
    content: "Definition. ";
    font-weight: bold;
    font-style: normal;
}

.definition[text]:before {
    content: "Definition (" attr(text) ") ";
}

