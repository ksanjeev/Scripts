#!/bin/ksh
# Determine machine type
# AIX Software Support

MachType=`uname -m | cut -c9-10`
case $MachType
in
  02)  nMachType="930";;
  10)  nMachType="530 or 720 or 730";;
  11|14)  nMachType="540";;
  18)  nMachType="53H";;
  1C)  nMachType="550";;
  20)  nMachType="930";;
  2E)  nMachType="950 or 950E";;
  30)  nMachType="520 or 740 or 741";;
  31)  nMachType="320";;
  34)  nMachType="52H";;
  35)  nMachType="32H or 320E";;
  37)  nMachType="340 or 34H";;
  38)  nMachType="350";;
  41)  nMachType="220 or 22W or 22G or 230";;
  42)  nMachType="41T or 41W";;
  43)  nMachType="M20";;
  45)  nMachType="220 or M20 or 230 or 23W";;
  46)  nMachType="250";;
  47)  nMachType="230";;
  48)  nMachType="C10";;
  49)  nMachType="250";;
  4C)  nMachType="43P";;
  4D)  nMachType="40P";;
  57)  nMachType="390 or 3BT or 3BT or 3AT or 390";;
  58)  nMachType="380 or 3AT or 3BT";;
  59)  nMachType="3CT or 39H";;
  5C)  nMachType="560";;
  63)  nMachType="970 or 97B";;
  64)  nMachType="980 or 98B";;
  66)  nMachType="580 or 58F or 580";;
  67)  nMachType="570 or 770 or 771 or R10 or 570";;
  70)  nMachType="590";;
  71)  nMachType="58H";;
  72)  nMachType="59H or R12 or 58H";;
  75)  nMachType="370 or 375 or 37T";;
  76)  nMachType="360 or 365 or 36T";;
  77)  nMachType="315 or 350 or 355 or 510 or 55H or 55L";;
  78)  nMachType="315 or 510";;
  79)  nMachType="590";;
  80)  nMachType="990";;
  82)  nMachType="R00 or R24";;
  90)  nMachType="C20";;
  91)  nMachType="42T";;
  A0)  nMachType="J30 or R30";;
  A3)  nMachType="R30";;
  A6)  nMachType="G30";;
  C4)  nMachType="F40";;
  E0)  nMachType="603/MOTOROLA PowerStack";;
  *)  nMachType="Unknown($MachType)"
esac
echo $nMachType

