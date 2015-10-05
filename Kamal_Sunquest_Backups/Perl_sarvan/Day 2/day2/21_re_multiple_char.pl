# multiple char regex
$\  ="\n"; $, = "\t";

# shell :
# 	* : 0 or more of any char
# re :
# 	* : 0 or more of what precedes it
# 	closure
#
@subjects = qw(abcd ab*d ad abbbd);
$pat = 'ab*d';
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

# positive closure
# + : 1 or more of what precedes
$pat = 'ab+d';
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

# integer constant
#	1729 -1729 +1729
#	optional sign followed by 1 or more digits
#	/[+-]?\d+/


# /[a+]/ a or +


#  * of shell  == .* of re
# Rule 1 :
# 	match from subject to pattern ; find the leftmost match
# Rule 2 :
# 	be eager
# Rule 3 :
# 	be greedy
# 	if necessary regex backtracks		

@subjects = ('axxxbyyybzzz');
$pat = 'a.*b';
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


# ? following a closure(* +)
# 	non greedy match
# 	does forward tracking to match the remaining pattern
#

@subjects = ('axxxbyyybzzz');
$pat = 'a.*?b';
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


@subjects = ('good food');
$pat = 'o+';
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

@subjects = ('good food');
$pat = 'o*'; # matches nothing successfully
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






