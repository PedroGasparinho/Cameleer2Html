{
  let () =
    if Array.length Sys.argv <> 2
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
    print "span {tab-size: 3;} ";
    print ".module { color: #f78d02; } ";
    print ".type { color: green; } ";
    print ".keyword { color: red; } ";
    print ".comment { color: #2177bf; } ";
    print ".number { color: black; }";
    print "</style></head><body><pre>"

  let count = ref 0
  let newline () = incr count; print "\n<span class=\"number\">%3d</span>: " !count
  let () = newline ()

  let is_module =
    let ht = Hashtbl.create 5 in
    List.iter
      (fun s -> Hashtbl.add ht s ())
      ["module"; "sig"; "struct"; "begin"; "end"];
    fun s -> Hashtbl.mem ht s
  
  let is_type =
    let ht = Hashtbl.create 28 in
    List.iter
      (fun s -> Hashtbl.add ht s ())
      ["type"; "val"; "int"; "bool"; "float"; "char"; "string"; "bytes";
        "array"; "list"; "option"; "None"; "Some"; "fun"; "'a"; "'b";
        "Bool"; "Float"; "Char"; "String"; "Bytes"; "Array"; "List";
        "Printf"; "true"; "false"; "Fun"; "function"];
    fun s -> Hashtbl.mem ht s

  let is_keyword =
    let ht = Hashtbl.create 45 in
    List.iter
      (fun s -> Hashtbl.add ht s ())
      [ "and"; "as"; "assert"; "asr"; "class"; "closed"; "constraint"; 
        "do"; "done"; "downto"; "else"; "exception"; "external"; "for"; 
        "function"; "functor"; "if"; "in"; "include"; "inherit"; "land"; 
        "lazy"; "let"; "lor"; "lsl"; "lsr"; "lxor"; "match"; "method"; 
        "mod"; "mutable"; "new"; "of"; "open"; "or"; "parser"; "private"; 
        "rec"; "then"; "to"; "try"; "virtual"; "when"; "while"; "with" ];
    fun s -> Hashtbl.mem ht s

}


let ident = ['A'-'Z' 'a'-'z' '_'] ['A'-'Z' 'a'-'z' '0'-'9' '_']*

rule scan = parse
  | "(*"   { print "<span class=\"comment\">(*";
             comment lexbuf;
             print "</span>";
             scan lexbuf }
  | eof    { () }
  | ident as s
    { if is_keyword s then begin
        print "<span class=\"keyword\">%s</span>" s
      end 
      else if is_module s then begin
        print "<span class=\"module\">%s</span>" s
      end
      else if is_type s then begin
        print "<span class=\"type\">%s</span>" s
      end
      else
        print "%s" s;
        scan lexbuf }
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