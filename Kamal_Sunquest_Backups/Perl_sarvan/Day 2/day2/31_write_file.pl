# create a file :
# mode :
# 	write : >
# 	read : default or <
$, = "\t";
$\ = "\n";
open OUTFH, ">y.dat" or die "y.dat $!";
open INFH, "<x.dat" or die "x.dat $!";
$i = 0;
while($x = <INFH>)
{
	chomp $x;
	print OUTFH ++$i, $x;
	#print filehandle <list of expr>
	#no comma bet the file handle and the first expr
}
close(INFH);
close(OUTFH);

