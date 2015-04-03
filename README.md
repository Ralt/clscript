# clscript

An ambitious project to make an ANSI Common Lisp standard
implementation that will compile to JavaScript.


## Implementation

Parses the Lisp code, uses sb-cltl2:macroexpand-all to get down to the
most basic forms, then use a hook system to have each basic form
implement a lisp-to-js transpiler.
