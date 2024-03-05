module E = Expression
 type variable = string
type literal =
| Atom of variable
| NotAtom of variable

type formula =
  | True
  | False
  | Literal of literal
  | Exists of string * formula
  | Forall of string * formula
  | Next of formula
  | Finally of E.expression
  | Globally of E.expression
  | Until of E.expression * E.expression
  | Release of E.expression * E.expression
  | Not of formula
  | Or of formula * formula
  | And of formula * formula
  | Impl of formula * formula
  | Equiv of formula * formula
