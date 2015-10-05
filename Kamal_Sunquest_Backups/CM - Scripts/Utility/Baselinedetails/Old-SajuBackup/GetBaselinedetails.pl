#!D:/perl/bin/perl.exe -w
use strict;
use Config::IniFiles;
use Cwd;


# The config file
my $ConfigFile = 'CC_Build.cfg';
my %cfg = ();

# Read the config file into hash
tie %cfg, 'Config::IniFiles', ( -file => "$ConfigFile" );

my $product_vob = $cfg{CLEARCASE}->{PROJECTVOB};
my $timeline = &GetTimeLine;

my $root_path = $cfg{CLEARCASE}->{ROOT_PATH};
my $logpath = $cfg{CLEARCASE}->{LOGPATH};
my $Current_dir = getcwd;


# The log files

my $Event_log = $Current_dir.'/'.$product_vob.$timeline.'_Event.log';
my $Report = $Current_dir.'/'.$product_vob.$timeline.'_BaselineDetails.log';
my $Error_log = $Current_dir.'/'.$product_vob.$timeline.'Error.log';



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

my $View_tag = $product_vob.$timeline;
my $ViewPath = $cfg{CLEARCASE}->{Storage_Location}.$View_tag;

# &CreateView();

# IX
#$ViewPath = "\\\\thazchail\\ccstg_d\\views\\SUNQUESTINDIA\\Thazchail\\thazchail_IX_INTERFACE_MHU_int.vws";
#$View_tag = "thazchail_IX_INTERFACE_MHU_int";

#AI
$ViewPath = "\\\\thazchail\\ccstg_d\\views\\SUNQUESTINDIA\\Thazchail\\thazchail_AI_3.1.0_MHU_int.vws";
$View_tag = "thazchail_AI_3.1.0_MHU_int";

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
# &RemoveView();

print "\n\n\n****** End of Program ******\n";

close(STDOUT)|| die "Can't close log file";
close(STDERR)|| die "Can't close log file";

open(STDERR,">&OLDSTDERR")  or die "Can't restore stderr: $!";
open(STDOUT,">&OLDSTDOUT")  or die "Can't restore stdout: $!";

close(OLDSTDOUT);
close(OLDSTDERR);
close(REPORT);



sub RemoveView
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


sub CreateView
{
    print "Creating View '$View_tag'\n\n";
    ########## Create view ########
    
    # $command_line = 'cleartool mkview -stream '.$int_stream.'@\\'.$product_vob.' -tag mkbl_int_view '.$Storage_Location.'mkbl_int_view.vws';
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
    #################
}

sub PrintInfo
{
    my $BaselineInfo = shift;
    print REPORT "\nBaseline: $Baseline\n Project VOB: $product_vob\n\n";
    my $count = 1;
    
    foreach (keys %{$BaselineInfo})
    {
	print REPORT "\n$count) Activity: $_ \nChange Set:\n";
	map {
            # s/(?:m\:\\[^\\]+)//;
	    print REPORT;
	    }(@{$BaselineInfo->{$_}});
        $count++;
    }
    print REPORT "\n\n***** End Report *****\n";
}

sub PrintInfo_ToExcel
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




sub GetBaselineInfo
{
    my $baseline = shift;
    my %Hash = ();
    
    # get the activity list
    #cleartool lsbl -l CM_MHI_7_12_2007.6121@\CM_PVOB
    
    my $command = 'cleartool lsbl -l '.$baseline.'@\\'.$product_vob;
    print "\nList the baseline details\n\n";
    print "COMMAND: $command\n\n";
    
    my @baseline_details = `$command`;
    
    print @baseline_details;
    print "\n\nThe list of activities associated:\n";
    my @activity_list = grep {/(?:^\s+(?:[A-z0-9]+\@\\(?:[^\n]+)))/} (@baseline_details);
    print @activity_list;
    
    print "\n\nForeach activities the change set contains:\n\n";
    foreach (@activity_list)
    {
	print "\n\nActivity: $_\n\t";
        chomp;
        s/^\s+//;  # Remove the space from the begining
        
        # Get the change set from each activity
        #cleartool describe activity:CM00000024@\CM_PVOB
        
        my $c = 'cleartool describe activity:'.$_;
        my @activity_details = `$c`;
        
        my @change_set = grep {/(?:[^\:\n]\s+((?:.+)\@+(?:.+)\\\d+))/} (@activity_details);
        
	print join("\t",@change_set);
	
        $Hash{$_} = \@change_set;
    }
    return %Hash;
}

####################################################
sub GetTimeLine
####################################################
{
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $time) = localtime();
    $year = $year + 1900;
    $mon  = $mon + 1;
    my $line    = "_" . $year . "_" . $mon . "_" . $mday  . "_" . $hour  . "H" . $min . "M";
    return $line;
}############################################################################################

