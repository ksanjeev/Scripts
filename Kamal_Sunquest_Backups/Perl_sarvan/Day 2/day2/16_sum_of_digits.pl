# sum of digits

$\ = "\n";
$, = "\t";
# input 1729  output 19

$n = <STDIN>;

# $n = chomp($n)  WRONG chomp returns # of char chomped
chomp $n;
$sum = 0;
$i = 0;
while($n)
{
	$sum = $sum + $n % 10;
	$n = int($n / 10);
	$i ++;
}
print "sum : $sum";
print "# of iterations : ", $i;
