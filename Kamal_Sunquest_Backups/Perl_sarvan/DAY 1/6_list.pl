# list
# 	has # of scalars enclosed in parentheses
# 	no name
#	no list of lists
#
#	inner lists are flattened out
#
# 	(10, 20)
# 	($x, $y)
# 	(10, "ten", "hattu")
# 	( 3 + 4, "ten" . "dulkar")
# 	( 11, (22, 33), 44)
#		=> (11, 22, 33, 44)
#
$, = "\t";
$\ = "\n";
($a, $b) = (11, 22);
print "a :" , $a, "b : ", $b; # a : 11 b : 22

# extra values on the right are ingored
($a, $b) = (33, 44, 55);
print "a :" , $a, "b : ", $b; # a : 33 b : 44


($a, $b) = (66);
print "a :" , $a, "b : ", $b; # a : 66 b : 

# variable b has been removed
# is undef - is a state
# undef : string context : ""
# 	  numeric context : 0
#

# assignment :
# Rule 1: evaluate rhs completely before assignment
# Rule 2 : evaluate rhs in the context of lhs
#
($x) = (11, 22, 33, 44);
print "x : ", $x; # 11

$x = (11, 22, 33, 44);
print "x : ", $x; # 44


($a, $b) = (11, 22);
($a, $b) = ($b, $a); # swap
# ($a, $b) = (22, 11)
print "a : ", $a, "b : ", $b;


# comma op
# 	has the least prec
# 	sequencing operator
# 	value of comma expr : value of the rightmost
#

#context
#	list :
#		list context : list
#		scalar context :
#			comma expr























