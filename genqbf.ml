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


 (* tail  recursive *)
 let remove_dup (ls:variable list) : variable list =
  let del_from a ls = List.filter (fun x -> not (String.equal a x)) ls in
  let rec aux ls rem =
    match rem with
      []     -> ls
    | hd::tl -> aux (hd::ls) (del_from hd rem)
  in
  aux ls []

 let rec get_vars (f:expression) : variable list =
  remove_dup (get_vars_expr f)
  and get_vars_expr (e:expression): variable list =
  get_vars_expr_aux [] e
  and get_vars_expr_aux (acc:variable list) (e:expression) : variable list=
      let get2 x y = get_vars_expr_aux (get_vars_expr_aux acc x) y in
          match e with
          | Literal(Atom(v)) -> v::acc
          | Literal(NotAtom(v)) -> v::acc
          | Not(x)   -> get_vars_expr_aux acc x
          | Or(x,y)  -> get2 x y
          | MOr(ls)  -> List.fold_left get_vars_expr_aux acc ls
          | And(x,y) -> get2 x y
          | MAnd(ls) -> List.fold_left get_vars_expr_aux acc ls
          | Impl(x,y) -> get2 x y
          | Equiv(x,y)     -> get2 x y
          | _ -> []

 let rename_variable (now:string) (next:string) (v:variable) : variable =
    let len  = String.length v in
    let last = v.[len-1] in
    let is_primed = (last == '\'') in
    if not is_primed then Printf.sprintf "%s%s" v now else
      Printf.sprintf "%s%s" (String.sub v 0 (len-1)) next

 let rename_literal (now:string) (next:string) (l:literal) : literal =
  match l with
    Atom v    -> Atom   (rename_variable now next v)
  | NotAtom v -> NotAtom(rename_variable now next v)

 let rec unroll_expr_suf (now:string) (next:string) (trel:expression) : expression =
  let rename = (unroll_expr_suf now next) in
  match trel with
  | True  -> True
  | False -> False
  | Literal(l)   -> Literal(rename_literal now next l)
  | Not(x)       -> Not(rename x)
  | Or(x,y)      -> Or(rename x, rename y)
  | And(x,y)     -> And(rename x, rename y)
  | Impl(x,y) -> Impl(rename x, rename y)
  | Equiv(x,y)     -> Equiv(rename x, rename y)
  | MOr(ls)      -> MOr(List.map rename ls)
  | MAnd(ls)     -> MAnd(List.map rename ls)


 let suffix (k:int) (name:string) : (string*string) =
  let now  = Printf.sprintf "%s[%d]" name k in
  let next = Printf.sprintf "%s[%d]" name (k+1) in
  (now,next)

 let unroll_name (f:expression) (k:int) (name:string) : expression =
  let str = if (String.length name) =0 then "" else "_" ^ name in
  let (now,next) = suffix k str in
  unroll_expr_suf now next f

  (* keep as k-1 because unroll_name is adding suffix (n+1), it's upto and include k *)
 let unroll_uptok (r:expression) (k:int) (name:string) : expression =
  let rec unroll_from n =
    let r_n = unroll_name r n name in
    if n==k-1 then r_n
    else  And (r_n,(unroll_from (n+1)))
  in
  unroll_from 0

 let unroll_expr (trel:expression) (k:int): expression =
    let (now,next) = suffix k "" in
    unroll_expr_suf now next trel

 let unroll_expr_uptok_U_OPT prop1 prop2 i k : expression =
    let rec unroll_from n =
        let prop1_n = unroll_expr prop1 n in
        let prop2_n = unroll_expr prop2 (n+1) in
        if n==k-1 then Or(And(prop1_n, prop2_n), And(prop1_n,unroll_expr prop1 k))
                  else Or(And(prop1_n, prop2_n), unroll_from (n+1))
        in
    unroll_from i

 let unroll_expr_uptok_U_PES prop1 prop2 i k : expression =
    let rec unroll_from n =
        let prop1_n = unroll_expr prop1 n in
        let prop2_n = unroll_expr prop2 (n+1) in
        if n==k-1 then And(prop1_n, prop2_n) else Or(And(prop1_n, prop2_n), unroll_from (n+1))
        in
    unroll_from i

 let unroll_expr_uptok_R_OPT prop1 prop2 i k : expression =
    let rec unroll_from n =
        let prop1_n = unroll_expr prop1 n in
        let prop2_n = unroll_expr prop2 n in
        if n==k then Or(unroll_expr prop1 k, unroll_expr prop2 k)
                else Or(prop1_n, And(prop2_n ,unroll_from (n+1)))
        in
    unroll_from i

 let unroll_expr_uptok_R_PES prop1 prop2 i k : expression =
    let rec unroll_from n =
        let prop1_n = unroll_expr prop1 n in
        let prop2_n = unroll_expr prop2 n in
        if n==k then prop1_n else Or(prop1_n, And(prop2_n ,unroll_from (n+1)))
      in
    unroll_from i


  let unroll_expr_uptok_F_P prop i k : expression =
     let rec unroll_from n =
         let prop_n = unroll_expr prop n in
         if n==k then prop_n else Or(prop_n,unroll_from (n+1))
     in
     unroll_from i

  let unroll_expr_uptok_G_P prop i k : expression =
     let rec unroll_from n =
         let prop_n = unroll_expr prop n in
         if n==k then prop_n else And(prop_n,unroll_from (n+1))
     in
     unroll_from i

 let generate_unrolled_desc (desc:problem_desc) (k:int) (path:variable): unrolled_problem_desc =
  {
    init = unroll_name  desc.init 0 path;
    trans   = unroll_uptok desc.trans k path;
  }


 let two_varlists_to_set l1 l2 =
  let add_elem ss x = SetVar.add x ss in
  let add_list s l = List.fold_left add_elem s l in
  add_list (add_list SetVar.empty l1) l2

 let get_model_set udesc=
    let varinit = get_vars udesc.init in
    let vartrans = get_vars udesc.trans in
    two_varlists_to_set varinit vartrans

let rec take_first_i_elements i lst =
  if i <= 0 then
    []
  else
    match lst with
    | [] -> []
    | hd :: tl -> hd :: take_first_i_elements (i - 1) tl

 let encode_expr desc i k epsilon : quantified_expression =
     let rec encode rest i k epsilon =
     match rest with
       Form.Exists(x,y) ->
         let udesc = generate_unrolled_desc desc k x in
         let vartrans = get_vars udesc.trans in
         let path_i = take_first_i_elements i vartrans in
         let path_i_old = take_first_i_elements i epsilon in
         let model_set = get_model_set udesc in
         (match epsilon with
             | [] -> Exists_gen(SetVar.elements model_set,encode y i k path_i)
             | _ -> let tl = encode y i k path_i in
                    let mid = Equiv_path(path_i,path_i_old,tl) in
                    Exists_gen(SetVar.elements model_set,mid))
     | Form.Forall(x,y) ->
         let udesc = generate_unrolled_desc desc k x in
         let vartrans = get_vars udesc.trans in
         let path_i = take_first_i_elements i vartrans in
         let path_i_old = take_first_i_elements i epsilon in
         let model_set = get_model_set udesc in
         (match epsilon with
             | [] -> Forall_gen(SetVar.elements model_set,encode y i k path_i)
             | _ -> let tl = encode y i k path_i in
                    let mid = Equiv_path(path_i,path_i_old,tl) in
                    Forall_gen(SetVar.elements model_set,mid))
     | Form.Next(e)     -> (match desc.sem with
                Args.OPT -> if i == k then True_gen else encode e (i+1) k epsilon  (* optimistic *)
              | Args.PES -> if i == k then False_gen else encode e (i+1) k epsilon)  (* pessimistic *)
     | Form.Until(e1,e2)   -> (match desc.sem with
               Args.OPT -> General (unroll_expr_uptok_U_OPT e1 e2 i k) (* optimistic *)
              | Args.PES -> General (unroll_expr_uptok_U_PES e1 e2 i k)) (* pessimistic *)
     | Form.Release(e1,e2)   -> (match desc.sem with
               Args.OPT -> General (unroll_expr_uptok_R_OPT e1 e2 i k) (* optimistic *)
              | Args.PES -> General (unroll_expr_uptok_R_PES e1 e2 i k)) (* pessimistic *)
     | Form.Finally(e)     -> General (unroll_expr_uptok_F_P e i k)
     | Form.Globally(e)     -> General (unroll_expr_uptok_G_P e i k)
     | Form.Not(x) -> Not_gen(encode x i k epsilon)
     | Form.Or(x,y) -> Or_gen(encode x i k epsilon,encode y i k epsilon)
     | Form.And(x,y) -> And_gen(encode x i k epsilon,encode y i k epsilon)
     | Form.Impl(x,y) -> Impl_gen(encode x i k epsilon,encode y i k epsilon)
     | Form.Equiv(x,y) -> Equiv_gen(encode x i k epsilon,encode y i k epsilon)
     in
     encode desc.hyperctl 0 k []

(* for hyperctl *)
let generate_qbf (desc:problem_desc) (k:int) =
   encode_expr desc 0 k []

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

let to_nnf f = nnf f

let to_circuit f = Circuit.formula_to_circuit f

let fprint_circuit ch qphi : unit =
    match !Args.format with
    | Some QCIR    ->
     let get_body () =
       let _ = pr_time "calling nnf" in
       let nphi = to_nnf qphi in
       let _ = pr_time "calling formula_to_circuit" in
       let b = to_circuit nphi in
       b
     in
     let body = get_body ()
     in
     let _ = pr_time "printing circuit" in
     let _ =
       if !Args.toNum then   Circuit.fprint_quantified_num_circuit ch body
       else                  Circuit.fprint_quantified_circuit ch body
     in
     let _ = pr_time "done" in
     ()
      | Some QDIMACS -> fprintf ch "error: QDIMACS output not implemented yet)"
      | Some AIGER   -> fprintf ch "error: AIGER output not implemented yet)"
      | None         -> fprintf ch "error: must specify QCIR | QDIMACS | AIGER"
(****************)
(* main         *)
(****************)
let _ =
  (* parse args *)
  try
    let _ = parse_command_line_args () in
    let desc = parse_problem_desc () in
    let k = parse_k () in
    let phi  = generate_qbf desc k in
    let outch = Args.open_output () in
    let _ = fprint_circuit outch phi in
    Args.close_output ()
  with
  | Global.ParserError msg ->
    raise(ArgsError("Parsing error"))
  | Lexer.LexerError ->
    raise(ArgsError("Lexing error"))
  | e -> raise(e)

let _ = Debug.flush()