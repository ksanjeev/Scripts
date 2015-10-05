# usage : perl mycat.pl <list of files>
# $, = "\t"; $\ = "\n";
foreach $ARGV (@ARGV)
{
	unless( open FH, $ARGV)
	{
		warn "$ARGV $!";
		next;
	}
	while(<FH>)
	{
		print;
	}
	close FH;
}

# C : break  Perl : last
#   : continue    : next
