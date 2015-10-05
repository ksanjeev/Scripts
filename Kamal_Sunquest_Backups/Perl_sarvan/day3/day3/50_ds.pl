# assignment
$\ = "\n"; $, = "\t";
# 0
@a = (11, 22, 33, 44);
# 1
($x) = (11, 22, 33, 44); # 11
# 2
$x = (11, 22, 33, 44); # 44
# 3
($x) = @a; # 11
# 4.
$x = @a; # 4
# 5.
@b = 11; # @b = (11)
# 6.
@b = @a;
# 7. rhs : reference to an anonymous array
$x = [11, 22, 33, 44];
print "all : ", @$x;

$y = $x;
$x = "fool";
$y = "stupid";

# every loc in memory is reference counted
# when ref count becomes 0, the loc is removed
# memory mgmt : deterministic ; builtin
#


# 8.
@x = [11, 22, 33, 44];
print "# of elements : ", scalar(@x); # 1

# 9.
#	ref to anonymous hash
$x = { 11, 22, 33, 44 };
print ref($x);

# 10
%x  = { 11, 22, 33, 44 };
# hash whose key is a ref to hash !!
# typo error ?
#












