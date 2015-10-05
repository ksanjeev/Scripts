# sum of digits

$\ = "\n";
$, = "\t";
# input 1729  output 19

chomp ($n = <STDIN>);

$sum = 0;
$i = 0;
$l = length $n;
while($i < $l)
{
	$sum = $sum + substr($n, $i, 1);
	$i ++;
}
print "sum : $sum";
