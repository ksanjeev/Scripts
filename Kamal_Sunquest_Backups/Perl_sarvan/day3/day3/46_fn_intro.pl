# books
# 	learning perl
# 	programming perl
# 	perl cookbook
# 	mastering regular expressions
#
# OO book :
# 	design patterns reusable architecture
# 	designing flexible systems using UML: Richter
# 	principles of programming lang : Pratt	
# 	Art of Computer programming : Knuth
# subroutines
#	definition
#	invoke
#	return
#	parameter
#	life and scope
#	recursion
#	callback : ptr to fn
#
# perldoc perlsub
#
$, = "\t"; $\ = "\n";
print "before";

# no return type
# fn name has no special prefix
# no parentheses after the fn name
# no named parameters
#
# invoke :
# 	a) with ampersand
# 	b) without ampersand
#		if called before defn,
#			parentheses required

what; # bareword without special meaning => string
what();
&what;

sub what
{
	print "in what";
}

print "after";

what;
&what;















