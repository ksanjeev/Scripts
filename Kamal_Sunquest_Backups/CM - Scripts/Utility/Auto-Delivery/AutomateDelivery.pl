#!/usr/bin/perl -w

#crmregister add -database LAB -connection 7.0.0 -user auto_delivery -password clearquest

 # Call the required modules 
# use strict;
 use warnings;
 use Config::IniFiles;
 use Misys::SendMail;


 # The config file
 my $ConfigFile = 'deliver.cfg';
 
 # The Log files
 my $Path_to_Log_files = "";
 my $log_File = "";
 my $log_Error = "";
 
 my $TMPDIR = "";
 my $DEVNULL = "";
 my $SLASH = "";
 my $QUOTE = "";
 my $COPY = "";
 my $PWD = "";
 my $result = "";
 my $message = "";
 my $baseline_list = "";
 my $deliver_logfile = "";
 my $bridge_stream_view_tag = "";
 my $bridge_stream = '';
 my $Deliver_From_MHI_Dev_To_MHI_Bridge = '';
 my $Deliver_From_MHI_Bridge_To_MHU_Dev = '';
 my $Deliver_From_MHI_Dev_To_MHI_Bridge_attempt = '';
 my $Deliver_From_MHI_Bridge_To_MHU_Dev_attempt = '';
 
 my $timeline = &GetTimeLine;
 
 my $outfile = $TMPDIR.$SLASH."cprompt.txt";
 
 my %cfg = ();
 my %deliver = ();
 my %email = ();
############################################################################################
# End of Global Variable diclaration
############################################################################################

####################################################
sub Get_Delivery_activity
# Added by Saju on 24th August 2007
####################################################
{
  my $bridge_stream = shift;
  $bridge_stream = "stream:$bridge_stream\@\\$deliver{ProductVOB}";
  
  my $delivery_activity;
  
  open (DELIVERLOG, "<$deliver_logfile") or die "Can't read deliver log file: $deliver_logfile.\n";
  
  while (<DELIVERLOG>)
  {
    if (/\s+Attached\sactivities\:/)
    {
      my $nextline = <DELIVERLOG>;
      ($delivery_activity) = ($nextline =~ /(?:activity\:([^\s]+))/);
      $delivery_activity =~ s/(?:(.+)\@(?:.+))/$1/;
      last;
    }
  } # End While loop
  
  close (DELIVERLOG);
  
  return $delivery_activity;
}
############################################################################################

############################################################################################
#
#  CreateView - Either start an existing view or create a new view.   
#  Parameters:
#
#      view_tag    -    The View tag to start or create.      
#      storage_dir -    The top-level storage directory.  Will use this directory plus
#                       the ${view-tag}.vws as the actual complete storage 
#                       directory when creating a view.
#      cachesize      - If specified, will pass this value along to the mkview command
#                       (i.e.: "512000", "1024000", "2048000", etc.)
#      text_mode      - If specified, will pass this value along to the mkview command
#                       (i.e.: unix, msdos).
#      snapshot       - If defined, will create a snapshot view and use the passed value
#                       as the View Root of the snapshot view.
#      stream         - If specified, will attach the view to the stream
#      nshareable_dos  - If not specified will create as shareable_dos
#      
#      output  - Defaults to 'output'.  Can also specify 'status'.
#                'output' - Will capture output of command (not the error,
#                           unless 2>&1 is part of the command).
#                'status' - Will call system to execute command (output will
#                           go to STDOUT, unless you redirect with something
#                           like 1>$DEVNULL, if you want error
#                           redirected, use 2>$DEVNULL, etc.)
#  Return Value:
#
#      1 - If the view was created or started.
#      0 - If something went wrong.
#
#  Author:
#    David E. Bellagio (dbellagio@rational.com)
#
####################################################
sub CreateView {
####################################################  
   my %args = (
      'view_tag' => "",
      'text_mode' => "",
      'cachesize' => "",
      'storage_dir' => "",
      'snapshot' => "",
      'stream' => "",
      'shareable_dos' => "",
      @_,
   );
   my ($result, $cmd, $msg);

   #----------------------------------------------------------
   # See if view already exists
   #----------------------------------------------------------
   $cmd = "lsview $args{'view_tag'} 2>&1";
   $result = ClearTool(cmd => \$cmd); 
   if ( $? ) {
      #-------------------
      # Create the View
      #-------------------   
      $cmd = "mkview -tag $args{'view_tag'}";
      if ( $args{'snapshot'} ) {
         #------------------------------------
         # a snapshot view
         #------------------------------------
         $cmd = "$cmd -snapshot";
         if ( $args{'storage_dir'} ) {
            $cmd = "$cmd -vws $QUOTE$args{'storage_dir'}$SLASH$args{'view_tag'}.vws$QUOTE";
         }
         else { 
            $cmd = "$cmd -stgloc Views";
         }
      }
      if ( $args{'text_mode'} ) {
         $cmd = "$cmd -tmode $args{'text_mode'}";
      }
      if ( $args{'cachesize'} ) {
         $cmd = "$cmd -cachesize $args{'cachesize'}";
      }
      if ( $args{'stream'} ) {
         $cmd = "$cmd -stream $args{'stream'}";
      }

      if ( $args{'snapshot'} ) {
         #---------------------------------
         # a snapshot view
         #---------------------------------
         $cmd = "$cmd $args{'snapshot'} 2>&1";
      } else {

# Commented by Ashwin on 28th Aug 2007
#         if ( $args{'shareable_dos'} eq "yes") {
#            $cmd = "$cmd -shareable_dos";
#         }
#         else {
#            $cmd = "$cmd -nshareable_dos";
#         }
# Commented by Ashwin on 28th Aug 2007

         if ( $args{'storage_dir'} ) {
            $cmd = "$cmd $QUOTE$args{'storage_dir'}$SLASH$args{'view_tag'}.vws$QUOTE 2>&1";
         } 
         else { 
            $cmd = "$cmd -stgloc Views";
         }
      }
      print "$cmd\n";
      $result = ClearTool(cmd => \$cmd);
      if ( $? ) {
         $msg = "Can't create view $args{'view_tag'}";
         Error(msg => \$msg);
         return(0);
      }
   } else {
      #--------------------------
      #  Just start the view
      #--------------------------
      $cmd = "startview $args{'view_tag'} 2>&1";
      $result = ClearTool(cmd => \$cmd);
      if ( $? ) {
         $msg = "Can't start view $args{'view_tag'}";
         Error(msg => \$msg);
         return(0);
      }
   }
   return(1);
}
############################################################################################

############################################################################################
#
#  ClearTool - Execute a cleartool command, return status or output.
#
#  Parameters:
#
#      cmd     - A string reference to the cleartool command 
#                (i.e.: \$cmd not $cmd).
#      output  - Defaults to 'output'.  Can also specify 'status'.
#                'output' - Will capture output of command (not the error,
#                           unless 2>&1 is part of the command).
#                'status' - Will call system to execute command (output will
#                           go to STDOUT, unless you redirect with something
#                           like 1>$DEVNULL, if you want error
#                           redirected, use 2>$DEVNULL, etc.)
#
#  Side Effects:
#
#      If an error occurs, and output => 'output' was in effect, you can 
#      determine an error occurred by checking $?.  If you had output => 'status',
#      then the return value will be $?/256, not $?.
#
#  Return Value:
#
#      'output' - If you expect a list return, this will split on "\n" before
#                 returning the list (after a chomp() is performed).  
#                 If you expect a string, you will get
#                 the entire contents (after a chomp() is performed).
#
#      'status' - $?/256 will be returned.  No need for you to divide by
#                 256.  Note, cleartool returns 0 if the command was a success,
#                 and 1 if it failed.
#
#  Author:
#    David E. Bellagio (dbellagio@rational.com)
#
#-------------------------------------------------------------------------
####################################################
sub ClearTool {
####################################################  
   my %args = (
      'output' => "output",
      @_,
   );
   my $CLEARTOOL = 'cleartool';
   my $type = ref($args{'cmd'}) or writelog("Reference to cleartool command not passed to ClearTool","error");    
   local($_);
   my $x =  ${$args{'cmd'}}; 
   if ( $args{'output'} =~ /status/o ) {
      system("$CLEARTOOL ${$args{'cmd'}}");
      $? / 256;
   } else {
      $_ = `cleartool ${$args{'cmd'}}`;
      chomp($_);
      if ( wantarray ) {
         split("\n");
      } else {
         $_;
      }
   }
}
############################################################################################

############################################################################################
#
#  RemoveView - Remove an existing view.
#
#  Parameters:
#
#      view_tag    - The View tag to remove.      
#
#  Side Effects:
#
#      If the view exists, it will be stopped first.
#      If the view exists, it will be removed with the -force option.
#
#  Return Value:
#
#      1 - If the view was removed.
#      0 - If something went wrong.
#
#  Author:
#    David E. Bellagio (dbellagio@rational.com)
#
#-------------------------------------------------------------------------
####################################################
sub RemoveView {
####################################################  
   my %args = (
      'view_tag' => "",
      @_,
   );
   my ($result, $cmd, $msg);

   #----------------------------------------------------------
   # Stop the view first
   #----------------------------------------------------------
   if ( ! StopView(view_tag => $args{'view_tag'},
                              server => "1") ) {
      $msg = "Can't stop view server for $args{'view_tag'}";
      Error(msg => \$msg);
      return(0);
   } else {
      #------------------------
      #  Delete it with force
      #------------------------
      $cmd = "rmview -force -tag $args{'view_tag'} 2>&1";
      $result = ClearTool(cmd => \$cmd);
      if ( $? ) {
         $msg = "Can't remove view $args{'view_tag'}";
         Error(msg => \$msg);
         return(0);
      }
   }
   return(1);
}
############################################################################################

############################################################################################
#
#  StopView - Stop an existing view.
#
#  Parameters:
#
#      view_tag    - The View tag to stop. 
#      server      - 1 if you want to stop the View server process.
#                    0 if you just want to deactivate it from your machine.     
#
#  Side Effects:
#
#      None.
#
#  Return Value:
#
#      1 - If the view was stopped.
#      0 - If something went wrong.
#
#  Author:
#    David E. Bellagio (dbellagio@rational.com)
#
#-------------------------------------------------------------------------
####################################################
sub StopView {
####################################################  
   my %args = (
      'view_tag' => "",
      'server' => "",
      @_,
   );
   my ($result, $cmd, $msg);

   #----------------------------------------------------------
   # See if view already exists
   #----------------------------------------------------------
   $cmd = "lsview $args{'view_tag'} 2>&1";
   $result = ClearTool(cmd => \$cmd);
   writelog("COMMAND: $cmd\n");
   if ( $? ) {
      #-----------------------
      # View does not exist
      #-----------------------   
      $msg = "View $args{'view_tag'} does not exist";
      Error(msg => \$msg);
      return(0);
   } else {
      #------------------------
      #  Stop the View
      #------------------------
      if ( $args{'server'} ) {
         $cmd = "endview -server $args{'view_tag'} 2>&1";
      } else {
         $cmd = "endview $args{'view_tag'} 2>&1";
      }
      $result = ClearTool(cmd => \$cmd);
      if ( $? ) {
         $msg = "Can't stop view $args{'view_tag'}";
         Error(msg => \$msg);
         return(0);
      }
   }
   return(1);
}
############################################################################################

####################################################
sub Error
{
####################################################  
   my %args = (
      'msg' => "",
      @_,
   );
   my $type = ref($args{'msg'}) or writelog("Reference to error message not passed to Error","error");
   print STDERR "\n ERROR: ${$args{'msg'}}\n";
}
############################################################################################

####################################################
sub Inform {
####################################################  
  my ($msg) = @_;
#   my %args = (
#      'msg' => "",
#      @_,
#   );
#   my $type = ref($args{'msg'}) or print "Reference to error message not passed to Error";
#   print(STDERR "INFORM: ${$args{'msg'}}\n");

  print(STDERR "\nINFORM: $msg\n");
}
############################################################################################

############################################################################################
#************** Start of SendMail() ***************
# Description:  Used to send email to the address specified in the configuration file.
#               The first email address in the configuration file is the sender and the
#               rest is the recipient list.
#
# Usage:        &SendMail([Subject],[Body],[Attachments],[Type]);
#
####################################################
sub SendMail
####################################################
{
    # Get the subject
    my $subject = shift;
    
    # Get the body of the email
    my $mailbodydata = shift;
    
    # Get the recipient list
    my @recipients = split(/,/,$email{EMAIL_LIST});
    
    # Get the attachments
    my $attachment = shift;
    
    # Get the type of email success/failure
    my $type = shift;
    
    # Create an email object
    my $Email = new SendMail($email{SMTP_SERVER}, $email{SMTP_PORT});

    if ($type eq 'success')
    {
      # The sender will be the first recipient
      my $sender = $recipients[0];
      $Email->From($sender);
      $Email->To(@recipients); 
    }
    elsif ($type eq 'fail')
    {
      $Email->From($recipients[0]);
      $Email->To($recipients[0]);
    }
    
    $Email->Subject($subject);
    $Email->setMailHeader($email{EMAIL_HEADER}, $email{EMAIL_HEADER_VALUE}); 
    $Email->setMailBody($mailbodydata);
  
    map {$Email->Attach($_)} (@{$attachment}) if (ref($attachment) eq 'ARRAY');

    # Send the email 
    if ($Email->sendMail() != 0) {
        print $Email->{'error'}."\n";
    }

    # Clear the recipient list
    $Email->clearTo();
    
    # Reset
    $Email->reset();
  #************** End of SendMail() ***************
}
############################################################################################

####################################################
sub Initialise
####################################################    
{
    # Read the config file into hash
    tie %cfg, 'Config::IniFiles', ( -file => "$ConfigFile" );

    # Get the section into a hash
    %deliver = %{$cfg{CLEARCASE_DELIVER}};

    # Get the details of the email
    %email = %{$cfg{EMAIL}};
    
    my @bllist = split(/,/,$deliver{BASELINE_LIST});
    map {$baseline_list .= 'baseline:'.$_.'@\\'.$deliver{ProductVOB}.','}@bllist;
    $baseline_list =~ s/,$//;
    
    if ($ENV{'OS'} eq "Windows_NT")
    {
       $TMPDIR = ".";
       $DEVNULL = "NUL";
       $SLASH = "\\";
       $QUOTE = "\"";

       $COPY = "copy";
       $PWD = "chdir";
    }
    $deliver{PATH_TO_LOG} .= '\\';
    
    $log_File = $deliver{PATH_TO_LOG}.$deliver{MHI_INTEGRATION_STREAM}.'_Deliver.log';
    $log_Error = $deliver{PATH_TO_LOG}.$deliver{MHI_INTEGRATION_STREAM}.'_Deliver_Error.log';;
    $deliver_logfile = $deliver{PATH_TO_LOG}.'Deliver.log';
    
    open(OLDOUT, ">&STDOUT");
    open(OLDERR, ">&STDERR");
    open STDOUT, ">$log_File" or die "\nUnable to open \nError: $!\n";
    open STDERR, ">$log_Error" or die "\nUnable to open \nError: $!\n";  
}
############################################################################################





####################################################
sub Close_Initialise
####################################################
{
  # Added by Saju on 28/08/07
  close(STDOUT)|| die "Can't close log file";
  close(STDERR) || die "Can't close log file";

  # Restore stdout and stderr
  open(STDERR, ">&OLDERR")            or die "Can't restore stderr: $!";
  open(STDOUT, ">&OLDOUT")            or die "Can't restore stdout: $!";
  
  # Avoid leaks by closing the independent copies
  close(OLDOUT)                       or die "Can't close OLDOUT: $!";
  close(OLDERR)                       or die "Can't close OLDERR: $!";

  unlink($deliver_logfile);
  # Added by Saju on 28/08/07
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

####################################################
sub writelog
####################################################
{
  my $msg = shift;
  my $err = shift;
  if ((defined $err) and ($err =~ /error/i))
  {
    print STDERR "$msg\n";
    return;
  }
  print "$msg \n";
}
############################################################################################

####################################################
sub Email_Template_success
####################################################
{
  my $message = <<'TEMPLATE';
Hi,

 The deliver process completed successfully. 

{{PROCESS}}

 The configuration settings used for the deliver process:
	
{{CONFIGURATION_SETTINGS}}

Regards,
CM Team

TEMPLATE

my $subject = 'Auto Deliver Process for $deliver{ProductVOB} Completed Successfully';

return $message,$subject;
}
############################################################################################

####################################################
sub Email_Template_Failure
####################################################
{
  my $message = <<'TEMPLATE';
Hi,

 The deliver process failed. 

{{PROCESS}}

The configuration settings used for the deliver process:
	
{{CONFIGURATION_SETTINGS}}

{{ERROR_LOG}}

Regards,
CM Team

TEMPLATE

my $subject = 'Auto Deliver Process for $deliver{ProductVOB} Failed !';

return $message,$subject;
}
############################################################################################


############################################################################################
#******************************************************************************************#
          #   ****** MAIN LOGIC STARTS HERE ******   #
#******************************************************************************************#
############################################################################################
 &Initialise();

 my $p = "";
 #system("clearprompt proceed -prompt \"Automated delivery ....\" -type error -mask abort -prefer_gui");   # to be removed

# $p = system("clearprompt proceed -prompt \"$deliver{MHI_INTEGRATION_STREAM}\" -type error -mask abort -prefer_gui"); # to be removed

 writelog("Project: $deliver{MHI_project}");
 writelog("Stream: $deliver{MHI_INTEGRATION_STREAM}");
 writelog("MHI Bridge Stream: $deliver{MHI_BRIDGE_STREAM}");
  #Inform("Stream: $deliver{MHI_INTEGRATION_STREAM}");
  #Inform("Project: $deliver{MHI_project}");
 
  # Added by saju on 09/12/2007 
  #crmregister add -database LAB -connection 7.0.0 -user auto_delivery -password clearquest
  #CQ_DB
  if ((!defined $deliver{CQ_DB})||($deliver{CQ_DB} =~ ?\s+?i))
  {
    writelog("\nError: \"ClearQuest database information not provided\" \n","error");
    exit;
  }
  $cmd = "crmregister add -database $deliver{CQ_DB} -connection 7.0.0 -user auto_delivery -password clearquest";
  #my $crm = system($cmd);
  my $crm = system($cmd);
  if ($crm != 0)
  {
    writelog("\nError: \"$cmd\" failed.\n","error");
  }
  # End Add
      
# If stream is a MHI stream
 if ($deliver{MHI_INTEGRATION_STREAM} =~ /MHI/i)
 {
   $bridge_stream = '';
   $Deliver_From_MHI_Dev_To_MHI_Bridge = '';
   
   # Want to start deliver to bridge?
   my $cmd = "clearprompt yes_no -prompt \"Do you want to deliver to bridge stream?\" -default yes -mask yes,no -newline -prefer_gui";
   $result = system($cmd);
   if ($result == 0)
   {
      $Deliver_From_MHI_Dev_To_MHI_Bridge_attempt = 'y';

      writelog("List of baselines to be delivered at bridge: $baseline_list");
      
      # $p = system("clearprompt proceed -prompt \"Project = $deliver{MHU_project}\" -type error -mask abort -prefer_gui");
      # Inform("MHU Project Integration Stream: $deliver{MHU_INTEGRATION_STREAM}\n");

      writelog("MHU Project Integration Stream: $deliver{MHU_INTEGRATION_STREAM}\n");

      if (($deliver{CREATE_MHI_BRIDGE_STREAM} eq 'y')||($deliver{CREATE_MHI_BRIDGE_STREAM} eq 'Y'))
      {
        writelog("Creating Bridge Stream.");
        $bridge_stream = 'Bridge_'.$deliver{MHI_project}.$timeline;
        $cmd = "cleartool mkstream -in $deliver{MHU_INTEGRATION_STREAM}\@\\$deliver{ProductVOB} $bridge_stream\@\\$deliver{ProductVOB}";
        writelog("COMMAND: $cmd");
        $result = `$cmd`;
        
        if ($result =~ /error/i)
        {
          writelog("COMMAND: $cmd","error");
          writelog("$result","error");
        }
        else
        {
          writelog("$result");
        }
      }
      else
      {
        $bridge_stream = $deliver{MHI_BRIDGE_STREAM};
      }


# Commented by Ashwin on 28th Aug 2007      
#      if (!CreateView(view_tag      => "$bridge_stream", 
#                      stream        => "$bridge_stream\@\\$deliver{ProductVOB}",
#                      shareable_dos => "yes")
# Commented by Ashwin on 28th Aug 2007


      $bridge_stream_view_tag = $bridge_stream.$timeline;

      writelog("Creating bridge stream view: $bridge_stream_view_tag");

      if (!CreateView(view_tag      => "$bridge_stream_view_tag", 
                      stream        => "$bridge_stream\@\\$deliver{ProductVOB}",
                      storage_dir => "$deliver{STORAGE_LOCATION}")          
      )
      {
        writelog("\nError creating $bridge_stream_view_tag view.\n","error");
      }


      
      # Added by Ashwin on 27th Aug 2007...
      # To Set the environment variable for PHAZ1....
      # This is temp... need to verify if this is really required...
      #$cmd = "crmregister add -database PHAZ1 -connection 7.0.0 -user auto_delivery -password clearquest";
      #$result = `$cmd`;
      #print "$cmd\n";


      # Run deliver command
      
      writelog("\n\nStart deliver to Bridge.\n");
      
      $cmd = "cleartool deliver -stream $deliver{MHI_INTEGRATION_STREAM}\@\\$deliver{ProductVOB} -to $bridge_stream_view_tag -baseline $baseline_list -abort -force 2>&1";
      writelog("COMMAND:$cmd");
      
      $result = `$cmd`;
      if ($result =~ /error/i)
      {
        writelog("COMMAND: $cmd","error");
        writelog("$result","error");
      }
      else
      {
        writelog("$result");
      }
     
      my $delivered_bl_already                      = "No activities to deliver from stream";
      my $deliver_policies_disabled1                = "does not allow deliver operations from streams in other projects";
      my $deliver_policies_disabled2                = "because they are derived from different import baselines or the initial baseline";
      my $deliver_bl_not_found                      = "cleartool: Error: Selected baselines may not be delivered from this stream";
      my $deliver_other_error                       = "cleartool: Error:";
      my $deliver_automatic_merge                   = "Automatic: Applying";
      my $deliver_need_merge                        = "Needs Merge";
      my $deliver_trivial_merge                     = "Trivial merge:";
      my $deliver_conflicted_merge                  = "No Automatic Decision Possible";
      
      my $deliver_cannot_revert_to_earlier_baseline = "cleartool: Error: Can't revert to earlier baseline";
      my $deliver_there_are_checkouts               = "cleartool: Error: There are checkouts in view ";
      my $deliver_canceled                          = "Deliver of stream \"$deliver{MHI_INTEGRATION_STREAM}\" canceled";  
      my $deliver_completed                         = "Deliver has completed";
      my $deliver_already_in_progress               = "Deliver operation in progress";
      my $file1                                     = "<<< file 1: ";
      my $file2                                     = ">>> file 2: ";
      my $file3                                     = ">>> file 3: ";
      my $directory1                                = "<<< directory 1: ";
      my $directory2                                = ">>> directory 2: ";
      my $directory3                                = ">>> directory 3: ";
      
      my $deliver_next_step;
      my $source_bl;

      my $base_version = "";
      my $from_version = "";
      my $to_version   = "";
      my @deliver_trivial_merge         = ();
      my @deliver_automatic_merge_base  = ();
      my @deliver_automatic_merge_from  = ();
      my @deliver_automatic_merge_to    = ();
      my @deliver_conflicted_merge_base = ();
      my @deliver_conflicted_merge_from = ();
      my @deliver_conflicted_merge_to   = ();
      my @deliver_error_list            = ();
      my @deliver_conflicted_merge_owner = ();

      my $n_deliver_conflicted_merge;
      

#    $p = system("clearprompt proceed -prompt \"$result\" -type error -mask abort -prefer_gui");

      # Analyze command results: 
      # 1. baseline has been already delivered from $deliver{MHI_INTEGRATION_STREAM} to $bridge_stream
      if ($result =~ /$delivered_bl_already/gi)
      { 
        writelog("\n\t No activities to deliver from $deliver{MHI_INTEGRATION_STREAM} to $bridge_stream","error");
        my $msg = "No activities to deliver from $deliver{MHI_INTEGRATION_STREAM} to $bridge_stream";
        system("clearprompt proceed -prompt \"$msg\" -type error -mask proceed -prefer_gui");
        $deliver_next_step = "abort";       
      # 2. project policies preventing inter-project or stream-to-stream deliver operation
      }
      elsif (($result =~ /$deliver_policies_disabled1/gi) or ($result =~ /$deliver_policies_disabled2/gi))
      {
        writelog("\nUCM Project policies do not allow deliver from \"$deliver{MHI_INTEGRATION_STREAM}\" to \"$bridge_stream\"\n","error");
        $deliver_next_step = "abort";             
      # 3. baseline selected to deliver not found in $deliver{MHI_INTEGRATION_STREAM} - should never happen! the bl has been verified already
      }
      elsif ($result =~ /$deliver_bl_not_found/gi)
      { 
        writelog("\nBaseline $source_bl not in \"$deliver{MHI_INTEGRATION_STREAM}\" stream\n","error");
        $deliver_next_step = "abort";            
      # 4. deliver already in progress
      }
      elsif ($result =~ /$deliver_already_in_progress/gi)
      {
        my $msg = "There is another deliver already in progress.";
        writelog("\nThere is another deliver already in progress.\n","error");
        system("clearprompt proceed -prompt \"$msg\" -type error -mask proceed -prefer_gui");
        $deliver_next_step = "abort";
      # 5. there are checkout in bridge view
      }
      elsif ($result =~ /$deliver_there_are_checkouts/gi)
      { 
        writelog("\nThere are checkouts in view $bridge_stream.\n","error");
        $deliver_next_step = "abort";
      }
      else
      {
         # 6. deliver started - need to count trivial, automatic, conflict merges and any other eventual error message 
         open (DELIVERLOG, ">$deliver_logfile") or die "Can't create deliver log file: $deliver_logfile.\n";
         print DELIVERLOG $result;      
         close(DELIVERLOG);
         
         # count number of trivial merges
         $_ = $result;
         @deliver_trivial_merge = /$deliver_trivial_merge/gi;
         my $n_deliver_trivial_merge = $#deliver_trivial_merge + 1;
         
         # Added to check the performance of the script
         my $citrivial = 1;
         my $ciautomatic = 1;
         
         if ($n_deliver_trivial_merge gt 0)
         {
            if (!$citrivial)
            { 
               $deliver_next_step = "notify";
            }
            else
            {         
               $deliver_next_step = "notify_and_complete";             
            }
         }
            
         # count number of merge conflicts (need to calculate # of conflicts before calculating # of automatic merges)
         $_ = $result;
         @deliver_conflicted_merge_base = /$deliver_conflicted_merge/gi;
         $n_deliver_conflicted_merge = $#deliver_conflicted_merge_base + 1;
         if ($n_deliver_conflicted_merge gt 0)
         {
            $deliver_next_step = "notify";             
         }

         # count number of automatic merges
         $_ = $result;
         @deliver_automatic_merge_base = /$deliver_need_merge/gi;
         # automatic and conflitect merges, BOTH messages starts with "Need Merge". To calculate the
         # of automatic merge it is necessary to subtract the # of conflicted merges.
         my $n_deliver_automatic_merge = $#deliver_automatic_merge_base + 1 - $n_deliver_conflicted_merge;
         if ($n_deliver_automatic_merge gt 0)
         {
            if (!$ciautomatic)
            {
               $deliver_next_step = "notify";
            }
            else
            {         
               $deliver_next_step = "notify_and_complete";             
            }
         } 

         # count number of error messages returned by the deliver command
         $_ = $result;
         @deliver_error_list = /$deliver_other_error/gi;      
         my $n_deliver_errors = $#deliver_error_list + 1;      
         if ($n_deliver_errors gt 0)
         {
            $deliver_next_step = "notify";             
         } 
            
         # print merge/errors summary
         $message = "... Delivery summary:\n" . 
                "\t\t\t Trivial Merges   : $n_deliver_trivial_merge\n" .
                "\t\t\t Automatic Merges : $n_deliver_automatic_merge\n" .
                "\t\t\t Conflicted Merges: $n_deliver_conflicted_merge\n" .
                "\t\t\t Error messages   : $n_deliver_errors\n";
         print "$message\n";
            
         # get name of the files to merge (automatic, trivial and conflicted)
         # and 
         # get list of error messages
         open (DELIVERLOG, "<$deliver_logfile") or die "Can't read deliver log file: $deliver_logfile.\n";      
         $base_version = "";
         $from_version = "";
         $to_version   = "";
         @deliver_trivial_merge         = ();
         @deliver_automatic_merge_base  = ();
         @deliver_automatic_merge_from  = ();
         @deliver_automatic_merge_to    = ();
         @deliver_conflicted_merge_base = ();
         @deliver_conflicted_merge_from = ();
         @deliver_conflicted_merge_to   = ();
         @deliver_error_list            = ();   
         my $junk;
         my $i_deliver_automatic_merge=0;
         my $i_deliver_trivial_merge=0;
         my $i_deliver_conflicted_merge=0;
         my $i_deliver_error=0;

         while (<DELIVERLOG>)
         {      
            my $newline    = $_;   
            if (($n_deliver_trivial_merge + $n_deliver_automatic_merge + $n_deliver_conflicted_merge + $n_deliver_errors) gt 0)
            { 
               # trivial merge
               if ($newline =~ /$deliver_trivial_merge/gi)
               { 
                  $i_deliver_trivial_merge++;
                  $n_deliver_trivial_merge--;               
                  # Format example:
                  # Trivial merge: "M:\merge_live-203\rim_app_domestic_client\ClusterManager\new\newfile.txt" is same as base "M:\merge_live-203\rim_app_domestic_client\ClusterManager\new\newfile.txt@@\main\0".
                  ($junk, $deliver_trivial_merge[$i_deliver_trivial_merge], $junk) = split (/$deliver_trivial_merge\s\"(\S+)\"\s(.*)\n/, $newline);
               
               }
               elsif ($newline =~ /$deliver_automatic_merge/gi)   # automatic merge
               {
                  # the $deliver_automatic_merge string is going to be printed in the logfile as many time (PER VERSION) as the number of differences to merge
                  # it is necessary to verify if the file name is different
                  if (($i_deliver_automatic_merge eq -1) or (($base_version) and ($base_version ne $deliver_automatic_merge_base[$i_deliver_automatic_merge])))
                  { 
                     $i_deliver_automatic_merge++;
                     $n_deliver_automatic_merge--;                  
                     $deliver_automatic_merge_base[$i_deliver_automatic_merge] = $base_version;
                     $deliver_automatic_merge_from[$i_deliver_automatic_merge] = $from_version; 
                     $deliver_automatic_merge_to[$i_deliver_automatic_merge]   = $to_version;
                  }
               
               }
               elsif ($newline =~ /$deliver_conflicted_merge/gi)   # conflicted merge
               {
                  $i_deliver_conflicted_merge++;
                  $n_deliver_conflicted_merge--;               
                  $deliver_conflicted_merge_base[$i_deliver_conflicted_merge] = $base_version;
                  $deliver_conflicted_merge_from[$i_deliver_conflicted_merge] = $from_version;
                  $deliver_conflicted_merge_to[$i_deliver_conflicted_merge] = $to_version;
                  $base_version = "";
                  $from_version = "";
                  $to_version = "";
               }
               elsif (($newline =~ /$file1(\S+)/o) or ($newline =~ /$directory1(\S+)/o))   # "base" contributor (automatic or conflicted merge)
               {
                  $base_version = $1;
                  chomp($base_version);
                  $from_version = "";
                  $to_version   = "";
                                                                      
               }
               elsif (($newline =~ /$file2(\S+)/o) or ($newline =~ /$directory2(\S+)/o))   # "from" contributor (automatic or conflicted merge)
               {
                  $from_version = $1;               
                  chomp($from_version);
                                                                     
               }
               elsif (($newline =~ /$file3(\S+)/o) or ($newline =~ /$directory3(\S+)/o))  # "to" contributor (automatic or conflicted merge) 
               {
                  $to_version = $1;
                  chomp($to_version);
               
               } elsif ($newline =~ /$deliver_other_error/o)   # error
               {   
                  $n_deliver_errors--;
                  $i_deliver_error++;
                  $newline =~ s/\n//g;
                  $deliver_error_list[$i_deliver_error] = $newline;
               } elsif ($newline =~ /$deliver_need_merge/o) {
                  $base_version = "";
                  $from_version = "";
                  $to_version = "";               
               }   
            }
            last if (($n_deliver_trivial_merge + $n_deliver_automatic_merge + $n_deliver_conflicted_merge + $n_deliver_errors) eq 0);   
         } # End of while
         close (DELIVERLOG);
   

         # Update log file with information of all merges:
         # 1. trivial merge
         $message = "";
         my $element = "";
         if (@deliver_trivial_merge)
         { 
            foreach $element (@deliver_trivial_merge)
            {
               $message = "$message\n\t\t\t File: $element"  
            } 
            print "\n\t List of trivial merges: $message\n";
            $element = "";
         }
     
         
         # 2. automatic merge
         $message = "";
         if (@deliver_automatic_merge_base)
         { 
            my $i_automatic = 0;           
            $cmd = "describe -fmt \"%u\" @deliver_automatic_merge_from ";
            my (@deliver_automatic_merge_owner) = ClearTool(cmd => \$cmd, output => "output");
            foreach $element (@deliver_automatic_merge_base)
            { 
               $message = $message . 
                      "\n\t\t Automatic merge " . ($i_automatic+1) . ":" .
                      "\n\t\t\t Base: $element".
                      "\n\t\t\t From: $deliver_automatic_merge_from[$i_automatic] (Owner: $deliver_automatic_merge_owner[$i_automatic])".
                      "\n\t\t\t To:   $deliver_automatic_merge_to[$i_automatic]";
               $i_automatic++;                  
            }
            $element = "";
            print "\n\t List of automatic merges: $message\n";
         }


         # 3. conflicted merge
         $message = "";
         if (@deliver_conflicted_merge_base)
         { 
            my $i_conflict = 0;           
            $cmd = "describe -fmt \"%u\" @deliver_conflicted_merge_from";      
            $result = ClearTool(cmd => \$cmd, output => "output");
            @deliver_conflicted_merge_owner = split(/\n/, $result); 
            foreach $element (@deliver_conflicted_merge_base)
            { 
               $message = $message . 
                      "\n\t\t Conflict " . ($i_conflict+1) . ":" .
                      "\n\t\t\t Base: $element".
                      "\n\t\t\t From: $deliver_conflicted_merge_from[$i_conflict] (Owner: $deliver_conflicted_merge_owner[$i_conflict])".
                      "\n\t\t\t To:   $deliver_conflicted_merge_to[$i_conflict]";
               $i_conflict++;                  
            }
            $element = "";
            print "\n\t List of conflicted merges: $message\n";
         }
         
         
         # 4. errors
         my $msg_deliver_error='';
         my $line = "";
         if (@deliver_error_list)
         { 
            foreach my $line (@deliver_error_list)
            { 
               $msg_deliver_error = $msg_deliver_error." \n\t\t $line";   
            } 
            writelog("\n\t Deliver error messages:$msg_deliver_error: $message\n","error");
          $line = "";
         }           
      } # End 6. deliver started
      # End Analyzing command results: 

      writelog("Next step: $deliver_next_step");
      #Inform();      
      # perform "start deliver" next step 
      if ($deliver_next_step eq "abort")
      { 
        print "\n... Aborting delivery.";      
      }
      elsif ($deliver_next_step eq "cancel")
      { 
         print "\n... Canceling deliver to $bridge_stream";                        
         $cmd = "deliver -cancel -stream $deliver{MHI_INTEGRATION_STREAM}\@\\$deliver{ProductVOB} -force ";
         $result = ClearTool(cmd => \$cmd); 
         if ($result !~ /$deliver_canceled/gi)
         { 
            print "\n\t $result";                          
         }
         else
         { 
            print "\n\t Deliver canceled.";                                   
         }          
      }
      elsif ($deliver_next_step =~ /notify/gi)
      { 
         # complete deliver - only if 
         #   . -citrivial specified and there are no automatic or conflicted merge required
         #   . -ciautomatic specified and there are no conflicted merge required
         #   . there are no error
          if (
             ($deliver_next_step eq "notify_and_complete")
             and
             ($n_deliver_conflicted_merge == 0)
            )
          {
#             (!@deliver_conflicted_merge_to)) and 
#             (($citrivial) or (!@deliver_trivial_merge)) and
#             (($ciautomatic) or (!@deliver_automatic_merge_to))) { 
            print "\n... Completing deliver to $bridge_stream";        
            $cmd = "deliver -complete -stream $deliver{MHI_INTEGRATION_STREAM}\@\\$deliver{ProductVOB} -abort -force";
            $result = ClearTool(cmd => \$cmd);
            $Deliver_From_MHI_Dev_To_MHI_Bridge = 'Y';
            if ($result !~ /$deliver_completed/gi)
            { 
              print "\n\t $result";                          
            }
            else
            { 
              print "\n\t Deliver completed.";
            }                                  
         }
         else
         { 
            print "\n... There are files that require merge still checked out.";
            print "\n... Canceling deliver to $bridge_stream";                        
            $cmd = "deliver -cancel -stream $deliver{MHI_INTEGRATION_STREAM}\@\\$deliver{ProductVOB} -force";
            $result = ClearTool(cmd => \$cmd); 
            if ($result !~ /$deliver_canceled/gi)
            { 
               print "\n\t $result";                          
            }
            else
            { 
               print "\n\t Deliver canceled.";                                   
            }             
         }      
      }        

      #  Remove view 
      if ( !RemoveView(view_tag => "$bridge_stream_view_tag") )
      {
         writelog("Can't remove view $bridge_stream_view_tag","error");
         
      }
      else
      {
        writelog("View removed: $bridge_stream_view_tag");
        # Inform();
      }   

#ASH      
    if ((($deliver{CREATE_MHI_BRIDGE_STREAM} eq "Y") or ($deliver{CREATE_MHI_BRIDGE_STREAM} eq "y"))  and (($deliver_next_step eq "abort") or ($deliver_next_step eq "cancel")))
    {
         $cmd = "rmstream -nc -force $bridge_stream\@\\$deliver{ProductVOB}";
         $result = ClearTool(cmd => \$cmd); 
         
         if ($result =~ /Error/gi)
         {
            writelog("\n\t$cmd\n\t$result","error");                          
         }
         else
         {
           writelog("Stream removed: $bridge_stream");
         }   
      } # End of $deliver_next_step
      
    } # End deliver to bridge?
  
  
  if ($Deliver_From_MHI_Dev_To_MHI_Bridge eq 'Y')
  {
    my $MHU_Development_view;
    # Added by Saju on 24th August 2007 
    $cmd = "clearprompt proceed -prompt \"Completed delivery to Bridge stream.\" -type ok -mask proceed -prefer_gui";
    system($cmd);
    $cmd = "clearprompt yes_no -prompt \"Do you want to post the delivery to MHU Development stream?\" -type ok -mask yes,no -prefer_gui";
    $result = system($cmd);
    if ($result == 0)
    {
      $Deliver_From_MHI_Bridge_To_MHU_Dev_attempt = 'Y';
      # cleartool deliver -stream bridge_2007_6_14_2H55M@\scenario2.5_pvob -to AutoPost_MHU_DEV -target stream:AutoPost_MHU_DEV@\scenario2.5_pvob -act deliver.AutoPost_MHI_Integration.20070824.172406@\scenario2.5_pvob -abort -force

      $MHU_Development_view = $deliver{MHU_DEVELOPMENT_STREAM}.$timeline;
      my $MHU_Development_stream = "$deliver{MHU_DEVELOPMENT_STREAM}\@\\$deliver{ProductVOB}";
    
    
# Commented by Ashwin on 28th Aug 2007      
#      if (!CreateView(view_tag      => "$MHU_Development_view", 
#                    stream        => "$MHU_Development_stream",
#                    shareable_dos => "yes")
#         )
# Commented by Ashwin on 28th Aug 2007

      if (!CreateView(view_tag      => "$MHU_Development_view", 
                    stream        => "$MHU_Development_stream",
                    storage_dir => "$deliver{STORAGE_LOCATION}")          
         )
      
      {
        writelog("\nError creating $bridge_stream view.\n","error");
      }
    
      my $delivery_activity = &Get_Delivery_activity($bridge_stream);
      $bridge_stream = "$bridge_stream\@\\$deliver{ProductVOB}";
      $cmd = 'cleartool deliver -stream '. $bridge_stream .' -to '. $MHU_Development_view.' -target stream:'. $MHU_Development_stream .' -act '. $delivery_activity .' -abort -force 2>&1';
      writelog("COMMAND:$cmd");      
      $result = `$cmd`;
      
      if ($result =~ /error/i)
      {
        writelog("COMMAND: $cmd","error");
        writelog("$result","error");
      }
      else
      {
        writelog("$result");
      }
      
      if ($result =~ /Deliver\shas\sposted\sstream/is)
      {
        $Deliver_From_MHI_Bridge_To_MHU_Dev = "Y";
        $cmd = system("clearprompt proceed -prompt \"Delivery is posted to MHU Development stream.\" -type ok -mask proceed -prefer_gui");
    
      }
      else
      {
        $Deliver_From_MHI_Bridge_To_MHU_Dev = "N";
        $cmd = system("clearprompt proceed -prompt \"Delivery could not be posted to MHU Development stream.\" -type error -mask proceed -prefer_gui");
      }
      
    }

    if ( !RemoveView(view_tag => "$MHU_Development_view") )
    {
      writelog("Can't remove view $MHU_Development_view","error");
    }
    else
    {
      writelog("View removed: $MHU_Development_view");
    }  
  } # End Addition by Saju
  
 } # EndIf stream is MHI stream 

# Added by Saju & Ashwin on 29/08/07
if (($Deliver_From_MHI_Dev_To_MHI_Bridge eq 'Y') and ($Deliver_From_MHI_Bridge_To_MHU_Dev eq 'Y'))
{ # 1
  # When there is a successful delivery from MHI Dev stream to Bridge stream
  # and a successful posting from Bridge stream to MHU dev stream
  my ($message,$subject) = &Email_Template_success();
  
  # Build the Config settings used
  my $config_settings = '';
  map {$config_settings .= "\t$_ = $deliver{$_}\n"}(keys %deliver);
  my $process = <<PROCESS;
 The process included the following deliveries:

	1) Baseline delivery from Stream($deliver{MHI_INTEGRATION_STREAM}) to Stream($deliver{MHI_BRIDGE_STREAM})
	2) Posting of delivery from Stream($deliver{MHI_BRIDGE_STREAM}) to Stream($deliver{MHU_DEVELOPMENT_STREAM})
PROCESS
  
  $message =~ s/\{\{CONFIGURATION_SETTINGS\}\}/$config_settings/;
  $message =~ s/\{\{PROCESS\}\}/$process/;
  
  system("clearprompt proceed -prompt \" * * * * * Delivery Process Completed Successfuly * * * * * \" -type ok -mask proceed -prefer_gui");
  print "\n * * * * * Delivery Process Completed Successfuly * * * * * ";
  &SendMail($subject,$message,"","success");
}
elsif(($Deliver_From_MHI_Dev_To_MHI_Bridge eq 'Y') and ($Deliver_From_MHI_Bridge_To_MHU_Dev_attempt ne 'Y'))
{ # 2
  # When there is a successful delivery from MHI Dev stream to Bridge stream
  # and posting from Bridge stream to MHU dev stream was not done
  
  my ($message,$subject) = &Email_Template_success();
  
  # Build the Config settings used
  my $config_settings = '';
  map {$config_settings .= "\t$_ = $deliver{$_}\n"}(keys %deliver);
  my $process = <<PROCESS;
 The process included the following delivery:

	1) Baseline delivery from Stream($deliver{MHI_INTEGRATION_STREAM}) to Stream($deliver{MHI_BRIDGE_STREAM})
PROCESS
  
  $message =~ s/\{\{CONFIGURATION_SETTINGS\}\}/$config_settings/;
  $message =~ s/\{\{PROCESS\}\}/$process/;
  
  system("clearprompt proceed -prompt \" * * * * * Delivery Process Completed Successfuly * * * * * \" -type ok -mask proceed -prefer_gui");
  print "\n * * * * * Delivery Process Completed Successfuly * * * * * ";
  &SendMail($subject,$message,"","success");
}
else
{
  my ($message,$subject) = &Email_Template_Failure();
  my $process = '';
  # Build the Config settings used
  my $config_settings = '';
  map {$config_settings .= "\t$_ = $deliver{$_}\n"}(keys %deliver);

  if (($Deliver_From_MHI_Dev_To_MHI_Bridge eq 'Y') and ($Deliver_From_MHI_Bridge_To_MHU_Dev eq "N"))
  {
    $process = <<PROCESS;
 The process included the following deliveries attempts:

	1) Baseline delivery from Stream($deliver{MHI_INTEGRATION_STREAM}) to Stream($deliver{MHI_BRIDGE_STREAM}) done successfully.
	2) Failed to post delivery from Stream($deliver{MHI_BRIDGE_STREAM}) to Stream($deliver{MHU_DEVELOPMENT_STREAM})
PROCESS
  }
  else
  {
    $process = <<PROCESS;
 The process included the following attempts:

	1) Baseline delivery from Stream($deliver{MHI_INTEGRATION_STREAM}) to Stream($deliver{MHI_BRIDGE_STREAM}) failed.
PROCESS
  }
  
  my $error_log_msg = "The log files have been attached.";
  $message =~ s/\{\{CONFIGURATION_SETTINGS\}\}/$config_settings/;
  $message =~ s/\{\{PROCESS\}\}/$process/;
  $message =~ s/\{\{ERROR_LOG\}\}/$error_log_msg/;
  
  if ($Deliver_From_MHI_Dev_To_MHI_Bridge_attempt =~ /y/i)
  {
    system("clearprompt proceed -prompt \"Delivery Process Failed !... Check The Logs\n\n Log File: $log_File \n\n And\n \n Error Log: $log_Error\" -type error -mask proceed -prefer_gui");
    print "\n * * * * * Delivery Process Failed - Check The Log File $log_File And Log Error $log_Error * * * * * ";
    my @attach = ();
    push (@attach,$log_File);
    push (@attach,$log_Error);
    &SendMail($subject,$message,\@attach,'fail');
  }
}
# End Add on 29/08/07

&Close_Initialise();

exit 0;

############################################################################################
#******************************************************************************************#
        #       * * * * * *  END OF MAIN SCRIPT  * * * * * *     #
#******************************************************************************************#
############################################################################################