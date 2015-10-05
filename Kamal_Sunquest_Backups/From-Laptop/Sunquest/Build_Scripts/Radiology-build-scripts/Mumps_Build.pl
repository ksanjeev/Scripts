#!/usr/bin/perl -w
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
# Mumps_Build.pl
#  Perform a MUMPS build For the given project in ClearCase and pulling all of
#  the necessary data from the rad.cfg file
#
# Usage:
#  
#
# Returns:
#  zero on success and non-zero on failure. Error messages will be sent
#  to STDOUT and STDERR
#
# Processing:
#
# Caveats:  
#   
#
#=========================================================================
# Edit history:
#
#	Initial creation:	kdo 6/19/06
#
# Sr.| Modified on    | Modified by      | Reason
# ------------------------------------------------------------------------------
# 1) | 7th Sept 2006  | Ashwin Deshmukh  |
# 2) | 19th Sept 2006 | Ashwin Deshmukh  |
# 3) | 27th Sept 2006 | Ashwin Deshmukh  |


# 1) | 13th Oct 2006  | Sharad Agarwal   |
# 2) | 16th Oct. 2006 | Sharad Agarwal   |
# 3) | 14th Nov. 2006 | Sharad Agarwal   |
# 4) | 1st Dec. 2006  | Sharad Agarwal   |
# 5) | 07th Dec. 2006 | Sharad Agarwal   |
# 6) | 13th Feb 2007  | Sharad Agarwal   |


# 1) | 7th Dec 2006   | Saju Carlos      | 1) To remove the problem of extra '0D' comming in the string "0D 0A 0D 0D 0A" in output file.
#                                          2) To add three lines at the end of the file.

# 2) | 18th Jan 2007  | Saju Carlos      | Added a new key 'MUMPS_FOLDER' into the configuration file for mumps folder

# 3) | 28th Feb 2007  | Saju Carlos      | Change of name format for Mumps ro files from product_date_time.ro to product_date.ro

# 4) | 02nd Mar 2007  | Saju Carlos      | Change mumps file name from the current form product_date.ro to product_version_date.ro



#
#=========================================================================

# Pragmas go here
#(Always use 'strict' unless you have a VERY good reason not to)
use strict;
# Added by Ashwin Deshmukh on 19th Sept 2006
use Misys::Find;
# Commented by Ashwin Deshmukh on 19th Sept 2006
#use File::Find;
use Config::IniFiles;
use File::Copy;
use File::Basename;
use Misys::SendMail;


# Global Script Variables
my ($cfgrec, @cfgsecs,%cfg, $bld_dir);
my ($bld_id, @bld_components, $component, @cfgsecs_cc_build);
my ($bld_name, @pats);
my ($log_file, $out_file, $log_error);
my $first_out = 1;
my $bld_fail = 0;


# Added by Saju on 19th June 2007,
my @ExcludedFileList=();


#my $bld_root = "/buildm";
#my $rm_root = "/Builds";
#my $bld_rec = ();
#my $cfg_data = ();

my @gof_files = ();
my $file_pats = ();
my $proc_files = ();
my $exclude_files = ();
my $exclude_folders = ();
my ($bld_path_name_MSQL1, $bld_path_name_MSQL2, $bld_name_MSQL1, $bld_name_MSQL2);
my $command_line;
my @total_files;
my $Email_Found;

# Added by Sharad Agarwal 0n 14th Nov. 2006
my @email_list = (); # For storing the email list from the config file.
my @file_output; # It stores the log file data for the body of mail.
my ($sm, $subject); #sm is the object of Sendmail and $subject is for manage subject text.
my ($user_domain, $user_Name, $serverName);

# Modified by Sharad Agarwal on 13th Feb 2007
#my $cfgfile = "MUMPS.cfg";
my $cfgfile = "cc_build.cfg";

# 1) Added by Saju Carlos 02nd Mar 2007 for mumps file name change
# my $Version = "";
# End of 02nd Mar 2007 changes

die "Unable to find $cfgfile.\n" if (! -f $cfgfile);
#
#=========================================================================
# Subroutines
#=========================================================================
#
sub get_date
{
  my ($sec, $min, $hr, $day, $month, $year) = (localtime (time))[0 .. 5];

# Commented and added new by Saju Carlos on 28th Feb 2007
#  return (sprintf("%04d%02d%02d_%02d%02d%02d",
#            ($year + 1900), ($month + 1), $day, $hr, $min, $sec));
  return (sprintf("%02d%02d%04d",
            ($month + 1), $day,($year + 1900)));
# End modification on 28th Feb 2007

}




sub wanted
{
    my $pattern = shift;
    my $path = $Misys::Find::name;
    $path =~ s/(?:(?:.+)[\\\/](.+))/$1/;        # Extract the file name
    push @ExcludedFileList,$path;
}


sub get_excludes
{
  #my $rec = shift;
  my $ndx = 0;
  my @file_list = ();
  my $files = "";
  $exclude_files = ();
  $exclude_folders = ();
  
  # Get the list of files to exclude if any
  if ((defined $cfg{'ExFile'}) && ($cfg{'ExFile'} ne "")) {
    $files = $cfg{'ExFile'};
    # Added by Sharad Agarwal on 13th Oct 2006
    print STDOUT "exclude files $files\n";
  }
  
  # If there are files to exclude then put thme in our hash reference
  if ((defined $files) && ($files ne ""))
  {
    @file_list = split /,/, $files; 
    # Build our hash of excluded items
    for ($ndx = 0; $ndx <= $#file_list; $ndx++)
    {
        # Added by Saju on 06/19/07
        # Description: To support wild characters in the config file for exclude files.
        if ($file_list[$ndx] =~ /(?:^\*(\.\D+))/)           # If the file pattern starts with *.extension, Ex:- *.doc
        {
            my $pattern = $1;
            my $regex = '(?:\\'.$pattern.'$)';
            finddepth(\&wanted, $bld_dir);
            my @FileList = grep {m/$regex/is} @ExcludedFileList;
            map { $exclude_files->{$_} = "" } @FileList;
        }
        elsif ($file_list[$ndx] =~ /(?:(.+)(?=\*\.\D+))/)   # If the file pattern is like GS*.RSA
        {
            my $pattern = $1;
            $pattern = 'qr/(?:'.$pattern.'(?=(?:.*)(?:\.\D+)))/s';
            my $regex = eval($pattern);
            warn $@ if $@;
            finddepth(\&wanted, $bld_dir);
            if (ref($regex) eq "Regexp")
            {
              my @FileList = grep {m/$regex/s} @ExcludedFileList;
              map {$exclude_files->{$_} = "" }@FileList;
            }
        }
        else
        {
            $exclude_files->{$file_list[$ndx]} = "";
        }
        # End addition by Saju on 06/19/07
    }
  }
  $files = "";
  
  # Get the list of folders to exclude if any
  if ((defined $cfg{ExFold}) && ($cfg{ExFold} ne "")) {
    $files = $cfg{ExFold};
    # Added by Sharad Agarwal on 13th Oct 2006
    print STDOUT "exclude folders $files\n";
    #print("We are here 2\n");
  }
  

  # If there are folders to exclude then put thme in our hash reference
  if ((defined $files) && ($files ne ""))
  {
    @file_list = split /,/, $files;
    
    # Build our hash of excluded items
    for ($ndx = 0; $ndx <= $#file_list; $ndx++) {
      $exclude_folders->{$file_list[$ndx]} = "";
    }
  }
  return;
}
#================================================================
sub get_csql_excludes {
  #my $rec = shift;
  my $ndx = 0;
  my @file_list = ();
  my $files = "";
  $exclude_files = ();
  $exclude_folders = ();
  
  # Get the list of files to exclude if any
  if ((defined $cfg{'ExFileCsql'}) && ($cfg{'ExFileCsql'} ne "")) {
    $files = $cfg{'ExFileCsql'};
    #print "exclude files $files\n";
    # Added by Sharad Agarwal on 13th Oct 2006
    print STDOUT "exclude files $files\n";
    #print("We are here 3\n");
  }
  
  # If there are files to exclude then put thme in our hash reference
  if ((defined $files) && ($files ne "")) {
    @file_list = split /,/, $files;
   
    # Build our hash of excluded items
    for ($ndx = 0; $ndx <= $#file_list; $ndx++) {
      $exclude_files->{$file_list[$ndx]} = "";
    }
  }
  $files = "";
  
  # Get the list of folders to exclude if any
  if ((defined $cfg{ExFoldCsql}) && ($cfg{ExFoldCsql} ne "")) {
    $files = $cfg{ExFoldCsql};
    print "exclude folders $files\n";
    # Added by Sharad Agarwal on 13th Oct 2006
    print STDOUT "exclude folders $files\n";
    #print("We are here 4\n");
  }
  

  # If there are folders to exclude then put them in our hash reference
  if ((defined $files) && ($files ne "")) {
    @file_list = split /,/, $files;
    
   
    # Build our hash of excluded items
    for ($ndx = 0; $ndx <= $#file_list; $ndx++) {
      $exclude_folders->{$file_list[$ndx]} = "";
    }
  }
  
  return;
}
#================================================================
sub get_msql_excludes {
  #my $rec = shift;
  my $ndx = 0;
  my @file_list = ();
  my $files = "";
  $exclude_files = ();
  $exclude_folders = ();
  
  # Get the list of files to exclude if any
  if ((defined $cfg{'ExFileMsql'}) && ($cfg{'ExFileMsql'} ne "")) {
    $files = $cfg{'ExFileMsql'};
    #print "exclude files $files\n";
    # Added by Sharad Agarwal on 13th Oct 2006
    print STDOUT "exclude files $files\n";
    #print("We are here 3\n");
  }
  
  # If there are files to exclude then put thme in our hash reference
  if ((defined $files) && ($files ne "")) {
    @file_list = split /,/, $files;
   
    # Build our hash of excluded items
    for ($ndx = 0; $ndx <= $#file_list; $ndx++) {
      $exclude_files->{$file_list[$ndx]} = "";
    }
  }
  $files = "";
  
  # Get the list of folders to exclude if any
  if ((defined $cfg{ExFoldMsql}) && ($cfg{ExFoldMsql} ne "")) {
    $files = $cfg{ExFoldMsql};
    print "exclude folders $files\n";
    # Added by Sharad Agarwal on 13th Oct 2006
    print STDOUT "exclude folders $files\n";
    #print("We are here 4\n");
  }
  

  # If there are folders to exclude then put them in our hash reference
  if ((defined $files) && ($files ne "")) {
    @file_list = split /,/, $files;
    
   
    # Build our hash of excluded items
    for ($ndx = 0; $ndx <= $#file_list; $ndx++) {
      $exclude_folders->{$file_list[$ndx]} = "";
    }
  }
  
  return;
}

sub get_patterns {
  @pats = split /,/,shift;
  my ($ndx);
  
  $file_pats = ();
  
  for ($ndx = 0; $ndx <= $#pats; $ndx++) {
    $pats[$ndx] =~ s/^"(.*?)"$/$1/;
    $pats[$ndx] = (split /\./,$pats[$ndx])[-1];
    $file_pats->{$pats[$ndx]} = "";
  }
  
  return;
}

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

#
#sub scan_log {
#  my $logfile = shift;
#  my $found = 0;
#  
#  # Return failure if the log file does not exist or it is empty
#  return 1 if ((!-e $logfile) || (-s $logfile == 0));
#  
#  # Open the log file and look for any lines that start with 'E'
#  open SRC , "<$logfile" or die "\nUnable to open $logfile\nError: $!\n";
#  while (<SRC>) {
#    if (/^E\d+/){
#      print STDOUT "$_\n";
#      $found++;
#    }
#  }
#  close SRC or die "\nUnable to close $logfile\nError: $!\n";
#  
#  return $found;
#}
#
sub add_file {
  my $file_name = $_;
  my ($tmp);
  my @src_lines = ();
  my $file_ext = (split /\./, $file_name)[-1];
  
  # Check here why it is picking Z first & not A Dir
  # Modified by Ashwin Deshmukh on 19th Sept 2006
  #my $cur_dir = (split /\//, $File::Find::dir)[-1];
  my $cur_dir = (split /\//, $Misys::Find::dir)[-1];
  
  
  ## If we are looking at a GOF file then save its path and name for later
  ## transfer to our output folder.
  #if (uc($file_ext) =~ "GOF") {
  #  #$tmp = "$bld_dir/$file_name";
  #  #$tmp = "$bld_dir/";
  #  #system "cp $file_name $bld_dir/";
  #  push @gof_files, "$bld_dir/$file_name";
  #  return;
  #}
  
  # Make sure we're not processing something that is excluded
  return if (defined $exclude_folders->{$cur_dir});
  return if (defined $exclude_files->{$file_name});
  
  return if ($file_name =~ /^\./);
  return if (!defined $file_pats->{$file_ext});
  
  # For Debugging
  # Added by Sharad Agarwal on 13th Oct 2006
  print STDOUT "Processing: $file_name\n";
  
  open SRC, "<$file_name" or die "\nUnable to open: $file_name\nError: $!\n";
  @src_lines = <SRC>;
  close SRC or die "\nUnable to close: $file_name\nError: $!\n";

  # Added by Saju on 19th June,2007
  # Description: Skip the empty files
  if (@src_lines == 0)
  {
    print STDOUT "  $file_name is empty\n\n";
    return;
  }   
  # End addition
  
  if (uc($file_ext) =~ "RSA")
  {
    #Lines added by RZD for Commercial Lab 4 line feed issues... July 6, 2007
    my $myTemp1 = 0;
    my $myTemp2;
    
    do{
        $myTemp2 = $src_lines[-1];
        if($myTemp2 eq "\x0a"){
            pop(@src_lines);    
        }else{
            $myTemp1=1;
        }
    }while($myTemp1 != 1);
    
    
    
    if ($cfg{'StripHeader'} =~ /y/i)
    {   # Process for the COMLAB,LAB6.1,LAB6.2 build
        
        if (  # Start of condition   
            (
              ($src_lines[0] !~ /^Cache/)
              &&
              ($src_lines[0] !~ /^Open M/)
              &&
              ($src_lines[0] !~ /^Saved by/)    # Added new by Saju on 05/30/07 for COMLAB build
              &&
              ($src_lines[0] !~ /^N\sIO/)       # Added by Saju on 19th June,2007 for Lab build
            ) 
            ||
            (
              ($src_lines[1] !~ /^\%RO /)       # Added by Saju on 19th June,2007
              &&
              ($src_lines[1] !~ /^DSM2CACHE/)   # Added new by Saju on 05/30/07 for COMLAB build
            )
           ) # End of condition 
        {
            print STDERR "$file_name has a bad or missing header.\n";
            # Added by Sharad Agarwal on 13th Oct 2006
            print STDOUT "$file_name has a bad or missing header.\n";
            $bld_fail = 1;
            return;
        }
    }
    elsif ($cfg{'StripHeader'} =~ /n/i)
    {   # Process for builds other than COMLAB like for RAD,AI,IX 
        if (   
            (
                ($src_lines[0] !~ /^\~Format/i)
                &&
                ($src_lines[0] !~ /^\n/)
                &&
                ($src_lines[0] !~ /^Cache/i)
                &&
                ($src_lines[0] !~ /^Open M/i)
            )
            ||
            (
                ($src_lines[2] !~ /^\^(\D)+/)
                &&
                ($src_lines[1] !~ /^\%RO /)     # Added by Saju on 19th June,2007 for AI Builds
            )    
           )
        {
            print STDERR "$file_name has a bad or missing header.\n";
            # Added by Sharad Agarwal on 13th Oct 2006
            print STDOUT "$file_name has a bad or missing header.\n";
            $bld_fail = 1;
            return;            
        }    
    }
  }  
  elsif (uc($file_ext) =~ "GSA")
  {
        if (  # Start of condition
            (
                ($src_lines[0] !~ /^\S*\~Format/i)     # Modified by Saju on 05/30/07 for COMLAB build
                &&
                ($src_lines[0] !~ /^\n/)
                &&
                ($src_lines[0] !~ /^(Cache|ZCache)/i)  # Modified by Saju on 05/30/07 for COMLAB build
                &&
                ($src_lines[0] !~ /^Open M/i)
                &&
                ($src_lines[0] !~ /^\s*\d+\-\S+\-\d+/) # Added new by Saju on 05/30/07 for COMLAB build
                &&
                ($src_lines[0] !~ /^Saved by/i)        # Added new by Saju on 05/30/07 for COMLAB build
            )
            ||
            ($src_lines[2] !~ /^\^(\D)+/)
           )  # End of condition
        {
            print STDERR "$file_name has a bad or missing header.\n";
            # Added by Sharad Agarwal on 13th Oct 2006
            print STDOUT "$file_name has a bad or missing header.\n";
            $bld_fail = 1; 
            return;
        }   
  }



  if ($first_out == 0)
  {
    shift @src_lines;
    shift @src_lines;
  }
  else {
    $first_out = 0;
  }
  
  # Commented by Saju on 7th Dec 2006
  # open OUT, ">>$out_file" or die "\nUnable to open: $out_file\nError: n$!\n";
  
  my $line = '' if ($cfg{'StripHeader'} =~ /y/i);
  my $flag = 'none' if ($cfg{'StripHeader'} =~ /y/i);
  
  foreach (@src_lines)
  {

    # Added by Saju on 17th July 2007
    if ($_ =~ /^(?:\s|\.)*;(?:[^;]|$)/)
    {
	next if ($cfg{'CommentRequired'} =~ /n/i);
    }
    # End Add on 17th July 2007

    if ($cfg{'StripHeader'} =~ /y/i)
    {   # Process for the COMLAB,LAB builds
        if (defined $flag)
        {
            if (($_ =~ /^(\s)*\n$/)&&($flag =~ /node/))
            {
                print OUT "$_" if ($line =~ /^(?:\^(?:.+)(?:\((?:.+)\))?)/i);
                $line = '';
                $flag = 'none';
                next
            }
        }
        
        if ($file_ext =~ /GSA/i)
        {
            $line = $_;            
            if (($line =~ /^(?:\^(?:.+)(?:\((?:.+)\))?)/i)&&($flag eq 'none'))
            {
                $flag = 'node';
            }
            else
            {
                next if (($flag eq 'none')&&(($line =~ /^(\s)*\n$/)));
                $flag = 'none';
            }
        }
        print OUT "$_";
    }
    elsif ($cfg{'StripHeader'} =~ /n/i)
    {   # Process for builds other than COMLAB like for RAD,AI,IX
        next if ($_ =~ /^(\s)*\n$/);
        next if ($_ =~ /^(?:\s|\.)*;(?:[^;]|$)/);
        print OUT "$_";
    } 
  }
  
    # Added & Commented by Saju on 7th Dec 2006  
    # print OUT "\x0d\x0a";
  
    if ($cfg{'StripHeader'} =~ /y/i)
    {
        # Process for builds like COMLAB,LAB
        print OUT "\x0a" if ($file_ext =~ /RSA/i);
    }  
    elsif ($cfg{'StripHeader'} =~ /n/i)
    {
        # Process for builds RAD,AI,IX
        print OUT "\x0a";
    }
    
    #close OUT or die "\nUnable to close: $out_file\nError: $!\n";
    # end of Change
    return;
}


#passed in component piece
sub do_build
{
    #my $rec = shift;
    my ($rtn, $out_path, $ndx);
    #my $vpath = $rec->{VPATH};

  # Create our RO and GO file names
  $out_file = $bld_name;

  # Make sure our RO and GO files do not exist
  unlink $out_file if (-e $out_file);
  
    # Added by Saju on 7th Dec 2006
  # Description :- 1) To remove the problem of extra '0D' comming in the string "0D 0A 0D 0D 0A" in output file.
  #                2) To add three lines at the end of the file.
    open OUT, ">>$out_file" or die "\nUnable to open: $out_file\nError: n$!\n";
  # End add
  
  # Process the mumps files under the current directory.
    find(\&add_file, ".");
    
    # Added by Saju on 7th Dec 2006
    print OUT "\x0a\x0a";
    close OUT or die "\nUnable to close: $out_file\nError: $!\n";
    # End Add

    # If our build failed then clean up and return
    if ($bld_fail == 1) {
      unlink $out_file if (-e $out_file);
      return;
    }
    
    ## Set our eof for our output file
    #set_eof() if (-e $out_file);
    
    ## Now move the file to our build server.
    #move_file($out_file) if (-e $out_file);
#}
#  else {
#    die "\n error:\nExtract failed for one or more files.\n";
  
  return;
}

sub get_components
{
    print "COMPONENTS : $cfg{'components'}\n";
    @bld_components = split /,/, $cfg{'components'};
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

sub get_cfg_recs {
   
  my $cfgref = new Config::IniFiles( -file => "$cfgfile" );
  @cfgsecs = $cfgref->Sections();
  
  # Added by Sharad Agarwal on 07th Dec. 2006
  # This will hold all the sections of cc_build.cfg file.
  # Commented by Sharad Agarwal on 13th Feb 2007
  #my $cfgref_cc_build = new Config::IniFiles( -file => "cc_build.cfg" );
  #@cfgsecs_cc_build = $cfgref_cc_build->Sections();
  return;
}

sub get_config_data {
  my $cfgsec = shift;
  
  # Added by Sharad Agarwal on 07th Dec. 2006
  # This will hold the section of cc_build.cfg file.
  # Commented by Sharad Agarwal on 13th Feb 2007
  #my $cfgsec_cc_build = shift(@cfgsecs_cc_build);
  my $cfgref = new Config::IniFiles( -file => "$cfgfile" );
  
  # Added by Sharad Agarwal on 07th Dec. 2006
  # This will read the cc_build.cfg file.
  # Commented by Sharad Agarwal on 13th Feb 2007
  #my $cfgref_cc_build = new Config::IniFiles( -file => "cc_build.cfg" );
  
  # Reset our cfg hash
  %cfg = ();

  # Modified by Sharad Agarwal on 07th Dec. 2006
  # This will read the value of "Product" from cc_build.cfg file.
  #$cfg{'prod'} = $cfgref->val( $cfgsec, 'Product' );
  #die "Missing product name in $cfgsec of $cfgfile.\n"
  $cfg{'prod'} = $cfgref->val( 'CLEARCASE', 'Product' );
  die "Missing product name in CLEARCASE of cc_build.cfg.\n"
    if (!defined $cfg{'prod'});

  # Modified by Sharad Agarwal on 07th Dec. 2006
  # This will read the value of "Working_Dir" from cc_build.cfg file.
  # and the blddir will be 'Working_Dir'. $cfg{'prod'}.'_BLD_VIEW\\'
  #$cfg{'blddir'} = $cfgref->val( $cfgsec, 'BuildDirectory' );
  #die "Missing DB name in $cfgsec of $cfgfile.\n"
  $cfg{'blddir'} = $cfgref->val( 'CLEARCASE', 'Working_Dir' ). $cfg{'prod'}.'_BLD_VIEW\\';
  die "Missing DB name in CLEARCASE of cc_build.cfg.\n"
    if (!defined $cfg{'blddir'});


#2 Added by Saju Carlos on 02nd Mar 2007 for the MUMPS file name change
# Get the build number
  $cfg{'Build_No'} = $cfgref->val( 'CLEARCASE', 'Build_No' );
  die "Missing Global Output in $cfgsec of $cfgfile.\n"
    if (!defined $cfg{'Build_No'});
# End of 02nd Mar 2007 changes


  $cfg{'db'} = $cfgref->val( $cfgsec, 'DB' );
  die "Missing DB name in $cfgsec of $cfgfile.\n"
    if (!defined $cfg{'db'});
      
  $cfg{'components'} = $cfgref->val( $cfgsec, 'Components' );
  die "Missing DB name in $cfgsec of $cfgfile.\n"
    if (!defined $cfg{'components'});
  
  $cfg{'ExFile'} = $cfgref->val( $cfgsec, 'ExcludeFile' );
  die "Missing excluded files in $cfgsec of $cfgfile.\n"
    if (!defined $cfg{'ExFile'});

  $cfg{'ExFileMsql'} = $cfgref->val( $cfgsec, 'ExcludeMsqlFile' );
  die "Missing excluded msql files in $cfgsec of $cfgfile.\n"
    if (!defined $cfg{'ExFileMsql'});
  
  $cfg{'ExFold'} = $cfgref->val( $cfgsec, 'ExcludeFolderList' );
  die "Missing excluded folders in $cfgsec of $cfgfile.\n"
    if (!defined $cfg{'ExFold'});
    
  $cfg{'ExFoldMsql'} = $cfgref->val( $cfgsec, 'ExcludeMsqlFolderList' );
  die "Missing msql excluded folders in $cfgsec of $cfgfile.\n"
    if (!defined $cfg{'ExFoldMsql'});
  #==========================================================================
  $cfg{'ExFoldCsql'} = $cfgref->val( $cfgsec, 'ExcludeCsqlFolderList' );
  die "Missing csql excluded folders in $cfgsec of $cfgfile.\n"
    if (!defined $cfg{'ExFoldCsql'});
  #==========================================================================
  $cfg{'BldSepFold'} = $cfgref->val( $cfgsec, 'BuildSeparateFolder' );
  die "Missing Build Separate Folder name in $cfgsec of $cfgfile.\n"
    if (!defined $cfg{'BldSepFold'});
  
  $cfg{'BldSepFile'} = $cfgref->val( $cfgsec, 'BuildSeparateFile' );
  die "Missing Build Separate Filename in $cfgsec of $cfgfile.\n"
    if (!defined $cfg{'BldSepFile'});
  
  $cfg{'RtnFiles'} = $cfgref->val( $cfgsec, 'RoutineFiles' );
  die "Missing Routine File name in $cfgsec of $cfgfile.\n"
    if (!defined $cfg{'RtnFiles'});
  
  $cfg{'GblFiles'} = $cfgref->val( $cfgsec, 'GlobalFiles' );
  die "Missing Global File name in $cfgsec of $cfgfile.\n"
    if (!defined $cfg{'GblFiles'});
    
  $cfg{'MsqlRtn'} = $cfgref->val( $cfgsec, 'MsqlRoutines' );
  die "Missing Global File name in $cfgsec of $cfgfile.\n"
    if (!defined $cfg{'MsqlRtn'});

  $cfg{'MsqlFiles'} = $cfgref->val( $cfgsec, 'MsqlFiles' );
  die "Missing Global File name in $cfgsec of $cfgfile.\n"
    if (!defined $cfg{'MsqlFiles'});
  
  $cfg{'RtnOut'} = $cfgref->val( $cfgsec, 'RoutineOutput' );
  die "Missing Routine Output name in $cfgsec of $cfgfile.\n"
    if (!defined $cfg{'RtnOut'});

  $cfg{'GblOut'} = $cfgref->val( $cfgsec, 'GlobalOutput' );
  die "Missing Global Output in $cfgsec of $cfgfile.\n"
    if (!defined $cfg{'GblOut'});
    
  $cfg{'MsqlRtnOut'} = $cfgref->val( $cfgsec, 'MsqlRoutineOutput' );
  die "Missing Global Output in $cfgsec of $cfgfile.\n"
    if (!defined $cfg{'MsqlRtnOut'});

  $cfg{'MsqlOut'} = $cfgref->val( $cfgsec, 'MsqlOutput' );
  die "Missing Global Output in $cfgsec of $cfgfile.\n"
    if (!defined $cfg{'MsqlOut'});


#1 Added by Saju on 18th Jan 2007 for the MUMPS folder
  $cfg{'MUMPS_Folder'} = $cfgref->val( $cfgsec, 'MUMPS_Folder' );
  die "Missing MUMPS Folder in $cfgsec of $cfgfile.\n"
    if (!defined $cfg{'MUMPS_Folder'});
# end of 18th jan changes


#1 Added by Saju on 18th Jan 2007 for the MUMPS folder
  $cfg{'StripHeader'} = $cfgref->val( $cfgsec, 'StripHeader' );
  #$cfg{'StripHeader'} = 'N' if ((!defined $cfg{'StripHeader'})||($cfg{'StripHeader'} =~ /[^YN]/i));
  $cfg{'StripHeader'} = 'N' if ($cfg{'StripHeader'} !~ /(?:y|n)/i);
# end of 18th jan changes


# Added by Saju on 17th July 2007
  $cfg{'CommentRequired'} = $cfgref->val( $cfgsec, 'CommentRequired' );
  $cfg{'CommentRequired'} = 'N' if ($cfg{'CommentRequired'} !~ /(?:y|n)/i);
# End add on 17th July 2007




  # Modified by Sharad Agarwal 0n 14th Nov. 2006
  #Reading Email list from the config file.
  #$cfg{'EmailAddress'} = $cfgref->val( $cfgsec, 'Email_List' );
  $cfg{'EmailAddress'} = $cfgref->val( 'CLEARCASE', 'Email_List' );
  if (!defined $cfg{'EmailAddress'})
  {
    $Email_Found = 1;   
  }
  else
  {
    $Email_Found = 0;
  }
}

#
#=========================================================================
# Main logic
#=========================================================================
#
#
print("* * * S T A R T   O F   O U R   B U I L D * * *\n");
print("\nPlease wait processing is on....\n\n");
# Get the existing sections in our config file
get_cfg_recs();

foreach my $cfgrec (sort(@cfgsecs)) {

  # Get the data from the config file
  # Added by Sharad Agarwal on 13th Feb 2007
  # This will select only the MUMPS section.
    if ($cfgrec eq "MUMPS")
    {
      print "Get details for : $cfgrec\n";
      get_config_data($cfgrec);
    }
    else
    {
      next;
    }
  #get_config_data($cfgrec);
}

#2 Make sure the build directory exists
# Commented and added by Saju on 18th Jan 2007, to use the key "MUMPS_Folder" from the MUMPS.cfg
# $bld_dir = $cfg{'blddir'} . $cfg{'prod'} . "\_". $cfg{'db'};
$bld_dir = $cfg{'blddir'} . $cfg{'MUMPS_Folder'};
# end of 18th jan changes


#3 Added by Saju Carlos 02nd Mar 2007 for Mumps filename changes
#($Version) =  ($cfg{'Build_No'} =~ /(.+)(?=\.\d+)/);
# End of 02nd Mar 2007 changes





if (!-d $bld_dir) {
  chdir $cfg{'blddir'};
  
  #3 Modified and added new by Saju on 18th Jan 2007
  # mkdir($cfg{'blddir'} . $cfg{'prod'} . "_". $cfg{'db'});
  # $bld_dir = $cfg{'blddir'} . $cfg{'prod'} . "\_". $cfg{'db'};
  mkdir($cfg{'blddir'} . $cfg{'MUMPS_Folder'});
  $bld_dir = $cfg{'blddir'}.$cfg{'MUMPS_Folder'};
  # end of 18th jan changes
}
# Added by Sharad Agarwal on 13th Oct 2006
open(OLDOUT, ">&STDOUT");
open(OLDERR, ">&STDERR");
#$log_file = $bld_dir . "\\". $cfg{'prod'} . "\_". $cfg{'db'} . ".log";
# Modified by Sharad Agarwal on 1st Dec. 2006
$log_file = $cfg{'blddir'}. $cfg{'prod'} . "\_". $cfg{'db'} . ".log";
open STDOUT, ">$log_file" or die "\nUnable to open $log_file\nError: $!\n";
#$log_error = $bld_dir . "\\". $cfg{'prod'} . "\_". $cfg{'db'} . "\_ERROR.log";
# Modified by Sharad Agarwal on 1st Dec. 2006
$log_error = $cfg{'blddir'}. $cfg{'prod'} . "\_". $cfg{'db'} . "\_ERROR.log";
open STDERR, ">$log_error" or die "\nUnable to open $log_error\nError: $!\n";

# Move to our build directory
chdir "$bld_dir";
# Added by Sharad Agarwal on 13th Oct 2006
print STDOUT "Build Directory : $bld_dir\n";

#break up component types to build
get_components($cfg{'components'});

# Added by Sharad Agarwal 0n 14th Nov. 2006
#calling the function to store the email list into an array.
if ($Email_Found == 0)
{
  get_Email_List($cfg{'EmailAddress'});
}

foreach $component (@bld_components)
{

    if ($component eq "RTN") {
    
        #4 Modified and added new by Saju Carlos on 02nd Mar 2007 for Mumps filename changes
        # $bld_name = $bld_dir . "\\" . $cfg{'prod'} . "_" . get_date() . $cfg{'RtnOut'};
        $bld_name = $bld_dir . "\\" . $cfg{'prod'} . "_" . $cfg{'Build_No'} . "_" . get_date() . $cfg{'RtnOut'};
        # End of 02nd Mar 2007 changes

        # get our file pattern hash for each type of component
        get_patterns($cfg{'RtnFiles'});
        # Get our list of excluded files and sub-directories if any
        get_excludes();
        
    } elsif ($component eq "GBL"){
    
        #5 Modified and added new by Saju Carlos on 02nd Mar 2007 for Mumps filename changes
        # $bld_name = $bld_dir . "\\" . $cfg{'prod'} . "_" . get_date() . $cfg{'GblOut'};
        $bld_name = $bld_dir . "\\" . $cfg{'prod'} . "_" . $cfg{'Build_No'} . "_" . get_date() . $cfg{'GblOut'};
        # End of 02nd Mar 2007 changes
        
        
        # get our file pattern hash for each type of component
        get_patterns($cfg{'GblFiles'});
        # Get our list of excluded files and sub-directories if any
        get_excludes();
        
    }  elsif ($component eq "MSQLRTN"){
    
        # Commented By Ashwin Deshmukh on 7th Sept 2006
        #6 Modified and added new by Saju Carlos on 02nd Mar 2007 for Mumps filename changes
        # $bld_name = $bld_dir . "\\" . $cfg{'BldSepFold'} . "_" . get_date() . $cfg{'MsqlRtnOut'};
        $bld_name = $bld_dir . "\\msql" . "_" . $cfg{'Build_No'} . "_" . get_date() . $cfg{'MsqlRtnOut'};
        #$bld_name = $bld_dir . "\\" . $cfg{'BldSepFold'} . "_" . $cfg{'Build_No'} . "_" . get_date() . $cfg{'MsqlRtnOut'};
        # End of 02nd Mar 2007 changes
        
        
        # Added " . $cfg{'prod'} . "_" to have the Product Name in the file name  - By Ashwin Deshmukh on 7th Sept 2006
        #$bld_name = $bld_dir . "\\" . $cfg{'prod'} . "_" . $cfg{'BldSepFold'} . "_" . get_date() . $cfg{'MsqlRtnOut'};
        
        # Added by Ashwin Deshmukh on 27th Sept 2006
        #$bld_name_MSQL1 = $bld_name;
        #$bld_path_name_MSQL1 = $bld_name;
        
        # get our file pattern hash for each type of component
        get_patterns($cfg{'MsqlRtn'});
        # Get our list of excluded files and sub-directories if any
        get_msql_excludes();
    
    }
    elsif ($component eq "MSQLGBL")
    {
       if ($cfg{'prod'} ne "RAD")
       {
            # Commented By Ashwin Deshmukh on 7th Sept 2006
            #7 Modified and added new by Saju Carlos on 02nd Mar 2007 for Mumps filename changes
            # $bld_name = $bld_dir . "\\" . $cfg{'BldSepFold'} . "_" . get_date() . $cfg{'MsqlOut'};
            $bld_name = $bld_dir . "\\msql" . "_" . $cfg{'Build_No'} . "_" . get_date() . $cfg{'MsqlOut'};
            # End of 02nd Mar 2007 changes
              
              
            #$bld_name_MSQL2 = $cfg{'BldSepFold'} . "_" . get_date() . $cfg{'MsqlOut'};
            #$bld_name = $bld_dir . "\\" . $bld_name_MSQL2;
              
            # Added " . $cfg{'prod'} . "_" to have the Product Name in the file name  - By Ashwin Deshmukh on 7th Sept 2006
            #$bld_name = $bld_dir . "\\" . $cfg{'prod'} . "_" . $cfg{'BldSepFold'} . "_" . get_date() . $cfg{'MsqlOut'};
             
            # Added by Ashwin Deshmukh on 27th Sept 2006
            #$bld_path_name_MSQL2 = $bld_name;
              
            # get our file pattern hash for each type of component
            get_patterns($cfg{'MsqlFiles'});
            # Get our list of excluded files and sub-directories if any
            get_msql_excludes();
       }
    }
    elsif ($component eq "CSQLRTN"){
    
        # Commented By Ashwin Deshmukh on 7th Sept 2006
        #6 Modified and added new by Saju Carlos on 02nd Mar 2007 for Mumps filename changes
        # $bld_name = $bld_dir . "\\" . $cfg{'BldSepFold'} . "_" . get_date() . $cfg{'MsqlRtnOut'};
        $bld_name = $bld_dir . "\\csql" . "_" . $cfg{'Build_No'} . "_" . get_date() . $cfg{'MsqlRtnOut'};
        #$bld_name = $bld_dir . "\\" . $cfg{'BldSepFold'} . "_" . $cfg{'Build_No'} . "_" . get_date() . $cfg{'MsqlRtnOut'};
        # End of 02nd Mar 2007 changes
        
        my $source_file = $bld_dir . "\\csql\\cdl\\All\.cdl";
        my $command = 'copy '. $source_file . ' ' . $bld_dir;
        
        system $command;
        
        my $file_name = "csql" . "_" . $cfg{'Build_No'} . "_" . get_date() . "\.cdl";
        
        $command = 'rename ' . $bld_dir . "\\All.cdl " . $file_name;
        system $command;
        
        # Added " . $cfg{'prod'} . "_" to have the Product Name in the file name  - By Ashwin Deshmukh on 7th Sept 2006
        #$bld_name = $bld_dir . "\\" . $cfg{'prod'} . "_" . $cfg{'BldSepFold'} . "_" . get_date() . $cfg{'MsqlRtnOut'};
        
        # Added by Ashwin Deshmukh on 27th Sept 2006
        #$bld_name_MSQL1 = $bld_name;
        #$bld_path_name_MSQL1 = $bld_name;
        
        # get our file pattern hash for each type of component
        get_patterns($cfg{'MsqlRtn'});
        # Get our list of excluded files and sub-directories if any
        get_csql_excludes();
    }
    
    # Commented by Sharad Agarwal on 13th Oct 2006
    #$log_file = $bld_name . ".log";
    $bld_fail = 0;

  #get_excludes($cfg{'components'});

  
  # get our file pattern hash
  #get_patterns($cfg{'components'});
  #get_patterns();

  # Do the extract
  do_build($component);
  
  # Did we fail?
    last if ($bld_fail == 1);
  
  # Reset ourselve and do the next config entry
    $first_out = 1;
    $proc_files = ();
    # Commented by Sharad Agarwal on 13th Oct 2006
    #unlink $log_file;
}

## Do a Mumps build for each key in our config hash
  #
  ## Do the extract
  #do_build($component);
#  

#
## Do we have any GOF files to move? If so then move them
#foreach (@gof_files) {
#  move_file($_);
#}
#
#

# Copy the MSQL.GOF file to someother directory & rename it...
# Added by Ashwin Deshmukh on 27th Sept 2006
if ($bld_fail == 0) {
  if ($cfg{'prod'} eq "RAD") {
    my $to_path = $bld_dir;
    my $file_from_path = $bld_dir."\\msql\\MSQL.GOF";
    my $orginal_file = "MSQL.GOF";
    my $result;
    $command_line = 'copy /Y '.$file_from_path.' '.$to_path;
    $result = system $command_line;
    #copy($file_from_path, $to_path);
    if ((!-e $to_path."\\".$orginal_file) || ($result > 0)) {
      print STDERR ("Warning : Could not copy $orginal_file to $to_path\n0 File(s) Copied.\n");
      # Added by Sharad Agarwal on 13th Oct 2006
      print STDOUT ("Warning : Could not copy $orginal_file to $to_path\n0 File(s) Copied.\n");
    }
    else {
      print STDOUT ("Copied $orginal_file to $to_path\n");
      # Added by Sharad Agarwal on 13th Oct 2006
    }
  }
}
  
# Did we fail our build?
=cut
# Commented by Saju on 19th June,2007
#Added by Sharad Agarwal on 14th Nov. 2006
#Creating a SendMail object passing the SMTP server as an argument. 
#  $sm = new SendMail('mhimail.mhi.onemisys.com');
#  $user_domain = $ENV{'USERDNSDOMAIN'};
#  $user_domain =~ tr/a-z/A-Z/;
# $user_Name = $ENV{'COMPUTERNAME'};
# $user_Name =~ tr/a-z/A-Z/;
# $serverName = "$user_Name\.$user_domain";
=cut


if ($bld_fail == 1)
{
  # Added by Sharad Agarwal on 13th Oct 2006
  print STDERR "\n\n* * * B U I L D  F A I L E D * * *\n";
  print STDOUT "\n\n* * * B U I L D  F A I L E D * * *\n";
  # Added by Sharad Agarwal 0n 14th Nov. 2006
  # Subject Line for the mail.
#  $subject = 'F A I L E D - Product : '.$cfg{'prod'}.' ***'.$cfg{'db'}. ' BUILD***';
}
else
{
  # Added by Sharad Agarwal on 13th Oct 2006
  print STDOUT "\n\n* * * B U I L D  S U C C E S S F U L L Y  C O M P L E T E D * * *\n";
  # Added by Sharad Agarwal 0n 14th Nov. 2006
  # Subject Line for the mail.
  # $subject = 'S U C C E S S F U L - Product : '.$cfg{'prod'}.' ***'.$cfg{'db'}. ' BUILD COMPLETED***';
}

# Added by Sharad Agarwal on 16th Oct. 2006
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


push(@file_output,"\n************Please Check The Build Server For Log Files************\n\n");

open FILEH, "<$log_file" or die "\nUnable to open $log_file\nError: $!\n";
  while (my $line = <FILEH>){
        chomp($line);
    	print "$line\n";
        #Added by Sharad on 14th Nov. 2006
        push(@file_output,$line);
  }

close (FILEH) || die "\nCan't close log file";


=cut
# Commented by Saju on 19th June,2007
# Added by Sharad Agarwal 0n 14th Nov. 2006
# Function call for sending the mail.
if ($Email_Found == 0)
{
  send_email();
}
=cut

#if($outfile = 0)
#if (-e $out_file);   
#if (-e $log_file); 


# No so exit with success.
print("\n\n* * * E N D   O F   O U R   B U I L D * * *\n");
exit 0;  

