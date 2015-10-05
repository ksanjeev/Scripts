#!/bin/ksh
#
# keysw
#
# Shell script the tell you the position of the keyswitch on the front
# of a classical RS6000 (MCA).
#
# John Roebuck - 14/04/99
#

position=`bootinfo -k`

case $position
in
  1)  description="Secure";;

  2)  description="Service";;

  3)  description="Normal";;
esac

echo "\nThe keyswitch is in the \""$description"\" position.\n"                