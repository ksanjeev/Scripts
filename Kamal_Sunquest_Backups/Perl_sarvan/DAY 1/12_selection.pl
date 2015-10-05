# selection :
# 	if stmt
@all = `ls`;
foreach $name (@all)
{
	chomp $name;
	if(-f $name)
	{
		print "$name : file\n";
	}
	elsif(-d $name)
	{
		print "$name : dir\n";
	}
	else
	{
		print "$name :  unknown\n";
	}
}


