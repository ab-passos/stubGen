open Cil
open Pretty
module E = Errormsg
module F = Frontc
module C = Cil

type functions = 
       NoFunction
    |  SomeFunction of string * typ * (string * typ * attributes) list option * bool * attributes ;;

let getFileNameWithoutExtension fileNameWithExtension =
	let substringSize = (String.length fileNameWithExtension) - 2 in
	String.sub fileNameWithExtension 0 substringSize
;;

let getFileNameWithoutPath cilFileNameWithPath = 
	let splitListWithPaths = Str.split (Str.regexp "/") cilFileNameWithPath.fileName in
	if List.length splitListWithPaths == 1 then 
		cilFileNameWithPath.fileName
	else
		List.hd (List.rev splitListWithPaths) ^ "\n"
;;

let isSystemFunction (str : string) = 
	let firstCharacter = String.get str 0 in
	let secondCharacter = String.get str 1 in
	if firstCharacter == '_' && secondCharacter == '_' 
	then true 
	else false;;

(*
let rec printType (t : typ) = 
	match t with
	| TVoid(_) ->  Printf.printf "Void\n"
	| TInt(_) -> Printf.printf "Int\n"
	| TFloat(_) -> Printf.printf "Float\n"
	| TPtr(_) -> Printf.printf "Ptr\n"
	| TArray(_) -> Printf.printf "Array\n"
	| TFun(returnType, argumentList, someBool, attr) -> printType returnType; Printf.printf "Function\n"
	| TNamed(_) -> Printf.printf "Function\n"
	| _ -> Printf.printf "Other\n";;


let rec giveFunctionsNames list =
	match list with
	| GVarDecl(v,l)::li -> if isSystemFunction v.vname == false then
								begin 
								Printf.printf "%s\n" v.vname;
								printType v.vtype;
								giveFunctionsNames li
								end
							else
								giveFunctionsNames li
	| _::li -> giveFunctionsNames li
	| [] -> Printf.printf "END\n"
;;
*)

let rec printDefaultType returnType = 
	match returnType with
	| TVoid(_) -> "//void"
	| TInt(_) -> "return 0;"
	| TFloat(_) -> "return 0.0;"
    | TNamed(typeinfo,_) -> printDefaultType typeinfo.ttype
    | TPtr(t, _) -> "return 0;"
	| _ -> ""
;;

let rec printType (t : typ) = 
	match t with
	| TVoid(_) -> "void"
	| TInt(_) -> "int"
	| TFloat(_) -> "float"
	| TNamed(typeinfo,_) -> typeinfo.tname
	| TPtr(t, _) -> printType t ^ "*"
	| _ -> ""
;;

(*
typedef ASML_result *cb_KVXA_remove_scan_from_buffer_t)(int scan_id)
*)

let rec printArgumentList list =
	match list with
	| (s, t, a) :: [] -> printType t ^ " " ^ s
	| (s, t, a) :: li -> printType t ^ " " ^ s ^ ", " ^ printArgumentList li
	| [] -> ""
;;

let rec printArgumentVariablesList list =
	match list with
	| (s, t, a) :: [] -> s
	| (s, t, a) :: li -> s ^ ", " ^ printArgumentVariablesList li
	| [] -> ""
;;

let hasArguments arg =
	match arg with
	| None -> ""
	| Some l -> printArgumentList l
;;

let printArgumentVariables arg =
	match arg with
	| None -> ""
	| Some l -> printArgumentVariablesList l
;;

let printCallbackType functionName = "cb_" ^ functionName ^ "_t";;

let rec printFunctionSignature list =
	match list with
	| SomeFunction (functionName, returnType, argumentList, someBool, attr) :: li -> 
					"typedef " ^ printType returnType ^ " (*" ^ printCallbackType  functionName ^ ")(" ^ hasArguments argumentList ^ ");\n" ^ 
					printFunctionSignature li   
	| NoFunction :: li -> printFunctionSignature li
	| [] -> "\n"
;;

let printCallbackPointerVariableName functionName = "cb_" ^ functionName;;

let printCounterPerFunction functionName =
	"count_of_" ^ functionName
;;

let rec getListOfFunctionsNames list =
	match list with 
	| SomeFunction (functionName, returnType, argumentList, someBool, attr) :: li -> 
		functionName :: getListOfFunctionsNames li
	| NoFunction :: li -> getListOfFunctionsNames li
	| [] -> []
;;

let rec printCallbackPointer list =
	match list with
	| functionName :: li -> 
					"static " ^ printCallbackType functionName ^  " " ^ printCallbackPointerVariableName functionName ^ 
					" = NULL;\n" ^ "static int " ^ printCounterPerFunction functionName ^ " = 0;\n" ^ 
					printCallbackPointer li
	| [] -> "\n"
;;

let getFunctionSignature (functionName : string) (t : typ) =
	match t with 
	| TFun(returnType, argumentList, someBool, attr) -> 
					SomeFunction (functionName, returnType, argumentList, someBool, attr)
	| _ ->  NoFunction
;;

let rec getListOfFunctions list =
	match list with
	| GVarDecl(v,l)::li -> if isSystemFunction v.vname == false then
							getFunctionSignature v.vname v.vtype :: getListOfFunctions li
						else
							getListOfFunctions li
	| el::li -> getListOfFunctions li
	| [] -> []
;;

let rec printResetStubsBody listOfFunctionNames =
	match listOfFunctionNames with
	| functionName::li -> printCallbackPointerVariableName functionName ^ " = NULL;\n" 
						  ^ printCounterPerFunction functionName ^ " = 0;\n" ^ printResetStubsBody li
	| [] -> ""
;;

let rec printGettersForCounters listOfFunctionNames = 
	match listOfFunctionNames with
	| functionName::li -> 
	            let variableName = printCounterPerFunction functionName in
				"int get_" ^ variableName ^ "(void){\n" ^ 
				"   return " ^ variableName ^ ";\n}\n" ^ printGettersForCounters li 
	| [] -> "\n"
;;

let printResetStubs (fileName : string) listOfFunctionNames =
	"/* reset function for stubs*/\n" ^ 
	"void reset_" ^ fileName ^ "(void){ \n" ^
	printResetStubsBody listOfFunctionNames ^ 
	"}\n"
;;


let rec printSettersForCallBacks listOfFunctionNames = 
	match listOfFunctionNames with
	| functionName::li -> let variableName = printCallbackPointerVariableName functionName in
	          let variableType = printCallbackType functionName in 
			"void set_" ^ variableName ^ "(" ^ variableType ^ " func){\n" ^
			variableName ^ " = func;\n}\n" ^ printSettersForCallBacks li 
	| [] -> "\n"
;;

let printCounterIncrement functionName = 
	printCounterPerFunction functionName ^ "++;"
;;

let bodyOfIfStatement functionName returnType =
	match returnType with
	| TVoid(_) -> "\t " ^ printCallbackPointerVariableName functionName 
	| _ -> "\t return " ^ printCallbackPointerVariableName functionName
;;

let printIfStatement functionName argumentList returnType= 
	"if(" ^ printCallbackPointerVariableName functionName ^ "){\n" ^ 
	bodyOfIfStatement functionName returnType ^ 
			"("^ printArgumentVariables argumentList ^");\n}\n" ^ 
			"else {\n" ^ 
			"\t" ^ printDefaultType returnType^ "\n}"
;;

(*
(printArgumentVariablesList argumentList)
*)


(*BUG: if the function returns void then it should not use void*)
let rec printStubFunction listOfFunctions =
	match listOfFunctions with 
	| SomeFunction (functionName, returnType, argumentList, someBool, attr) :: li -> 
		printType returnType ^ " " ^ functionName ^ "(" ^ hasArguments argumentList ^ "){\n" ^ 
		printCounterIncrement functionName ^ "\n" ^ (printIfStatement  functionName argumentList returnType) ^  "\n}\n\n" ^ printStubFunction li
	| NoFunction :: li -> printStubFunction li
	| [] -> "\n"
;;

let rec findType element =
	match element with
	| TVoid(_) -> "void"
	| TInt(_,_) -> "int"
	| TFloat(_,_) -> "float"
	| TPtr(_,_) -> "ptr"
	| TArray(_,_,_) -> "array"
	| TNamed(typeinfo,_) -> findType typeinfo.ttype
	| TComp(_,_) -> "comp"
	| _ -> ""
;;

let rec getTypedefType list =
	match list with
	| (s,t)::li -> s ^ " " ^ findType t ^ ", " ^getTypedefType li
	| [] -> "\n"


let rec getListOfTypedefs list =
	match list with
	| GType(typeinfo, _)::li -> (typeinfo.tname, typeinfo.ttype) :: getListOfTypedefs li
	| el::li -> getListOfTypedefs li 
	| [] -> []
;;

(* Write message to file *)
let writeToFile file message = 
	let oc = open_out file in    (* create or truncate file, return channel *)
	Printf.fprintf oc "%s\n" message;   (* write something *)   
	close_out oc;;                      (* flush and close the channel *)

let stubGen_main fileName = 
	let cilFile = Frontc.parse fileName () in 
	let listOfFunctions = getListOfFunctions cilFile.globals in
	let fileNameWithoutPath = getFileNameWithoutPath cilFile in 
	let onlyFunctionNames = getListOfFunctionsNames listOfFunctions in
	let listOfTypedefs = getListOfTypedefs cilFile.globals in
	let typedefs = getTypedefType listOfTypedefs in
	let result = 
	"#include <stdio.h>\n" ^
	"//" ^ typedefs ^ "\n" ^
	"#include \"" ^ fileNameWithoutPath ^ "\"\n" ^ 
	(printFunctionSignature listOfFunctions) ^ "\n" ^ 
	(printCallbackPointer onlyFunctionNames) ^ "\n" ^ 
	(printResetStubs (getFileNameWithoutExtension (fileNameWithoutPath)) onlyFunctionNames) ^ "\n" ^ 
	(printGettersForCounters onlyFunctionNames) ^ "\n" ^ 
	(printSettersForCallBacks onlyFunctionNames) ^ "\n" ^
	(printStubFunction listOfFunctions) in
	writeToFile ((getFileNameWithoutExtension fileNameWithoutPath)^"_stub.c") result
;;


(*
ocamltop call
#use "topfind";;
#require "cil";;
#use "stubGen.ml";;

ocamlopt -c -I /Users/andrepassos/.opam/system/lib/cil/ stubGen.ml

ocamlopt -ccopt -L/Users/andrepassos/.opam/system/lib/cil/ -o main unix.cmxa str.cmxa nums.cmxa /Users/andrepassos/.opam/system/lib/cil/cil.cmxa stubGen.cmx

*)