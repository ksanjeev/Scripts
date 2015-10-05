# sum of digits

$\ = "\n";
$, = "\t";
# input 1729  output 19

chomp ($n = <STDIN>);
#print split(//, $n);
#print join(" + ", split(//, $n));
print eval(join(" + ", split(//, $n)));

exit(0);

$a = '$b = 10';
print "a : $a"; # $b = 10
print "b : $b"; # undef
# execute a valid expr in perl
eval $a;

print "a : $a"; # $b = 10
print "b : $b"; # 10



