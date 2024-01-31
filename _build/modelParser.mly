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


%right IMPL EQUIV
%right AND OR
%nonassoc NOT



%start model
%type <Model.expression> model



%%

model:
    | formula               { $1 }

formula:
    | OP formula CL           { $2 }
    | TRUE                    { Model.True }
    | FALSE                   { Model.False }
    | NOT formula             { let phi = $2 in
                                match phi with
                                 | Model.Literal(Model.Atom(name)) -> Model.Literal(Model.NotAtom(name))
                                 | _ -> Model.Not(phi) }
    | formula AND formula         { Model.And ($1,$3) }
    | formula OR formula          { Model.Or ($1,$3) }
    | formula IMPL formula        { Model.Impl ($1,$3) }
    | formula EQUIV formula       { Model.Equiv ($1,$3) }
    | ID                      { Model.Literal(Atom(get_name($1)))}



