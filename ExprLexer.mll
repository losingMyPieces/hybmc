{
    open ExprParser
    exception LexerError

    let keyword_table = Hashtbl.create 128

    let _ = List.iter (fun (kwd, tok) -> Hashtbl.add keyword_table kwd tok)
          [ ("true" , TRUE);
            ("false", FALSE)]
}

let letter = ['A'-'Z' 'a'-'z']
let mostletters =['A'-'Z' 'a'-'z' '0'-'9' '_' '-' '[' ']' '\'' '.']

rule lex = parse
    | "&" | "/\\"                {Global.last "/\\"; AND }
    | "|" | "\\/"              {Global.last "\\/"; OR }
    | ['~' '!']          { Global.last "~"; NOT }
    | ['-' '='] '>'      { Global.last "->"; IMPL }
    | '<' ['-' '='] '>'  { Global.last "<->"; EQUIV }
    | (letter mostletters*) as id {
            Global.last id;
            try
              Hashtbl.find keyword_table id
            with Not_found ->
              ID (id, Global.get_linenum())
          }
    | [' ' '\t' ]    {Global.last "whitespc"; lex lexbuf }
    | '\n'           {Global.last "\\n"; Global.incr_linenum(); lex lexbuf }
    | "("                { Global.last "("; OP }
    | ")"                {Global.last ")"; CL }
    | eof                {Global.last "EOF"; EOF }
    | _ as x            {Global.last (String.make 1 x); print_endline ("Bad token: " ^ (String.make 1 x)); raise LexerError }