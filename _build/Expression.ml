 open Printf
exception ErrorInNNF

 type variable = string

 type literal =
 | Atom of variable
 | NotAtom of variable

 type expression =
  True
 | False
 | Literal of literal
 | Not of expression
 | Or of expression * expression
 | MOr of expression list
 | And of expression * expression
 | MAnd of expression list
 | Impl of expression * expression
 | Equiv of expression * expression

let trueSym = "true"
let falseSym = "false"
let andSym = "/\\"
let orSym = "\\/"
let negSym = "~"
let implSym = "->"
let iffSym = "<->"

type logic_op_t = AndOp | OrOp | ImplOp | EquivOp | NotOp | NoneOp

 type quantified_expression =
  True_gen
 | False_gen
 | Literal_gen of literal
 | Not_gen of quantified_expression
 | Or_gen of quantified_expression * quantified_expression
 | MOr_gen of quantified_expression list
 | And_gen of quantified_expression * quantified_expression
 | MAnd_gen of quantified_expression list
 | Impl_gen of quantified_expression * quantified_expression
 | Equiv_gen of quantified_expression * quantified_expression
 | Equiv_path of (variable list) * (variable list) * quantified_expression
 | Forall_gen of (variable list) * quantified_expression
 | Exists_gen of (variable list) * quantified_expression
 | General of expression

(* CONVERTERS *)
let rec normalize_suf (e:expression) : expression =
  let rec is_and (e:expression) : bool=
    match e with
    | And(_,_) -> true
    | MAnd(_) -> true
    | _ -> false
  and is_or (e:expression) : bool =
    match e with
      Or(_,_) -> true
    | MOr(_)  -> true
    | _       -> false
  and and_list (e:expression) : expression list =
    match e with
      MAnd xs -> xs
    | And(a,b) -> [a ; b]
    | _ -> [e]
  and or_list (e:expression) : expression list =
    match e with
      MOr xs -> xs
    | Or(a,b) -> [a ; b]
    | _ -> [e]
  in
  match e with
  | False          -> False
  | True           -> True
  | Literal(a)     -> e
  | Equiv(e1,e2)     -> Equiv(normalize_suf e1,normalize_suf e2)
  | Impl(e1,e2) -> Impl(normalize_suf e1, normalize_suf e2)
  | MAnd(ls) -> let newls = List.flatten (List.map and_list (List.map normalize_suf ls)) in
		MAnd(newls)
  | MOr (ls) -> let newls = List.flatten (List.map or_list (List.map normalize_suf ls)) in
		MOr(newls)
  | And(x,y) -> let (nx,ny) = (normalize_suf x, normalize_suf y) in
		if (is_and nx || is_and ny) then MAnd((and_list nx) @ (and_list ny)) else And(nx,ny)
  | Or(x,y)  -> let (nx,ny) = (normalize_suf x, normalize_suf y) in
		if (is_or nx  || is_or ny)  then MOr((or_list nx) @ (or_list ny)) else Or(nx,ny)
  | Not(x)   -> Not(normalize_suf x)


(* CONVERTERS *)
let rec normalize (e:quantified_expression) : quantified_expression =
  let rec is_and (e:quantified_expression) : bool=
    match e with
    | And_gen(_,_) -> true
    | MAnd_gen(_) -> true
    | _ -> false
  and is_or (e:quantified_expression) : bool =
    match e with
      Or_gen(_,_) -> true
    | MOr_gen(_)  -> true
    | _       -> false
  and and_list (e:quantified_expression) : quantified_expression list =
    match e with
      MAnd_gen xs -> xs
    | And_gen(a,b) -> [a ; b]
    | _ -> [e]
  and or_list (e:quantified_expression) : quantified_expression list =
    match e with
      MOr_gen xs -> xs
    | Or_gen(a,b) -> [a ; b]
    | _ -> [e]
  in
  match e with
  | False_gen          -> False_gen
  | True_gen           -> True_gen
  | Literal_gen(a)     -> e
  | Equiv_gen(e1,e2)     -> Equiv_gen(normalize e1,normalize e2)
  | Impl_gen(e1,e2) -> Impl_gen(normalize e1, normalize e2)
  | MAnd_gen(ls) -> let newls = List.flatten (List.map and_list (List.map normalize ls)) in
		MAnd_gen(newls)
  | MOr_gen (ls) -> let newls = List.flatten (List.map or_list (List.map normalize ls)) in
		MOr_gen(newls)
  | And_gen(x,y) -> let (nx,ny) = (normalize x, normalize y) in
		if (is_and nx || is_and ny) then MAnd_gen((and_list nx) @ (and_list ny)) else And_gen(nx,ny)
  | Or_gen(x,y)  -> let (nx,ny) = (normalize x, normalize y) in
		if (is_or nx  || is_or ny)  then MOr_gen((or_list nx) @ (or_list ny)) else Or_gen(nx,ny)
  | Not_gen(x)   -> Not_gen(normalize x)
  | Forall_gen(x,y) ->Forall_gen(x, normalize y)
  | Exists_gen(x,y) ->Exists_gen(x, normalize y)
  | Equiv_path(x,y,z) ->Equiv_path(x,y, normalize z)
  | General(e) -> General(normalize_suf e)


let rec nnf (phi:quantified_expression) : quantified_expression =
  let rec nnf_suf (psi:expression) : quantified_expression =
  match psi with
    | False -> False_gen
    | True -> True_gen
    | Equiv (e1,e2)    -> And_gen (nnf_suf (Impl(e1,e2)),nnf_suf (Impl(e2,e1)))
    | Impl(e1,e2) -> Or_gen (nnf_suf (Not e1),nnf_suf e2)
    | And (e1,e2)    -> And_gen (nnf_suf e1, nnf_suf e2)
    | MAnd(ls)       -> MAnd_gen(List.map nnf_suf ls)
    | MOr(ls)        -> MOr_gen (List.map nnf_suf ls)
    | Or (e1,e2)     -> Or_gen (nnf_suf e1, nnf_suf e2)
    | Not (Not e)    -> nnf_suf e
    | Not (And (e1,e2)) -> Or_gen(nnf_suf (Not e1),nnf_suf (Not e2))
    | Not (Or (e1,e2))  -> And_gen(nnf_suf (Not e1),nnf_suf (Not e2))
    | Not (MOr (ls))    -> MAnd_gen(List.map (fun x -> nnf_suf (Not(x))) ls)
    | Not (MAnd(ls))    -> MOr_gen (List.map (fun x -> nnf_suf (Not(x))) ls)
    | Not (Impl (e1,e2))  -> And_gen(nnf_suf e1, nnf_suf (Not e2))
    | Not (Equiv (e1, e2)) ->  Or_gen (And_gen (nnf_suf e1, nnf_suf (Not e2)), And_gen (nnf_suf (Not e1), nnf_suf e2))
    | Not Literal(Atom a)    -> Literal_gen(NotAtom a)
    | Not Literal(NotAtom a) -> Literal_gen(Atom a)
    | Not True -> False_gen
    | Not False -> True_gen
    | Literal(Atom a) -> Literal_gen(Atom a)
    | Literal(NotAtom a) -> Literal_gen(NotAtom a)
  in
  let nnf_aux (phi:quantified_expression) : quantified_expression =
    match phi with
    | False_gen -> False_gen
    | True_gen -> True_gen
    | Equiv_gen (e1,e2)    -> And_gen (nnf (Impl_gen(e1,e2)),nnf (Impl_gen(e2,e1)))
    | Impl_gen(e1,e2) -> Or_gen (nnf (Not_gen e1),nnf e2)
    | And_gen (e1,e2)    -> And_gen (nnf e1, nnf e2)
    | MAnd_gen(ls)       -> MAnd_gen(List.map nnf ls)
    | MOr_gen(ls)        -> MOr_gen (List.map nnf ls)
    | Or_gen (e1,e2)     -> Or_gen (nnf e1, nnf e2)
    | Exists_gen(x,y) -> Forall_gen(x,nnf y)
    | Forall_gen(x,y) -> Exists_gen(x,nnf y)
    | Equiv_path(x,y,z) -> Equiv_path(x,y,nnf z)
    | General(e)        -> nnf_suf e
    | Not_gen (Not_gen e)    -> nnf e
    | Not_gen (And_gen (e1,e2)) -> Or_gen(nnf (Not_gen e1),nnf (Not_gen e2))
    | Not_gen (Or_gen (e1,e2))  -> And_gen(nnf (Not_gen e1),nnf (Not_gen e2))
    | Not_gen (MOr_gen (ls))    -> MAnd_gen(List.map (fun x -> nnf (Not_gen(x))) ls)
    | Not_gen (MAnd_gen(ls))    -> MOr_gen (List.map (fun x -> nnf (Not_gen(x))) ls)
    | Not_gen (Impl_gen (e1,e2))  -> And_gen(nnf e1, nnf (Not_gen e2))
    | Not_gen (Equiv_gen (e1, e2)) ->  Or_gen (And_gen (nnf e1, nnf (Not_gen e2)), And_gen (nnf (Not_gen e1), nnf e2))
    | Not_gen Literal_gen(Atom a)    -> Literal_gen(NotAtom a)
    | Not_gen Literal_gen(NotAtom a) -> Literal_gen(Atom a)
    | Not_gen (Exists_gen(x,y)) -> Forall_gen(x,nnf (Not_gen y))
    | Not_gen (Forall_gen(x,y)) -> Exists_gen(x,nnf (Not_gen y))
    | Not_gen (Equiv_path(x,y,z)) -> Equiv_path(x,y,nnf (Not_gen z))
    | Not_gen True_gen -> False_gen
    | Not_gen False_gen -> True_gen
    | Not_gen General(e) -> nnf_suf (Not e)
    | Literal_gen(_) -> phi
  in
  normalize (nnf_aux phi)

let var_to_str (v:variable) : string = v

let literal_to_str (l:literal) : string =
  match l with
  | Atom v    -> var_to_str v
  | NotAtom v -> negSym ^ (var_to_str v)

let rec expression_to_str_aux (op:logic_op_t) (phi:quantified_expression) : string =
  let tostr = expression_to_str_aux in
  match phi with
  | Literal_gen l -> literal_to_str l
  | True_gen -> trueSym
  | False_gen -> falseSym
  | And_gen(a,b)   ->  if op = AndOp then
		    sprintf  "%s %s %s" (tostr AndOp a) andSym (tostr AndOp b)
                  else
		    sprintf "(%s %s %s)" (tostr AndOp a) andSym (tostr AndOp b)
  | Or_gen(a,b)      -> if op = OrOp then
		    sprintf  "%s %s %s" (tostr OrOp a) andSym (tostr OrOp b)
                  else
		    sprintf "(%s %s %s)" (tostr OrOp a) andSym (tostr OrOp b)
  | MOr_gen(ls)      -> let body = String.concat orSym (List.map (expression_to_str_aux OrOp) ls) in
		    if op = OrOp then body else "(" ^ body ^ ")"
  | MAnd_gen(ls)      -> let body = String.concat orSym (List.map (expression_to_str_aux AndOp) ls) in
		    if op = AndOp then body else "(" ^ body ^ ")"
  | Not_gen a        -> let s =  sprintf "%s %s" negSym (tostr NotOp a) in
                    if op = NotOp then s else "(" ^ s ^ ")"
  | Impl_gen(a,b) -> let s = sprintf "%s -> %s" (tostr ImplOp a) (tostr ImplOp b) in
                    if op = ImplOp then s else "(" ^ s ^ ")"
  | Equiv_gen(a,b)     -> let s = sprintf "%s <-> %s" (tostr EquivOp a) (tostr EquivOp b) in
                    if op = EquivOp then s else "(" ^ s ^ ")"
let expression_to_str (phi:quantified_expression) : string =
  expression_to_str_aux NoneOp phi