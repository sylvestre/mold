#!/bin/bash
export LANG=
set -e
testname=$(basename -s .sh "$0")
echo -n "Testing $testname ... "
cd "$(dirname "$0")"/../..
mold="$(pwd)/mold"
t="$(pwd)/out/test/elf/$testname"
mkdir -p "$t"

cat <<EOF | clang -c -o "$t"/a.o -x assembler -
.globl _start
_start:
  ret
EOF

"$mold" -o "$t"/exe "$t"/a.o

readelf --sections "$t"/exe > "$t"/log
! fgrep .interp "$t"/log || false

readelf --dynamic "$t"/exe > "$t"/log

"$mold" -o "$t"/exe "$t"/a.o --dynamic-linker=/foo/bar

readelf --sections "$t"/exe > "$t"/log
fgrep -q .interp "$t"/log

echo OK
