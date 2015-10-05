# change :
# 	tr   : transliterate
# 	s   : substitute
#
$\ = "\n"; $, = "\t";
$x = "get";
$x =~ tr/e/o/;
print $x;

$_ = "get";
tr/e/o/;
print $x;

$_ = "good";
tr/og/ef/;
print ;

tr/a-z/A-Z/;
print ;

# replace + with space
$_ = "we+love+perl";
tr/+/ /;
print;

$_ = "zebra";
tr/a-z/za-y/;
print;

# substitute
# s/pattern/replacestr/flags
$_ = "good perl good lecture good assignment";
s/good/bad/;
print;


$_ = "good perl good lecture good assignment";
s/good/bad/g;
print;


$_ = "we    lover	 	perl very   much";
# squeeze white space
s/\s+/ /g;
print;


#  s/#.*//;
#  if( ! /^\s*$/ ) { ... }
#
#
#












