#!/bin/ksh
#
#  wits - What Is The System
#       A shell script that gives information about the RS60000
#       that it is being executed on.
#
# model E0 (motorola) hasn't been included yet.
#
# informations from : man uname (AIX4.1.2)
#                     Bull DPX/20 Reference Guide (rev. 5.3)
# lines with '#' haven't been verified
#
# Rev: 1.2
# Send comments and new info to C.Deignan@frec.bull.fr
#
##################################################################

# set -x
#exec 2>/dev/null

USAGE="Usage : $0 [-l]"
MODNUM=""

#
# input parameters control
#
case $# in
0) MACHIDNUM=`uname -m`
CPUNUM=`echo $MACHIDNUM | cut -c3-8`
MODNUM=`echo $MACHIDNUM | cut -c9-10`
;;

1) if [[ $1 = "-l" ]]
then
clear
print "Model Number\t Model ID   |\tModel Number\t Model ID"
print "\t\t\t\t|\t\t\t\t"
print "DPX/20 100/105\t\t43\t|\tDPX/20 100/110\t\t45"
print "DPX/20 100/130\t\t47\t|\tDPX/20 100/150\t\t46"
print "DPX/20 200/215\t\t42\t|"
print "DPX/20 300/310\t\t48\t|"
print "DPX/20 400/420\t\t37\t|\tDPX 20 400/455\t\t77"
print "DPX/20 400/460\t\t76\t|\tDPX/20 400/465\t\t76"
print "DPX/20 400/470\t\t75\t|\tDPX/20 400/475\t\t75"
print "DPX/20 400/480\t\t58\t|\tDPX/20 400/485\t\t57"
print "DPX/20 400/490\t\t57\t|\tDPX/20 400/495\t\t58"
print "DPX/20 600/630\t\t77\t|\tDPX/20 600/640\t\t67"
print "DPX/20 600/660\t\t66\t|\tDPX/20 600/680\t\t71"
print "DPX/20 600/690\t\t70\t|"
print "DPX/20 800/810\t\t63\t|\tDPX/20 800/840\t\t64"
print "DPX/20 800/890\t\t80\t|\tDPX/20 800/890H\t\t82"
print "\t\t\t\t|\t\t\t\t"
print "DPX/20 ESCALA D201-D401\tA0\t|"
print "DPX/20 ESCALA R201-R401\tA3\t|"
print "DPX/20 ESCALA M101-M401\tA6\t|"
print "\nWhich Model ID do you want ?\t\c"
read MODNUM
else
print $USAGE
exit
fi
;;

*) echo $USAGE
   exit
;;

esac


if test "$TERM" != emacs
then
tput clear
fi

#
# result of `uname -m` :
# 12 digits machine id: xxyyyyyymmss
# where :       xx      system = 00
#       yyyyyy  cpu id
#       mm      model id
#       ss      submodel number = 00

processor=""
processor_num=""
clock_mhz=""
dcache_kB=""
icache_kB=""
L1cache_kB=""
L2cache_MB=""
mflops=""
specmarks=""
specint92=""
specfp92=""
mcabuses=""
mcarate_MBps=""
mem_MB=""
#memrate_MBps=""
other=""

case $MODNUM in

"18") BULLMODEL="Bull DPX/20 Model 620"
IBMMODEL="IBM RISC System/6000 Model 530H"
#  clock_mhz="33"
#  dcache_kB="64"
#  icache_kB="8"
#  mflops="20.2"
#  specmarks="59.9"
#  specint92="28.5"
#  specfp92="45.3"
#  mcabuses="1"
#  mcarate_MBps="40"
#  mem_MB="128"
#  memrate_MBps="528"
;;

"34") BULLMODEL="Bull DPX/20 Model 610"
IBMMODEL="IBM RISC System/6000 Model 520H"
#  clock_mhz="25"
#  dcache_kB="32"
#  icache_kB="8"
#  specint92="21.5"
#  specfp92="45.3"
#  mcabuses="1"
#  mcarate_MBps="40"
#  other="Integrate_MBpsd ethernet\nIntegrate_MBpsd SCSI-1"
;;

"35") BULLMODEL="Bull DPX/20 Model 430"
IBMMODEL="IBM RISC System/6000 Model 320H"
#  clock_mhz="25"
#  dcache_kB="32"
#  icache_kB="8"
#  mflops="11.7"
#  specmarks="43.3"
#  mcabuses="1"
#  mcarate_MBps="40"
#  mem_MB="64"
#  memrate_MBps="160"
;;

"37") BULLMODEL="Bull DPX/20 Model 420"
IBMMODEL="IBM RISC System/6000 Model 34H"
processor="Power"
clock_mhz="42"
dcache_kB="32"
icache_kB="32"
L2cache_MB="No"
#  mflops="14.8"
#  specmarks="56.6"
specint92="48.1"
specfp92="83.3"
mcabuses="1"
mcarate_MBps="80"
mem_MB="from 16 to 512"
#  memrate_MBps="264"
#  other="Integrate_MBpsd ethernet\nIntegrate_MBpsd SCSI"
;;

"38") BULLMODEL="Bull DPX/20 Model 450"
IBMMODEL="IBM RISC System/6000 Model 350"
#  clock_mhz="41.7"
#  dcache_kB="32"
#  icache_kB="8"
#  mflops="18.6"
#  specmarks="71.4"
#  mcabuses="1"
#  mcarate_MBps="40"
#  mem_MB="64"
#  memrate_MBps="333"
#  other="Integrate_MBpsd ethernet\nIntegrate_MBpsd SCSI"
;;

"41") BULLMODEL="Bull DPX/20 Model 115,125,125W,130S,135,135G,140,140S"
IBMMODEL="IBM RISC System/6000 Model 22W,22W,22W+,230S,22G,22G,220,220+"
#  clock_mhz="33"
#  dcache_kB="8"
#  icache_kB="0"
#  mflops="6.5"
#  specmarks="25.9"
#  specint92="16.6"
#  specfp92="26.1"
#  mcabuses="1"
#  mcarate_MBps="40"
#  mem_MB="32"
#  memrate_MBps="89"
#  other="Integrate_MBpsd ethernet\nIntegrate_MBpsd SCSI"
;;

"42") BULLMODEL="Bull DPX/20 Model 215"
IBMMODEL="IBM RISC System/6000 Model 41W"
processor="PowerPC"
clock_mhz="80"
dcache_kB="32"
L2cache_MB="No"
specint92="78.8/88.1"
specfp92="90.4/98.7"
mem_MB="from 16 to 256"
;;

"43") BULLMODEL="Bull DPX/20 Model 105"
#  IBMMODEL="IBM RISC System/6000 Model M20"
#  clock_mhz="33"
#  specint92="16.6"
#  specfp92="26.1"
#  mcabuses="1"
#  mcarate_MBps="40"
;;

"45") BULLMODEL="Bull DPX/20 Model 110"
#  IBMMODEL="IBM RISC System/6000 Model 220"
;;

"46") BULLMODEL="Bull DPX/20 Model 150"
IBMMODEL="IBM RISC System/6000 Model 250"
processor="PowerPC"
clock_mhz="66/80"
dcache_kB="32"
L2cache_MB="No"
specint92="62.6/78.8"
specfp92="72.2/90.4"
mcabuses="1"
mcarate_MBps="80"
mem_MB="from 16 to 256"
;;

"47") BULLMODEL="Bull DPX/20 Model 130"
IBMMODEL="IBM RISC System/6000 Model 230"
processor="Power"
clock_mhz="45"
dcache_kB="8"
L2cache_MB="No"
specint92="28.5"
specfp92="39.9"
mcabuses="1"
mcarate_MBps="40"
mem_MB="from 16 to 64"
;;

"48") BULLMODEL="Bull DPX/20 Model 310"
IBMMODEL="IBM RISC System/6000 Model C10"
processor="PowerPC"
clock_mhz="80"
dcache_kB="32"
L2cache_MB="0/1"
specint92="78.8/90.5"
specfp92="90.4/100.8"
mcabuses="1"
mcarate_MBps="80"
mem_MB="from 16 to 256"
;;

"57") BULLMODEL="Bull DPX/20 Model 485 or 490"
IBMMODEL="IBM RISC System/6000 Model 3AT or 390"
processor="Power2 or Power2-L2"
clock_mhz="59 or 67"
dcache_kB="64"
icache_kB="32"
L2cache_MB="0/0.5/1"
specint92="99.3 or 109.7/113.2/114.3"
specfp92="187.2 or 202.1/204.5/205.3"
mcabuses="1"
mcarate_MBps="80"
mem_MB="from 32 to 512"
;;

"58") BULLMODEL="Bull DPX/20 Model 480 or 495"
IBMMODEL="IBM RISC System/6000 Model 380 or 3BT"
processor="Power2 or Power2-L2"
clock_mhz="59 or 67"
dcache_kB="64"
icache_kB="32"
L2cache_MB="No"
specint92="99.3 or 109.7"
specfp92="187.2"
mcabuses="1"
mcarate_MBps="80"
mem_MB="from 32 to 512"
;;

"5C") BULLMODEL="Bull DPX/20 Model 650"
IBMMODEL="IBM RISC System/6000 Model 560"
#  clock_mhz="50"
#  dcache_kB="64"
#  icache_kB="8"
#  mflops="30.5"
#  specmarks="89.3"
#  mcabuses="1"
#  mcarate_MBps="40"
#  mem_MB="128"
#  memrate_MBps="800"
;;

"63") BULLMODEL="Bull DPX/20 Model 810 or 820"
IBMMODEL="IBM RISC System/6000 Model 97B or 970"
processor="Power"
clock_mhz="50"
dcache_kB="64"
icache_kB="32"
L2cache_MB="No"
#  mflops="30.7"
#  specmarks="100.3"
specint92="58.8"
specfp92="108.9"
mcabuses="2"
mcarate_MBps="80"
mem_MB=" from 128 to 2048"
;;

"64") BULLMODEL="Bull DPX/20 Model 830 or 840"
IBMMODEL="IBM RISC System/6000 Model 980 or 98B"
processor="Power"
clock_mhz="62.5"
dcache_kB="64"
icache_kB="32"
L2cache_MB="No"
specint92="73.3"
specfp92="134.6"
mcabuses="2"
mcarate_MBps="80"
mem_MB="from 128 to 2048"
;;

"66") BULLMODEL="Bull DPX/20 Model 660"
IBMMODEL="IBM RISC System/6000 Model 580"
processor="Power"
clock_mhz="62.5"
dcache_kB="64"
icache_kB="32"
L2cache_MB="No"
specint92="73.3"
specfp92="134.6"
mcabuses="1"
mcarate_MBps="80"
mem_MB="from 64 to 2048"
;;

"67") BULLMODEL="Bull DPX/20 Model 640"
IBMMODEL="IBM RISC System/6000 Model 570"
processor="Power"
clock_mhz="50"
dcache_kB="32"
icache_kB="32"
L2cache_MB="No"
specint92="57.5"
specfp92="99.2"
mcabuses="1"
mcarate_MBps="80"
mem_MB="from 32 to 1024"
;;

"70") BULLMODEL="Bull DPX/20 Model 690"
IBMMODEL="IBM RISC System/6000 Model 590"
processor="Power2"
clock_mhz="66.6"
dcache_kB="256"
icache_kB="32"
L2cache_MB="No"
specint92="121.4"
specfp92="254.2"
mcabuses="1"
mcarate_MBps="80"
mem_MB="from 64 to 2048"
;;

"71") BULLMODEL="Bull DPX/20 Model 680"
IBMMODEL="IBM RISC System/6000 Model 58H"
processor="Power2"
clock_mhz="55.5"
dcache_kB="256"
icache_kB="32"
L2cache_MB="No"
specint92="97.6"
specfp92="203.9"
mcabuses="1"
mcarate_MBps="80"
mem_MB="from 64 to 2048"
;;

"75") BULLMODEL="Bull DPX/20 Model 470 or 475"
IBMMODEL="IBM RISC System/6000 Model 370 or 375"
processor="Power"
clock_mhz="62 or 62.5"
dcache_kB="32"
icache_kB="32"
L2cache_MB="No"
specint92="70.3"
specfp92="121.1"
mcabuses="1"
mcarate_MBps="80"
mem_MB="from 32 to 512"
;;

"76") BULLMODEL="Bull DPX/20 Model 460 or 465"
IBMMODEL="IBM RISC System/6000 Model 360 or 365"
processor="Power"
clock_mhz="50"
dcache_kB="32"
icache_kB="32"
L2cache_MB="No"
specint92="57.5 or 45"
specfp92="99.2 or 89"
mcabuses="1"
mcarate_MBps="80"
mem_MB="from 16 to 512"
;;

"77") BULLMODEL="Bull DPX/20 Model 455 or 630"
IBMMODEL="IBM RISC System/6000 Model 355 or 550L"
processor="Power"
clock_mhz="42"
dcache_kB="32"
icache_kB="32"
L2cache_MB="No"
specint92="48.1"
specfp92="83.3"
mcabuses="1"
mcarate_MBps="80"
mem_MB="from 32 to 256"
;;

"80") BULLMODEL="Bull DPX/20 Model 890"
IBMMODEL="IBM RISC System/6000 Model 990"
processor="Power2"
clock_mhz="71.5"
dcache_kB="256"
icache_kB="32"
L2cache_MB="No"
specint92="131"
specfp92="279"
mcabuses="2"
mcarate_MBps="80"
mem_MB="from 128 to 2048"
;;

"82") BULLMODEL="Bull DPX/20 Model 890H"
IBMMODEL="IBM RISC System/6000 Model R00 or R24"
processor="Power2-L2"
clock_mhz="71.5"
dcache_kB="128"
icache_kB="32"
L2cache_MB="2"
specint92="131.5"
specfp92="273.8"
mcabuses="2"
mcarate_MBps="80"
mem_MB="from 128 to 2048"
;;

"A0") BULLMODEL="Bull DPX/20 ESCALA Model D201 or D401"
IBMMODEL="IBM RISC System/6000 Model J30"
processor="PowerPC-601"
processor_num="2 or 4 (later 6 or 8)"
clock_mhz="75"
L1cache_kB="32"
L2cache_MB="1"
specint92="77 (per processor)"
specfp92="84 (per processor)"
mcabuses="1 to 2 (D201) or 2 (D401)"
mcarate_MBps="160 to 2x160 (D201) or 2x160 (D401)"
mem_MB="from 64 to 2048 (D201) or 256 to 2048 (D401)"
;;

"A3") BULLMODEL="Bull DPX/20 ESCALA Model R201 or R401"
IBMMODEL="IBM RISC System/6000 Model R30"
processor="PowerPC-601"
processor_num="2 or 4 (later 6 or 8)"
clock_mhz="75"
L1cache_kB="32"
L2cache_MB="1"
specint92="77 (per processor)"
specfp92="84 (per processor)"
mcabuses="2"
mcarate_MBps="2x160"
mem_MB="from 64 to 2048"
;;

"A6") BULLMODEL="Bull DPX/20 ESCALA Model M101, M201 or M401"
IBMMODEL="IBM RISC System/6000 Model G30"
processor="PowerPC-601"
processor_num="1, 2 or 4"
clock_mhz="75"
L1cache_kB="32"
L2cache_MB="0.5"
specint92="77 (per processor)"
specfp92="84 (per processor)"
mcabuses="1"
mcarate_MBps="160"
mem_MB="from 32 to 512 (M101) or 64 to 512 (M201)"
;;

"E0") BULLMODEL="Bull DPX/20 ESTRELLA Model DT603M"
#  IBMMODEL=""
;;

*) BULLMODEL="Error:  This system type ("$MODNUM") is unrecognized, you need a
later version of wits"

esac

#
# Results screen
#
echo "Marketing Reference Information"
echo "\n${BULLMODEL}\n${IBMMODEL}\n"
if [ -n "${processor}" ]; then echo "processor : ${processor}" ; fi
if [ -n "${processor_num}" ];
	then echo "Number of Processors : ${processor_num}\n" ; fi
if [ -n "${clock_mhz}" ]; then echo "clock : ${clock_mhz} MHz\n" ; fi
if [ -n "${dcache_kB}" ]; then echo "data cache : ${dcache_kB} KBytes" ; fi
if [ -n "${icache_kB}" ];
	then echo "instruction cache : ${icache_kB} KBytes"; fi
if [ -n "${L1cache_kB}" ];
	then echo "L1 cache : ${L1cache_kB} KBytes per CPU"; fi
if [ -n "${L2cache_MB}" ];
	then echo "L2 cache : ${L2cache_MB} MByte per CPU\n" ; fi
if [ -n "${mem_MB}" ]; then echo "memory : ${mem_MB} MB\n"; fi
if [ -n "${mcabuses}" ] && [ -n "${mcarate_MBps}" ]
then
	echo "${mcabuses} Microchannel bus(es)"
	echo "\tat ${mcarate_MBps} MBytes/sec\n"
elif [ -n "${mcabuses}" ]
then
	echo "${mcabuses} Microchannel bus(es)\n"
fi
if [ -n "${mflops}" ]; then echo "performances : ${mflops} MFLOPS" ; fi
if [ -n "${specmarks}" ];
	then echo "performances : ${specmarks} SPECmarks" ; fi
if [ -n "${specint92}" ];
	then echo "performances : ${specint92} SPECint92" ; fi
if [ -n "${specfp92}" ];
	then echo "performances : ${specfp92} SPECfp92\n" ; fi
if [ -n "${other}" ]; then echo "${other}"; fi

if [ $# -eq 0 ]
then
	print "\nType return to continue"
	read rep
	clear
	exec 2>/dev/null
	print "Current Configuration Information\n"
	echo "Hardware ID :  $CPUNUM\tModel ID :  $MODNUM\n"
	count_cpu=$(lscfg -l "proc*" 2>/dev/null | tail -n +3 | wc -l)
	if [ $count_cpu -gt 1 ]
	then
		print $count_cpu "Processors"
	else
		print "Mono-Processor"
	fi
	echo ""
	lscfg -l "mem*" | tail -n +3 | cut -c39-70
	echo ""
	lscfg -l "bus*" | tail -n +3 | cut -c39-70
	echo ""
	lscfg -l "hd*" | tail -n +3 | cut -c39-79
	echo ""
	lscfg -l "rmt*" | tail -n +3 | cut -c39-79
	echo ""
	lscfg -l "cd*" 2>/dev/null | tail -n +3 | cut -c39-79
	echo ""
fi


