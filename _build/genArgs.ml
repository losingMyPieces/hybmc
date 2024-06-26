(******************************************************************************)
(* @file GenArgs.ml                                                           *)
(* Command Line Arguments for genqbf                                          *)
(******************************************************************************)

exception MoreThanOneInputFile
exception No_file

let is_input_file = ref false
let is_output_file = ref false

let input_file  = ref ""
let output_file  = ref ""

let output_channel = ref Stdlib.stdout
let input_channel = ref Stdlib.stdin

(* Program arguments *)
let debugFlag       = ref false
let fastFlag       = ref false

let assignopt (valref : 'a ref) (valbool : bool ref) (aval : 'a) : unit =
  valref := aval ; valbool := true

let setdebug () =
  (*  Debug.enable_debug(); *)
  debugFlag := true

let setfast () =
  (*  Debug.enable_debug(); *)
  fastFlag := true

let onlyParse = ref false
let onlyparse() =  onlyParse := true


let anonymous = ref false
let doanonymous() =  anonymous := true


let toNum = ref false
let tonum() = toNum := true


let simplify = ref false

let dosimplify() =
  simplify := true

let convert_opt_list = ["dnf"; "cnf"; "nnf"]
type convert_t = DNF | CNF | NNF

let conversion = ref None

let set_convert (co:string) : unit  =
  match co with
  | "dnf" -> conversion := Some DNF
  | "cnf" -> conversion := Some CNF
  | "nnf" -> conversion := Some NNF
  | _ -> conversion := None


(* -F qcir|dimacs|aiger *)
type output_format_t = QCIR | QDIMACS | AIGER
let output_format_list = ["qcir"; "qdimacs"; "qaiger"]
let format = ref None
let set_output_format (fmt:string) : unit =
  match fmt with
  | "qcir"    -> format := Some QCIR
  | "qdimacs" -> format := Some QDIMACS
  | "qaiger"   -> format := Some AIGER
  | _         -> format := None


(* -i filename *)
let set_input_file (s:string) : unit = input_file:=s ; is_input_file:=true

(* -o filename *)
let set_output_file (s:string) : unit = output_file:=s ; is_output_file:=true

let print_vars = ref false

(* -k k *)
let is_unroll_num = ref false
let unroll_num    = ref 0
let set_unroll_num k =  is_unroll_num := true;  unroll_num    := k


(* ---------------only one model needed------------------ *)

 (* -I initial_file *)
 let is_initial_file_A = ref false
 let initial_file_A = ref ""
 let set_initial_file_A s =  is_initial_file_A := true ;  initial_file_A := s

 (* -R transition_file *)
 let is_transition_file_A = ref false
 let transition_file_A = ref ""
 let set_transition_file_A s =  is_transition_file_A := true ;  transition_file_A := s

(* -Q hyperctl_file *)
let is_hyperctl_file = ref false
let hyperctl_file = ref ""
let set_hyperctl_file s =  is_hyperctl_file := true ;  hyperctl_file := s


(* -sem  OPT | PES *)
type semantics = OPT | PES
let unrolling_semantics_list = ["OPT"; "PES"]
let unrolling_semantics = ref None
let set_unrolling_semantics (fmt:string) : unit =
  match fmt with
    "OPT" -> unrolling_semantics  := Some OPT
  | "PES" -> unrolling_semantics  := Some PES
  | _    -> unrolling_semantics  := None


let opts =
  [
    ("-i", Arg.String set_input_file, "input file");
    ("-a", Arg.Unit   doanonymous, "do not append \"_A\" and \"_B\" for systems A and B");
    ("-I", Arg.String set_initial_file_A, "input file for initial state for A");
    ("-R", Arg.String set_transition_file_A, "input file for transition relation for A");
    ("-Q", Arg.String set_hyperctl_file, "hyperctl* file");
    ("-sem", Arg.Symbol (unrolling_semantics_list,set_unrolling_semantics), "semantics of the unrolling:(optimistic/pessimistic)");
    ("-k", Arg.Int set_unroll_num, "integer depth of the unrolling");
    ("-n", Arg.Unit tonum, "transform variable ids to numeric");
    ("-o", Arg.String set_output_file, "output file");
    ("-f", Arg.Symbol (output_format_list, set_output_format), "output format: qcir, qdimacs, qaiger");
    ("-c", Arg.Symbol (convert_opt_list,set_convert)," convert to CNF or DNF");
    ("-s", Arg.Unit dosimplify, "perform simplification after conversion");
    ("-p", Arg.Unit onlyparse, "only parse the input formula and print it");
    ("--debug", Arg.Unit setdebug,  "debug output information");
    ("--fast", Arg.Unit setfast,  "use tail recursive faster algorithms");
  ]

let anon_fun str =
  if !is_input_file then raise(MoreThanOneInputFile)
  else set_input_file str

let usagemsg =
  "Parses a Boolean formula and generates a representation of the input formula
and generates output of the formula in some formats: Boolean (default) QCIR, QDIMACS, AIGER.
It can optionally transform the formula to cnf,dnf,nnf and perform simple simplifications."

let error msg = Arg.usage opts msg ; exit 0
let simple_error msg = Printf.eprintf "%s\n" msg ; exit 0
let postcheck () = ()

let parse_args _ =
  Arg.parse opts anon_fun usagemsg;
  postcheck ()


let open_input _ =
  if !is_input_file then
    if(String.equal !input_file "-") then
	input_channel := Stdlib.stdin
    else
      begin
	input_channel := Stdlib.open_in !input_file
    (* input_file_fd := Unix.openfile !input_file [Unix.O_RDONLY] 0 ; *)
    (* input_channel := Unix.in_channel_of_descr !input_file_fd *)
      end
  else
    raise(No_file)
  ;
  !input_channel

    (*stdin*)

let close_input _ =
(*  if !is_input_file then Unix.close !input_file_fd*)
  Stdlib.close_in !input_channel

let open_output _ =
  if !is_output_file then
    begin
      output_channel := Stdlib.open_out !output_file
  (*   output_file_fd := Unix.openfile !output_file [Unix.O_WRONLY] 0 ; *)
  (* Unix.out_channel_of_descr !output_file_fd *)
    end
  ;
  !output_channel

let close_output _ =
  Stdlib.close_out !output_channel
(* if !is_output_file then Unix.close !output_file_fd *)
