#!/bin/bash

countdown() {

      if [ $1 -lt 0 ]
      then
        echo “Blast off!”
        return 0
      fi

      current_value=$1
      echo $current_value
      current_value=`expr $1 - 1`
      countdown $current_value
}

countdown 10

if [ $? -eq 0 ]
then
  echo “We have lift-off!”
  exit 0
fi
