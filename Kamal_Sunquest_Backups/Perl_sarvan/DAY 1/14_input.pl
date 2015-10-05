$/ = "what";
$x = <STDIN>;
# chomp removes $/ at the end of the variable if any
chomp $x;
print $x;

