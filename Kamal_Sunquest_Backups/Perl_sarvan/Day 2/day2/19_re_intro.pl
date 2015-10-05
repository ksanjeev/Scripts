# regular expression
# 	according to formal language theory :
# 		type 3 language : Chomsky
# 		formal mechanism : finite state machine
# 	pattern matching
# 	superset of classical regular expression
# 	perldoc perlre
# 	book : mastering regular expressions
#
$, = "\t"; $\ = "\n";

# new operator
# 	=~    match
# 	!~    not to match

$x = "together";
if($x =~ /get/)
{
	print "matched";
	print "prematch : ", $`;
	print "match : ", $&;
	print "pstmatch : ", $';
}
else
{
	print "did not match";
}

$_ = "together";
if(/get/)  # $_ =~ /get/
{
	print "matched";
	print "prematch : ", $`;
	print "match : ", $&;
	print "pstmatch : ", $';
}
else
{
	print "did not match";
}

# program is in perl
# pattern is in regex
# run the pgm in the shell 
# 	same symbol may have diff semantics
# 	for same semantics, diff symbols have to be used


	

	
