open OUnit2;;

let test1 test_printCallbackType = assert_equal "cb_funct_t" (StubGen.printCallbackType "funct")

(* Name the test cases and group them together *)
let suite =
"suite">:::
 ["test1">:: test1;]
;;

let () =
  run_test_tt_main suite
;;
