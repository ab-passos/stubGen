#!/bin/bash 

ocamlopt -c -I /Users/andrepassos/.opam/system/lib/cil/ -I /Users/andrepassos/.opam/system/lib/cmdliner/ stubGen.ml
ocamlopt -ccopt -L/Users/andrepassos/.opam/system/lib/cil/ -o main unix.cmxa str.cmxa nums.cmxa /Users/andrepassos/.opam/system/lib/cil/cil.cmxa /Users/andrepassos/.opam/system/lib/cmdliner/cmdliner.cmxa stubGen.cmx


#ocamlopt -c -I /Users/andrepassos/.opam/system/lib/cmdliner/ rm.ml
#ocamlopt -o rmml unix.cmxa str.cmxa nums.cmxa /Users/andrepassos/.opam/system/lib/cmdliner/cmdliner.cmxa rm.cmx