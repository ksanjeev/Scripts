#!/bin/bash

chaos () {
 if [ "$1" = "begin" ]
 then
         butterfly_wings="flapping"
         location="Brazil"
         return 0
 else
         return 1
 fi
}

theorize () {

 chaos_result=$?
 if [ "$butterfly_wings" = "flapping" ] 
 then
         tornado="Texas"
 fi

 if [ $chaos_result -eq 0 ] 
 then
         echo -n "If a butterfly flaps its wings in $location, a tornado“
         echo " is caused in $tornado."
 else
         echo -n "When a butterfly rests at night in $location, the”
         echo " stars are big and bright in $tornado."
 fi
}

# Begin the chaos
chaos yes

# What happens when we instigate chaos?
theorize

# Stop the madness
chaos no

# What happens when there is no chaos?
theorize
