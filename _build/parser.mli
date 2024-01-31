
(* The type of tokens. *)

type token = 
  | UNTIL
  | TRUE
  | RELEASE
  | OR
  | OP
  | NOT
  | NEXT
  | IMPL
  | ID of (string*int)
  | GLOBALLY
  | FORALL
  | FALSE
  | EXISTS
  | EVENTUALLY
  | EQUIV
  | EOF
  | DOT
  | CL
  | AND

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val main: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Formula.formula)
