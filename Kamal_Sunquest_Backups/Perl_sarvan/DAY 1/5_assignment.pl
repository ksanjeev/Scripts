# operators
# assignment
#
$\ = "\n" ;$, = "\t";
# multiple assignment
$a = $b =10;
print $a, $b;

# combined ops
# += -= *= /= %= .= x=
#
$x  = 10;
$x *= 2 + 2; # $x = $x * (2 + 2)
print $x; # 40

# add to 1 to a variable
# ++ --

$a = "sum";
$a += 1;
print $a; # 1


$a = "sum";
$a++;
print $a; # sun

# perldoc perlop
$a = "zz";
$a++; # incr op on strings is magical
print $a; # aaa

$a--; # decr op is not magical
print $a; # -1  
















