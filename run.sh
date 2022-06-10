#!/bin/sh

if [ -f "$1.asm" ]; then
  as -mfpu=vfp "$1.asm" -o "$1.o";
  gcc "$1.o" -march="armv8-a" -o $1;
  ./$1;
  rm $1 "$1.o";
else
  echo "File not found."
fi
