open Kaputt.Abbreviations;;

let unity x = x;;

let t1 =
	Test.make_simple_test
    ~title:"first test"
    (fun () -> Assert.equal_int 2 2)
;;

let test_printCallbackType =
	Test.make_simple_test
	~title:"Print Callback Type test"
	(fun () ->
		(
	   		List.iter (fun (x,y) -> Assert.equal_string x (StubGen.printCallbackType y))
	   		["cb_type_t","type";
	   		"cb_f_t","f";
	   		"cb_some_type_t","some_type";
	   		"cb_someType_t","someType"]
		)
	)

let test_FileNameWithoutExtension = 
	Test.make_simple_test
	~title:"Print File name without extensions"
	(fun () -> 
		List.iter (fun (expected,input) -> 
		Assert.equal_string expected (StubGen.getFileNameWithoutExtension input))
		["test","test.h";
	 	"a","a.h";
	 	"myFile","myFile.c";]
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




let () =
  Test.run_tests [t1;test_printCallbackType; test_FileNameWithoutExtension]
;;

