$, = "\t"; $\ = "\n";
use Rect;
# a) Rect::new(20, 10)
# b) Rect->new(20, 10)
# 	what is behind the arrow is passed
# 		as the first arg
# 	Rect::new(Rect, 20, 10)
#
	
$r = Rect->new(20, 10);
# $r = 	Rect::new(Rect, 20, 10)
print "ref : ", ref($r);
print "area : ", $r->area();
#	Rect::area($r)
