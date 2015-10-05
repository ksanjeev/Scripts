# read a file
open FH, "x.dat" or die "x.dat $!";
# reads the whole file
# each element of the array is a rec of the file
@x = <FH>;
print @x;
close FH;
