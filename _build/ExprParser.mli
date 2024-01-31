
(* The type of tokens. *)

type token = 
  | TRUE
  | OR
  | OP
  | NOT
  | IMPL
  | ID of (string*int)
  | FALSE
  | EQUIV
  | EOF
  | CL
  | AND

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val main: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Expression.expression)
