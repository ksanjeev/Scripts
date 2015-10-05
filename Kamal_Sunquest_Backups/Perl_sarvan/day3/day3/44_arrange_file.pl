$, = "\t"; $\ = "\n";
@all = <*>; # shell metachar
#print @all;
%fi = ();
foreach (@all)
{
	if(-f ) # -f $_
	{
	#	print $_, -s ;# -s $_
		$fi{$_} = -s;
	}
}

#print %fi;
foreach $name (sort {$fi{$a} <=> $fi{$b}} (keys(%fi)))
{
	print $name, $fi{$name};
}

# <>
# 	a) read from file handle
# 	b) pickup files from the dir : globbing
#
