# reference :
# 	similar to points in C
# 	no pointer arithmetic
#
# 	special scalar
#
# 	addr op : C &
# 	          perl \
#
# 	dereferencing op : C *
# 		perl : depends on the context
#		SCALAR : $
#		ARRAY : @
#		HASH : %
$\ = "\n"; $, = "\t";
$x = 10;
$px = \$x;
print '$px : ', $px; # SCALAR (hex #)
# distinguish simple scalar and ref : ref
print 'ref $x : ', ref($x); # undef
print 'ref $px : ', ref($px); # SCALAR
print "deref : ", $$px;

@y = (11, 22, 33, 44);
$py = \@y;
print 'ref $py : ', ref($py); # ARRAY
print "array : ", @$py;
print "elem : ", $$py[2];
print "elem : ", $py->[2];

%z = (11, 22, 33, 44);
$pz = \%z;
print 'ref $pz : ', ref($pz); # HASH
print 'hash : ', %$pz;
print 'val : ', $$pz{33};
print 'val : ', $pz->{33};
















          
