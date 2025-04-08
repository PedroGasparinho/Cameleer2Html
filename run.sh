#!/bin/sh

file=$1
readonly file

lines=$2

if [ -e $file ]
then
  make
  ./cameleer2html $file $lines
else
  echo "File not found"
fi