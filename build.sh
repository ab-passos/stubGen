#!/bin/bash 

ocamlfind ocamlopt -c -package cil,cmdliner stubGen.ml

if [ $? -eq 0 ]
then 
	ocamlfind ocamlopt -o main.exe -linkpkg -package cil,cmdliner stubGen.cmx -g main.ml
else
	echo "Failed to build stubGen.ml"
fi

if [ $? -eq 0 ]
then 
    echo "Successfully build main.exe for stubGen"
	ocamlfind ocamlc -o test.exe -package cmdliner,cil,kaputt -linkpkg -g stubGen.ml test_stubGen.ml
else
	echo "Failed to build main"
fi

if [ $? -eq 0 ]
then
	echo "Successfully build test.exe for testing"
else
	echo "Failed to build tests"
fi