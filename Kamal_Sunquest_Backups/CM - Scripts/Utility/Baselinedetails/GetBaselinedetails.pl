#!C:/perl/bin/perl.exe -w
############################################################################################



############################################################################################
use strict;
use Config::IniFiles;
use Cwd;

# The config file
my $ConfigFile = 'CC_Build_Activity.cfg';
my %cfg = ();

# Read the config file into hash
tie %cfg, 'Config::IniFiles', ( -file => "$ConfigFile" );

my $product_vob = $cfg{CLEARCASE}->{PROJECTVOB};
my $timeline = &GetTimeLine;

my $root_path = $cfg{CLEARCASE}->{ROOT_PATH};
my $logpath = $cfg{CLEARCASE}->{LOGPATH};
my $Current_dir = getcwd;

# Added by Ashwin Deshmukh on 31st Oct 2007...
# This variable should hold the Activity List...
my $ChangeSet_Required = $cfg{CLEARCASE}->{CHANGE_SET};
my @Total_Activity_List;
my $count = 1;


# Modified by Ashwin Deshmukh on 31st Oct 2007
# The log files... To hold $logpath instead of current dir.
my $Event_log = $logpath.$product_vob.$timeline.'_Event.log';
my $Report = $logpath.$product_vob.$timeline.'_BaselineDetails.log';
my $Error_log = $logpath.$product_vob.$timeline.'Error.log';

print "\n\n***** Start Of Report *****\n\n";

if ($cfg{CLEARCASE}->{EXPORT_TO} =~ /^EXCEL$/i)
{
    $Report = $Current_dir.'/'.$product_vob.$timeline.'_BaselineDetails.xls';
    open(REPORT,">$Report") or die "\nUnable to open $Report: $!\n";
    print REPORT "\n\nBuilding the report file on baseline information\n\n";
    print REPORT "Project VOB: $product_vob\n\n";
    print REPORT "\tBaseline\tActivity\tChange set\n";
}
elsif ($cfg{CLEARCASE}->{EXPORT_TO} =~ /^NOTEPAD$/i)
{
    open(REPORT,">$Report") or die "\nUnable to open $Report: $!\n";    
}

my $Baseline = '';
my @ViewInfo = ();

open(OLDSTDOUT,">&STDOUT");
open(OLDSTDERR,">&STDERR");
open(STDOUT,">$Event_log") or die "\nUnable to open $Event_log: $!\n";
open(STDERR,">$Error_log") or die "\nUnable to open $Error_log: $!\n";

my %BaselineInfo = ();

# Go to the view directory
chdir($root_path);

print "\n****** Start of Program ******\n\n";

my @Baselines = split(/,/,$cfg{CLEARCASE}->{BASELINES});

my $View_tag = $product_vob.$timeline;
my $ViewPath = $cfg{CLEARCASE}->{Storage_Location}.$View_tag.'.vws';


#   This below code is added by Ashwin Deshmukh on 20th Nov 2007
#   The code is required to register the ClearQuest databse for which we are running this script.  
#   Key - CQ_DB
my $ClearQuest_DB = $cfg{CLEARCASE}->{CQ_DB};
if ((!defined $ClearQuest_DB)||($ClearQuest_DB =~ ?\s+?i))
{
    print "\nError: ClearQuest database information not provided. CQ_DB key required in the config file... \n";
    print STDERR "\nError: ClearQuest database information not provided. CQ_DB key required in the config file... \n";
    print REPORT "\nError: ClearQuest database information not provided. CQ_DB key required in the config file... \n";
    print OLDSTDOUT "\nError: ClearQuest database information not provided. CQ_DB key required in the config file... \n";
   
    &close_report();
    exit;
}
my $Command  = "crmregister add -database $ClearQuest_DB -connection 7.0.0 -user auto_delivery -password clearquest";
my $crm = system($Command);
if ($crm != 0)
{
    print STDERR "Error: Command failed : $Command\n";
}
# End of Ashwin's code change for CQ_DB on 20th Nov 2007

# Below Lines added by Ashwin Deshmukh on 31st Oct 2007
my ($sec1, $min1, $hour1, $mday1, $mon1, $year1, $wday1, $yday1, $time1) = localtime();
$year1 = $year1 + 1900;
$mon1  = $mon1 + 1;
my $today_date = "Year:".$year1." Month:". $mon1. " Day:". $mday1."  ".$hour1. "H ".$min1."M";
print REPORT "Report Date : $today_date\n";
print REPORT "Project_VOB : $cfg{CLEARCASE}->{PROJECTVOB}\n";
print REPORT "Baseline(s): $cfg{CLEARCASE}->{BASELINES}\n\n";
# End of Ashwin's code (2nd Nov 2007)

&CreateView();

# Go to the view directory
chdir($View_tag);

foreach (@Baselines)
{
    $Baseline = $_;
    %BaselineInfo = ();
    %BaselineInfo = GetBaselineInfo($Baseline);
    print "\n\nBuilding the report file on baseline information\n\n";
    if ($cfg{CLEARCASE}->{EXPORT_TO} =~ /^EXCEL$/i)
    {
        &PrintInfo_ToExcel(\%BaselineInfo);
    }
    elsif ($cfg{CLEARCASE}->{EXPORT_TO} =~ /^NOTEPAD$/i)
    {
        &PrintInfo(\%BaselineInfo);
    }
}

chdir($root_path);
$count = 1;
&RemoveView();

#   Added by Ashwin Deshmukh on 20th Nov 2007
&close_report();

############################################################################################
#       END OF MAIN     #
############################################################################################


########################################################################
sub close_report
#   Created by Ashwin Deshmukh on 20th Nov 2007
########################################################################
{
    print "\n\n\n****** End of Program ******\n";
    print REPORT "\n\n***** End Report *****\n";
    
    close(STDOUT)|| die "Can't close log file";
    close(STDERR)|| die "Can't close log file";
    
    open(STDERR,">&OLDSTDERR")  or die "Can't restore stderr: $!";
    open(STDOUT,">&OLDSTDOUT")  or die "Can't restore stdout: $!";
    
    close(OLDSTDOUT);
    close(OLDSTDERR);
    close(REPORT);

    print "\n\n***** End Of Report *****\n\n";
}
############################################################################################

########################################################################
sub RemoveView
########################################################################
{
    ########## End view ########
    my $Command  = 'cleartool endview '.$View_tag.' 2>&1';
    # Run the command and get the result
    my $endview = `$Command`;
    chomp $ViewInfo[2];
    my ($global_view_path) = ($ViewInfo[2] =~ /(?:(\\.+))/);
    
    # $command_line = 'cleartool rmview -force \\thazchail\Temp\mkbl_int_view.vws';
    $Command  = 'cleartool rmview -force '.$global_view_path;

    @ViewInfo = ();
    
    # Run the command and get the result
    @ViewInfo = `$Command`;

    if ($ViewInfo[0] =~ /cleartool:\sError:/) {
       print STDERR "Unable to remove view." if (!-d $ViewPath);
    }
    elsif ($ViewInfo[0] =~ /Removing\sreferences\sfrom\sVOB/) {
       map { print "$_ \n"} @ViewInfo;
    }   
}
############################################################################################

########################################################################
sub CreateView
########################################################################
{
    print "Creating View '$View_tag'\n\n";
    ########## Create view ########
    my $Command  = 'cleartool mkview -stream '.$cfg{CLEARCASE}->{STREAM}.'@\\'.$cfg{CLEARCASE}->{PROJECTVOB}.' -tag '.$View_tag.' '.$ViewPath;

    # Run the command and get the result
    @ViewInfo = `$Command`;

    # Check the exit status
    if ($ViewInfo[0] =~ /^Created view/)
    {
      map { print "$_ \n"} @ViewInfo;
    }
    else {
      print STDERR "Unable to create view $View_tag in the path $ViewPath \n";
    }
}
############################################################################################

########################################################################
sub PrintInfo
########################################################################
{
    my $BaselineInfo = shift;
    # Commented by Ashwin Deshmukh on 31st Oct 2007
    #print REPORT "\nBaseline: $Baseline\n Project VOB: $product_vob\n\n";

    foreach (keys %{$BaselineInfo})
    {
	print REPORT "\n$count) Activity: $_\n";
        if ($ChangeSet_Required eq "Y" or $ChangeSet_Required eq "")
        {
            print REPORT "Change Set:\n";
            map {
                # s/(?:m\:\\[^\\]+)//;
                print REPORT;
                }(@{$BaselineInfo->{$_}});
        }
        
        $count++;
    }
    # Commented by Ashwin Deshmukh on 31st Oct 2007    
    #print REPORT "\n\n***** End Report *****\n";
}
############################################################################################

########################################################################
sub PrintInfo_ToExcel
########################################################################
{
    my $BaselineInfo = shift;
    my $count = 1;
    
    foreach (keys %{$BaselineInfo})
    {
        print REPORT "\nActivity\($count\)  Change set No.: ";
        my $activity = $_;
        $activity =~ s/(.+)\@(?:.+)/$1/;
	#print REPORT "\n$count) Activity: $_ \nChange Set:\n";
        my $c = 1;
	map {
#                if ($c == 1)
#                {
#                   print REPORT "\t$activity\t$_\n";
#                }
#                else
#                {
#                    print REPORT "\t\t$activity\t$_\n";
#                }
                #my $cs = chomp $_;
                #my ($first,$second)=($_ =~ /((?:m\:\\[^\\]+)(.+))/);
                print REPORT "$c\t$Baseline\t$activity\t$_";
            $c++;
	    }(@{$BaselineInfo->{$_}});
        $count++;
    }
    print REPORT "\n\n***** End of $Baseline details *****\n";
}
############################################################################################

########################################################################
sub GetBaselineInfo
#
########################################################################
{
    my $baseline = shift;
    my %Hash = ();
    
    # get the activity list
    
    # Commented by Ashwin Deshmukh on 31st Oct 2007
    # lsbl command gives wrong information & hence not required.
    # my $command = 'cleartool lsbl -l '.$baseline.'@\\'.$product_vob;

    # Added by Ashwin Deshmukh on 31st Oct 2007
    # To get the actual baseline difference...     
    my $command = 'cleartool diffbl -pre '.$baseline.'@\\'.$product_vob;
    print "\nList the baseline details\n\n";
    #print "COMMAND: $command\n\n";
    
    my @baseline_details = `$command`;
    
    print @baseline_details;
    print "\n\nThe list of activities associated:\n";
    # Commented by Ashwin Deshmukh on 31st Oct 2007
    #my @activity_list = grep {/(?:^\s+(?:[A-z0-9]+\@\\(?:[^\n]+)))/} (@baseline_details);
    
    # Added by Ashwin Deshmukh on 31st Oct 2007
    my @activity_list1 = grep {/(?:(?:\w+\@\\\w+\s+["'])(?!deliver|rebase))/} (@baseline_details);
    my @activity_list;
    foreach(@activity_list1)
    {
        chomp;
        s/^\s+//;  # Remove the space from the begining
        /((?:[^\s\>\s](?:[A-z0-9.]+\@\\(?:[^\s\"\n]+))))/;
        #/((?:[^\s](?:\w+\@\\(?:[^\s\"\n]+))))/; # DO NOT DELETE THIS LINE
        print "$1\n";
        push @activity_list,$1;
    }
    # End of Ashwin's Changes....(2nd Nov 2007)
    
    print "\n\n";
    #print @activity_list;
    
    print "\n\nForeach activities the change set contains:\n\n";
    foreach (@activity_list)
    {
	print "\n\nActivity: $_\n\t";
        chomp;
        s/^\s+//;  # Remove the space from the begining
        
        # Get the change set from each activity
                
        # Added by Ashwin Deshmukh on 31st Oct 2007
        # To keep a track of the processed Activities...
        my $current_activity=$_;
        my $array_activity;
        my $exists=0;
        foreach (@Total_Activity_List)
        {
            $array_activity = $_;
            if ($current_activity eq $array_activity )
            {
                $exists=1;
                #exit;
            }
        }
        if ($exists==0)
        {
            push @Total_Activity_List,$_;

            my $c = 'cleartool describe activity:'.$_;
            my @activity_details = `$c`;
            my @change_set = grep {/(?:[^\:\n]\s+((?:.+)\@+(?:.+)\\\d+))/} (@activity_details);
            print join("\t",@change_set);
            $Hash{$_} = \@change_set;
            
        }
        # End of Ashwin's changes....
    }
    return %Hash;
}
############################################################################################

####################################################
sub GetTimeLine
####################################################
{
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $time) = localtime();
    $year = $year + 1900;
    $mon  = $mon + 1;
    my $line    = "_" . $year . "_" . $mon . "_" . $mday  . "_" . $hour  . "H" . $min . "M";
    return $line;
}
############################################################################################

