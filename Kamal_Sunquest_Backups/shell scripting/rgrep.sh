#!/bin/ksh
#
# rgrep.sh - recursive grep (find and grep)
#
# John Roebuck - 01/11/99

if [ $# -ne 2 ]
   then echo " "
        echo "Usage : rgrep.sh path what-to-grep-for"
        echo " "
        exit 1
fi

find $1 -exec grep -l "$2" {} \;
