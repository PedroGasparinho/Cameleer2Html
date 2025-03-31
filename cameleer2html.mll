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
    print ".keyword { color: green; } .comment { color: #990000; } .number { color: black; }";
    print "</style></head><body><pre>"

  let count = ref 0
  let newline () = incr count; print "\n<span class=\"number\">%3d</span>: " !count
  let () = newline ()


  let is_keyword =
    let ht = Hashtbl.create 97 in
    List.iter
      (fun s -> Hashtbl.add ht s ())
      [ "and"; "as"; "assert"; "asr"; "begin"; "class";
      "closed"; "constraint"; "do"; "done"; "downto"; "else";
      "end"; "exception"; "external"; "false"; "for"; "fun";
      "function"; "functor"; "if"; "in"; "include"; "inherit";
      "land"; "lazy"; "let"; "lor"; "lsl"; "lsr";
      "lxor"; "match"; "method"; "mod"; "module"; "mutable";
      "new"; "of"; "open"; "or"; "parser"; "private";
      "rec"; "sig"; "struct"; "then"; "to"; "true";
      "try"; "type"; "val"; "virtual"; "when"; "while";
      "with" ];
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
      end else
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