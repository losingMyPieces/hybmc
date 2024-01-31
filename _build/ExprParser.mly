%{
    open Global
    let get_name id = fst id
    let get_line id = snd id
%}

%token TRUE
%token FALSE
%token <string*int> ID
%token NOT
%token AND
%token OR
%token IMPL
%token EQUIV
%token OP
%token CL
%token EOF

%right AND OR
%nonassoc NOT

%start main
%type <Expression.expression> main
%type <Expression.expression> expression

%%

main:
    | expression EOF            { $1 }

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



