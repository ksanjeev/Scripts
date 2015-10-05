#!/usr/bin/perl

#(Always use 'strict' unless you have a VERY good reason not to)
use strict;
use warnings;
use Cwd;
use Config::IniFiles;
# Commented by Sharad Agarwal on 09th March 2007
#use Misys::SendMail;

# Config file used for this script
my $cfgfile = "cc_build.cfg"; 
# Added $BuildDirectory global directory: Robert Daniels 31 May 2007
#============================================================================#
# Important Note: Build Number($build_no)/Product($product)/Project($project - Version)
# needs to be specified before you run this script in the Config file.
#============================================================================#
my ($build_no, $product, $project, $product_vob, $int_stream, $Storage_Location, $working_directory, $BuildDirectory);
my $cfgref = new Config::IniFiles( -file => "$cfgfile" );
#============================================================================#
my ($cfgrec, @cfgsecs, @mount_VOBs, %cfg);
my $build_no1 = ();
my $product_build_view = ();
my $product_base_line = ();
my ($Product_Baseline, $CC_BUILD);
my $VOB_list = ();
my $VOBs = ();
my $ndx = 0;
my $command_line;
my $current_dir = getcwd;
my $root_path = 'M:\\';
my $yymmdd;
my $result;
my ($log_details , $log_Path);
my $process_fail = 0;
my ($log_File, $log_Error);
my $script_path = getcwd;
my $line;

# Added by Saju on 09/05/07
my $Recommend_Baseline = '';
# End add by Saju on 09/05/07

# Commented by Sharad Agarwal on 09th March 2007
#my $Email_Found;
my $Make_Baseline = "Y";
# Added by Sharad Agarwal 0n 14th Nov. 2006
# Commented by Sharad Agarwal on 09th March 2007
#my @email_list = (); # For storing the email list from the config file.
my @file_output; # It stores the log file data for the body of mail.
my ($sm, $subject); #sm is the object of Sendmail and $subject is for manage subject text.
my ($user_domain, $user_Name, $serverName);
#============================================================================#
sub log_error
# This function logs error into the log file. 
#============================================================================#
{
    #Added by Sharad Agarwal on 16th Oct. 2006
    print STDERR $log_details. "\n";
    print STDOUT $log_details. "\n";
}

#============================================================================#
sub result{
#   Runs the command line & logs if any error into the log file.
#============================================================================#
    $result = system $command_line;
    if ($result > 0) {
        $log_details = "Error : Product[$product]: $command_line\n";
        log_error($log_details);
        #Added by Sharad Agarwal on 16th Oct 2006
        $process_fail = 1;
        return;
        #die "* * *   C h e c k   T h e   E r r o r  F r o m    L o g   F i l e   * * * \n"
    }
}

=put
# Commented by Sharad Agarwal on 09th March 2007
#===========================================================================
sub send_email
# Added by Sharad Agarwal 0n 14th Nov. 2006
# This function is used for composing mail and send it to the given 
# addresses in config file
#===========================================================================
{
  if (scalar(@email_list)!= 0)
  {
    $sm->setDebug($sm->ON);
    $sm->setDebug($sm->OFF);
    $sm->From($email_list[0]);
    $sm->Subject($subject);
    my $recipient = join(',', @email_list);
    $sm->To(@email_list);
    my $body = join("\n", @file_output); 
    $sm->setMailBody($body);
    if ($sm->sendMail() != 0) {
      print $sm->{'error'}."\n";
      exit -1;
    }
  }
  else
  {
    print "Unable to send an Email. No mailing list provided.";
  }
}

#=================================================================================
sub get_Email_List
# Added by Sharad Agarwal 0n 14th Nov. 2006
# This function gives all the mail addresses from the config file.
#=================================================================================
{
    #print "Email List : $cfg{'EmailAddress'}\n";
    @email_list = split /,/, $cfg{'EmailAddress'};
}
=cut

#============================================================================#
sub get_date_yymmdd {
#  This function gives the currrent date in YYMMDD Format.
#============================================================================#  
  my ($sec, $min, $hr, $day, $month, $year) = (localtime (time))[0 .. 5];
  return (sprintf("%02d%02d%02d", ($year - 100), ($month + 1), $day));
}

#============================================================================#  
sub get_cfg_recs {
#   Gets all the sections from the config File [RAD], [Rx].. etc...
#============================================================================#      
  my $cfgref = new Config::IniFiles( -file => "$cfgfile" );
  @cfgsecs = $cfgref->Sections();
  print "Sections in the Config file : @cfgsecs\n";
  
  return;
}

#============================================================================#  
sub get_config_data {
#   Gets all the details from those sections for the defined key's.
#============================================================================#      
  my $cfgsec = shift;
  $VOBs = ();
  # Reset our cfg hash
  %cfg = ();
  
  $cfg{'Prod'} = $cfgref->val( $cfgsec, 'Product' );
  die "Missing product name in $cfgsec section of $cfgfile.\n" if (!defined $cfg{'Prod'});
  if ((defined $cfg{Prod}) && ($cfg{Prod} ne "")) {
    $product = $cfg{Prod};
    print "Product name : $product\n";
  }

  $cfg{'Prod_VOB'} = $cfgref->val( $cfgsec, 'ProductVOB' );
  die "Missing product VOB in $cfgsec section of $cfgfile.\n" if (!defined $cfg{'Prod_VOB'});
  if ((defined $cfg{Prod_VOB}) && ($cfg{Prod_VOB} ne "")) {
    $product_vob = $cfg{Prod_VOB};
    print "Product VOB : $product_vob\n";
  }   
    
  $cfg{'Project_ver'} = $cfgref->val( $cfgsec, 'Project' );
  die "Missing product version in $cfgsec section of $cfgfile.\n" if (!defined $cfg{'Project_ver'});    
  if ((defined $cfg{Project_ver}) && ($cfg{Project_ver} ne "")) {
    $project = $cfg{Project_ver};
    print "Project Version : $project\n";
  }

  $cfg{'Build_Num'} = $cfgref->val( $cfgsec, 'Build_No' );
  die "Missing build number for the product in $cfgsec section of $cfgfile.\n" if (!defined $cfg{'Build_Num'});
  if ((defined $cfg{Build_Num}) && ($cfg{Build_Num} ne "")) {
    $build_no = $cfg{Build_Num};
    print "Build Number : $build_no\n";
  }   

  $cfg{'Int_Stream'} = $cfgref->val( $cfgsec, 'Integration_Stream' );
  die "Missing Integration Stream for the product in $cfgsec section of $cfgfile.\n" if (!defined $cfg{'Int_Stream'});
  if ((defined $cfg{Int_Stream}) && ($cfg{Int_Stream} ne "")) {
    $int_stream = $cfg{Int_Stream};
    print "Integration Stream : $int_stream\n";
  }   

  #Added by Robert Daniels on 31 May 2007	
  $cfg{'BuildDirectory'} = $cfgref->val($cfgsec,'BuildDirectory' );
  die "Missing BUild Directory for the product in $cfgsec section of $cfgfile.\n" if (!defined $cfg{'BuildDirectory'});
  if ((defined $cfg{BuildDirectory}) && ($cfg{BuildDirectory} ne "")) {
    $BuildDirectory = $cfg{BuildDirectory};
    print "BuildDirectory : $BuildDirectory\n";
  }

    # Added by Sharad Agarwal 0n 05th Dec. 2006
  # Reading Make_Baseline from the config file.
  $cfg{'MakeBaseline'} = $cfgref->val( $cfgsec, 'Make_Baseline' );
  if (!defined $cfg{'MakeBaseline'} && $cfg{'MakeBaseline'} eq "")
  {
    $Make_Baseline = "Y";   
  }
  else
  {
    $Make_Baseline = "N";   
  }
  
  $cfg{'Prod_Baseline'} = $cfgref->val( $cfgsec, 'Product_Baseline' );
  die "Missing Baseline VOB in $cfgsec section of $cfgfile.\n" if ((!defined $cfg{'Prod_Baseline'}) && ($Make_Baseline eq "Y"));
  if ((defined $cfg{Prod_Baseline}) && ($cfg{Prod_Baseline} ne ""))
  {
    $product_base_line = $cfg{Prod_Baseline};
    print "Base line from : $product_base_line\n";
  }
  else
  {
    $product_base_line = "";
    print "Product base line not defined \n";    
  }
    
  $cfg{'VOB'} = $cfgref->val( $cfgsec, 'Mount_VOBs' );
  die "Missing vob list in $cfgsec section of $cfgfile.\n" if (!defined $cfg{'VOB'});
  if ((defined $cfg{VOB}) && ($cfg{VOB} ne "")) {
    $VOB_list = $cfg{VOB};
    print "VOB list : $VOB_list\n";
    
    #   If there are VOB's to be mounted then put thme in our hash reference
    if ((defined $VOB_list) && ($VOB_list ne "")) {
        @mount_VOBs = split /,/, $VOB_list;
        #   Build our hash for vob's to be mounted
        for ($ndx = 0; $ndx <= $#mount_VOBs; $ndx++) {
            $VOBs->{$mount_VOBs[$ndx]} = "";
            print STDOUT "VOB's to be mounted : $mount_VOBs[$ndx]\n";
        }
    }    
  }
  # To find list of view storage locations: cleartool lsstgloc   
  $cfg{'Storage_Loc'} = $cfgref->val( $cfgsec, 'Storage_Location' );
  die "Missing storage location in $cfgsec section of $cfgfile.\n" if (!defined $cfg{'Storage_Loc'});
  if ((defined $cfg{Storage_Loc}) && ($cfg{Storage_Loc} ne "")) {
    $Storage_Location = $cfg{Storage_Loc};
    print "Storage Location : $Storage_Location\n";
  }

  $cfg{'Work_Dir'} = $cfgref->val( $cfgsec, 'Working_Dir' );
  die "Missing working directory in $cfgsec section of $cfgfile.\n" if (!defined $cfg{'Work_Dir'});
  if ((defined $cfg{Work_Dir}) && ($cfg{Work_Dir} ne "")) {
    $working_directory = $cfg{Work_Dir};
    print "Working directory : $working_directory\n"; 
  }
  
  # Added by Saju on 09/05/07
  $cfg{'Recommend_Baseline'} = $cfgref->val( $cfgsec, 'Recommend_Baseline' );
  $Recommend_Baseline =   $cfg{'Recommend_Baseline'};
  # End add
  
  
  # Commented by Sharad Agarwal on 09th March 2007
  # Added by Sharad Agarwal 0n 14th Nov. 2006
  #Reading Email list from the config file.
  #$cfg{'EmailAddress'} = $cfgref->val( $cfgsec, 'Email_List' );
  #if (!defined $cfg{'EmailAddress'})
  #{
  #  $Email_Found = 1;
  #}
  #else
  #{
  #  $Email_Found = 0;
  #}

  
  
  return;
}
# Subroutine update_build_no commented out by Robert Daniels on 23_04_2007
=put
#============================================================================#      
sub update_build_no {
#   This is to increment the build number by one in configuration file.
#============================================================================#
#Open
        chdir($script_path);
        $current_dir = getcwd;
        
        open CFG, "<$cfgfile" or die "Could not open configuration file";
        my @cfg_data = <CFG>;
        close (CFG);
        
        #open TEMP, ">temp.txt" or die "Could not open temp file";
        
        my $line_value;
        my @build_num = split /\./, $build_no;
        $build_num[-1]++;
        my $build_num = join "\.", @build_num;
        my $search = "Build_No=". $build_no;
        my $replace = "Build_No=".$build_num;
        
        for (my $i=0;$i<@cfg_data;$i++)
        {
            #chomp($line);
            if (substr($cfg_data[$i], 0) =~ $search){
                $cfg_data[$i] =~ s/$search/$replace/;
            }
        }
        
        open CFG, ">$cfgfile" or die "Could not open configuration file";

        print CFG @cfg_data;

        close(CFG);
}
=cut
#============================================================================#      
sub reset_variables {
#   This is to reset all the global variables
#============================================================================#
    @mount_VOBs = ();
    %cfg = ();
    $build_no = ();
    $product = (); 
    $project = (); 
    $product_vob =  ();
    $build_no1 = ();
    $product_build_view = ();
    $product_base_line = ();
    $VOB_list = ();
    $VOBs = ();
    $ndx = 0;
    $current_dir = getcwd;
    $BuildDirectory=();
    
    return;
}






#********************************************************************************************#
#           M A I N   L O G I C   S T A R T S   H E R E   
#********************************************************************************************#
print("* * * S T A R T   O F   C L E A R C A S E   P R E   B U I L D  P R O C E S S * * *\n");
die "Unable to find the Config file : $cfgfile.\n" if (! -f $cfgfile);

#   Get the existing sections in our config file
get_cfg_recs();
#my %ini;
#  tie %ini, 'Config::IniFiles', ( -file => "$cfgfile" );
#  print "We have $ini{Section}{Parameter}." if $ini{Section}{Parameter};
# Loop through all the sections[scenario] in the config file...
foreach my $cfgrec (sort(@cfgsecs)) {
    $yymmdd = get_date_yymmdd();
    
    #   Reset the variables
    reset_variables();
    
    # Get the data from the config file
    # Added by Sharad Agarwal on 13th Feb 2007
    # This will select the section with CLEARCASE
    if ($cfgrec eq "CLEARCASE")
    {
      print "Get details for : $cfgrec\n";
      get_config_data($cfgrec);
    }
    else
    {
      next;
    }
    
    print("\n* * * Start Of ClearCase Pre Build Process For $product * * *\n");
    print("\nPlease wait processing is on....\n\n");

    # Commented by Sharad Agarwal on 09th March 2007
    # Added by Sharad Agarwal 0n 14th Nov. 2006
    #calling the function to store the email list into an array.
    #if ($Email_Found == 0)
    #{
    #    get_Email_List($cfg{'EmailAddress'});
    #}
    
    #   This will be our Directory to be created.
    #rzd 
    $product_build_view = $product.'_BLD_VIEW';
    #$product_build_view = $BuildDirectory;
    #$log_Path = $working_directory.$product_build_view;
    $log_Path = $BuildDirectory;
    $log_File = $log_Path . "\\". $product_build_view. ".log";
    $log_Error = $log_Path . "\\". $product_build_view. "_error.log";
    
    #   Added by Sharad Agarwal on 16th Oct. 2006
    #   Below Logic added/modified by Ashwin on 18th Oct 2006
    #   We will delete if the directory already exists & then recreate it again
    if (-d $log_Path)
    {
        system 'rmdir /S /Q '.$log_Path; #  Delete the existing directory
        mkdir $log_Path;                 #  Create the Directory Again  
    }
    else {
        mkdir $log_Path;                 #  Create the Directory if it does not exists
    }

    open(OLDOUT, ">&STDOUT");
    open(OLDERR, ">&STDERR");
    
    open STDOUT, ">$log_File" or die "\nUnable to open $log_Path\nError: $!\n";
    open STDERR, ">$log_Error" or die "\nUnable to open $log_Path\nError: $!\n";
    

    #============================================================================#
    #   This will be used to create the label
    #============================================================================#
    $build_no1 = '"'.$build_no.'"';
    
    #============================================================================#
    #   Go to M: Drive
    #============================================================================#
    chdir($root_path);
    $current_dir = getcwd;
    #print "Current Dir : $current_dir\n";
    
    #============================================================================#
    #   Create view in the storage location specified in the config file.
    #============================================================================#
    #   Before we proceed we need to delete the folder 'mkbl_int_view.vws' from the storage location if exixys.
    #$command_line = 'rmdir /S /Q '.$Storage_Location.'mkbl_int_view.vws';
    if (-d $Storage_Location.'mkbl_int_view.vws'){
        #system $command_line #  Delete the existing directory
        # Below 2 lines Commented by Ashwin on 22nd Nov 2006
        #$command_line = 'cleartool endview mkbl_int_view';
        #result();
        
        #if ($result == 0) {
        #    print STDOUT "Command successfully executed : $command_line\n";
        #    print STDOUT "Deleted $Storage_Location mkbl_int_view.vws\n";
        #}
        $command_line = 'cleartool rmview -force -tag mkbl_int_view';
        result();        
    }
    
    #   The below line has been added by Ashwin Deshmukh on 30th Oct 2006
    #   Now storage location will be the full path of the server where you want to create the view.
    $command_line = 'cleartool mkview -stream '.$int_stream.'@\\'.$product_vob.' -tag mkbl_int_view '.$Storage_Location.'mkbl_int_view.vws';
    #   The below line has been commented by Ashwin for the above case.
    #$command_line = 'cleartool mkview -tag mkbl_int_view -stream '.$int_stream.'@\\'.$product_vob.' -stgloc '.$Storage_Location;
    result();
    if ($result == 0) {
        print STDOUT "Command successfully executed : $command_line\n";
        print STDOUT "Info : Product[$product]: mkbl_int_view view created.\n";
    }
    
    #system $command_line;
    
    #============================================================================#
    #   Mount all the required VOB's
    #============================================================================#
    #   Get all those VOB's which needs to be mounted & mount them one by one...
    #rzd added two lines below 5/29/07
    $command_line = 'cleartool umount -all';
    system $command_line;	
    $ndx = 0;
    for ($ndx = 0; $ndx <= $#mount_VOBs; $ndx++) {
        $command_line = 'cleartool mount \\'.$mount_VOBs[$ndx];
        #result();
        system $command_line;
    }
    
    #============================================================================#
    #   Go to mkbl_int_view\RAD_VOB($product_vob) directory
    #   on M: drive
    #============================================================================#
    chdir ('mkbl_int_view');
    chdir ($product_vob);   
    $current_dir = getcwd;
    print "Current Dir : $current_dir\n";
    
    #============================================================================#
    #   Make a Baseline here...
    #============================================================================#
    $command_line = 'cleartool mkbl -c '.$build_no1.' -view mkbl_int_view '.$build_no;
    result();
    if ($result == 0) {
        print STDOUT "Command successfully executed : $command_line\n";
        print STDOUT "Info : Product[$product]: Baseline created for mkbl_int_view view.\n";
    }
    
    chdir($root_path);
    $current_dir = getcwd;
    #print "Current Dir : $current_dir\n";
    
    if($Make_Baseline eq "Y")
    {
        #============================================================================#
        #   Remove the View (To be rectified - Why is this step required?)
        #============================================================================#
        $command_line = 'cleartool endview mkbl_int_view';
        result();
        if ($result == 0) {
            print STDOUT "Command successfully executed : $command_line\n";
            print STDOUT "Info : Product[$product]: mkbl_int_view view ended.\n";
        }
        
        $command_line = 'cleartool rmview -force -tag mkbl_int_view';
        result();
        if ($result == 0) {
            print STDOUT "Command successfully executed : $command_line\n";
            print STDOUT "Info : Product[$product]: mkbl_int_view view removed.\n";
        }
        
        #============================================================================#
        #   Make a Stream
        #============================================================================#
        #   We asume that whenever a baseline is made by default it will be created with current date
        $Product_Baseline = $product_base_line.'_'.$yymmdd.'_'.$build_no;
        #   Stream to be created...($CC_BUILD)
        $CC_BUILD = 'CC_'.$product.'_'.$build_no.'_BUILD';
        
        chdir($root_path);
        $current_dir = getcwd;
        #print "Current Dir : $current_dir\n";
        
        $command_line = 'cleartool mkstream -in '.$int_stream.'@\\'.$product_vob.' -baseline '.$Product_Baseline.'@\\'.$product_vob.' -readonly '.$CC_BUILD.'@\\'.$product_vob;
        result();
        if ($result == 0) {
            print STDOUT "Command successfully executed : $command_line\n";
            print STDOUT "Info : Product[$product]: $Product_Baseline baseline used.\n";
            print STDOUT "Info : Product[$product]: $CC_BUILD stream created.\n";
        }    
        #============================================================================#
        #   Make a View out of the newly created Stream ($CC_BUILD)
        #============================================================================#
        #   The below line has been added by Ashwin Deshmukh on 30th Oct 2006
        #   Now storage location will be the full path of the server where you want to create the view.    
        $command_line = 'cleartool mkview -stream '.$CC_BUILD.'@\\'.$product_vob.' -tag '.$product_build_view.' '.$Storage_Location.$product_build_view.'.vws';
        #   The below line has been commented by Ashwin for the above case.    
        #$command_line = 'cleartool mkview -tag '.$product_build_view.' -stream '.$CC_BUILD.'@\\'.$product_vob.' -stgloc '.$Storage_Location;
        result();
        if ($result == 0) {
            print STDOUT "Command successfully executed : $command_line\n";
            print STDOUT "Info : Product[$product]: $product_build_view view created.\n";
        }        
    } 
    
    #============================================================================#
    #   Copy the RAD_BUILD_VIEW($product_build_view ) Directory
    #   from M:\> drive to C:\> drive ($working_directory).
    #============================================================================#
    chdir($root_path);
    $current_dir = getcwd;

    print STDOUT "Current Dir : $current_dir\n";
    print STDOUT "Target path : $working_directory".$product_build_view."\n";
    
    if ($Make_Baseline eq "Y")
    {
        print STDOUT "Source path : M:\\".$product_build_view."\n";  
        #Changed by Robert Daniels on 31 May 2007
        #$command_line =  'xcopy /E /Y /I M:\\'.$product_build_view.' '.$working_directory.$product_build_view;
        $command_line =  'xcopy /E /Y /I M:\\'.$product_build_view.' '. $BuildDirectory;
    }
    else
    {
        # Target = $working_directory.$product_build_view
        # Source = M:\\.'mkbl_int_view'
        print STDOUT "Source path : M:\\mkbl_int_view\n";
        #Changed by Robert Daniels on 31 May 2007
        #$command_line =  'xcopy /E /Y /I M:\\mkbl_int_view '.$working_directory.$product_build_view;
        $command_line =  'xcopy /E /Y /I M:\\mkbl_int_view '. $BuildDirectory;
    }
    #system $command_line;
    
    result();
    if ($result == 0) {
        print STDOUT "Command successfully executed : $command_line\n";
        #Changed by Robert Daniels on 31 May 2007
        #print STDOUT "Info : Product[$product]: Files copied to ".$working_directory.$product_build_view."\n";
        print STDOUT "Info : Product[$product]: Files copied to ". $BuildDirectory ."\n";
    }            
   
    #============================================================================#
    #   Unmount All The VOB's which were mounted
    #============================================================================#
    #   Now its our turn to un-mount all those mounted VOBS.
    $ndx = 0;
    for ($ndx = 0; $ndx <= $#mount_VOBs; $ndx++) {
        #print "Un-mounting : $mount_VOBs[$ndx]\n";
        $command_line = 'cleartool umount \\'.$mount_VOBs[$ndx];
        result();
        #system $command_line;
    }

    # Added by Ash on 5th Dec 2006    
    if($Make_Baseline eq "N")
    {
        #============================================================================#
        #   Remove the View (To be rectified - Why is this step required?)
        #============================================================================#
        $command_line = 'cleartool endview mkbl_int_view';
        result();
        if ($result == 0) {
            print STDOUT "Command successfully executed : $command_line\n";
            print STDOUT "Info : Product[$product]: mkbl_int_view view ended.\n";
        }
        
        $command_line = 'cleartool rmview -force -tag mkbl_int_view';
        result();
        if ($result == 0) {
            print STDOUT "Command successfully executed : $command_line\n";
            print STDOUT "Info : Product[$product]: mkbl_int_view view removed.\n";
        }
    }    
    
    # Added by Ash on 5th Dec 2006    
    if($Make_Baseline eq "Y")
    {
        #============================================================================#
        #   Remove view($product_build_view) after done
        #============================================================================#
        $command_line = 'cleartool endview '.$product_build_view;
        result();
        if ($result == 0) {
            print STDOUT "Command successfully executed : $command_line\n";
            print STDOUT "Info : Product[$product]: ".$product_build_view." view ended\n";
        }            
        
        $command_line = 'cleartool rmview -force -tag '.$product_build_view;
        result();
        if ($result == 0) {
            print STDOUT "Command successfully executed : $command_line\n";
            print STDOUT "Info : Product[$product]: ".$product_build_view." view removed\n";
        }            
        
        #============================================================================#
        #   Remove stream ($CC_BUILD)
        #============================================================================#
        $command_line = 'cleartool rmstream -force '.$CC_BUILD.'@\\'.$product_vob;
        result();
        if ($result == 0) {
            print STDOUT "Command successfully executed : $command_line\n";
            print STDOUT "Info : Product[$product]: ".$CC_BUILD." stream removed\n";
        }
    }
    
    #============================================================================#
    #   End of the ClearCase Pre Build Process for a product
    #============================================================================#
    #wait;
    print("\n* * * End Of ClearCase Pre Build Process For $product * * *\n");
    #============================================================================#
    
    
    # Added by Saju on 09/05/07
    # For adding the feature of Recommending the baseline
    Clearcase->RecommendBaseline({CONFIG_FILE=>$cfgfile}) if ($Recommend_Baseline !~ ?^y$?i);
    # End Add by Saju on 09/05/07
    
    
    # Commented by Sharad Agarwal on 09th March 2007
=put
    #Added by Sharad Agarwal on 14th Nov. 2006
    #Creating a SendMail object passing the SMTP server as an argument. 
    $sm = new SendMail('sqex3.sunquestinfo.com');
    $user_domain = $ENV{'USERDNSDOMAIN'};
    $user_domain =~ tr/a-z/A-Z/;
    $user_Name = $ENV{'COMPUTERNAME'};
    $user_Name =~ tr/a-z/A-Z/;
    $serverName = "$user_Name\.$user_domain";
    
    #Added by Sharad Agarwal on 16th Oct 2006
    if ($process_fail == 1){
        # Added by Sharad Agarwal on 13th Oct 2006
        print STDERR "\n* * * Process Failed For Product $product * * *\n";
        print STDOUT "\n* * * Process Failed For Product $product * * *\n";
        
        # Added by Sharad Agarwal 0n 14th Nov. 2006
        # Subject Line for the mail.
        $subject = 'F A I L E D - Product : '.$cfg{'Prod'}.' ***CLEARCASE PRE BUILD PROCESS***';
        
        print STDOUT "\nPlease check the error log file($log_Error) for more detail.\n";
        #exit 1;
    }
    else{
        # Added by Sharad Agarwal on 13th Oct 2006
        print STDOUT "\n* * * Process Successfully Completed For Product $product * * *\n";
        
        # Added by Sharad Agarwal 0n 14th Nov. 2006
        # Subject Line for the mail.
        $subject = 'S U C C E S S F U L - Product : '.$cfg{'Prod'}.' ***CLEARCASE PRE BUILD PROCESS COMPLETED***';

        update_build_no();
    }
=cut
    # Added by Sharad Agarwal on 09th March 2007
    #Commented out by Robert Daniels on 23rd April 2007
=put
    if ($process_fail == 0)
    {
      update_build_no();
    }
=cut
    #Added by Sharad Agarwal on 16th Oct. 2006
    close(STDOUT)|| die "Can't close log file";
    close(STDERR) || die "Can't close log file";

    # restore stdout and stderr
    open(STDERR, ">&OLDERR")            or die "Can't restore stderr: $!";
    open(STDOUT, ">&OLDOUT")            or die "Can't restore stdout: $!";
    
    # avoid leaks by closing the independent copies
    close(OLDOUT)                       or die "Can't close OLDOUT: $!";
    close(OLDERR)                       or die "Can't close OLDERR: $!";

    #   By Ashwin
    
    # Added by Sharad Agarwal 0n 14th Nov. 2006
    # @file_output contains the each line of log file into an array.
    push(@file_output,"\n************Please Check The Server $serverName For Log Files************\n\n");
    
    open FILEH, "<$log_File" or die "\nUnable to open $log_Path\nError: $!\n";
    while ($line = <FILEH>){
        chomp($line);
    	print "$line\n";
        
        #Added by Sharad on 14th Nov. 2006
        push(@file_output,$line);
    }
    close (FILEH) || die "\nCan't close log file";
    
    # Commented by Sharad Agarwal on 09th March 2007
    #Added by Sharad Agarwal on 14th Nov. 2006
    #Call the function for sending mail
    #if ($Email_Found == 0)
    #{
    #    send_email();
    #}
    
    $process_fail = 0; # Reset the Process flag..
    
    #   We shall loop untill all the sections in our config file are complete
}
print  ("\n* * * E N D   O F   C L E A R C A S E   P R E   B U I L D  P R O C E S S * * *\n");

exit 0;


# Added by Saju on 09/06/07
# Reason: The script to recommend baseline
# Usage:
#   Clearcase->RecommendBaseline({CONFIG_FILE=><Path to pre build config file>});

   package Clearcase;
    our $ConfigFile = '';            # Absolute path to the "CC_Build.cfg"
    our $log_File = '';
    our $log_Error = '';

    # Email server configurations
    our $SMTPserver = '';
    our $SMTPport;
    our $Emailheader = "";
    our $Emailheadervalue = "";
    
    # The global variables 
    our (%Build,%NewRecommendedBl,%PreviousRecommendedBl) = ();
    our $Integration_Stream = '';
    
 sub RecommendBaseline
 {
    my $class = shift;
    my $self = shift;
    $ConfigFile = $self->{CONFIG_FILE};
    
    # Initialise
    &Init;
    print "\n**** Start ****\n\n";
    
    return if ($Build{Recommend_Baseline} !~ ?^y$?i);
    &GetRecommendedBaselines();    
    my @BaselineInfo = ();
    my @Recommend_Component = split (/,/,$Build{Recommend_Component});
    my %rec = ();
    print "\n\nThe new baselines availabe are:";
    foreach (@Recommend_Component)
    {
        # cleartool lsbl -s -com component:RX_6x_GUI@\RX_PVOB
        my $Command = 'cleartool lsbl -s -com component:'.$_.'@\\'.$Build{ProductVOB} if ($_ !~ /(?:\_pvob)/i);
        next if (!defined $Command);
        @BaselineInfo = `$Command`;
        if (&CheckBaseline(\@BaselineInfo,$_))
        {
            print "\nBaseline: $NewRecommendedBl{$_} has already been recommended for the VOB $_.\n";
        }
        else
        {
            print "Recomending Baseline: $NewRecommendedBl{$_} for the VOB $_.\n";
        }
    }
    &GoForRecommendBaseline(\@Recommend_Component);
    print "\n**** End ****\n";
    &CloseInit;
 }

sub CheckBaseline
{
    my $baseline = shift;
    my $vob = shift;
    my $size = @{$baseline};
    print "\n$vob => $baseline->[$size-1]";
    $NewRecommendedBl{$vob} = $baseline->[$size-1];
    chomp $NewRecommendedBl{$vob};
    my $flag = 0;
    $flag = 1 if ($NewRecommendedBl{$vob} eq $PreviousRecommendedBl{$vob});
    return $flag;
}

sub GetRecommendedBaselines
{
    my $Command = '';
    
    # cleartool describe -l stream:RAD_5.0.1_Int@\RAD_PVOB
    $Command = 'cleartool describe -l stream:'.$Integration_Stream;
    my @details = `$Command`;
    my $details = join('',@details);
    print "The current recommended baseline for the components:\n";
    ($details) = ($details =~ /(?:recommended\sbaselines\:(?:(.+?)(?=\:)))/is);
    while ($details =~ /(?:(?:\n\s+(.+?)(?:\@(?:[^\(]+\())([^\s]+)(?:\@[^\(]+)(?=\n))+?)/isg)
    {
        print "$2 => $1\n";
        $PreviousRecommendedBl{$2} = $1;
    }
}

sub Set_New_Recommended_Baseline
{
    my $baseline = shift;
    
    # cleartool chstream -c "Recommending Baseline through automated script" -ntarget -generate -recommended baseline:AutoPost_MHI_8_30_2007@\scenario2.5_pvob stream:AutoPost_MHI_Integration@\scenario2.5_pvob
    my $cmd = 'cleartool chstream -c "Recommending Baseline through automated script" -ntarget -generate -recommended baseline:'.$baseline.'@\\'.$Build{ProductVOB}.' stream:'.$Build{Integration_Stream}.'@\\'.$Build{ProductVOB};
    my @rec = `$cmd`;
    if ($rec[0] =~ /Changed\sstream/)
    {
       print "Recommended the baseline \"$baseline\" \n";
    }
    else
    {
       print "unable to recommend the baseline \"$baseline\" \n";
    }
}

sub GoForRecommendBaseline
{
    my $vlist = shift;
    my $EmailBody = &EmailTemplate;
    my ($previouslist,$newlist) = '';
    
    # Product
    my $product = $Build{Product}.$Build{Build_No};
    $EmailBody =~ s/\{\{PRODUCT\}\}/$product/;
    
    # Recommend Component
    my $Recommend_Component = 'Recommend_Component='.$Build{Recommend_Component};
    $EmailBody =~ s/\{\{RECOMMEND_COMPONENT\}\}/$Recommend_Component/;
    
    map {
        $previouslist .= "\t$_ => $PreviousRecommendedBl{$_}\n" if ($_ !~ /(?:\_pvob)/i);
        $newlist .= "\t$_ => $NewRecommendedBl{$_}\n";
        
        # Recommend the new baseline
        # &Set_New_Recommended_Baseline($NewRecommendedBl{$_}) if defined $NewRecommendedBl{$_};
    } (@{$vlist});
    
    $EmailBody =~ s/\{\{PREVIOUS_BASELINES\}\}/$previouslist/;
    $EmailBody =~ s/\{\{NEW_BASELINES\}\}/$newlist/;
    
    # Get the recipient list
    my @recipients = split(/,/,$Build{Email_List});
    
    # The sender will be the first recipient
    my $sender = $recipients[0];
    
    my ($firstname,$lastname) = ($sender =~ /(?:(?:(.+)\.(.+))(?=\@))/);
    $sender = $firstname.' '.$lastname."\n(".$sender.')';
    $EmailBody =~ s/\{\{SENDER\}\}/$sender/;
    
    my $subject = "Baseline Recommended For $product";
    &Send_The_Email($subject,$EmailBody,$SMTPserver);
}

sub EmailTemplate
{
    my $template = <<'TEMPLATE';
Hi,

Following Baselines have been recommended for {{PRODUCT}}

{{RECOMMEND_COMPONENT}}

New Recommended baseline(s):

{{NEW_BASELINES}}

Previous Recommended Baseline(s):
{{PREVIOUS_BASELINES}}

Please Rebase your Development\Bridge Streams accordingly.

Any question\query please let me know.


Thanks & Regards,
{{SENDER}}

TEMPLATE
    return $template;
}

#************** Start of Init() ***************
# Description:  Initialise the variables and functions
# Usage:        &Init();
#
sub Init
{
   $log_File = 'RecommendBaseline_';
   $log_Error = 'RecommendBaseline_';

   # Email server configurations
   $SMTPserver = 'mhimail.mhi.onemisys.com';
   $SMTPport   = 25;
   $Emailheader		= "X-Mailer";
   $Emailheadervalue	= "Recommending Baseline";


    my %cfg = ();
    # Read the config file into hash
    tie %cfg, 'Config::IniFiles', ( -file => "$ConfigFile" );

    # Get the section into a hash
    %Build = %{$cfg{CLEARCASE}};

    $log_File .= $Build{Product}.'.log';
    $log_Error .= $Build{Product}.'_error.log';
    
    $Integration_Stream = $Build{Integration_Stream}.'@\\'.$Build{ProductVOB};
    

    open(OLDOUT, ">&STDOUT");
    open(OLDERR, ">&STDERR");
    
    open STDOUT, ">$log_File" or die "\nUnable to open $log_File: $!\n";
    open STDERR, ">$log_Error" or die "\nUnable to open $log_Error: $!\n";

}

#************** End of init() ***************

sub CloseInit
{
    
    close(STDOUT)|| die "Can't close log file";
    close(STDERR) || die "Can't close log file";

    # restore stdout and stderr
    open(STDERR, ">&OLDERR")  or die "Can't restore stderr: $!";
    open(STDOUT, ">&OLDOUT")  or die "Can't restore stdout: $!";
    
    # avoid leaks by closing the independent copies
    close(OLDOUT)  or die "Can't close OLDOUT: $!";
    close(OLDERR)  or die "Can't close OLDERR: $!";

}

#************** Start of Send_The_Email() ***************
# Description:  Used to send email to the address specified in the configuration file.
#               The first email address in the configuration file is the sender and the
#               rest is the recipient list.
#
# Usage:        &SendMail([Subject],[Body]);
#
sub Send_The_Email
{
    # Get the subject
    my $subject = shift;
    
    # Get the body of the email
    my $mailbodydata = shift;
    
    # Get the recipient list
    my @recipients = split(/,/,$Build{Email_List});
    
    # The sender will be the first recipient
    my $sender = $recipients[0];
    
    # Create an email object
    my $Email = new SendMail($SMTPserver, $SMTPport);

    $Email->From($sender);
    $Email->Subject($subject);
    $Email->To(@recipients);
    $Email->setMailHeader($Emailheader, $Emailheadervalue);
    $Email->setMailBody($mailbodydata);
  
    # Send the email 
    if ($Email->sendMail() != 0) {
        print $Email->{'error'}."\n";
    }

    # Clear the recipient list
    $Email->clearTo();
    
    # Reset
    $Email->reset();

}

  #************** End of SendMail() ***************

# End add by Saju on 09/06/07

1;






