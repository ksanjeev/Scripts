# create a file with a name having time stamp

$, = "\t";
$\ = "\n";
$_ = localtime();
($mname, $d, $y) = /\w+\s+(\w+)\s+(\d+).*?(\d+)$/;

%monthhash = (
	Jan => "01",
	Feb => "02",
	Mar => "03"
);

$m = $monthhash{$mname};


$name = "pqrs";
open FH, ">${name}_$m$d$y";
close FH;


