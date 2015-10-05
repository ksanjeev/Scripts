#!/bin/sh -
#
# shar shell archive script, can only be used for text files only, 
# no binary please.
#
# John Roebuck - 13/10/98.
#

if [ $# -eq 0 ]; then
	echo 'usage: shar file ...'
	exit 1
fi

cat << EOF
# This is a shell archive.  Save it in a file, remove anything before
# this line, and then unpack it by entering "sh filename".  Note, it may
# create directories; files and directories will be owned by you and
# have default permissions.
#
EOF

today=`date +%d/%m/%y`

echo "# This archive was create on $today"

cat << EOF
#
# This archive contains:
#
EOF

for i
do
	echo "#	$i"
done

echo "#"

for i
do
	if [ -d $i ]; then
		echo "echo c - $i"
		echo "mkdir -p $i > /dev/null 2>&1"
	else
		echo "echo x - $i"
		echo "sed 's/^X//' >$i << 'END-of-$i'"
		sed 's/^/X/' $i
		echo "END-of-$i"
	fi
done
echo exit
echo ""

exit 0
