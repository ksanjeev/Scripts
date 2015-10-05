# struct == hash
# field == key
$, = "\t"; $\ = "\n";
$r = { L => 20, B => 10 };
disp($r);

# @_ = ref to hash
sub disp
{
	my $self = shift;
	print $self->{L}, $self->{B};
}

$d = {
	DD => 25,
	MM => 12,
	YY => 2004
};

print "date : ", %$d;

$e = {
	DETAIL => "Tsunami",
	DATE => $d,
	COUNTRIES => ["Srilanka", "India"]
};

print "month : ", $e->{DATE}->{MM};
print "month : ", $e->{DATE}{MM};

$e->{DATE}->{DAY} =  "Sun";
print "date : ", %$d;

print $e->{COUNTRIES}->[0];
print @{$e->{COUNTRIES}};

#perldoc perldsc




