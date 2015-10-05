# create a file with a name having time stamp

$, = "\t";
$\ = "\n";
$name = "abcd";
($d, $m, $y) = (localtime())[3, 4, 5];
$m ++;
$m = "0" . $m if($m < 10);
$y += 1900;
print $d, $m, $y;
$s = sprintf "%2s%2d%4d", $m,$d, $y;
print $s;
open FH, ">${name}_$s" or die $!;
close FH;

