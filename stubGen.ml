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

let printType (t : typ) = 
	match t with
	| TVoid(_) -> "void"
	| TInt(_) -> "int"
	| TFloat(_) -> "float"
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

let hasArguments arg =
	match arg with
	| None -> ""
	| Some l -> printArgumentList l
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

let () = 
	let cilFile = Frontc.parse "test.h" () in 
	let result = getListOfFunctions cilFile.globals in
	let fileNameWithoutPath = getFileNameWithoutPath cilFile in 
	let onlyFunctionNames = getListOfFunctionsNames result in
	Printf.printf "%s\n%s%s%s\n%s%s"
	(fileNameWithoutPath)
	(printFunctionSignature result)
	(printCallbackPointer onlyFunctionNames)
	(printResetStubs (getFileNameWithoutExtension (fileNameWithoutPath)) onlyFunctionNames)
	(printGettersForCounters onlyFunctionNames)
	(printSettersForCallBacks onlyFunctionNames)
;;

(*
ocamltop call
#use "topfind";;
#require "cil";;
#use "stubGen.ml";;

ocamlopt -c -I /Users/andrepassos/.opam/system/lib/cil/ stubGen.ml

ocamlopt -ccopt -L/Users/andrepassos/.opam/system/lib/cil/ -o main unix.cmxa str.cmxa nums.cmxa /Users/andrepassos/.opam/system/lib/cil/cil.cmxa stubGen.cmx

*)