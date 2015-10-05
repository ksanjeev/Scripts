#module
#	not a keyword
#	physical unit of reuse
#	refers to a file with extension .pm
#
#package
#	is a keyword
#	avoid clash of global names
#
#module has a package

package Utility;

sub msg
{
	print "msg : ", $_[0];
}	

sub cube
{
	my $val = shift;
	return $val * $val * $val;
}

#return 1;
1;

