#!/bin/ksh
#
# Korn Shell Script to mount CDRoms on Unix machines and read them onto a hard drive file system.
#
# Revisions:
# 2004 July 21 Don White:  Added the switch -o nocase to the AIX mount command to enable mixed case for CD file names.
#                          I also added the -rp switches to the cp command in order to copy subdirectories and preserve 
#                          permissions.
#

trap "trap '' 0 1 2 3 15; rm -f /tmp/.tmp.$$; \
                          cd /tmp; umount /mnt$$ 1>/dev/null 2>&1; \
                          rm -rf /mnt$$ 1>/dev/null 2>&1; \
                          exit 0" 0 1 2 3 15

[ "$SQROOT" ] || . /etc/sq_base.sh
 

tmp=/tmp/.tmp.$$
OS=`uname -s`
curdir=`pwd`
mountpt=/mnt$$

[ "$OS" = "OSF1" ] && sizer -v|grep V5 1>/dev/null 2>&1 && OS=5


getdev ()
{
 devlist=""

 case $OS in
   AIX*) devlist=`lsdev -C -S a -c cdrom|cut -f1 -d" "` ;;
      5) devlist=`ls /dev/disk/cdrom[0-9]c|sed 's?/dev/??g'1` ;;
      *) cddev=`scu show edt|grep "Read-Only"`
         if [ "$cddev" ]
         then businfo=`print ${cddev##*Bus:}`
              bus=`print ${businfo%%,*}`
              tarinfo=`print ${businfo##*Target:}`
              tar=`print ${tarinfo%%,*}`
              let rz="($bus*8)+$tar"
              devlist=rz$rz"c"
         fi ;;
 esac

 [ $devlist ] || { print "\nNo devices found...exiting."; exit; }

 devlist=`print $devlist|tr ' ' '\012'`

 dflt=`echo "$devlist"|head -1`

 print "\nAvailable Devices:\n"
 while :
 do print "$devlist\n"|sed 's/^/                   /'
    read -r "dev?Enter Device {'q' to exit} [$dflt]: "
    case $dev in
     q*|Q*) exit ;;
    esac

    [ "$dev" ] || dev=$dflt
    if `echo "$devlist"|grep "$dev" 1>/dev/null 2>&1`
    then break
    else print "\nInvalid Device\n"
    fi
 done
 dev=/dev/$dev
}

getdir ()
{
  while :
  do read -r "ans?Enter directory </sunquest/test>: "
     [ "$ans" ] && { directory=$ans; break; } || { directory="/sunquest/test"; break; }
  done

  post=`echo $directory|sed 's/^\///'`
  pref=`echo $post|sed 's/\/$//'`
  directory="/$pref"

  [ -d $directory ] || while :
  do read -r "ans?Directory $directory doesn't exist. Create [<y>|n]? "
        case $ans in
         y*|Y*|"") mkdir -p $directory
                   print "Directory $directory created." ;;
                *) print "\nQuitting...\n"
                   exit ;;
        esac
        [ -d "$directory" ] && break
  done
}

chknum ()
{
 (( `expr $1 : "[0-9]*"` == `expr $1 : ".*"` )) && return 0 || return 1
}

gettoc ()
{
  mkdir $mountpt
  case $OS in
   AIX*) mount -o nocase -v cdrfs -r $dev $mountpt 1>/dev/null || \
                       { print "\nUnable to mount cdrom.\n"; exit; } ;;
      *) mount -t cdfs -o rrip,ro,noversion $dev $mountpt \
                       1>/dev/null || \
                       { print "\nUnable to mount cdrom.\n"; exit; } ;;
  esac
  ls -1 $mountpt 1>$tmp 2>/dev/null || \
                       { print "\nUnable to read cdrom.\n"; exit; }
  let i=0
  cat $tmp|awk '{print $NF}'|while read file
  do let i=$i+1
     index[$i]="$file"
     print "$i. ${index[$i]}"
  done
  print "\n\nEnter one file at a time.  You'll be prompted for more files."
}

getfiles ()
{
  all=false

  let k=1
  while (( $k<$i+1 ))
  do filesel[$k]="" 
     let k=$k+1
  done

  print_files=""

  while :
  do read -r "ans?Enter file number {'q' to exit, 'a' for all}: "
     case "$ans" in
          "") break ;;
       a*|A*) all=true
              print_files=`ls -1 $mountpt|tr '\012' ' '`
              break ;;
       q*|Q*) print "Quiting..."
              exit ;;
     esac
     chknum "$ans" || { print "Invalid Entry"; continue; }
     (( $ans < 1 || $ans > $i )) && { print "Invalid Entry"; continue; }
     filesel[$ans]="yes"
  done

  FILES=""; status=""
  print "\nYou have choosen:\n"
  if $all
  then print "     All files\n"
       status="all"
  else let k=1
       while (( $k<$i+1 ))
       do [ "${filesel[$k]}" ] && { print "     ${index[$k]}"; \
                                      FILES="$FILES ${index[$k]}"; }
          let k=$k+1
       done 
       status="$FILES"
  fi 
  
  [ "$status" ] || { print "No files...Quiting\n"; exit; }
}

clear
print "                      Overlay CD-ROM Transfer\n"
 
print

print "\nPlease have CD in the drive."

getdev

print
getdir

print "\nData dump from $dev to $directory.\n"
while :
do read -r "ans?Do you want to start now? "
   case $ans in
    y*|Y*) print
           break ;;
    n*|N*) print
           exit ;;
        *) print "\nPlease answer 'yes' or 'no'\n" ;;
   esac
done

getlist ()
{
  print "\nGetting a list of files...please wait"
  print
  gettoc
  print "\n\n"
  getfiles

  out=false
  while :
  do while :
     do print
        read -r "ans?Do you want to change the list [<n>|y]? "
        case $ans in
         y*|Y*) print
                getfiles ;;
      ""|n*|N*) print
                out=true
                break ;;
             *) print "\nPlease answer 'yes' or 'no'\n" ;;
        esac
     done
     $out && break
  done
}

getlist

print "\nTransfer started..."

cd $mountpt
[ "$FILES" ] || FILES="*"
# cp $FILES $directory
cp -rp $FILES $directory

print "\nTransfer completed\n"

read -r "crap?Press ENTER to continue..."

print "\nFiles on CD...\n"
$all && ls -l $print_files 2>/dev/null
$all || ls -l $FILES

read -r "crap?Press ENTER to continue..."

print "\n\nFiles in $directory...\n"
cd $directory
$all && ls -l $print_files 2>/dev/null
$all || ls -l $FILES

read -r "crap?Press ENTER to continue..."

print "\n\nAlso, verify the files against the log, if one available.\n"
cd $curdir

print "\nDismounting CD..."
umount $mountpt || { print "\nUnable to dismount the cdrom\n"; exit; }
rm -rf $mountpt
print "\nCD dismounted"
