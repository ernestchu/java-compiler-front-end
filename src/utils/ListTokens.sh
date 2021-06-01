#!/bin/sh
if [[ $# != 1 ]]
then
    echo "Usage: $0 file (e.g. B073040018.l)"
    exit 1
fi

sed -n 's/.*return *\(.*\) *;.*/\1/p' $1 | tr '\n' ' '
echo
