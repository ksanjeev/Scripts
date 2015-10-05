# read a file
open FH, "x.dat" or die "x.dat $!";
# <> read from  a file
# reads a rec ; rec sep by default is \n
$/ = "trouble";
$x = <FH>; # do not trouble
#print $x;
chomp $x;
print $x;
close FH;
