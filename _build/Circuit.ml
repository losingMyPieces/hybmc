open Expression
open SymbolTable
open Printf

  type 't circuit =
    True
  | False
  | Literal of 't * literal
  | Let of  't * ('t circuit) * ('t circuit)
  | Or   of 't * ('t circuit) * ('t circuit)
  | And  of 't * ('t circuit) * ('t circuit)
  | MAnd of 't * ('t circuit list)
  | MOr  of 't * ('t circuit list)
  | Xor  of 't * ('t circuit) * ('t circuit)
  | Ite  of 't * ('t circuit) * ('t circuit) * ('t circuit)
  | Exists  of 't * (variable list) * ('t circuit)
  | Forall  of 't * (variable list) * ('t circuit)

(* First version:
   - gives a name to every node of the expression tree
   - uses only binary operators
*)

type str_circuit = string circuit

(***********************)
(* Converts to circuit *)
(***********************)


let rec formula_to_circuit (f:quantified_expression) : str_circuit =
  let last_id = ref 1 in
  let get_new_symbol (unit): int =
    let ret = !last_id in
    last_id := !last_id + 1 ; ret in
  let get_new_name (unit): string =
    "g" ^ (Stdlib.string_of_int (get_new_symbol())) in
  let convert_literal (l:literal) : str_circuit =
    match l with
      Atom(v)    -> Literal(v,l)
    | NotAtom(v) -> Literal("-"^v,l) in
  let rec expression_to_circuit (name:string) (e:quantified_expression) : str_circuit =
    let convert = expression_to_circuit "" in
    let get_name () = if name="" then get_new_name() else name in
    let rec compare_lists l1 l2 =
      match l1, l2 with
      | [], [] -> true           (* Both lists are empty, consider them equal *)
      | x1 :: rest1, x2 :: rest2 -> x1 = x2 && compare_lists rest1 rest2
      | _, _ -> false            (* Lists have different lengths, consider them unequal *)
    in
    match e with
      True_gen   -> True
    | False_gen  -> False
    | Literal_gen(l)   -> convert_literal l
    | Not_gen(_)       -> print_endline (expression_to_str e) ; raise(ErrorInNNF)
    | Or_gen(x,y)      -> let (cx,cy)=(convert x, convert y) in  Or(get_name(),cx,cy)
    | And_gen(x,y)     -> let (cx,cy)=(convert x, convert y) in And(get_name(),cx,cy)
    | MOr_gen(ls)      -> MOr (get_name(), List.map convert ls)
    | MAnd_gen(ls)     -> MAnd(get_name(), List.map convert ls)
    | Impl_gen(x,y)    -> print_endline (expression_to_str e) ; raise(ErrorInNNF)
    | Equiv_gen(x,y)   -> let (cx,cy)=(convert x, convert y) in Ite(get_name(),cx,cy,cy)
    | Equiv_path(x,y,z)-> let r=if compare_lists x y then True else False in let cz=convert z in And(get_name(),r,cz)
    | Forall_gen(x,y)  -> let cy=convert y in Forall(get_name(),x,cy)
    | Exists_gen(x,y)  -> let cy=convert y in Exists(get_name(),x,cy)
  in
expression_to_circuit "" f


(****************************************)
(* Renumbers vars and gates to 1,2,3... *)
(****************************************)

let rec tag_vars (e:str_circuit): symbol_table =
  let table = new_table() in
  let rec tag_expr (e:str_circuit) : unit =
      match e with
	Literal(_,Atom(v))    -> tag table v
      | Literal(_,NotAtom(v)) -> tag table v
      | Let(a,x,y)    -> tag table a ; tag_expr x ; tag_expr y
      | Or(_,x,y)     -> tag_expr x ; tag_expr y
      | And(_,x,y)    -> tag_expr x ; tag_expr y
      | MOr(_,ls)     -> List.iter tag_expr ls
      | MAnd(_,ls)    -> List.iter tag_expr ls
      | Xor(_,x,y)    -> tag_expr x ; tag_expr y
      | Ite(_,c,x,y)  -> tag_expr c ; tag_expr x ; tag_expr y
      | _ -> ()
  in
  tag_expr e ; table

let tag_circuit (circ:str_circuit) : symbol_table =
  let table = tag_vars circ in
  let addtag t = tag table t in
  let rec tag_c (circ:str_circuit) : unit =
    match circ with
    | Literal(_) -> ()
    | Let(_,x,y)    -> tag_c x ; tag_c y
    | Or (t,x,y)    -> addtag t ; tag_c x ; tag_c y
    | And(t,x,y)    -> addtag t ; tag_c x ; tag_c y
    | MOr(t,ls)     -> addtag t ; List.iter tag_c ls
    | MAnd(t,ls)    -> addtag t ; List.iter tag_c ls
    | Xor(t,x,y)    -> addtag t ; tag_c x ; tag_c y
    | Ite(t,c,x,y)  -> addtag t ; tag_c c ; tag_c x ; tag_c y
    | And(t,x,y)    -> addtag t ; tag_c x ; tag_c y
    | Exists(t,x,y) -> addtag t ; List.iter addtag x ; tag_c y
    | Forall(t,x,y) -> addtag t ; List.iter addtag x ; tag_c y
    | _ -> ()
  in
  tag_c circ ; table

let quantified_circuit_to_num_circuit (circ:str_circuit) (st:symbol_table) =
  let get_tag t = string_of_int(Hashtbl.find st.tag_to_idx t) in
  let rec trans c =
    match c with
    | Literal(t,Atom(v))    -> let newt=get_tag v in Literal(newt,Atom(newt))
    | Literal(t,NotAtom(v)) -> let newt=get_tag v in Literal("-"^newt,NotAtom(newt))
    | Let(n,x,y)   -> Let(get_tag n, trans x, trans y)
    | Or(t,x,y)    -> Or (get_tag t, trans x, trans y)
    | And(t,x,y)   -> And(get_tag t, trans x, trans y)
    | MAnd(t,ls)   -> MAnd(get_tag t, List.map trans ls)
    | MOr(t,ls)    -> MOr(get_tag t, List.map trans ls)
    | Xor(t,x,y)   -> Xor(get_tag t, trans x, trans y)
    | Ite(t,c,x,y) -> Ite(get_tag t, trans c,trans x, trans y)
    | Exists(t,x,y)-> Exists(get_tag t, List.map get_tag x, trans y)
    | Forall(t,x,y)-> Forall(get_tag t, List.map get_tag x, trans y)
    | True  -> True
    | False -> False
  in
  trans circ


(* TO_STR *)
let get_name (c:str_circuit) : string =
  match c with
    True         -> "gtrue"
  | False        -> "gfalse"
  | Literal(t,_) -> t
  | Let(t,_,_)   -> t
  | Or(t,_,_)    -> t
  | MOr(t,_)   -> t
  | And(t,_,_)   -> t
  | MAnd(t,_)   -> t
  | Xor(t,_,_)   -> t
  | Ite(t,_,_,_) -> t
  | Exists(t,_,_) -> t
  | Forall(t,_,_) -> t

let circuit_to_str (c: str_circuit) : string =
  let rec to_str c =
    match c with
      True  -> "and()\n"
    | False -> "or()\n"
    | Literal(s,_) -> ""
    | Let(s,cx,cy) -> sprintf "%s\n%s" (to_str cx) (to_str cy)
    | Or(s,cx,cy)  ->
      let (sx,sy)=(to_str cx,to_str cy) in
      sx ^ sy ^ sprintf "%s = or(%s,%s)\n" s (get_name cx) (get_name cy)
    | And(s,cx,cy)  ->
      let (sx,sy)=(to_str cx,to_str cy) in
      sx ^ sy ^ sprintf "%s = and(%s,%s)\n" s (get_name cx) (get_name cy)
    | MOr(s,ls) ->
      let pre = List.fold_left (fun pref c -> pref ^ (to_str c)) "" ls in
      let args = String.concat "," (List.map get_name ls) in
      pre ^ s ^ " = or(" ^ args ^ ")\n"
    | MAnd(s,ls) ->
      let pre = List.fold_left (fun pref c -> pref ^ (to_str c)) "" ls in
      let args = String.concat "," (List.map get_name ls) in
      pre ^ s ^ " = and(" ^ args ^ ")\n"
    | Xor(s,cx,cy)  ->
      let (sx,sy)=(to_str cx,to_str cy) in
      sx ^ sy ^ sprintf "%s = xor(%s,%s)\n" s (get_name cx) (get_name cy)
    | Ite(s,cx,cy,cz)  ->
      let (sx,sy,sz)=(to_str cx,to_str cy,to_str cz) in
      sx ^ sy ^ sz ^ sprintf "%s = ite(%s,%s,%s)\n" s (get_name cx) (get_name cy)(get_name cz)
  in
  (sprintf "output(%s)\n" (get_name c)) ^ (to_str c)

(* OUTPUT *)
let rec fprint_quantified_circuit ch circ=
  let rec pr_circ circ =
    match circ with
	True  -> output_string ch "and()\n"
      | False -> output_string ch "or()\n"
      | Literal(s,_) -> ()
      | Let(n,cx,cy) -> pr_circ cx ; pr_circ cy
      | Or(s,cx,cy)  ->
	let me = sprintf "%s = or(%s,%s)\n" s (get_name cx) (get_name cy)in
	pr_circ cx ; pr_circ cy ; output_string ch me
      | And(s,cx,cy)  ->
	let me = sprintf "%s = and(%s,%s)\n" s (get_name cx) (get_name cy)in
	pr_circ cx ; pr_circ cy ; output_string ch me
      | MOr(s,ls) ->
	let args = String.concat "," (List.map get_name ls) in
	let me = s ^ " = or(" ^ args ^ ")\n" in
	List.iter (fun c -> pr_circ c) ls ; output_string ch me
      | MAnd(s,ls) ->
	let args = String.concat "," (List.map get_name ls) in
	let me = s ^ " = and(" ^ args ^ ")\n" in
	  List.iter (fun c -> pr_circ c) ls ; output_string ch me
      | Xor(s,cx,cy)  ->
	let me = sprintf "%s = xor(%s,%s)\n" s (get_name cx) (get_name cy) in
	pr_circ cx ; pr_circ cy ; output_string ch me
      | Ite(s,cx,cy,cz)  ->
	let me = sprintf "%s = ite(%s,%s,%s)\n" s (get_name cx) (get_name cy)(get_name cz) in
	pr_circ cx ; pr_circ cy ; pr_circ cz ; output_string ch me
	  | Exists(s,x,cy)  ->
    let me = sprintf "%s = exists(%s; %s)\n" s (String.concat ", " x) (get_name cy)in
	pr_circ cy ; output_string ch me
	  | Forall(s,x,cy)  ->
    let me = sprintf "%s = forall(%s; %s)\n" s (String.concat ", " x) (get_name cy)in
	pr_circ cy ; output_string ch me
  in
  let _ = output_string ch "#QCIR-G14\n" in
  output_string ch (sprintf "output(%s)\n" (get_name circ)) ; pr_circ circ

let fprint_quantified_num_circuit ch qc =
  let table = tag_circuit qc in
  let nqc = quantified_circuit_to_num_circuit qc table in
  fprint_quantified_circuit ch nqc