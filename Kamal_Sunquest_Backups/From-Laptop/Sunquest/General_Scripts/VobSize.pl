
my $now_string = localtime;
my $date =
my ($time) = ($now_string =~ /((?:\d+\:)+(?>\d+))/);
$time =~ s/:\d+$//;
$time =~ s/://;

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
                                                localtime(time);
$year+=1900;
$mon+=1;



# chdir("M:");
my @vobs = `cleartool lsvob -s`;
 # cleartool space -vob \AI_PVOB


my $Report_file = "VOB_size_".$year.$mon.$mday."_".$time.".txt";
open(REPORT,">>logs/$Report_file");

 foreach (@vobs)
 {
      chomp;
      my @details = `cleartool space -vob $_`;
      print REPORT "$details[$#details] \n";

 }
 
 close(REPORT);
 
 
 
