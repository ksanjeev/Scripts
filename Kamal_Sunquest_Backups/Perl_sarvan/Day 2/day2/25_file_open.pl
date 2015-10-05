# file :
# 	a) physical filename
# 		as per the OS
# 	b) logical filename
# 		as perl the language
# 	c) mode
# 		read
# 		write
# 		append
# 		i/o
#  open connects all these three
#    first arg ; handle, logical filename, bareword
#    no special prefix
#    second arg : string
#    	has both filename and mode
#    	default mode : write mode

# does not in its own report i/o errors
# $! in string context holds the error msg
open FH, "junk.dat" or die("junk.dat $!");
print "after open\n";
close FH;




