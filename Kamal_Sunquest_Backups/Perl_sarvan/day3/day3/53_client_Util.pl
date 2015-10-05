$, = "\t"; $\ = "\n";
print "before";
use Util; # module name
print "after";
# use package name
Utility::msg("my message");
print Utility::cube(10);


# use :
# 	compile time mechanism
# 	compiler finds the file
# 	reads the file into a variable
# 		by slurping
# 	evals it
#
# 	fails if eval does not return a true value	
