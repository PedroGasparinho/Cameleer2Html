# Cameleer2Html

A lexer to translate Cameleer programs to Html files.

---

What is a Cameleer program? For simplicity, we denominate OCaml files with GOSPEL specifications as Cameleer files.

OCaml - https://ocaml.org/about \
GOSPEL - https://github.com/ocaml-gospel/gospel \
Cameleer - https://github.com/ocaml-gospel/cameleer

---

This project uses as a basis a lexer for (pure) OCaml programs by Jean-Christophe Filliâtre and the team behind the course Langages de programmation et compilation 2024-2025 at École Normale Supérieure.

Base lexer - https://usr.lmf.cnrs.fr/~jcf/ens/compil/caml2html.mll.html \
Course - https://usr.lmf.cnrs.fr/~jcf/ens/compil/ \
Jean-Christophe Filliâtre - https://usr.lmf.cnrs.fr/~jcf/index.fr.html \
École Normale Supérieure - https://www.ens.psl.eu/

## Usage

Convert lexer to OCaml program - ocamllex cameleer2html.mll \
Compile lexer result - ocamlopt- o cameleer2html cameleer2html.ml \
Convert example.ml to Html - ./cameleer2html example.ml false \
The first argument is the .ml file to be parsed into HTML \
The second argument is a boolean to print line numbers (Can be omitted and its default is true)

## Styling

The selected color code is personal preference and does not fully cover
every facet of the language, such as official module names.