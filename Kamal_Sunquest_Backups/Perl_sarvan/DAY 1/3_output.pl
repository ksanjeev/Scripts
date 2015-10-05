# output
# a) print
#	print is a function
#		parentheses are optional
#	can take multiple arguments
#	all are significant
#	free format printing
#	argument to a fn is considered an expr and 
#		is evaluated
# b) printf : as in c
# c) write : format stmt similar to fortran
#
# perl documentation
# a)perldoc -f <fnname>
# b) perldoc pelfunc
# c) perldoc perltoc
#
print "one\n";
print ("two\n");

print "three\n", "four\n";

printf "number : %5d\n", 1234;

print 2 + 2; # 4
print "\n";


print (2 + 2); # 4
print "\n";

3 + 4;

print (2 + 2) * 5; # 4

# print(2 + 2)
# 	display 4
# 	print on success returns 1
# 	1 * 5
# 	any expr followed by a semicolon is a stmt
print "\n";


print ((2 + 2) * 5); # 20
print "\n";

# parentheses :
# 	a) modify the precedence and association of operators
# 	b) invoke a fn
#		whenever parenthesis follows the fn name
#			it is considered fn call operator



print (print (2 + 2) * 5);
# inner print
# display 4 and return 1
# print (1 * 5)
# display 5 and return 1
print "\n";




































