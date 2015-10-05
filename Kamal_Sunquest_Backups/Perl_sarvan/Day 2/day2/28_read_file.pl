# read a file
open FH, "x.dat" or die "x.dat $!";
# <> read from  a file
# reads a rec each time; rec sep by default is \n
while($x = <FH>)
{
	print $x;
}
close FH;
