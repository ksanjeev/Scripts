# array
$, = "\t"; $\ = "\n";
@a = (11, 22, 33, 44, 55);
@b = @a; # deep copy
# after assignment, no relation bet the two arrays
$b[0] = 100;
print "a : ", @a;

@x = (11, 22);
@y = (33, 44);
(@x, @y) = (@y, @x);
# (@x, @y) = ((33, 44), (11, 22))
# (@x, @y) = (33, 44, 11, 22)
# @x gets all the elements : greedy
# @y gets nothing 
print "x : ", @x;
print "y : ", @y;

@a = (11, 22, 33, 44, 55);
($x) =  @a;
print "x : ", $x; # 11
$x = @a;
print "x : ", $x; # 5
# array
# 	list context : list
# 	scalar context : # of elements in the array
#

# + : scalar context
@a = @a + 10;
# @a =  5 + 10
# @a = 15
# @a = (15)
print "array : ", @a;

@a = (11, 22, 33, 44, 55);
#      0   1   2   3   4
#      -5 -4 -3  -2    -1
print "array : ", @a . "\n"; # 5   scalar context !

# last element :
print "last element : ", $a[@a - 1];
print "index of the last element : ", $#a;
print "last element : ", $a[$#a];
print "last element : ", $a[-1];

@a = (11, 22, 33, 44, 55, 66, 77, 88);
$x = 60;
$i = 5;
# insert $x in @a at posn $i
@a = (@a[0 .. $i - 1], $x, @a[$i .. $#a]);
print "a : ", @a;







































