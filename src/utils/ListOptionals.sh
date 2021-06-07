#!/bin/sh
if [ $# != 1 ]
then
    echo "Usage: $0 file (e.g. Parser.y)"
    exit 1
fi

egrep -o '[^ ]+Opt' $1 | sort | uniq \
| sed 's,\(.*\)Opt,& : \1 | /* empty */ ;,'
