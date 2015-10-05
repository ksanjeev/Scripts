# array :
# 	like a named list
#	elements are scalars
# 	name starts with @
# 	is indexed by integer
# 	make an array :
# 		assign a list
#	is not a pointer
#	stands all the elements of the array
#	lower bound of index : 0
#	index out of bounds not checked
#	no specification of array size while creating
#	array size : dynamic
$, = "\t"; $\ = "\n";
@a = (11, 22, 33, 44);
print "array :", @a;
print "what : ", $a; # no relation bet scalar $a and array @a

# index on the array
print "val : ", $a[2] ; # single value : $

print "val : ", $a[6]; # undef
$a[6] = 77;
print "array :", @a;

# make an array on the fly
$b[2] = "wall";
print "array  ", @b;

@a = (11, 22, 33, 44);

# $ => single value;  , becomes an op
print "what : ", $a[1,3];  # $a[3]

# slicing
# @ => multiple values; , becomes a sep
print "what : ", @a[1, 3]; # ($a[1], $a[3])

@a[1, 3] = (12, 24);
print "a : ", @a;


@a = (11, 22, 33, 44);
# slice a list
@a[1, 3] = (12, 24, 36, 48, 60)[4,2];# (60, 36)
print "a : ", @a;

# file size
print "size : ", (stat("1_intro.pl"))[7];

# .. : range op
@a = (1 .. 5);
print "a : ", @a;

# operands are evaluated in int context
@a = (1.5 .. 5.5);
print "a : ", @a;

@a = (5 .. 1); # empty range
print "a : ", @a; # ()


@a = (11, 22, 33, 44);
print @a[1 .. 3]; # @a[1, 2, 3]
















































