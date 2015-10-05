#! /usr/bin/ksh

gcc --version > gcc
awk '{print $3}' gcc > gccversion
