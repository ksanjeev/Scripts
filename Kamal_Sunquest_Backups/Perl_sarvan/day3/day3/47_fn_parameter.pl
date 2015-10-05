# parameter passing
#	no named parameters
#	no checking of args and para
$\ = "\n"; $, = "\t";
sub what1
{
	print "what1";
}

what1(11, 22);
what1(33, 44, 55);

# args get associated with the parameter array
# name : @_
#
sub what2
{
	while(@_)
	{
	#	print shift(@_);
		print shift; # shifts @_ by default
	}
}

what2(12, 24, 36);


# 'C'
# printf("area : %d\n", area(20, 10));
# int area(int l, int b) { ... }

#perl

# @_ = (20, 10)
sub area
{
# simulate named parameters
my $length = shift;
my $breadth = shift;
return $length * $breadth;	
}


print "area :" , area(20, 10);


# parameter passing :
# 	a) positional parameters
# 	b) keyword parameter
# 		specify a parameter name and a value for it
# 		make the order of args irrevalent
#
# 		simulation of keyword parameter
# @_ = (NUM, 20, DEN, 5)
sub divide
{
	my %def = (DEN => 1); 
	my %arg = (%def, @_);
	return $arg{NUM} / $arg{DEN};
}

print "divide : ", divide(NUM, 20, DEN, 5);
print "divide : ", divide(DEN, 5,NUM, 20);
print "divide : ", divide(NUM => 20, DEN => 5);
# => same as comma

print "divide : ", divide(NUM => 20);






