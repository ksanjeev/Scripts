# memory or backreference
#
# match if two consecutive chars are same
$\ = "\n";
$, = "\t";

$_ = "hello";
if(/../)
{
	print "matched : $&"; # matched the first two char
}

# what is enclosed in parentheses will be remembered
# 	as $1 $2 $3 ...
# can be recalled in the same regex as
# 	\1 \2 \3 ...	
if(/(.)\1/)
{
	print "matched : $&"; # matched the first two char
	print "memory variable : ", $1;
}

# subject : hello
# memory var 1 : h	e	l
# pattern	: hh	ee	ll


# numbering of memory variables :
# 	based on left parentheses
#
$_ = "abcdefgh";
/((..)(..))(.(..).)/;
#12   3    4 5
print $1; # abcd
print $2; # ab
print $3; # cd 
print $4; # efgh
print $5; # fg

$_ = "host: india";
/host: (\w+)/;
print $1;

$_ = "perl easy perl powerful perl simple perl nice";
$res = /perl (\w+)/;
print "res : ", $res; # 1 or under
print "mem : ", $1; # memory variable


@res = /perl (\w+)/;
print "res : ", @res; # list of memory variables

# pattern matching :
# 	scalar context : 1 or undef
# 	list context : all memory variables





@res = /perl (\w+)/g;
print "res : ", @res; # list of memory variables

































