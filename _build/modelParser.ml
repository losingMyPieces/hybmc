
module MenhirBasics = struct
  
  exception Error
  
  let _eRR =
    fun _s ->
      raise Error
  
  type token = 
    | TRUE
    | OR
    | OP
    | NOT
    | IMPL
    | ID of (
# 9 "ExprParser.mly"
       (string*int)
# 20 "modelParser.ml"
  )
    | FALSE
    | EQUIV
    | EOF
    | CL
    | AND
  
end

include MenhirBasics

# 1 "ExprParser.mly"
  
    open Global
    let get_name id = fst id
    let get_line id = snd id

# 38 "modelParser.ml"

type ('s, 'r) _menhir_state = 
  | MenhirState00 : ('s, _menhir_box_model) _menhir_state
    (** State 00.
        Stack shape : .
        Start symbol: model. *)

  | MenhirState02 : (('s, _menhir_box_model) _menhir_cell1_OP, _menhir_box_model) _menhir_state
    (** State 02.
        Stack shape : OP.
        Start symbol: model. *)

  | MenhirState03 : (('s, _menhir_box_model) _menhir_cell1_NOT, _menhir_box_model) _menhir_state
    (** State 03.
        Stack shape : NOT.
        Start symbol: model. *)

  | MenhirState08 : (('s, _menhir_box_model) _menhir_cell1_formula, _menhir_box_model) _menhir_state
    (** State 08.
        Stack shape : formula.
        Start symbol: model. *)

  | MenhirState10 : (('s, _menhir_box_model) _menhir_cell1_formula, _menhir_box_model) _menhir_state
    (** State 10.
        Stack shape : formula.
        Start symbol: model. *)

  | MenhirState12 : (('s, _menhir_box_model) _menhir_cell1_formula, _menhir_box_model) _menhir_state
    (** State 12.
        Stack shape : formula.
        Start symbol: model. *)

  | MenhirState14 : (('s, _menhir_box_model) _menhir_cell1_formula, _menhir_box_model) _menhir_state
    (** State 14.
        Stack shape : formula.
        Start symbol: model. *)


and ('s, 'r) _menhir_cell1_formula = 
  | MenhirCell1_formula of 's * ('s, 'r) _menhir_state * (Model.expression)

and ('s, 'r) _menhir_cell1_NOT = 
  | MenhirCell1_NOT of 's * ('s, 'r) _menhir_state

and ('s, 'r) _menhir_cell1_OP = 
  | MenhirCell1_OP of 's * ('s, 'r) _menhir_state

and _menhir_box_model = 
  | MenhirBox_model of (Model.expression) [@@unboxed]

let _menhir_action_01 =
  fun _2 ->
    (
# 37 "ExprParser.mly"
                              ( _2 )
# 94 "modelParser.ml"
     : (Model.expression))

let _menhir_action_02 =
  fun () ->
    (
# 38 "ExprParser.mly"
                              ( Model.True )
# 102 "modelParser.ml"
     : (Model.expression))

let _menhir_action_03 =
  fun () ->
    (
# 39 "ExprParser.mly"
                              ( Model.False )
# 110 "modelParser.ml"
     : (Model.expression))

let _menhir_action_04 =
  fun _2 ->
    (
# 40 "ExprParser.mly"
                              ( let phi = _2 in
                                match phi with
                                 | Model.Literal(Model.Atom(name)) -> Model.Literal(Model.NotAtom(name))
                                 | _ -> Model.Not(phi) )
# 121 "modelParser.ml"
     : (Model.expression))

let _menhir_action_05 =
  fun _1 _3 ->
    (
# 44 "ExprParser.mly"
                                  ( Model.And (_1,_3) )
# 129 "modelParser.ml"
     : (Model.expression))

let _menhir_action_06 =
  fun _1 _3 ->
    (
# 45 "ExprParser.mly"
                                  ( Model.Or (_1,_3) )
# 137 "modelParser.ml"
     : (Model.expression))

let _menhir_action_07 =
  fun _1 _3 ->
    (
# 46 "ExprParser.mly"
                                  ( Model.Impl (_1,_3) )
# 145 "modelParser.ml"
     : (Model.expression))

let _menhir_action_08 =
  fun _1 _3 ->
    (
# 47 "ExprParser.mly"
                                  ( Model.Equiv (_1,_3) )
# 153 "modelParser.ml"
     : (Model.expression))

let _menhir_action_09 =
  fun _1 ->
    (
# 48 "ExprParser.mly"
                              ( Model.Literal(Atom(get_name(_1))))
# 161 "modelParser.ml"
     : (Model.expression))

let _menhir_action_10 =
  fun _1 ->
    (
# 34 "ExprParser.mly"
                            ( _1 )
# 169 "modelParser.ml"
     : (Model.expression))

let _menhir_print_token : token -> string =
  fun _tok ->
    match _tok with
    | AND ->
        "AND"
    | CL ->
        "CL"
    | EOF ->
        "EOF"
    | EQUIV ->
        "EQUIV"
    | FALSE ->
        "FALSE"
    | ID _ ->
        "ID"
    | IMPL ->
        "IMPL"
    | NOT ->
        "NOT"
    | OP ->
        "OP"
    | OR ->
        "OR"
    | TRUE ->
        "TRUE"

let _menhir_fail : unit -> 'a =
  fun () ->
    Printf.eprintf "Internal failure -- please contact the parser generator's developers.\n%!";
    assert false

include struct
  
  [@@@ocaml.warning "-4-37"]
  
  let rec _menhir_run_01 : type  ttv_stack. ttv_stack -> _ -> _ -> (ttv_stack, _menhir_box_model) _menhir_state -> _menhir_box_model =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s ->
      let _tok = _menhir_lexer _menhir_lexbuf in
      let _v = _menhir_action_02 () in
      _menhir_goto_formula _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_goto_formula : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_model) _menhir_state -> _ -> _menhir_box_model =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match _menhir_s with
      | MenhirState00 ->
          _menhir_run_18 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState14 ->
          _menhir_run_15 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState12 ->
          _menhir_run_13 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState10 ->
          _menhir_run_11 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState08 ->
          _menhir_run_09 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState02 ->
          _menhir_run_07 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | MenhirState03 ->
          _menhir_run_06 _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok
  
  and _menhir_run_18 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_model) _menhir_state -> _ -> _menhir_box_model =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      let _menhir_stack = MenhirCell1_formula (_menhir_stack, _menhir_s, _v) in
      match (_tok : MenhirBasics.token) with
      | OR ->
          _menhir_run_08 _menhir_stack _menhir_lexbuf _menhir_lexer
      | IMPL ->
          _menhir_run_12 _menhir_stack _menhir_lexbuf _menhir_lexer
      | EQUIV ->
          _menhir_run_14 _menhir_stack _menhir_lexbuf _menhir_lexer
      | AND ->
          _menhir_run_10 _menhir_stack _menhir_lexbuf _menhir_lexer
      | _ ->
          _eRR ()
  
  and _menhir_run_08 : type  ttv_stack. (ttv_stack, _menhir_box_model) _menhir_cell1_formula -> _ -> _ -> _menhir_box_model =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer ->
      let _menhir_s = MenhirState08 in
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | TRUE ->
          _menhir_run_01 _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s
      | OP ->
          _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s
      | NOT ->
          _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s
      | ID _v ->
          _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s
      | FALSE ->
          _menhir_run_05 _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s
      | _ ->
          _eRR ()
  
  and _menhir_run_02 : type  ttv_stack. ttv_stack -> _ -> _ -> (ttv_stack, _menhir_box_model) _menhir_state -> _menhir_box_model =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s ->
      let _menhir_stack = MenhirCell1_OP (_menhir_stack, _menhir_s) in
      let _menhir_s = MenhirState02 in
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | TRUE ->
          _menhir_run_01 _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s
      | OP ->
          _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s
      | NOT ->
          _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s
      | ID _v ->
          _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s
      | FALSE ->
          _menhir_run_05 _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s
      | _ ->
          _eRR ()
  
  and _menhir_run_03 : type  ttv_stack. ttv_stack -> _ -> _ -> (ttv_stack, _menhir_box_model) _menhir_state -> _menhir_box_model =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s ->
      let _menhir_stack = MenhirCell1_NOT (_menhir_stack, _menhir_s) in
      let _menhir_s = MenhirState03 in
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | TRUE ->
          _menhir_run_01 _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s
      | OP ->
          _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s
      | NOT ->
          _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s
      | ID _v ->
          _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s
      | FALSE ->
          _menhir_run_05 _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s
      | _ ->
          _eRR ()
  
  and _menhir_run_04 : type  ttv_stack. ttv_stack -> _ -> _ -> _ -> (ttv_stack, _menhir_box_model) _menhir_state -> _menhir_box_model =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s ->
      let _tok = _menhir_lexer _menhir_lexbuf in
      let _1 = _v in
      let _v = _menhir_action_09 _1 in
      _menhir_goto_formula _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_run_05 : type  ttv_stack. ttv_stack -> _ -> _ -> (ttv_stack, _menhir_box_model) _menhir_state -> _menhir_box_model =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s ->
      let _tok = _menhir_lexer _menhir_lexbuf in
      let _v = _menhir_action_03 () in
      _menhir_goto_formula _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  and _menhir_run_12 : type  ttv_stack. (ttv_stack, _menhir_box_model) _menhir_cell1_formula -> _ -> _ -> _menhir_box_model =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer ->
      let _menhir_s = MenhirState12 in
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | TRUE ->
          _menhir_run_01 _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s
      | OP ->
          _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s
      | NOT ->
          _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s
      | ID _v ->
          _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s
      | FALSE ->
          _menhir_run_05 _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s
      | _ ->
          _eRR ()
  
  and _menhir_run_14 : type  ttv_stack. (ttv_stack, _menhir_box_model) _menhir_cell1_formula -> _ -> _ -> _menhir_box_model =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer ->
      let _menhir_s = MenhirState14 in
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | TRUE ->
          _menhir_run_01 _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s
      | OP ->
          _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s
      | NOT ->
          _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s
      | ID _v ->
          _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s
      | FALSE ->
          _menhir_run_05 _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s
      | _ ->
          _eRR ()
  
  and _menhir_run_10 : type  ttv_stack. (ttv_stack, _menhir_box_model) _menhir_cell1_formula -> _ -> _ -> _menhir_box_model =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer ->
      let _menhir_s = MenhirState10 in
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | TRUE ->
          _menhir_run_01 _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s
      | OP ->
          _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s
      | NOT ->
          _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s
      | ID _v ->
          _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s
      | FALSE ->
          _menhir_run_05 _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s
      | _ ->
          _eRR ()
  
  and _menhir_run_15 : type  ttv_stack. ((ttv_stack, _menhir_box_model) _menhir_cell1_formula as 'stack) -> _ -> _ -> _ -> ('stack, _menhir_box_model) _menhir_state -> _ -> _menhir_box_model =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match (_tok : MenhirBasics.token) with
      | OR ->
          let _menhir_stack = MenhirCell1_formula (_menhir_stack, _menhir_s, _v) in
          _menhir_run_08 _menhir_stack _menhir_lexbuf _menhir_lexer
      | IMPL ->
          let _menhir_stack = MenhirCell1_formula (_menhir_stack, _menhir_s, _v) in
          _menhir_run_12 _menhir_stack _menhir_lexbuf _menhir_lexer
      | EQUIV ->
          let _menhir_stack = MenhirCell1_formula (_menhir_stack, _menhir_s, _v) in
          _menhir_run_14 _menhir_stack _menhir_lexbuf _menhir_lexer
      | AND ->
          let _menhir_stack = MenhirCell1_formula (_menhir_stack, _menhir_s, _v) in
          _menhir_run_10 _menhir_stack _menhir_lexbuf _menhir_lexer
      | CL ->
          let MenhirCell1_formula (_menhir_stack, _menhir_s, _1) = _menhir_stack in
          let _3 = _v in
          let _v = _menhir_action_08 _1 _3 in
          _menhir_goto_formula _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | _ ->
          _eRR ()
  
  and _menhir_run_13 : type  ttv_stack. ((ttv_stack, _menhir_box_model) _menhir_cell1_formula as 'stack) -> _ -> _ -> _ -> ('stack, _menhir_box_model) _menhir_state -> _ -> _menhir_box_model =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match (_tok : MenhirBasics.token) with
      | OR ->
          let _menhir_stack = MenhirCell1_formula (_menhir_stack, _menhir_s, _v) in
          _menhir_run_08 _menhir_stack _menhir_lexbuf _menhir_lexer
      | IMPL ->
          let _menhir_stack = MenhirCell1_formula (_menhir_stack, _menhir_s, _v) in
          _menhir_run_12 _menhir_stack _menhir_lexbuf _menhir_lexer
      | EQUIV ->
          let _menhir_stack = MenhirCell1_formula (_menhir_stack, _menhir_s, _v) in
          _menhir_run_14 _menhir_stack _menhir_lexbuf _menhir_lexer
      | AND ->
          let _menhir_stack = MenhirCell1_formula (_menhir_stack, _menhir_s, _v) in
          _menhir_run_10 _menhir_stack _menhir_lexbuf _menhir_lexer
      | CL ->
          let MenhirCell1_formula (_menhir_stack, _menhir_s, _1) = _menhir_stack in
          let _3 = _v in
          let _v = _menhir_action_07 _1 _3 in
          _menhir_goto_formula _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | _ ->
          _eRR ()
  
  and _menhir_run_11 : type  ttv_stack. ((ttv_stack, _menhir_box_model) _menhir_cell1_formula as 'stack) -> _ -> _ -> _ -> ('stack, _menhir_box_model) _menhir_state -> _ -> _menhir_box_model =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match (_tok : MenhirBasics.token) with
      | OR ->
          let _menhir_stack = MenhirCell1_formula (_menhir_stack, _menhir_s, _v) in
          _menhir_run_08 _menhir_stack _menhir_lexbuf _menhir_lexer
      | AND ->
          let _menhir_stack = MenhirCell1_formula (_menhir_stack, _menhir_s, _v) in
          _menhir_run_10 _menhir_stack _menhir_lexbuf _menhir_lexer
      | CL | EQUIV | IMPL ->
          let MenhirCell1_formula (_menhir_stack, _menhir_s, _1) = _menhir_stack in
          let _3 = _v in
          let _v = _menhir_action_05 _1 _3 in
          _menhir_goto_formula _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | _ ->
          _eRR ()
  
  and _menhir_run_09 : type  ttv_stack. ((ttv_stack, _menhir_box_model) _menhir_cell1_formula as 'stack) -> _ -> _ -> _ -> ('stack, _menhir_box_model) _menhir_state -> _ -> _menhir_box_model =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match (_tok : MenhirBasics.token) with
      | OR ->
          let _menhir_stack = MenhirCell1_formula (_menhir_stack, _menhir_s, _v) in
          _menhir_run_08 _menhir_stack _menhir_lexbuf _menhir_lexer
      | AND ->
          let _menhir_stack = MenhirCell1_formula (_menhir_stack, _menhir_s, _v) in
          _menhir_run_10 _menhir_stack _menhir_lexbuf _menhir_lexer
      | CL | EQUIV | IMPL ->
          let MenhirCell1_formula (_menhir_stack, _menhir_s, _1) = _menhir_stack in
          let _3 = _v in
          let _v = _menhir_action_06 _1 _3 in
          _menhir_goto_formula _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | _ ->
          _eRR ()
  
  and _menhir_run_07 : type  ttv_stack. ((ttv_stack, _menhir_box_model) _menhir_cell1_OP as 'stack) -> _ -> _ -> _ -> ('stack, _menhir_box_model) _menhir_state -> _ -> _menhir_box_model =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok ->
      match (_tok : MenhirBasics.token) with
      | OR ->
          let _menhir_stack = MenhirCell1_formula (_menhir_stack, _menhir_s, _v) in
          _menhir_run_08 _menhir_stack _menhir_lexbuf _menhir_lexer
      | IMPL ->
          let _menhir_stack = MenhirCell1_formula (_menhir_stack, _menhir_s, _v) in
          _menhir_run_12 _menhir_stack _menhir_lexbuf _menhir_lexer
      | EQUIV ->
          let _menhir_stack = MenhirCell1_formula (_menhir_stack, _menhir_s, _v) in
          _menhir_run_14 _menhir_stack _menhir_lexbuf _menhir_lexer
      | CL ->
          let _tok = _menhir_lexer _menhir_lexbuf in
          let MenhirCell1_OP (_menhir_stack, _menhir_s) = _menhir_stack in
          let _2 = _v in
          let _v = _menhir_action_01 _2 in
          _menhir_goto_formula _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
      | AND ->
          let _menhir_stack = MenhirCell1_formula (_menhir_stack, _menhir_s, _v) in
          _menhir_run_10 _menhir_stack _menhir_lexbuf _menhir_lexer
      | _ ->
          _eRR ()
  
  and _menhir_run_06 : type  ttv_stack. (ttv_stack, _menhir_box_model) _menhir_cell1_NOT -> _ -> _ -> _ -> _ -> _menhir_box_model =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer _v _tok ->
      let MenhirCell1_NOT (_menhir_stack, _menhir_s) = _menhir_stack in
      let _2 = _v in
      let _v = _menhir_action_04 _2 in
      _menhir_goto_formula _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s _tok
  
  let _menhir_run_00 : type  ttv_stack. ttv_stack -> _ -> _ -> _menhir_box_model =
    fun _menhir_stack _menhir_lexbuf _menhir_lexer ->
      let _menhir_s = MenhirState00 in
      let _tok = _menhir_lexer _menhir_lexbuf in
      match (_tok : MenhirBasics.token) with
      | TRUE ->
          _menhir_run_01 _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s
      | OP ->
          _menhir_run_02 _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s
      | NOT ->
          _menhir_run_03 _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s
      | ID _v ->
          _menhir_run_04 _menhir_stack _menhir_lexbuf _menhir_lexer _v _menhir_s
      | FALSE ->
          _menhir_run_05 _menhir_stack _menhir_lexbuf _menhir_lexer _menhir_s
      | _ ->
          _eRR ()
  
end

let model =
  fun _menhir_lexer _menhir_lexbuf ->
    let _menhir_stack = () in
    let MenhirBox_model v = _menhir_run_00 _menhir_stack _menhir_lexbuf _menhir_lexer in
    v
