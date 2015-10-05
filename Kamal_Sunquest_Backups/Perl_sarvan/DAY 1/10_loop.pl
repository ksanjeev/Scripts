# control structure
# similar to that of C
# 	block required even if there is only one stmt

# 1.while
#	while(<expr>) {  <stat> ... }
#
@a = (11, 22, 33, 44);
# word without a prefix : bareword
# becomes a string
# i = 0;  # 'i' = 0;
$, = "\t"; $\ = "\t";
$i = 0;
# $i < $#a  # once less
# $i <= @a # once extra
# $i <= $#a # ok
# $i < @a  # ok
while($i < @a)
{
	print $a[$i];
	$i ++;
}
print "\n";


# 2. for(e1;e2;e3) {  <stat> ... }

# 3. foreach 
# foreach <var> (<list>) { <stat> ... }
foreach $x ("apple", "banana", "orange")
{
	print $x;

}
print "\n\n";
$\ = "\n";
# is $x a copy of each element of the list or it it a ref?
#	is a ref
foreach $x (@a)
{
	print $x;
	$x += 100;
}
print "\n", @a; # array changed !!


# @x == @y  ?
# 	scalar context
# 	compares the number of elements







