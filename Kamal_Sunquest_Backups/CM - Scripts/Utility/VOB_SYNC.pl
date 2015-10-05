#!D:/Perl/bin/perl
#=========================================================================
#  (c) COPYRIGHT, 2005,
#  Misys Helathcare Systems, Inc., as an unpublished work.
#  THIS IS A CONFIDENTIAL WORK OF AUTHORSHIP SUBJECT
#  TO LIMITED USE AGREEMENTS AND IS A TRADE SECRET WHICH IS
#  THE PROPERTY OF MISYS HEALTHCARE SYSTEMS, INC. ALL USE,
#  DISCLOSURE AND/OR REPRODUCTION NOT SPECIFICALLY AUTHORIZED
#  IN WRITING BY MISYS HEALTHCARE SYSTEMS, INC.
#  IS PROHIBITED. All rights reserved.
#
#=========================================================================
# VOB_SYNC.pl
#      Build a log file (VOB_SYNC_YearMonthDay.txt) giving the details about syncronization. For the VOB's which
#      are not syncronized it is written into NOT_SYNC_YearMonthDay.txt
#
#
# Usage:
#      Edit the the variable "$LogFolder" below and specify the path to store the log files
#
# Returns:
#      The Log file is created in the folder given by "$LogFolder"
#
#
#=========================================================================
# Edit history:
#
#	Initial creation:	Sharad Agrawal on 02/09/07
#
# Sr.| Modified on    | Modified by      | Reason
# ------------------------------------------------------------------------------
# 1) | 03/06/07       | Saju Carlos      | 1) Compare the output for each VOB
#                                          2) Write into the error log file when
#                                             there is no match
#=========================================================================



# Specify the path to the Logs folder where the Log is to be created.
my $LogFolder = "Logs";



# ******************************************************************************
# Please do not edit below this line
# ******************************************************************************

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

#Added by Saju Carlos on 03/06/07
my $Error_log_file = 'NOT_SYNC_'. $yyyymmdd. '.txt';
open NOTSYNC, ">>$LogFolder/$Error_log_file" or die "\nUnable to open $Error_log_file\nError: $!\n";
# End 03/06/07 changes


open REPORT, ">>$LogFolder/$log_file" or die "\nUnable to open $log_file\nError: $!\n";

foreach my $vob (@Vob_List) {
my $command = 'multitool lsepoch -invob '. $vob;
my @log_data = `$command`;

#Added by Saju Carlos on 03/06/07
my %status = ();
my $syncronized = 'Yes';

  foreach (@log_data)
  {
     next if (/^Oplog\sIDs/);
     # build hash
     if (/(?:([^=]*)\=(\d+)(?:\s+)(?:\((.*?)\)))/)
     {
         my $server = $1 . '_server';

         if ((defined $status{$server})&&($status{$server} eq $3))
         {
              if ($status{$1} != $2)
              {
                 # Not syncronized
                 $syncronized = 'No';
                 last;
              }
         } else
         {
              $status{$server} = $3;
              $status{$1} = $2;
         }
     }
  }

#End changes on 03/06/07


# Modified by Saju Carlos on 03/06/07
#print REPORT @log_data;
  if ($syncronized eq 'Yes')
  {
     print REPORT @log_data;
  }
  elsif ($syncronized eq 'No')
  {
     print NOTSYNC @log_data;
  }
#End changes on 03/06/07

}

#Added by Saju Carlos on 03/06/07
close(NOTSYNC);
#End changes on 03/06/07


close(REPORT);

my @packet_data = `multitool lspacket`;
my $log_packet = 'VOB_PACKET_'. $yyyymmdd. '.txt';

open LOGPACKET, ">>$LogFolder/$log_packet" or die "\nUnable to open $log_packet\nError: $!\n";

print LOGPACKET @packet_data;

close(LOGPACKET);

