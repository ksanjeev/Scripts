#!/bin/ksh
# clock.sh
#
# Diplays the time on an classic RS6000 led display.
# Needs to be run with root authority.
#
# John Roebuck - 27/05/99
#

while true
do

        m=`date +%M`
        h=`date +%H`

        /usr/lib/methods/showled 0x$h
        sleep 1
        /usr/lib/methods/showled 0x$m
        sleep 1
        /usr/lib/methods/showled
        sleep 1
done