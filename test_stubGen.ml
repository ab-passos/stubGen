open Kaputt.Abbreviations
open Cil

let unity x = x;;

let t1 =
	Test.make_simple_test
    ~title:"first test"
    (fun () -> Assert.equal_int 2 2)
;;

(*
let test_isSystemFunction = 
	Test.make_simple_test
	~title:"Is system function test"
	(fun () ->
		List.iter (fun (expected,input) ->
		Assert.equal_bool expected (StubGen.isSystemFunction input))
		[true,"__func";
		 true,"__21212func";
		 true,"__myfunc";
		 false,"func"]
	)

let wrapForTest testName func listOfValues =
	Test.make_simple_test
	~title:testName
	(fun () -> 
		List.iter (fun (expected,input) -> 
		Assert.equal_string expected (func input))
		listOfValues
	)
;;

(*
let testFileNameWithoutPath test_FileNameWithoutPath =
	List.iter (fun (expected,input) -> 
		assert_equal expected (StubGen.getFileNameWithoutPath input))
	["home/xxx/yyyy/zue/file.h","file.h";
	 "home/xxx/yyyy/file.h","file.h";
	 "home/xxx/file.h","file.h";
	 "home/file.h","file.h"]
;;
*)

let test_printCallbackType =
	wrapForTest
		"Print Callback Type test"
		StubGen.printCallbackType
		["cb_type_t","type";
	   	 "cb_f_t","f";
	   	 "cb_some_type_t","some_type";
	   	 "cb_someType_t","someType"]


let test_FileNameWithoutExtension = 
	wrapForTest
		"Print File name without extensions test"
		StubGen.getFileNameWithoutExtension
		["test","test.h";
	 	"a","a.h";
	 	"myFile","myFile.c";]



let test_PrintType =
	wrapForTest
		"Print Type Test"
		StubGen.printType
		["void", TVoid([]);
		 "int", TInt(IInt,[]);
		 "float", TFloat(FFloat,[])]



let test_PrintDefaultType =
	wrapForTest 
		"Print Default Value Test" 
		StubGen.printDefaultType
		["//void", TVoid([]);
		 "return 0;", TInt(IInt,[]);
		 "return 0.0;", TFloat(FFloat,[]);
		 "return 0;", TNamed(
		 			{tname =  "Result";
		 			 ttype = TInt(IInt,[]); 
		 			 treferenced = true}, [])]



let () = 
  Test.run_tests [t1; 
  				  test_printCallbackType;
  				  test_FileNameWithoutExtension;
  				  test_isSystemFunction;
  				  test_PrintType;
  				  test_PrintDefaultType;
  				  ]
;;

*)

let () = 
  Test.run_tests [t1;
  				  ]
;;