$_ = "I have 2 numbers: 53147";
@pats = qw{
        (.*)(\d*) # 0 or more char longest followed 0 or more digits
        (.*)(\d+) # 0 or more char longest followed 1 or more digit
        (.*?)(\d*) # 0 or more char shortest followed by 0 or more digits
        (.*?)(\d+) # 0 or more char shortest followed by 1 or more digits
        (.*)(\d+)$
        (.*?)(\d+)$
        (.*)\b(\d+)$
        (.*\D)(\d+)$
};

$pat = '(.*)(\d*)';
$pat = '(.*)(\d+)';
$pat = '(.*?)(\d*)';
$pat = '(.*?)(\d+)';
$pat = '(.*)(\d+)$';
$pat = '(.*?)(\d+)$';
printf "%-12s ", $pat;
if ( /$pat/ ) {
      print "<$1> <$2>\n";
} else {
      print "FAIL\n";
}
