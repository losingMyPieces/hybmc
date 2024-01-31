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


type quantified_expression =
  True_gen
| False_gen
| Literal_gen of literal
| Not_gen of quantified_expression
| Or_gen of quantified_expression * quantified_expression
| And_gen of quantified_expression * quantified_expression
| Impl_gen of quantified_expression * quantified_expression
| Equiv_gen of quantified_expression * quantified_expression
| Equiv_path of (variable list) * (variable list)
| Forall_gen of (variable list) * (quantified_expression list)
| Exists_gen of (variable list) * (quantified_expression list)


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

let rec unroll_expr_suf (now:string) (next:string) (trel:Formula.formula) : quantified_expression =
  let rename = (unroll_expr_suf now next) in
  match trel with
  | True  -> True_gen
  | False -> False_gen

  | Literal(l)   -> Literal_gen(rename_literal now next l)
  | Not(x)       -> Not_gen(rename x)
  | Or(x,y)      -> Or_gen(rename x, rename y)
  | And(x,y)     -> And_gen(rename x, rename y)
  | Impl(x,y) -> Impl_gen(rename x, rename y)
  | Equiv(x,y)     -> Equiv_gen(rename x, rename y)


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

let unroll_expr (trel:Formula.formula) (k:int): quantified_expression =
    let (now,next) = suffix k "" in
    unroll_expr_suf now next trel


let rec encode rest i k epsilon:quantified_expression =
    match rest with
    | Form.Exists(x,y) ->
        let udesc = generate_unrolled_desc desc k x in
        let model_set = get_model_set udesc in
        (match epsilon with
            | [] -> let hd = Exists_gen(SetVar.elements model_set) in
                    let tl = encode y i k model_set in
                    (hd, tl)
            | _ -> let hd = Exists_gen(SetVar.elements model_set) in
                   let mid = Equiv_path(List.take i epsilon,List.take i model_set) in
                   let tl = encode y i k model_set in
                   (hd ,(mid @ tl)))
    | Form.Forall(x,y) ->
        let udesc = generate_unrolled_desc desc k x in
        let model_set = get_model_set udesc in
        (match epsilon with
            | [] -> let hd = Forall_gen(SetVar.elements model_set) in
                    let tl = encode y i k model_set in
                    (hd, tl)
            | _ -> let hd = Forall_gen(SetVar.elements model_set) in
                   let mid = Equiv_path(List.take i epsilon,List.take i model_set) in
                   let tl = encode y i k model_set in
                   (hd ,(mid @ tl)))
    | Form.Globally(e)    -> unroll_expr_uptok_G_P e i k
    | Form.Finally(e)     -> unroll_expr_uptok_F_P e i k
    | Form.Next(e)     -> (match sema with
            | Args.OPT -> unroll_expr_X_OPT e i k  (* optimistic *)
            | Args.PES -> unroll_expr_X_PES e i k  (* pessimistic *)
    | Form.Until(e1,e2)   -> (match sema with
            | Args.OPT -> [unroll_expr_uptok_U_OPT e1 e2 i k] (* optimistic *)
            | Args.PES -> [unroll_expr_uptok_U_PES e1 e2 i k]) (* pessimistic *)
    | Form.Release(e1,e2)   -> (match sema with
            | Args.OPT -> [unroll_expr_uptok_R_OPT e1 e2 i k] (* optimistic *)
            | Args.PES -> [unroll_expr_uptok_R_PES e1 e2 i k]) (* pessimistic *)
and unroll_expr_X_OPT prop i k : quantified_expression =
    if i == k then True_gen else encode prop (i+1) k
and unroll_expr_X_PES prop i k : quantified_expression =
    if i == k then False_gen else encode prop (i+1) k
and unroll_expr_uptok_F_P prop i k : quantified_expression =
    let rec unroll_from n =
        (match prop with
        | Form.Exists(x,y) | Form.Forall(x,y) ->
            let prop_n = encode prop n k in
            if n==k then prop_n else
                Or_gen(prop_n,unroll_from (n+1))
        | _ ->
            let prop_n = unroll_expr prop n in
            if n==k then prop_n else
                Or_gen(prop_n,unroll_from (n+1)))
    unroll_from i
and unroll_expr_uptok_G_P prop i k : quantified_expression =
    let rec unroll_from n =
        (match prop with
        | Form.Exists(x,y) | Form.Forall(x,y) ->
            let prop_n = encode prop n k in
            if n==k then prop_n else
                And_gen(prop_n,unroll_from (n+1))
        | _ ->
            let prop_n = unroll_expr prop n in
            if n==k then prop_n else
                And_gen(prop_n,unroll_from (n+1)))
    unroll_from i
and unroll_expr_uptok_U_OPT prop1 prop2 i k : quantified_expression =
    let rec unroll_from n =
        let prop1_n = unroll_expr prop1 n in
        let prop2_n = unroll_expr prop2 (n+1) in
        if n==k-1 then Or_gen(And_gen(prop1_n, prop2_n), And_gen(prop1_n,unroll_expr prop1 k))
                  else Or_gen(And_gen(prop1_n, prop2_n), unroll_from (n+1))
        in
    unroll_from i
and unroll_expr_uptok_U_PES prop1 prop2 i k : quantified_expression =
    let rec unroll_from n =
        let prop1_n = unroll_expr prop1 n in
        let prop2_n = unroll_expr prop2 (n+1) in
        if n==k-1 then And_gen(prop1_n, prop2_n) else Or_gen(And_gen(prop1_n, prop2_n), unroll_from (n+1))
        in
    unroll_from i
and unroll_expr_uptok_R_OPT prop1 prop2 i k : quantified_expression =
    let rec unroll_from n =
        let prop1_n = unroll_expr prop1 n in
        let prop2_n = unroll_expr prop2 n in
        if n==k then Or_gen(unroll_expr prop1 k, unroll_expr prop2 k)
                else Or_gen(prop1_n, And_gen(prop2_n ,unroll_from (n+1)))
        in
    unroll_from i
and unroll_expr_uptok_R_PES prop1 prop2 i k : quantified_expression =
    let rec unroll_from n =
        let prop1_n = unroll_expr prop1 n in
        let prop2_n = unroll_expr prop2 n in
        if n==k then prop1_n else Or_gen(prop1_n, And_gen(prop2_n ,unroll_from (n+1)))
      in
    unroll_from i