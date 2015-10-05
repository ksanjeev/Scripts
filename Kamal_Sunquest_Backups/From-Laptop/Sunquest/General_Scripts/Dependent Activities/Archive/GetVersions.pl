#!D:\Perl\bin\perl.exe
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
# GetVersions.pl
#      This script fetches the versions of an element associated with a activity from Clearcase.
#      The script gets input from the configuration file ( Versions.cfg ). 
#
#
# Usage:
#      1) Edit the configuration file ( Versions.cfg )
#      2) Edit the the variable "$ConfigFile" below and specify the path to the "Versions.cfg"
#      3) Edit the the variable "$root_path" below and specify the drive in the global path where the view is created
#      4) Edit the the variable "$ErrorLog" below and specify the path to store the error log file
#      3) Edit the the variable "$EventLog" below and specify the path to store the event log file
#
#
# Returns:
#      1) It creates folder for each activity specified in the "Versions.cfg" file and copies the associated versions of elements as per the change set.
#      2) It builds the error log and event log files. If the size of the error log file is more than 0kb then we have an error. 
#
#=========================================================================
# Edit history:
#
#	Initial creation:	Saju Carlos on 04/03/07
#
#=========================================================================

# Edit the below variables as per required
    
    my $ConfigFile = 'D:\CC\Versions.cfg';            # Absolute path to the "Versions.cfg"
    my $root_path = "M:\\";                           # The drive in the global path where the view is created
    my $ErrorLog = 'D:\Temp\Error_buildversion.log';  # Path to the error log file
    my $EventLog = 'D:\Temp\Buildversion.log';        # Path to the event log file





# Please do not edit below this line
################################################################################

    use Config::IniFiles;
    use File::Copy;
    use File::Path;
    use Cwd;
   
    my (%cfg,%Build) = ();
    my $Command = '';
    
    # Read then config file into hash
    tie %cfg, 'Config::IniFiles', ( -file => "$ConfigFile" );

    # Get the section into a hash
    %Build = %{$cfg{BUILDVERSION}};

    # Map the network drive
    #$Command = `net use G: $Build{Storage_Location}`;

    # Open the log
    open (LOG,">$EventLog") or die "Cannot open $EventLog";
    
    # Open the error log
    open (ERRORLOG,">$ErrorLog") or die "Cannot open $ErrorLog";


    # Go to the view directory
    chdir($root_path);
 
    ########## Create view ########

    my $ViewPath = $Build{Storage_Location}.'mkbl_int_view.vws';
    
    # $command_line = 'cleartool mkview -stream '.$int_stream.'@\\'.$product_vob.' -tag mkbl_int_view '.$Storage_Location.'mkbl_int_view.vws';
    $Command  = 'cleartool mkview -stream '.$Build{STREAM}.'@\\'.$Build{PROJECT_VOB}.' -tag mkbl_int_view '.$Build{Storage_Location}.'mkbl_int_view.vws';


    # Run the command and get the result
    my @execute = `$Command`;
    

    # Check the exit status
    if ($execute[0] =~ /^Created view/)
    {
      map { print LOG "$_ \n"} @execute;
    }
    else {
      printlog("Unable to create view 'mkbl_int_view' in the path $ViewPath \n", 'error');
    }
    #################
    
    

    # Get the LIST of activities
    my @activities = split(/,/,$Build{ACTIVITIES});

    # Go to the view directory
    chdir('mkbl_int_view');

    my @ChangeSet = ();

    foreach (@activities)
    {
        my %cset = ();
        my $activity = $_;
        my $activitydir = $Build{DESTINATION_FOLDER}.$_;
        my $Containsdir = '';
        rmtree([$activitydir],1,1);  # rmtree(['foo/bar/baz', 'blurfl/quux'], 1, 1);
        mkdir($activitydir);    #  unless (-e $activitydir);
        GetChangeSet($_,\%cset);
        
        foreach (keys %cset) {
          
          # ($Containsdir) = ($cset{$_} =~ /(.+)(?=\@\@)/);
          # next if (-d $Containsdir);
          next if (CheckElementType($cset{$_}));
          $Command = "";
          
          # Get the version from clearcase
          # cleartool get -to G:\PHAZ100001048\25thAug2006-MHI.TXT M:\mkbl_int_view\scenario2.5_gui\Applications\axMRadTO\25thAug2006-MHI.TXT@@\main\scenario2.5_Rel5.1_MHI\10
          $Command = 'cleartool get -to G:\\'.$activity.'\\'.$_.' '.$cset{$_}.' 2>&1';

          # Run the command and get the result
          my @exec = `$Command`;

          if ($exec[0] =~ /cleartool:\sError:/) {
            printlog("Unable to copy the version file.","error");
          }
          else {
            chomp $cset{$_};
            print LOG "Copied version '$cset{$_}' to G:\\$activity \n" ;
          }
        }
    }
    


    ########## End view ########
    $Command  = 'cleartool endview mkbl_int_view 2>&1';
    
    # Run the command and get the result
    my $endview = `$Command`;
 
    chomp $execute[2];
    
    my ($global_view_path) = ($execute[2] =~ /(?:(\\.+))/);
    
    # $command_line = 'cleartool rmview -force \\thazchail\Temp\mkbl_int_view.vws';
    $Command  = 'cleartool rmview -force '.$global_view_path;

    @execute = ();
    
    # Run the command and get the result
    @execute = `$Command`;

    if ($execute[0] =~ /cleartool:\sError:/) {
       printlog("Unable to remove view.","error") if (!-d $ViewPath);
    }
    elsif ($execute[0] =~ /Removing\sreferences\sfrom\sVOB/) {
       map { print LOG "$_ \n"} @execute;
    }
    #####################
    
    
    close(LOG);
    close(ERRORLOG);
    


    sub CheckElementType()
    {
      # Checks element type and returns true if the element is a directory
      my $element = shift;
      my $type = 0;
      my @exec = `cleartool describe -l $element`;
      
      foreach (@exec)
      {
        if (/element\stype:\s(.+)/)
        {
          $type = 1 if ($1 =~ /directory/i);
        }else { next }
      }
      return $type;
    }

    sub GetChangeSet
    {
        my $activity = shift;
        my $cshash = shift;
        
        @ChangeSet=();
        # cleartool lsactivity -l PHAZ100001050@\scenario2.5_pvob
        my $cmd = 'cleartool lsactivity -l '.$activity.'@\\'.$Build{PROJECT_VOB}.' 2>&1';
        my @activityInfo = `$cmd`;
        @ChangeSet = grep {/^\s*M\:(?:.+)\\\d+$/} @activityInfo;
        
        foreach (@ChangeSet)
        {
          if (/(?:\\([^\\]+)(?=\@\@))/)
          {
            $cshash->{$1} = $_;
          }
        }
    }


    sub printlog
    {
        my $message = shift;
        my $type = shift;

        if ($type eq 'error')
        {
          print ERRORLOG "$message \n";
        }
        else
        {
          print LOG "$message \n";
        }
    }



