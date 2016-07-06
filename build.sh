#!/bin/bash 

ocamlfind ocamlopt -c -package cil,cmdliner stubGen.ml
ocamlfind ocamlopt -o main -linkpkg -package cil,cmdliner stubGen.cmx
ocamlfind ocamlc -o test -package oUnit -package cmdliner -package cil -linkpkg -g foo.ml stubGen.ml test_stubGen.ml
