all:
	ocamllex cameleer2html.mll
	ocamlopt -o cameleer2html cameleer2html.ml

.PHONY:
	all