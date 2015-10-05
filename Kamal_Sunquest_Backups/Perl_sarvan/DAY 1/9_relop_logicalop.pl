
# relational and logical operators
$, = "\t"; $\ = "\n";

# relational op :
# 	numeric comparison 
# 	< > == <= >= != <=>
#	string comparison
#	lt gt eq le ge ne cmp

# <=> : three way comparison operator
print "5 <=> 5", 5 <=> 5; # 0
print "5 <=> 15", 5 <=> 15; # -1
print "25 <=> 15", 25 <=> 15; # 1

# true : 5 -5 1 "sunquest" 
# false : 0 "" undef
# system evaluates true as 1
# 	evaluates false as undex
print "5 == 5", 5 == 5; # 1
print "5 != 5", 5 != 5; # 1

# relational op are not associative
#print "5 == 5 == 5", 5 == 5 == 5;

print "what : ", "cat" == "tiger"; # 1
print "what : ", "cat" eq "tiger"; # 

print "what : ", 25 > 3; # 1
print "what : ", 25 gt 3;# undef


print "amar" cmp "amar";# 0
print "amar" cmp "akbar";# 1
print "amar" cmp "anthony";# -1

# logical operators
# 	! && ||      as in C ; higher prec
#       not and or   as in pascal ; lower prec

$a = 2;
$b = 10;
print $b / $a > 3; # 1

$a = 0;
$b = 10;
#print $b / $a > 3; # error at runtime
# short ckt eval
# 	eval of logical expr proceedes left to right
# 	eval stops as soon as the truth or falsehood is found
print $a == 0 or $b / $a > 3; # 1




































