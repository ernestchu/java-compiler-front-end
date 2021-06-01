#!/bin/sh
if [[ $# != 1 ]]
then
    echo "Usage: $0 file (e.g. B073040018.y)"
    exit 1
fi

egrep -o '[^ ]+_opt' $1 | sort | uniq \
| sed 's,\(.*\)_opt,& : \1 | /* empty */ ;,'
