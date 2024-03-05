%token TRUE
%token FALSE
%token <string*int> ID
%token NOT
%token AND
%token OR
%token IMPL
%token EQUIV
%token NEXT
%token UNTIL
%token RELEASE
%token EVENTUALLY
%token GLOBALLY
%token OP
%token CL
%token FORALL
%token EXISTS
%token DOT
%token EOF

%right UNTIL RELEASE
%left IMPL EQUIV
%left AND OR
%nonassoc EVENTUALLY GLOBALLY
%nonassoc NOT NEXT

%{
    open Formula
    open Expression
    open Global

    let get_name id = fst id
    let get_line id = snd id
%}

%start main
%type <Formula.formula> main
%type <Formula.formula> formula_expr
%type <Expression.expression> expression

%%

expression:
    | OP expression CL           { $2 }
    | TRUE                    { Expression.True }
    | FALSE                   { Expression.False }
    | NOT expression             { let phi = $2 in
                                match phi with
                                 | Expression.Literal(Expression.Atom(name)) -> Expression.Literal(Expression.NotAtom(name))
                                 | _ -> Expression.Not(phi) }
    | expression AND expression         { Expression.And ($1,$3) }
    | expression OR expression          { Expression.Or ($1,$3) }
    | expression IMPL expression        { Expression.Impl ($1,$3) }
    | expression EQUIV expression       { Expression.Equiv ($1,$3) }
    | ID                      { Expression.Literal(Atom(get_name($1)))}

formula_expr:
    | TRUE                                      { Formula.True }
    | FALSE                                     { Formula.False }
    | ID                                        { Formula.Literal(Formula.Atom(get_name($1))) }
    | NOT f=formula_expr                        { Formula.Not (f) }
    | f=formula_expr AND g=formula_expr         { Formula.And (f,g) }
    | f=formula_expr OR g=formula_expr          { Formula.Or (f,g) }
    | f=formula_expr IMPL g=formula_expr        { Formula.Impl (f,g) }
    | f=formula_expr EQUIV g=formula_expr       { Formula.Equiv (f,g) }
    | NEXT f=formula_expr                       { Formula.Next (f) }
    | f=expression UNTIL g=expression       { Formula.Until (f,g) }
    | f=expression RELEASE g=expression     { Formula.Release (f,g) }
    | EVENTUALLY f=expression                 { Formula.Finally (f) }
    | GLOBALLY f=expression                   { Formula.Globally (f) }
    | OP f=formula_expr CL                      { f }
    | EXISTS s=ID f=formula_expr   { Formula.Exists (get_name(s),f) }
    | FORALL s=ID f=formula_expr   { Formula.Forall (get_name(s),f) }

main:
    | EXISTS s=ID f=formula_expr   { Formula.Exists (get_name(s),f) }
    | FORALL s=ID f=formula_expr   { Formula.Forall (get_name(s),f) }
    | NOT f=main                   { Formula.Not (f) }
    | OP f=main CL                 { f }
    | f=formula_expr EOF           { f }

