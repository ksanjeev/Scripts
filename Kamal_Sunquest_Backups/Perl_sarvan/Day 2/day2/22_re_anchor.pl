# anchor
$\  ="\n"; $, = "\t";

@subjects = qw(cat cattle concat catdogcat);
$pat = 'cat';
print "pattern : $pat";
foreach (@subjects)
{
	if(/$pat/)
	{
		print "matches $_ : $&";
	}
	else
	{
		print "no match $_";
	}
}
print "";

# ^ :
# 	first char of the pattern : anchor; start with
# 	first char of a char class : invert
# 	anywhere else : ^
$pat = '^cat';
print "pattern : $pat";
foreach (@subjects)
{
	if(/$pat/)
	{
		print "matches $_ : $&";
	}
	else
	{
		print "no match $_";
	}
}
print "";

# /^[^^]/
#		begin with not a caret
#

$pat = 'cat$'; # end with 
print "pattern : $pat";
foreach (@subjects)
{
	if(/$pat/)
	{
		print "matches $_ : $&";
	}
	else
	{
		print "no match $_";
	}
}
print "";

# anchors are 0 width pattern
$pat = '^cat$'; # 
print "pattern : $pat";
foreach (@subjects)
{
	if(/$pat/)
	{
		print "matches $_ : $&";
	}
	else
	{
		print "no match $_";
	}
}
print "";


# match rama in
#  rama
#  rama krishna
#  bala rama
#  lakshmana rama seetha
#
#  not in
#  ramakrishna		/\brama\B/  \B :nonword boundary
#  balarama		/\Brama\b/
#  abcdramapqrs         /\Brama\B/

#	/rama/	match all
#	/ rama / will not match the first one
#	/\brama\b/	/\b/ word boundary















