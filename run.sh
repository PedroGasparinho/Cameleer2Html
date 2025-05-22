#!/bin/sh

file=$1
readonly file

title=$2

lines=$3

if [ -e $file ]
then
  make
  ./cameleer2html $file $title $lines
else
  echo "File not found"
fi