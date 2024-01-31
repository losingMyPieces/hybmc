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

%%

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
    | f=formula_expr UNTIL g=formula_expr       { Formula.Until (f,g) }
    | f=formula_expr RELEASE g=formula_expr     { Formula.Release (f,g) }
    | EVENTUALLY f=formula_expr                 { Formula.Finally (f) }
    | GLOBALLY f=formula_expr                   { Formula.Globally (f) }
    | OP f=formula_expr CL                      { f }
    | EXISTS s=ID f=formula_expr   { Formula.Exists (get_name(s),f) }
    | FORALL s=ID f=formula_expr   { Formula.Forall (get_name(s),f) }

main:
    | EXISTS s=ID f=formula_expr   { Formula.Exists (get_name(s),f) }
    | FORALL s=ID f=formula_expr   { Formula.Forall (get_name(s),f) }
    | NOT f=main                   { Formula.Not (f) }
    | OP f=main CL                 { f }
    | f=formula_expr EOF           { f }

