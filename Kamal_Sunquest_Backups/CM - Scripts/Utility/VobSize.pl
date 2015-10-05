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
# VobSize.pl
#      Build a log giving the details of the size occpied for the list of VOBs
#      in a the current server
#
#
# Usage:
#      1) Edit the the varable $create_time below and specify the creation time
#         for the log file in 24 hours.
#      2) Edit the the variable "$LogFolder" below and specify the path to store the log files
#
# Returns:
#      The Log file is created in the folder given by "$LogFolder"
#
#
#=========================================================================
# Edit history:
#
#	Initial creation:	Saju Carlos on 03/02/07
#
#=========================================================================





# Specify the creation time for a new log file
# Example: If you want the time to be
#          17:00 hrs then give then give the value as "17"
#          17:30 hrs give the value as "17:30"
my $create_time = "8";

# Specify the path to the Logs folder where the Log is to be created.
my $LogFolder = "Logs";



# ******************************************************************************
# Please do not edit below this line
# ******************************************************************************

my $now_string = localtime;
my ($time) = ($now_string =~ /((?:\d+\:)+(?>\d+))/);
my $t = $time;
$t =~ s/:\d+$//;
$t =~ s/://;

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
                                                localtime(time);
$year+=1900;
$mon+=1;

# Get the list of vobs
my @vobs = `cleartool lsvob -s`;

if ($time =~ /^0?$create_time/)
{
  # Modify log
  build_log($Report_file,$Errorlog_file,'add');
} else
{
  # Build the log
  modify_log()
}






sub modify_log
{

    # Get the latest VOB_size file
    my $Report_file = '';
    opendir(DIR,"$LogFolder") || die "NO SUCH Directory: $LogFolder";

    foreach my $file ( sort {uc($b) cmp uc($a)} readdir(DIR) )
    {
      next if (($file eq '.')||($file eq '..'));
      $Errorlog_file = $file if ($file =~ /^Error/);
      $Report_file = $file if ($file =~ /^VOB_size/);
      last if ((defined $Report_file)&&(defined $Errorlog_file));
    }

    closedir(DIR);

    build_log($Report_file,$Errorlog_file,'edit');
}






sub build_log
{
    my $Report_file = shift;
    my $Errorlog_file = shift;
    my $type = shift;

    my $mkdir = `mkdir $LogFolder` unless (-d $LogFolder);

    $Report_file = "VOB_size_".$year.$mon.$mday."_".$t.".xls" if ($type eq 'add');
    $Errorlog_file = "Error_VOB_size_".$year.$mon.$mday."_".$t.".txt" if ($type eq 'add');


    open(REPORT,">>$LogFolder/$Report_file") or die "Cannot open Logs/$Report_file";
    print REPORT "Project\tVOB Name\tDate Extracted\tTime Extracted\tSize(Mb)\n" if ($type eq 'add');

    open(ERRORLOG,">>$LogFolder/$Errorlog_file") or die "Cannot open Logs/$Errorlog_file";

    my @VOBLIST = ();
    my @PVOBS = grep {/PVOB/} @vobs;

    foreach (@PVOBS) {
        my $pvob = $_;
        chomp $pvob;
        my ($s,$n) = (/([\\a-zA-Z0-9-]+)(?=\_)/);
        @VOBLIST = grep {/^\\$s/} @vobs;
        foreach (@VOBLIST)
        {
            my @details = `cleartool space -vob $_`;

            #if ($details[0] =~ /(?:(?:.*)Error(?:.*))/)
            if (!@details)
            {
                print ERRORLOG "Error: Unable to get information about the vob $_ \n";

            } else
            {
                my ($date,$vob,$size) = ($details[$#details] =~ /(?:((?:\d+\-)+\d+)(?:.*)(?:\"([^\s]+)\")(?:.*)((?:\d+\.\d+)(?>.*))$)/);
                $size =~ s/Mb$//;
                print REPORT "$pvob\t$vob\t$date\t$time\t$size\n" if ($vob);
            }
        } # End of foreach

    } # End of foreach

    close(REPORT);
    close(ERRORLOG);

} # end of build_log()



 
 

 
