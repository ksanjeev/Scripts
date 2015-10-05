package Rect;
sub new
{
	my $class = shift;
	my $self = {
		L => shift,
		B => shift
	};
	# associate a ref with the package name
	bless $self, $class;
	return $self;
}

sub area
{
	my $self = shift;
	return $self->{L} * $self->{B};
}

1;

