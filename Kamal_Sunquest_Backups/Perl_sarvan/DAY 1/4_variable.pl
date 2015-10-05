# variable
# scalar
# 	has a single value
# 	stored as a string
# 	no declaration of variables wrt type
# 	name starts with $

$a = "sunquest" ;
$b = $a;

# shell :
# a=sunquest
# b=$a
# lvalue and rvalue usages are different
# no space on either side of assignment
#
# perl :
# 	quotes required
# 	spacing on either side of assignment is optional
# 	no diff bet lvalue and rvalue usages

$a = 10;
$b = "10";
#no diff bet the two

# + : addition, arithmetic
# . : concatenation, string
#
# special variable
# 	output record sep : $\
# 	appears at the end of each print
# 	perldoc perlvar
#$\ = "\nbangalore\n";
# $, : output field sep

$\ = "\n";
$a =  10;
$b = 20;
print $a + $b; # 30
print $a . $b; # 1020


$a = "cat";
$b = "dog";
print $a + $b; # 0
print $a . $b; # catdog

$a = "10cat";
$b = "20dog";
print $a + $b; # 30
print $a . $b; # 10cat20dog

$a = "cat10";
$b = "dog20";
print $a + $b; # 0
print $a . $b; # cat10dog20

# operators :
# 	arithmetic : + - * / %
# 	string : . x
#		x : replication op

$, = "\t";
print 25 / 4, int(25 / 4), 25 % 4, 25.8 % 4.2;
#      6.25	6	     1		1

print "cat" x 3; # catcatcat
print 25 x 4; # 25252525
print 25 x 4.5; # 25252525
# x : left operand : string
#     right operand : integer


# scalar
# 	a) string
# 	b) numeric
# 		leftmost char which can be part of a number
# 		are pickedup
#
#	c) integer
#		numeric value is truncated
#
#












