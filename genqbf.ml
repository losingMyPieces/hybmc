(* introduce fileds *)
open Printf
open Global
module Form = Formula
open Expression
module Args = GenArgs
exception ArgsError of string

module SetVar = Set.Make(String)

let parse_command_line_args () : unit =
  Args.parse_args ()

let parse_I_file () : expression =
  if !Args.is_initial_file_A then
    let ch = Stdlib.open_in !Args.initial_file_A in
    let f = Parse.parse ch (ExprParser.main ExprLexer.lex) in
    f
  else
    raise(ArgsError("must provide initial state formula file with -I file"))

 let parse_R_file () : expression =
  if !Args.is_transition_file_A then
    let ch = Stdlib.open_in !Args.transition_file_A in
    let f = Parse.parse ch (ExprParser.main ExprLexer.lex) in
    f
  else
    raise(ArgsError("must provide transition relation formula file with -R file"))

 let parse_Q_file () : Form.formula =
  if !Args.is_hyperctl_file then
    let ch = Stdlib.open_in !Args.hyperctl_file in
    let p = Parse.parse ch (Parser.main Lexer.lex) in
    p
  else
    raise(ArgsError("must provide hyperctl* formula file with -Q file"))


(* problem description *)
type problem_desc =
  {
    init   : expression ;
    trans     : expression ;
    hyperctl : Form.formula ;
    sem      : Args.semantics ;
  }
type unrolled_problem_desc =
  {
    init   : expression ;
    trans     : expression ;
  }

let parse_k () =
  if !Args.is_unroll_num then
    !Args.unroll_num
  else
    raise (ArgsError("missing unrolling depth with -k <num>"))

 let generate_unrolled_desc (desc:problem_desc) (k:int) (path:variable): unrolled_problem_desc =
  {
    init = unroll_name  desc.init 0 path;
    trans   = unroll_uptok desc.trans k path;
  }

 let two_varlists_to_set l1 l2 =
  let add_elem ss x = SetVar.add x ss in
  let add_list s l = List.fold_left add_elem s l in
  add_list (add_list SetVar.empty l1) l2

(* (* tail  recursive *) *)
(* let remove_dup (ls:variable list) : variable list = *)
(*  let del_from a ls = List.filter (fun x -> not (String.equal a x)) ls in *)
(*  let rec aux ls rem = *)
(*    match rem with *)
(*      []     -> ls *)
(*    | hd::tl -> aux (hd::ls) (del_from hd rem) *)
(*  in *)
(*  aux ls [] *)
(*  *)
(* let rec get_vars (f:expression) : variable list = *)
(*  remove_dup (get_vars_expr f) *)
(*  and get_vars_expr (e:expression): variable list = *)
(*  get_vars_expr_aux [] e *)
(*  and get_vars_expr_aux (acc:variable list) (e:expression) : variable list= *)
(*      let get2 x y = get_vars_expr_aux (get_vars_expr_aux acc x) y in *)
(*          match e with *)
(*          | Literal(Atom(v)) -> v::acc *)
(*          | Literal(NotAtom(v)) -> v::acc *)
(*          | Not(x)   -> get_vars_expr_aux acc x *)
(*          | Or(x,y)  -> get2 x y *)
(*          | MOr(ls)  -> List.fold_left get_vars_expr_aux acc ls *)
(*          | And(x,y) -> get2 x y *)
(*          | MAnd(ls) -> List.fold_left get_vars_expr_aux acc ls *)
(*          | Impl(x,y) -> get2 x y *)
(*          | Equiv(x,y)     -> get2 x y *)
(*          | _ -> [] *)

 let get_model_set udesc=
    let varinit = get_vars udesc.init in
    let vartrans = get_vars udesc.trans in
    two_varlists_to_set varinit vartrans

 (* not completed *)
 let encode_formula desc k=
    encode desc.hyperctl 0 []

(* for hyperctl *)
 let generate_qbf (desc:problem_desc) (k:int) =
    encode_formula desc k

let parse_files () : problem_desc =
   {
      init     = parse_I_file();
      trans       = parse_R_file();
      hyperctl   = parse_Q_file();
      sem        = (match !Args.unrolling_semantics with
                    | Some sem -> sem
                    | None -> raise(ArgsError("must provide semantics of unrolling")))
   }

let parse_problem_desc () : problem_desc =
    parse_files ()

let pr_time s =
  print_endline (sprintf "Time elapsed: %.3f secs (%s)" (Sys.time()) s)

(****************)
(* main         *)
(****************)
let _ =
  (* parse args *)
  try
    let _ = parse_command_line_args () in
    let _ = pr_time "parsing smv and HyperCTL* files" in
    let desc = parse_problem_desc () in
    let k = parse_k () in
    let phi  = generate_qbf desc k in
    let outch = Args.open_output () in
(*    (* conversion (into CNF, etc, if required) for the time being on the *)
(*       whole formula and not on the unrolling for M and N separately *) *)
(*    let form = convert phi in *)
(*  *)
(*    (* simplification (if required) *) *)
(*    let form =if (!Args.simplify) then (simplify_formula form) else form in *)
(*    (* generate_circuit *) *)
(*  *)
(*    (* OLD *) *)
(*    (* let str = generate_circuit (quants,form) in *) *)
(*    (* fprintf outch "%s\n" str  ; *) *)
(*    (* NEW *) *)
(*    let _ = fprint_circuit outch form in *)
    Args.close_output ()
  with
  | Global.ParserError msg ->
    raise(ArgsError("Parsing error"))
  | Lexer.LexerError ->
    raise(ArgsError("Lexing error"))
  | e -> raise(e)
