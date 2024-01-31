type variable = string

type literal =
| Atom of variable
| NotAtom of variable

type expression =
  True
| False
| Literal of literal
| Atom of variable
| Not of expression
| Or of expression * expression
| MOr of expression list
| And of expression * expression
| MAnd of expression list
| Impl of expression * expression
| Equiv of expression * expression


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

let unroll (f:expression) (k:int) =
  let (now,next) = suffix k "" in
  unroll_expr_suf now next f

let unroll_expr (trel:expression) (k:int): expression =
    let (now,next) = suffix k "" in
    unroll_expr_suf now next trel

let unroll_expr_X_P (prop:expression) (k:int) : expression =
  let rec unroll_from n =
    let prop_n = unroll_expr prop n in
    if n==k-1 then prop_n else And(prop_n,unroll_from (n+1))
  in
  unroll_from 0

let unroll_expr_uptok_G_P (prop:expression) (k:int) : expression =
  let rec unroll_from n =
    let prop_n = unroll_expr prop n in
    if n==k then prop_n else And(prop_n,unroll_from (n+1))
  in
  unroll_from 0

let unroll_expr_uptok_F_P (prop:expression) (k:int) : expression =
  let rec unroll_from n =
    let prop_n = unroll_expr prop n in
    if n==k then prop_n else Or(prop_n,unroll_from (n+1))
  in
  unroll_from 0

(* UNTIL *)
(* OPTIMISTIC*)
(* prop1 UNTIL prop2, forever pro1 = UNSAT, "Weak until" *)
let unroll_expr_uptok_OPT_U_P (prop1:expression) (prop2:expression) (k:int) : expression =
  let rec unroll_from n =
    let prop1_n = unroll_expr prop1 n in
    let prop2_n = unroll_expr prop2 (n+1) in
    if n==k-1 then Or(And(prop1_n, prop2_n), And(prop1_n,unroll_expr prop1 k))
              else Or(And(prop1_n, prop2_n), unroll_from (n+1))
  in
  unroll_from 0

(* UNTIL *)
(* PESSIMISTIC *)
(* pro1 UNTIL prop2, forever pro1 = UNSAT  *)
let unroll_expr_uptok_PES_U_P (prop1:expression) (prop2:expression) (k:int) : expression =
  let rec unroll_from n =
    let prop1_n = unroll_expr prop1 n in
    let prop2_n = unroll_expr prop2 (n+1) in
    if n==k-1 then And(prop1_n, prop2_n) else Or(And(prop1_n, prop2_n), unroll_from (n+1))
  in
  unroll_from 0

(* RELEASE *)
(* OPTIMISTIC *)
(* prop1 RELEASE prop2, forever prop2 = SAT *)
let unroll_expr_uptok_OPT_R_P (prop1:expression) (prop2:expression) (k:int) : expression =
  let rec unroll_from n =
    let prop1_n = unroll_expr prop1 n in
    let prop2_n = unroll_expr prop2 n in
    if n==k then Or(unroll_expr prop1 k, unroll_expr prop2 k)
            else Or(prop1_n, And(prop2_n ,unroll_from (n+1)))
  in
  unroll_from 0

(* RELEASE *)
(* PESSIMISTIC *)
(* prop1 RELEASE prop2, forever prop2 = UNSAT, "Strong release" *)
let unroll_expr_uptok_PES_R_P (prop1:expression) (prop2:expression) (k:int) : expression =
  let rec unroll_from n =
    let prop1_n = unroll_expr prop1 n in
    let prop2_n = unroll_expr prop2 n in
    if n==k then prop1_n else Or(prop1_n, And(prop2_n ,unroll_from (n+1)))
  in
  unroll_from 0

