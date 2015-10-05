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
# GetFileElimentFromClearCase.PL
#      This script fetches the versions of an element associated with a activity from Clearcase.
#      The script gets input from the configuration file ( GetFileElimentFromClearCase.CFG ). 
#
#
# Usage:
#      1) Edit the configuration file ( GetFileElimentFromClearCase.CFG )
#
#
# Returns:
#      1) It creates folder for each activity specified in the "GetFileElimentFromClearCase.CFG" file and copies the associated versions of elements as per the change set.
#      2) It builds the error log and event log files. If the size of the error log file is more than 0kb then we have an error. 
#
#=========================================================================
# Edit history:
#
#	Initial creation:	Saju Carlos on 04/03/07
#
#=========================================================================

# Edit the below variables as per required
    
    my $ConfigFile = 'GetFileElimentFromClearCase.CFG';            # Absolute path to the "GetFileElimentFromClearCase.CFG"
    my $ViewTag = 'mkbl1_int_view';




#-------------------- Please do not edit below this line -----------------#




  
  
  ##################### Start of Main Program #####################
    use Config::IniFiles;
    use strict;
    use File::Copy;
    use File::Path;
    use Cwd;
   
    my (%cfg,%Build) = ();
    my $Command = '';
    my $Global_view_path = '';
    my @ChangeSet = ();    
    
    # Read then config file into hash
    tie %cfg, 'Config::IniFiles', ( -file => "$ConfigFile" );

    # Get the section into a hash
    %Build = %{$cfg{ACTIVITY_DETAIL}};

    my $root_path = 'M:\\';   
    my $ErrorLog = $Build{DESTINATION_FOLDER}.'Error_GetFileElimentFromClearCase.log';  
    my $EventLog = $Build{DESTINATION_FOLDER}.'GetFileElimentFromClearCase.log';

    #system 'rmdir /S /Q '.$log_Path; #  Delete the existing directory
    #mkdir $log_Path;                 #  Create the Directory Again
        
    #my $command = "cd $Build{DESTINATION_FOLDER}";
    #system $command;
    
    #my $command = "cd $Build{DESTINATION_FOLDER}";
    #system $command;
    
    
    #rmtree([$Build{DESTINATION_FOLDER}],1,1);
    
    # Create the destination folder if not exists
    mkdir($Build{DESTINATION_FOLDER}) unless (-e $Build{DESTINATION_FOLDER});
    
    # Open the log
    open (LOG,">$EventLog") or die "Cannot open $EventLog";
    
    # Open the error log
    open (ERRORLOG,">$ErrorLog") or die "Cannot open $ErrorLog";

    printlog("----- Start event log ------ \n\n","");
    # printlog("----- Start error log ------ \n\n",'error');


    # Go to the view directory
    chdir($root_path);
 
    # Create view 
    &CreateView($ViewTag);

    # Mount all vobs
    &MountVobs();

    # Go to the view directory
    chdir($ViewTag);

    # Get the LIST of activities
    my @activities = split(/,/,$Build{ACTIVITIES});

    # Get all the child activities if any
    #&GetChildActivities(\@activities);

    printlog("\n Start fetching elements from activities. \n","");
    
    # Now process for each activity
    foreach (@activities)
    {
        #my %cset = ();
        my $activity = $_;
        
        &printlog("\nActivity: $activity \n","");
        my $activitydir = $Build{DESTINATION_FOLDER}.$_;
        rmtree([$activitydir],1,1);
        &BuildActivityDetails($activity,$activitydir);        
    }

    printlog("\n End fetching elements from activities. \n","");
    
    # Unmount the VOBs  
    &UnmountVobs();

    # Go to the view directory
    chdir($root_path);

    # Remove the created view ########
    &RemoveView($ViewTag);
    
    printlog("\n ----- End event log ------ \n","");
    # printlog("\n ----- End error log ------ \n","error");
    
    close(LOG);
    close(ERRORLOG);
    
 
    print "\n\n* * * End of GetFileElimentFromClearCase.PL.......* * * \n";
    
    
    exit;

  ##################### End of Main program #####################




  #************** Start of GetChildActivities() ***************
  
  sub GetChildActivities
  {
    my $activitylist = shift;
    my @CurrentActivities = @{$activitylist};
    
    # cleartool describe -l stream:scenario2.5_Rel5.1_Shared_Dev_MHI@\scenario2.5_pvob
    my $Command = '';
    $Command = 'cleartool describe -l stream:'.$Build{STREAM}.'@\\'.$Build{PROJECT_VOB};
    
    my @execute = `$Command`;
    
    foreach (@CurrentActivities)
    {
       my @child = grep {/^$_/} @execute;
       map {
        s/(.+)(?=\@)/$1/;
        push @{$activitylist},$_;
        } @child;
    }
  }
  
  
    #************** End of GetChildActivities() ***************







  #************** Start of RemoveView() ***************

  sub RemoveView
  {
    my $ViewTag = shift;
    my $ViewPath = $Build{View_Storage_Location}.$ViewTag.'.vws';
    
    my @execute = ();
    my $Command  = 'cleartool endview '.$ViewTag; #.' 2>&1';
    
    printlog("Removing view '$ViewTag'. \n","");
    
    # Run the command and get the result
    #my $endview = `$Command`;
    system $Command;
    
    if ($? == 0)
    {
      printlog("Deactiviated view '$ViewTag'. \n","");  
    } else
    {
      printlog("Unable to deactiviate view '$ViewTag'. \n","");
      printlog("Unable to deactiviate view '$ViewTag'. \n",'error');
    }
    
    
    # $command_line = 'cleartool rmview -force \\thazchail\Temp\mkbl1_int_view.vws';
    #$Command  = 'cleartool rmview -force '.$Global_view_path;
    #$Command = 'cleartool rmview -force -tag '.$ViewTag;

    # Pause for a while
    #sleep(60);
    
    # Run the command and get the result
    #@execute = `$Command`;
    #system $Command;
    
    
    
    
    
    # If view already exists then remove the view
    if (-d $ViewPath)
    {
      $Command = 'cleartool rmview -force -tag '.$ViewTag;
      system $Command;
    }
    
    

    if ($? != 0) {
      printlog("Unable to remove view '$ViewTag'. \n","");  
      printlog("Unable to remove view '$ViewTag'. \n","error");
    }
    else {
      printlog("Removed view $ViewTag","");
    }
  }
  
  #************** End of RemoveView() ***************

  
  
  
  #************** Start of CreateView() **********************
  
  sub CreateView
  {
    
    my $ViewTag = shift;
    my $ViewPath = $Build{View_Storage_Location}.$ViewTag.'.vws';
    
    # If view already exists then remove the view
    if (-d $ViewPath)
    {
      printlog("Found view '$ViewTag' in the path $Build{View_Storage_Location} \n","");
      printlog("Removing view '$ViewTag' ..............\n","");
      
      my $command = 'cleartool rmview -force -tag '.$ViewTag;
      system $command;
      
      if ($? == 0)
      {
        printlog("Removed existing view '$ViewTag' from the path $Build{View_Storage_Location} \n","");
      } else
      {
        printlog("Unable to remove existing view '$ViewTag' from the path $Build{View_Storage_Location} \n","");
        printlog("\n ----- End event log ------ \n","");
        printlog("\n ----- End error log ------ \n","error");
        print("\n ----- Please check error log ------ \n");
        exit;
      }
    }
    
    printlog("Creating view '$ViewTag' in the path $Build{View_Storage_Location} \n","");
    # $command_line = 'cleartool mkview -stream '.$int_stream.'@\\'.$product_vob.' -tag mkbl1_int_view '.$View_Storage_Location.'mkbl1_int_view.vws';
    $Command  = 'cleartool mkview -stream '.$Build{STREAM}.'@\\'.$Build{PROJECT_VOB}.' -tag '.$ViewTag.' '.$Build{View_Storage_Location}.$ViewTag.'.vws';

    # Run the command and get the result
    my @execute = `$Command`;

    # Check the exit status
    if (@execute)
    {
      if ($execute[0] =~ /^Created view/)
      {
        map { print LOG } @execute;
        print LOG "\n";
      }
      else {
        printlog("\nUnable to create view '$ViewTag' in the path $Build{View_Storage_Location} \n", 'error');
        printlog("\n ----- End event log ------ \n","");
        printlog("\n ----- End error log ------ \n","error");
        print("\n ----- Please check error log ------ \n");
        exit;
      }
    } else
    {
      printlog("\nUnable to create view '$ViewTag' in the path $Build{View_Storage_Location} \n", 'error');
      printlog("\n ----- End event log ------ \n","");
      printlog("\n ----- End error log ------ \n","error");
      print("\n ----- Please check error log ------ \n");
      exit;        
    }

    # Set the view Global path
    chomp ($execute[2]) if defined ($execute[2]);
    ($Global_view_path) = ($execute[2] =~ /(?:(\\.+))/) if defined ($execute[2]);
  }
    
  #************** End of CreateView() **********************
  
  
  
  


  #************** Start of MountVobs() **********************

  sub MountVobs
  {
    # Get all those VOB's which needs to be mounted & mount them one by one...
    my @mount_VOBs = split /,/, $Build{Mount_VOBs};
    
    my $ndx = 0;
    for ($ndx = 0; $ndx <= $#mount_VOBs; $ndx++)
    {
        
      my $command_line = 'cleartool mount \\'.$mount_VOBs[$ndx];
      my @execute = `$command_line`;
      # system $command_line;
      
      if (@execute)
      {
        printlog("$execute[0] \n","");
      }
      else
      {
        printlog("Unable to mount the VOB $mount_VOBs[$ndx] \n","");
        printlog("Unable to mount the VOB $mount_VOBs[$ndx] \n",'error');
      }
    }
  }

  #************** End of MountVobs() **********************




  #************** Start of UnmountVobs() **********************

  sub UnmountVobs
  {
    #==============================================================#
    #   Unmount All The VOB's which were mounted
    #==============================================================#
    #   Now its our turn to un-mount all those mounted VOBS.
    my $ndx = 0;
    my @mount_VOBs = split /,/, $Build{Mount_VOBs};
    for ($ndx = 0; $ndx <= $#mount_VOBs; $ndx++)
    {
      my $command_line = 'cleartool umount \\'.$mount_VOBs[$ndx];
      system $command_line;
      
      if ($? == 0)
      {
        printlog("Unmounting the VOB $mount_VOBs[$ndx] \n","");
      }
      else
      {
        printlog("Unable to unmount the VOB $mount_VOBs[$ndx] \n","");
        printlog("Unable to unmount the VOB $mount_VOBs[$ndx] \n",'error');
      }
    }
  }

  #************** Start of UnmountVobs() **********************
  
  
  
  

  #************** Start of BuildActivityDetails() **********************

  sub BuildActivityDetails
  {
    my $activity = shift;
    my $activitydir = shift;        
    my $Containsdir = '';
    my %cset = ();
      
    # Create the activity folder 
    mkdir($activitydir);
     
    # Get the change set for the current activity
    &GetChangeSet($activity,\%cset);
    
    # Fetch the version for this activity
    &FetchVersions($activity,$activitydir,\%cset);

    # If contributing activities are needed
    if ($Build{GET_CONTRIBUTING_ACTIVITIES} =~ /y/i)
    {
      # Get the contributing activities
      my %contrib = ();
      &GetContribActivities($activity,\%contrib,$activitydir);
      foreach (keys %contrib)
      {
        $activitydir = $contrib{$_};
        &BuildActivityDetails($_,$activitydir);
      }
    }
    return;
  } # End BuildActivityDetails()
  
  #************** End of BuildActivityDetails() **********************
  
  

  #************** Start of FetchVersions() **********************

  sub FetchVersions
  {
    my $activity = shift;
    my $activitydir = shift;
    my $cset = shift;
    
    printlog("Fetching versions into '$activitydir' \n","");  
    # Fetch the versions into the activity folder  
    foreach (keys %{$cset})
    {
      next if (&CheckElementType($cset->{$_}));
      my $newactivitydir = $activitydir;
      
      my ($getelementpath,$filename) = (/(?:M\:\\(?:.+?)(\\.+)\\(.+))/);
      $getelementpath =~ s/\\/\//g;
      $newactivitydir .= $getelementpath;

      # Create the folder
      mkpath([$newactivitydir], 1, 0711);

      #mkdir($newactivitydir);
      
      
      $Command = "";
          
      # Get the version from clearcase

      # $Command = 'cleartool get -to G:\\'.$activity.'\\'.$_.' '.$cset{$_}.' 2>&1';
        $Command = 'cleartool get -to '.$newactivitydir.'/'.$filename.' '.$cset->{$_}.' 2>&1';

      # Run the command and get the result
        my @exec = `$Command`;

      if (@exec)
      {
        chomp $cset->{$_};
        $cset->{$_} =~ s/^\s+//;
        if ($exec[0] =~ /cleartool:\sError:/) {
          printlog("Unable to copy the version file '$cset->{$_}'. \n","");  
          printlog("Unable to copy the version file '$cset->{$_}'.","error");
        }
        else {
          printlog("Copied version file '$cset->{$_}' to $activitydir\\$_ \n","");  
          # print LOG "Copied version '$cset->{$_}' to $activitydir\\$_ \n" ;
        }
      }
      #else
      #{
      #  printlog("Unable to copy the version file '$cset->{$_}'.","");
      #  printlog("Unable to copy the version file '$cset->{$_}'.","error");
      #}
    } # End of foreach

    # end of fetch of versions
    return;
  }
  
  
  #************** End of FetchVersions() **********************


  

  #************** Start of GetContribActivities() **********************

  sub GetContribActivities {
    # Returns the list of contributing activities
    my $activity = shift;
    my $contrib = shift;
    my $activitydir = shift;
    
    # my @contrib = ();
    printlog("Get contributing activities for the activity '$activity': \n","");  
    
    # cleartool lsactivity -contrib PHAZ100000360@\scenario2.5_pvob
    my $Command = 'cleartool lsactivity -contrib '.$activity.'@\\'.$Build{PROJECT_VOB};
    my @execute = `$Command`;
    
      if ($execute[0] =~ /cleartool:\sError:/) {
        printlog("Unable to get contributing activities for the integartion activity $activity@\\$Build{PROJECT_VOB}","error");
      }
      else {
        foreach (@execute)
        {
          chomp;
          printlog("$_ \n","");  
          $contrib->{$_} = $activitydir.'/'.$_;  
        }  
      } 
  } # End of GetContribActivities()

  #************** End of GetContribActivities() **********************






  #************** Start of CheckElementType() **********************

    sub CheckElementType()
    {
      # Checks element type and returns true if the element is a directory
      my $element = shift;
      my $type = 0;
      my $Command = 'cleartool describe -l '.$element;
      
      #my @exec = `cleartool describe -l $element`;
      my @exec = `$Command`;
      
      foreach (@exec)
      {
        if (/element\stype:\s(.+)/)
        {
          $type = 1 if ($1 =~ /directory/i);
        }else { next }
      }
      return $type;
    }

  #************** End of CheckElementType() **********************




  #************** Start of GetChangeSet() **********************

    sub GetChangeSet
    {
        my $activity = shift;
        my $cshash = shift;

        my @ChangeSet=();

        printlog("Change set: \n","");
        # cleartool lsactivity -l PHAZ100001050@\scenario2.5_pvob
        my $cmd = 'cleartool lsactivity -l '.$activity.'@\\'.$Build{PROJECT_VOB}.' 2>&1';
        my @activityInfo = `$cmd`;
        @ChangeSet = grep {/^\s*M\:(?:.+)\\\d+$/} @activityInfo;
        
        foreach (@ChangeSet)
        {
          if (/(?:(.+)(?=\@\@))/)
          {
            my $key = $1;
            $key =~ s/(?:(?:.+)(M\:\\(?:.+)))/$1/;
            printlog("$_","");
            if (defined $cshash->{$key})
            {
               if ($cshash->{$1} =~ /(?:.+)\\(\d+)/)
               {
                my $current_version = $1;
                my ($new_version) = (/(?:.+)\\(\d+)/);
                $cshash->{$key} = $_ if ($new_version > $current_version);
               }
            }
            else
            {
              $cshash->{$key} = $_;
            }  
          }
        }
    }

  #************** End of GetChangeSet() **********************


  #************** Start of printlog() **********************

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

  #************** End of printlog() **********************

