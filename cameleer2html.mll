{
  let print_line_numbers = ref true
  
  let () =
    if Array.length Sys.argv = 3 then
      print_line_numbers := bool_of_string Sys.argv.(2)
    else if Array.length Sys.argv <> 2
    || not (Sys.file_exists Sys.argv.(1)) then begin
      Printf.eprintf "usage: caml2html file\n";
      exit 1
    end

  let file = Sys.argv.(1)
  let cout = open_out (file ^ ".html")
  let print s = Printf.fprintf cout s

  let () =
    print "<!DOCTYPE html>";
    print "<html><head><title>%s</title><style>" file;
    print "span {tab-size: 2;} ";
    print ".logical { color:rgb(226, 124, 106); } "; (* #d87b6b *)
    print ".keyword { color: red; } ";
    print ".contract { color: #2177bf; } "; (* #2177bf *)
    print ".comment { color: #666666; } "; (* #666666 *)
    print ".number { color: black; }";
    print "</style></head><body><pre>"

  let count = ref 0
  let newline () = 
    if !print_line_numbers then begin
      incr count; print "\n<span class=\"number\">%3d</span>: " !count
    end
    else print "\n"
  let () = newline ()

  let keywords = [ "and"; "as"; "assert"; "asr"; "class"; "closed"; 
    "constraint";  "do"; "done"; "downto"; "else"; "exception"; "external"; 
    "for"; "function"; "functor"; "if"; "in"; "include"; "inherit"; "land"; 
    "lazy"; "let"; "lor"; "lsl"; "lsr"; "lxor"; "match"; "method"; "mod"; 
    "mutable"; "new"; "of"; "open"; "or"; "parser"; "private"; "rec"; "then"; 
    "to"; "try"; "virtual"; "when"; "while"; "with"; "module"; "sig"; "struct"; 
    "begin"; "end"; "type"; "val"; "int"; "bool"; "float"; "char"; "string"; 
    "bytes"; "array"; "list"; "option"; "None"; "Some"; "fun"; "'a"; "'b";
    "Bool"; "Float"; "Char"; "String"; "Bytes"; "Array"; "List"; "Printf"; 
    "true"; "false"; "Fun"; "function"; "ensures"; "variant"; "invariant";
    "lemma"; "requires"; "axiom"; "predicate"; "forall"; "exists" ]

  let kw_len = List.length keywords

  let is_keyword =
    let ht = Hashtbl.create kw_len in
    List.iter (fun s -> Hashtbl.add ht s ()) keywords;
    fun s -> Hashtbl.mem ht s

}


let ident = ['A'-'Z' 'a'-'z' '_'] ['A'-'Z' 'a'-'z' '0'-'9' '_']*

rule scan = parse
  | "(*@" { print "<span class=\"contract\">(*@";
             comment lexbuf;
             print "</span>";
             scan lexbuf }
  | "(*"   { print "<span class=\"comment\">(*";
             comment lexbuf;
             print "</span>";
             scan lexbuf }
  | eof    { () }
  | ident as s
    { if is_keyword s then begin
        print "<span class=\"keyword\">%s</span>" s
      end 
      else print "%s" s; scan lexbuf }
  | "<"    { print "&lt;"; scan lexbuf }
  | "&"    { print "&amp;"; scan lexbuf }
  | "\n"   { newline (); scan lexbuf }
  | '"'    { print "\""; string lexbuf; scan lexbuf }
  | "'\"'"
  | _ as s { print "%s" s; scan lexbuf }
and comment = parse
  | "(*"   { print "(*"; comment lexbuf; comment lexbuf }
  | "*)"   { print "*)" }
  | eof    { () }
  | ident as s
  { if is_keyword s then begin
        print "<span class=\"logical\">%s</span>" s
      end 
      else print "%s" s; comment lexbuf }
  | "\n"   { newline (); comment lexbuf }
  | '"'    { print "\""; string lexbuf; comment lexbuf }
  | "<"    { print "&lt;"; comment lexbuf }
  | "&"    { print "&amp;"; comment lexbuf }
  | "'\"'"
  | _ as s { print "%s" s; comment lexbuf }
and string = parse
  | '"'    { print "\"" }
  | "<"    { print "&lt;"; string lexbuf }
  | "&"    { print "&amp;"; string lexbuf }
  | "\\" _
  | _ as s { print "%s" s; string lexbuf }

{
  let () =
    scan (Lexing.from_channel (open_in file));
    print "</pre>\n</body></html>\n";
    close_out cout

}