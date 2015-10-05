# read a file
$/ = undef;
#no record sep
#whole file is a rec
#reads the file into a scalar variable in one operation
#	slurping
#
open FH, "x.dat" or die "x.dat $!";
$x = <FH>; # do not trouble
print $x;
close FH;

# remove all new lines
$x =~ s/\n/ /g;
print $x;
