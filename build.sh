#!/bin/bash 

ocamlopt -c -I /Users/andrepassos/.opam/system/lib/cil/ stubGen.ml
ocamlopt -ccopt -L/Users/andrepassos/.opam/system/lib/cil/ -o main unix.cmxa str.cmxa nums.cmxa /Users/andrepassos/.opam/system/lib/cil/cil.cmxa stubGen.cmx
