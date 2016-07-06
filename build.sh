#!/bin/bash 

ocamlfind ocamlopt -c -package cil,cmdliner stubGen.ml
ocamlfind ocamlopt -o main.exe -linkpkg -package cil,cmdliner stubGen.cmx -g main.ml
ocamlfind ocamlc -o test.exe -package oUnit -package cmdliner -package cil -linkpkg -g stubGen.ml test_stubGen.ml
