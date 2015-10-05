$, = "\t";
$\ = "\n";

@a = (11, 22, 33);
@b = (44, 55);
@c = (66, 77, 88);
@d = (@a, @b, @c);
print "# of elements : ", scalar(@d);

@e = (\@a, \@b, \@c);
print "# of elements : ", scalar(@e);
print "val : ", $e[2]->[1];
# arrow bet closing and opening bracket can be dropped
print "val : ", $e[2][1];

disp(\@e);

@f = ( [ 10, 20, 30 ], [40, 50], [60, 70, 80]);
disp(\@f);

$g = [ [ 10, 20, 30 ], [40, 50], [60, 70, 80]];
disp($g);
# @_ = (ref to an array of ref to array
sub disp
{
	my $pp = shift;
	foreach my $p (@$pp)
	{
		print @$p;
	}
}











