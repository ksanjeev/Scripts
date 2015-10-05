$, = "\t";
$\ = "\n";

# global :
# 	by default
# 	accessed anywhere
# 	created anywhere
# 	modified anywhere

# my :
# 	accessible only in the block in which it is defined

# local :
# 	globally available in all fns called
# 	from there onwards
# 	not available before
# 	not available in other branches of the calling
# 		sequence
package main;
# all global symbols belong to the package called main
# by default
# package : avoid clash of global names
$a = 10;
f();
print "main : a : $a b : $b c : $c";
#	a : 11 b : 22 c : 33 | undef

sub f
{
	print "f a : $a";  # 10
	$a = 1;
	my $b = 2; local $c = 3;
	g();
	print "f : a : $a b : $b c : $c";
	#      a : 11 b : 2 c : 33
	print "global b : ", $main::b;
}

sub g
{
	print "g : a : $a b : $b c : $c";
	# a : 1 b : undef c : 3
	$a = 11; $b  = 22; $c = 33;
}


# local
#	localize the effect of change of global variable
#	temporarily replace the global variable
#	should be used to modify builtin variables
#		of perl
$d = 100;
ff();
print "main d : $d";

sub ff
{
	local $d = 200;
	print "d : $d"; # 200
	print "global d : ", $main::d; # 200
}

print "hello", "world";
gg();
print "hello", "world";


sub gg
{
	local $, = undef;
	print "to", "get", "her";
}





