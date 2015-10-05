# hash
# 	key value pairs
# 	key, value : scalars
# 	key : unique
#
# 	name starts with %

$, = "\t"; $\ = "\n";
%a = qw(apple fruit bat cricket cat mammal);
print "hash ", %a; # order not defined

# flower brackets while indexing
print "val : ", $a{cat};

# replace the value for the given key
$a{cat} = "cmd of unix";
print "hash ", %a; # order not defined

# key value pair
$a{dove} = "bird";
print "hash ", %a; # order not defined

# remove
delete $a{dove};
print "hash ", %a; # order not defined

# keys :
# 	scalar context : # of keys
# 	list context : all the keys
$k = keys(%a);
print $k; # number of keys

@k = keys(%a);
print @k;

print values(%a);
print scalar(values(%a));

foreach $k (keys(%a))
{
	print $k, $a{$k};
}

# check for a key : exists
# check for a value for a key : defined
#
%b = (1, 2, 3, 4, 5);
print exists($b{1}), exists($b{5}), exists($b{4});
#		1             1          undef
print defined($b{1}), defined($b{5}), defined($b{4});
#	1	      undef             undef


