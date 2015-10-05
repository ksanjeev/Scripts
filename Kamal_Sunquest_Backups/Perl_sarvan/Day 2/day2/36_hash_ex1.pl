$, = "\t" ;$\ = "\n";
open FH, "place.txt" or die $!;
while(<FH>) # $_ = <FH>
{
#	print;
	($city, $place) = split /\s+/, $_;
#	print $city;
#	print $place;
	if(exists($cityinfo{$city}))
	{
		$cityinfo{$city} .= ":" . $place;
	}
	else
	{
		$cityinfo{$city} = $place;
	}
}
close FH;
foreach $city (keys(%cityinfo))
{
	print $city;
	foreach $place (split(/:/, $cityinfo{$city})) 
	{
		print "\t$place";
	}
}
