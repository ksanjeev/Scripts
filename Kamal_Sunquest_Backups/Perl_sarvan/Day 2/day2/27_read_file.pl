# read a file
open FH, "x.dat" or die "x.dat $!";
# <> read from  a file
# reads a rec ; rec sep by default is \n
$x = <FH>;
print $x;
close FH;
