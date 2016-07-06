open StubGen
open Cmdliner

let parseFiles filesName = List.map stubGen_main filesName

let files = Arg.(non_empty & pos_all file [] & info [] ~docv:"FILE")

let stubGen_t = 
	let doc = "stubGen - Stub generator" in
  	let man = [`S "DESCRIPTION"] in
	Term.(const parseFiles $ files),
    Term.info "stubGen" ~version:"0.0.1" ~doc ~man

let () = 
match Term.eval (stubGen_t) with
| `Error _ -> exit 1 
| _ -> exit 0
;;