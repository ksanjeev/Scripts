use strict;
use Misys::Find;
use Cwd;

sub get_date_yyyymmdd {
#  This function gives the currrent date in YYYYMMDD Format.
#============================================================================#
  my ($sec, $min, $hr, $day, $month, $year) = (localtime (time))[0 .. 5];
  return (sprintf("%02d%02d%02d", ($year - 100), ($month + 1), $day));
}

chdir("M:\\");
my $current_dir = getcwd;
my $yyyymmdd = get_date_yyyymmdd();
my @Vob_List = system 'cleartool lsvob -s';
my $log_file = 'VOB_SYNC_'. $yyyymmdd. '.txt';

open LOG, ">>Logs\$log_file" or die "\nUnable to open $log_file\nError: $!\n";

foreach my $vob (@Vob_List) {
my $command = 'multitool lsepoch -invob '. $vob;
my @log_data = system $command;
print LOG @log_data;
}

close(LOG);

my @packet_data = system 'multitool lspacket';
my $log_packet = 'VOB_PACKET_'. $yyyymmdd. '.txt';

open LOGPACKET, ">>Logs\$log_packet" or die "\nUnable to open $log_packet\nError: $!\n";

print LOGPACKET @packet_data;

close(LOGPACKET);

