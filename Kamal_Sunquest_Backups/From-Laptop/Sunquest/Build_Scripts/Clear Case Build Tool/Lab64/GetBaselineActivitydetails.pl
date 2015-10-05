#!C:/perl/bin/perl.exe -w
############################################################################################



############################################################################################
use strict;
use Config::IniFiles;
use Cwd;
use Win32::OLE;
use Getopt::Long;
use Tk;
# The config file
my $ConfigFile = 'CC_Build_Activity.cfg';
my %cfg = ();

# Read the config file into hash
tie %cfg, 'Config::IniFiles', ( -file => "$ConfigFile" );

my $product_vob = $cfg{CLEARCASE}->{PROJECTVOB};
my $timeline = &GetTimeLine;
my $root_path = $cfg{CLEARCASE}->{ROOT_PATH};
my $database_name = $cfg{CLEARCASE}->{CQ_DB};
my $logpath = $cfg{CLEARCASE}->{LOGPATH};
my $Current_dir = getcwd;

# Added by Ashwin Deshmukh on 31st Oct 2007...
# This variable should hold the Activity List...
my $ChangeSet_Required = $cfg{CLEARCASE}->{CHANGE_SET};
my @Total_Activity_List;
my $count = 1;

# Added by Suma Krishna on 12th Feb,2008
# This is variable declaration to fetch data from the ClearQuest.
my $AD_PRIVATE_SESSION = 2;
my $AD_BOOL_OP_OR = 2;
my $AD_COMP_OP_EQ = 1;
my @Temp;
my $records = 0;
my $loginid = 'auto_delivery';
my $password = 'clearquest';
my $record_type = 'Defect';
my $status='';
my $ucm_project = $cfg{CLEARCASE}->{STREAM};
my $FinalActivity;
my @activity_list;
# delcaration ends here

# Modified by Ashwin Deshmukh on 31st Oct 2007
# The log files... To hold $logpath instead of current dir.
my $Event_log = $logpath.$product_vob.$timeline.'_Event.log';
my $Report = $logpath.$product_vob.$timeline.'_BaselineDetails.log';
my $Error_log = $logpath.$product_vob.$timeline.'Error.log';

print "\n\n***** Start Of Report *****\n\n";

# Added by Suma Krishna on 12th Feb,2008
# This is variable declaration is to create a ClearQuest session
my ($CQsession) = Win32::OLE->new ("CLEARQUEST.SESSION") or
   die "Can't create ClearQuest session object via call to Win32::OLE->new(): $!";
      
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

print "\n****** Start of Program \n\n";

my @Baselines = split(/,/,$cfg{CLEARCASE}->{BASELINES});
# Below Lines added by Ashwin Deshmukh on 31st Oct 2007
my ($sec1, $min1, $hour1, $mday1, $mon1, $year1, $wday1, $yday1, $time1) = localtime();
$year1 = $year1 + 1900;
$mon1  = $mon1 + 1;
my $today_date = "Year:".$year1." Month:". $mon1. " Day:". $mday1."  ".$hour1. "H ".$min1."M";
print REPORT "Report Date : $today_date\n";
print REPORT "Project_VOB : $cfg{CLEARCASE}->{PROJECTVOB}\n";
print REPORT "Baseline(s): $cfg{CLEARCASE}->{BASELINES}\n\n";
# End of Ashwin's code (2nd Nov 2007)

my $View_tag = $product_vob.$timeline;
my $ViewPath = $cfg{CLEARCASE}->{Storage_Location}.$View_tag.'.vws';

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

             # Added by Suma Krishna on 12th Feb,2008
    # This is variable declaration to join all the activities with ','.
        my $opt_activitylist = join(',',@activity_list);
        # split the activites for '@'.
        my @activities_list = split(/[@,]/,$opt_activitylist);
        # add all the activities into a Temp array
        foreach my $i (@activities_list){
            my $Val = $i;
            push (@Temp,$Val);
        }
        my %Val1 = @Temp;
        my @value = keys %Val1;
        

        for (my $j=0; $j<@value; $j++)
        {
            if ($value[$j] =~ (/\.+/))
            {
            print REPORT "Activity Id: $value[$j]\n";
            
            }
        }
    print REPORT "\n";
       
        # variable declaration to fetch the details for each activity.
        my $st;
        my $id;
        my $owner;
        my $state;
        my $headline;
        my $cr_number;
        
        # To join all the activities
        $FinalActivity = join(',',@value);
        
        # split the list of activities from the activitylist
                my @activities = split /,/,$FinalActivity;
        # Log into ClearQuest
                $CQsession->UserLogon("$loginid", "$password", "$database_name", $AD_PRIVATE_SESSION, "");
        # Get a ClearQuest Query Def object We will query on All UCM Activities
                my ($QueryDef) = $CQsession->BuildQuery($record_type);
        
        # Specify fields to get as a result of the ClearQuest Query This will be the column numbers in this order, starting at 1, not 0.
        
            $QueryDef->BuildField("id");
            $QueryDef->BuildField("Owner");
            $QueryDef->BuildField("State");
            $QueryDef->BuildField("CR_Number");
            $QueryDef->BuildField("headline");
        
        # The ucm_vob_object field in CQ holds a CC internal identifier for the UCM activity associated with the CQ record
        
            $QueryDef->BuildField("ucm_vob_object");
        
        # Specify the ClearQuest Query filter tree ucm_project = specified project list of states = specified list of states
        # This is used to query the ClearQuest for each activities.
        my ($FilterNode1) =
                  $QueryDef->BuildFilterOperator($AD_BOOL_OP_OR);
                foreach $st (@activities) {
                    $FilterNode1->BuildFilter( "id", $AD_COMP_OP_EQ, "$st" );
                    print "CQ ID is $st\n";
                }
                    # Printing the details to the text file
                    print REPORT "Activity Id \t";
                    print REPORT "Owner  \t\t";
                    print REPORT "State \t\t\t";
                    print REPORT "CR Number\t\t\t";
                    print REPORT "Headline \t\t\t";
                    print REPORT "\n";
                    print REPORT "############ \t";
                    print REPORT "######   \t";
                    print REPORT "####### \t\t";
                    print REPORT "########### \t\t\t";
                    print REPORT "########## \t\t";
                    print REPORT "\n";
                    
                    # To retrieve the records for the query
                    my ($ResultSet) = $CQsession->BuildResultSet($QueryDef);
                    
                    #execute the query.
                    $ResultSet->Execute();
                    
                    # Move to the next record
                    $status = $ResultSet->MoveNext();
                    print REPORT "\n";
                    
                    # Checking each record
                    while ($status == 1)
                    {
                        $records++;
                        
                        # retrieve the values for Id, CR_number,State and Headline from resultset.
                        $id = $ResultSet->GetColumnValue(1);
                        $owner = $ResultSet->GetColumnValue(2);
                        $state = $ResultSet->GetColumnValue(3);
                        $cr_number = $ResultSet->GetColumnValue(4);
                        $headline = $ResultSet->GetColumnValue(5);
                        
                        #opening the Report file to print the details for each activity.
                        open(REPORT,">>$Report") or die "\nUnable to open $Report: $!\n";
                        print REPORT "$id\t";
                        print REPORT "$owner\t\t";
                        print REPORT "$state\t\t\t";
						print REPORT "$cr_number\t\t\t";
                        print REPORT "$headline\t\t";
                        print REPORT "\n";
                        # To move to the next record after process the current record.
                                if ($records >= 1)
                                {
                                    # To move the resultset to next record.
                                    $status = $ResultSet->MoveNext();
                                }
                    }
                    print REPORT "\n";
            # The Changes for getting the activity details ends here
        
chdir($root_path);
$count = 1;

&RemoveView();

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

############################################################################################
#       END OF MAIN     #
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
	#print REPORT "\n$count) Activity: $_\n";
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
    #my @activity_list;
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
    print "\n\nForeach activities the change set contains:\n\n";
    foreach (@activity_list)
    {
        # commented by Suma Krishna because the above function displays the activity details
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

