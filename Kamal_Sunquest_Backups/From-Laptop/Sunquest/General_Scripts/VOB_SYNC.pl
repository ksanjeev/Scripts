use Cwd;

sub get_date_yyyymmdd {
#  This function gives the currrent date in YYYYMMDD Format.
#============================================================================#
  my ($sec, $min, $hr, $day, $month, $year) = (localtime (time))[0 .. 5];
  return (sprintf("%02d%02d%02d", ($year - 100), ($month + 1), $day));
}


my $current_dir = getcwd;
my $yyyymmdd = get_date_yyyymmdd();
my @Vob_List = `cleartool lsvob -s`;
my $log_file = 'VOB_SYNC_'. $yyyymmdd. '.txt';

open REPORT, ">>Logs/$log_file" or die "\nUnable to open $log_file\nError: $!\n";

foreach my $vob (@Vob_List) {
my $command = 'multitool lsepoch -invob '. $vob;
my @log_data = `$command`;
print REPORT @log_data;
}

close(REPORT);

 my @packet_data = `multitool lspacket`;
my $log_packet = 'VOB_PACKET_'. $yyyymmdd. '.txt';

open LOGPACKET, ">>Logs/$log_packet" or die "\nUnable to open $log_packet\nError: $!\n";

print LOGPACKET @packet_data;

close(LOGPACKET);

