module E = Expression
type formula =
  | True
  | False
  | General of E.expression
  | Exists of string * formula
  | Forall of string * formula
  | Next of formula
  | Finally of formula
  | Globally of formula
  | Until of formula * formula
  | Release of formula * formula
  | Not of formula
  | Or of formula * formula
  | And of formula * formula
  | Impl of formula * formula
  | Equiv of formula * formula
