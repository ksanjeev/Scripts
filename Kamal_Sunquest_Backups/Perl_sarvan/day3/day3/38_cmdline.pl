# command line arg
# $0 : command name
# @ARGV : rest of the arguments
$, = "\t"; $\ = "\n";
print "cmdname : ", $0;
print "args : ", @ARGV;

