#!/usr/bin/perl

#(Always use 'strict' unless you have a VERY good reason not to)
use strict;
use warnings;
use Cwd;
use Config::IniFiles;
my %cfg = ();
#=============================================#
# Config file used for this script
#=============================================#

my $cfgfile = "cc_Base.cfg";

#===============================================#
# Read the config file into hash
#===============================================#

tie %cfg, 'Config::IniFiles', ( -file => "$cfgfile" );

#============================================================================#
# Variable declaration
#============================================================================#

my $cfgref = new Config::IniFiles( -file => "$cfgfile" );
my $product_build_view = ();
my ($Product_Baseline, $cc_Base);
my $VOB_list = ();
my $VOBs = ();
my $ndx = 0;
my $command_line;
my $current_dir = getcwd;
my $result;
my ($log_details);
my $process_fail = 0;
my ($log_File, $log_Error);
my $script_path = getcwd;
my $line;
my $root_path = $cfg{CLEARCASE}->{ROOT_PATH};
my $log_Path = $cfg{CLEARCASE}->{LOGPATH};
my $Storage_Location = $cfg{CLEARCASE}->{Storage_Location} ;
my $new_stream = $cfg{CLEARCASE}->{New_Stream};
my $int_stream = $cfg{CLEARCASE}->{Integration_Stream};
my $destination_path = $cfg{CLEARCASE}->{Destination_Path};
my $product = $cfg{CLEARCASE}->{Product};
my $product_vob = $cfg{CLEARCASE}->{ProductVOB};
my @baselines = split(/,/,$cfg{CLEARCASE}->{Product_Baselines});
my @mount_VOBs = split(/,/,$cfg{CLEARCASE}->{Mount_VOBs});
my $Baselines='';
my $Val='';
my @Temp=();
my $Final_Baseline='';
my $i;
my @file_output; # It stores the log file data for the body of mail.
my ($user_domain, $user_Name, $serverName);
#Added by Sharad Agarwal on 14th Nov. 2006
    $user_domain = $ENV{'USERDNSDOMAIN'};
    $user_domain =~ tr/a-z/A-Z/;
    $user_Name = $ENV{'COMPUTERNAME'};
    $user_Name =~ tr/a-z/A-Z/;
    $serverName = "$user_Name\.$user_domain";

#============================================================================#
# This function logs error into the log file. 
#============================================================================#
sub log_error
{
    #Added by Sharad Agarwal on 16th Oct. 2006
    print STDERR $log_details. "\n";
    print STDOUT $log_details. "\n";
}
    
#============================================================================#
#   Runs the command line & logs if any error into the log file.
#============================================================================#
sub result
{
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
#============================================================================================#
#   Checks all the details for the defined key's, splits the baselines and splits the Vobs
#============================================================================================#   
sub check_config_data
{
    #============================================================================#
    # This condition checks for the product
    #============================================================================#
    if ((defined $product) && ($product ne ""))
    {
      print "Product : $product\n";
    }
    else
    {
        die "Missing product name in $cfgfile.\n";
        print STDERR "\nError: Product name not provided.... \n";
    }
    #============================================================================#
    # This condition checks for the product vob
    #============================================================================#
    if ((defined $product_vob) && ($product_vob ne ""))
    {
      print "Product Vob : $product_vob\n";
    }
    else
    {
        die "Missing product VOB in $cfgfile.\n";
        print STDERR "\nError: Product Vob not provided.... \n";
    }
    #============================================================================#
    # This condition checks for the Integration Stream
    #============================================================================#
    if ((defined $int_stream ) && ($int_stream  ne ""))
    {
      print "Integration Stream : $int_stream\n";
    }
    else
    {
        die "Missing Integration Stream for the product in $cfgfile.\n";
        print STDERR "\nError: Integration Stream not provided.... \n";
    }
    #============================================================================#
    # This condition checks for the New stream
    #============================================================================#
    if ((defined $new_stream ) && ($new_stream  ne ""))
    {
      print "New Stream : $new_stream\n";
    }
    else
    {
        die "Missing New Stream for the product in $cfgfile.\n";
        print STDERR "\nError: New Stream not provided.... \n";
    }
    #============================================================================#
    # Spliting the baselines
    #============================================================================#
    foreach $i (@baselines){
        $Val = $i. '@\\'. $product_vob;
        push (@Temp,$Val);
    }
    $Final_Baseline = join (",",@Temp);
    print STDOUT "Baselines : $Final_Baseline\n";
    #============================================================================#
    # Spliting the VOBs
    #============================================================================#
    #   If there are VOB's to be mounted then put thme in our hash reference
    #   Build our hash for vob's to be mounted
        for ($ndx = 0; $ndx <= $#mount_VOBs; $ndx++) {
            $VOBs->{$mount_VOBs[$ndx]} = "";
            print STDOUT "VOB's to be mounted : $mount_VOBs[$ndx]\n";
        }
       
}

#********************************************************************************************#
#           M A I N   L O G I C   S T A R T S   H E R E   
#********************************************************************************************#
print("* * * S T A R T   O F   C L E A R C A S E   P R E   B U I L D  P R O C E S S * * *\n");
die "Unable to find the Config file : $cfgfile.\n" if (! -f $cfgfile);

    #============================================================================#
    # Checks config data
    #============================================================================#
    
    check_config_data();
    
    #===========================================================================#
    #   This will be our Directory to be created.
    #===========================================================================#
    
    $product_build_view = $product.'_BLD_VIEW';
    
    #============================================================================#
    # This will be our Log path
    #============================================================================#
    
    $log_Path = $destination_path.$product_build_view;
    $log_File = $log_Path . "\\". $product_build_view. ".log";
    $log_Error = $log_Path . "\\". $product_build_view. "_error.log";
    
    #==================================================================================#
    #   Added by Sharad Agarwal on 16th Oct. 2006
    #   Below Logic added/modified by Ashwin on 18th Oct 2006
    #   We will delete if the directory already exists & then recreate it again
    #===================================================================================#
    
    if (-d $log_Path)
    {
        system 'rmdir /S /Q '.$log_Path; #  Delete the existing directory
        mkdir $log_Path;                 #  Create the Directory Again  
    }
    else {
        mkdir $log_Path;                 #  Create the Directory if it does not exists
    }
    #============================================================================#
    # writing to a log file
    #============================================================================#
    open(OLDOUT, ">&STDOUT");
    open(OLDERR, ">&STDERR");
    
    open STDOUT, ">$log_File" or die "\nUnable to open $log_Path\nError: $!\n";
    open STDERR, ">$log_Error" or die "\nUnable to open $log_Path\nError: $!\n";
    
    
        #============================================================================#
        #   Make a Stream
        #============================================================================#
        #   We asume that whenever a baseline is made by default it will be created with current date
        #   Stream to be created...($cc_Base)
        $cc_Base = $new_stream;
        
        chdir($root_path);
        $current_dir = getcwd;
        print "Current Dir : $current_dir\n";
        
        $command_line = 'cleartool mkstream -in '.$int_stream.'@\\'.$product_vob.' -baseline '.$Final_Baseline.' -readonly '.$cc_Base.'@\\'.$product_vob;
        result();
        if ($result == 0) {
            print STDOUT "Command successfully executed : $command_line\n";
            print STDOUT "Info : Product[$product]: $Final_Baseline baseline used.\n";
            print STDOUT "Info : Product[$product]: $cc_Base stream created.\n";
        }    
        #============================================================================#
        #   Make a View out of the newly created Stream ($CC_Base)
        #============================================================================#
        #   The below line has been added by Ashwin Deshmukh on 30th Oct 2006
        #   Now storage location will be the full path of the server where you want to create the view.    
        $command_line = 'cleartool mkview -stream '.$cc_Base.'@\\'.$product_vob.' -tag '.$product_build_view.' '.$Storage_Location.$product_build_view.'.vws';
        result();
        if ($result == 0) {
            print STDOUT "Command successfully executed : $command_line\n";
            print STDOUT "Info : Product[$product]: $product_build_view view created.\n";
        }
        
        #==================================================================================#
        #   Get all those VOB's which needs to be mounted & mount them one by one...
        #==================================================================================#
        $ndx = 0;
        for ($ndx = 0; $ndx <= $#mount_VOBs; $ndx++) {
        $command_line = 'cleartool mount \\'.$mount_VOBs[$ndx];
        #result();
        system $command_line;
        }
        
        #============================================================================#
        # Copy to the destination path
        #============================================================================#
        print STDOUT "Source path : M:\\".$product_build_view."\n";
        $command_line =  'xcopy /E /Y /I M:\\'.$product_build_view.' '.$destination_path.$product_build_view;
        #system $command_line;
        result();
        if ($result == 0) {
        print STDOUT "Command successfully executed : $command_line\n";
        print STDOUT "Info : Product[$product]: Files copied to ".$destination_path.$product_build_view."\n";
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
        #============================================================================#
        #   End view($product_build_view) after done
        #============================================================================#
        $command_line = 'cleartool endview '.$product_build_view;
        result();
        if ($result == 0) {
            print STDOUT "Command successfully executed : $command_line\n";
            print STDOUT "Info : Product[$product]: ".$product_build_view." view ended\n";
        }            
        #============================================================================#
        #   Remove view($product_build_view) after done
        #============================================================================#
        $command_line = 'cleartool rmview -force -tag '.$product_build_view;
        result();
        if ($result == 0) {
            print STDOUT "Command successfully executed : $command_line\n";
            print STDOUT "Info : Product[$product]: ".$product_build_view." view removed\n";
        }            
        
        #============================================================================#
        #   Remove stream ($CC_Base)
        #============================================================================#
        $command_line = 'cleartool rmstream -force '.$cc_Base.'@\\'.$product_vob;
        result();
        if ($result == 0) {
            print STDOUT "Command successfully executed : $command_line\n";
            print STDOUT "Info : Product[$product]: ".$cc_Base." stream removed\n";
        }
     
    #============================================================================#
    #   End of the ClearCase Pre Build Process for a product
    #============================================================================#
    #wait;
    print("\n* * * End Of ClearCase Pre Build Process For $product * * *\n");
    #============================================================================#
    
    #============================================================================#
    # close the log file
    #============================================================================#
    #Added by Sharad Agarwal on 16th Oct. 2006
    close(STDOUT)|| die "Can't close log file";
    close(STDERR) || die "Can't close log file";
    #============================================================================#
    # restore stdout and stderr
    #============================================================================#
    open(STDERR, ">&OLDERR")            or die "Can't restore stderr: $!";
    open(STDOUT, ">&OLDOUT")            or die "Can't restore stdout: $!";
    
    #============================================================================#
    # avoid leaks by closing the independent copies
    #============================================================================#
    
    close(OLDOUT)                       or die "Can't close OLDOUT: $!";
    close(OLDERR)                       or die "Can't close OLDERR: $!";

    #   By Ashwin
    # Added by Sharad Agarwal 0n 14th Nov. 2006
    
    #=============================================================================#
    #@file_output contains the each line of log file into an array.
    #=============================================================================#
    push(@file_output,"\n************Please Check The Server $serverName For Log Files************\n\n");
    
    #============================================================================#
    # open the log file 
    #============================================================================#
    open FILEH, "<$log_File" or die "\nUnable to open $log_Path\nError: $!\n";
    while ($line = <FILEH>){
        chomp($line);
    	print "$line\n";
        #Added by Sharad on 14th Nov. 2006
        push(@file_output,$line);
    }
    #============================================================================#
    # Close the log file
    #============================================================================#
    close (FILEH) || die "\nCan't close log file";
    
        $process_fail = 0; # Reset the Process flag..
    
    #   We shall loop untill all the sections in our config file are complete

print  ("\n* * * E N D   O F   C L E A R C A S E   P R E   B U I L D  P R O C E S S * * *\n");

exit 0;
