# read from the keyboard
# 	read from a file : <>
# 		angle brackets
# 		specify a logical filename within <>
# keyboard : STDIN
#
# reads a line by default
# input rec sep by default is a newline
# input rec sep is read into the variable
#$x = <STDIN>;
#print $x;


$y = <STDIN>;
$z = <STDIN>;
print $y, $z;

# chomp : inputs record sep at the end if any
chomp $y;
chomp $z;
print $y, $z;
	
