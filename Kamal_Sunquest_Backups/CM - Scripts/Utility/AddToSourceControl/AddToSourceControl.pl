#!D:/perl/bin/perl.exe
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
# AddToSourceControl.pl
#   This script adds a hirerchy of files into source control
#   The script is custoosed only for Lab 6x scripts
#
# Usage:
# It is specially made for Lab 6.x make files to be added to source control.
#
# Returns:
#      The creates a text file in the current directory and writes the details.
#
#
#=========================================================================
# Edit history:
#
#	Initial creation:	T Saju Carlos & Sharad Agrawal on 06/14/07
#
#=========================================================================

use strict;
use Cwd;
undef $/;

my $ViewPath = "M:\\agarwal_LAB_SLASH_MHI_int";
#chdir ($ViewPath);

open (IN,"GUI.cfg");
my $GUI_CFG = <IN>;
close (IN);
#print $GUI_CFG;


open(LOG,">Event.log");
print LOG "Added the following files:\n\n";

#my $copy_dir = getcwd;

my $count = 0;
while ($GUI_CFG =~ /(?:omake\,(.+?)\,([^\n]+))/isg)
{
    my ($copied_path,$source_path,$source_file,$temp_file,$command,$target_path,$OutPut_dir,$Target_Dir)="";
    
    #chdir $copy_dir;
    
    $source_path = $1;
    $temp_file = $2;
    $source_path =~ s/LAB_BLD_VIEW/Temp\\Sharad/;

    #$source_path =~ s/\\/\//g; # Convert all backslash to slash 
    $source_path =~ s/[\\\/]$//; # Remove the trailing slash or backslash
    $source_path =~ s/\s+/\ /g;
    $source_file = $source_path."\\".$temp_file;
    
    # Copy the file to local
    #$command = 'xcopy /H /Y /R /K "'.$source_file.'" "."';
    #system $command;
    
    #$copied_path = getcwd;

    $count++;
    print "Source Path is : $source_path\n";
    print "Temp File is : $temp_file\n";

    &CopyToSourceControl($source_path,$source_path,$temp_file);
    print LOG "$count $source_path\\$temp_file\n"; 

}

print LOG "********* End of Log **********";
close (LOG);



sub CopyToSourceControl
{
    my ($Source_path,$copied_path,$file,$CopytoViewPath) = "";
    $Source_path = shift;
    $copied_path = shift;
#    $file = shift;
#    
#    # Go to the view path
    $Source_path =~ s/C\:\\Temp\\Sharad//i;
    $CopytoViewPath = $ViewPath;
    $CopytoViewPath .= $Source_path;
#    #$CopytoViewPath = '"'.$CopytoViewPath.'"';
    
    my $command1= 'cd "'.$CopytoViewPath. '"';
#    system $command1;
#    chdir ($CopytoViewPath);
#
    print "Target Path is : $CopytoViewPath\n\n";
#    my $cur_dir = getcwd;
#
#    # Get the content of the file
#    open(GETCONTENT,"$copied_path/$file");
#    my $copied_content = <GETCONTENT>;
#    close (GETCONTENT);
#    
#    
#    
#    # Step 1) Checkout the parent folder
#    #	> cleartool checkout -nc .
#    my $command = 'cleartool checkout -nc .';
#    system $command;
# 
# 
#    #Step 2) Create the element in the CC
#    #	> cleartool mkelem -c "Makefile" test3.mak
#    $command = 'cleartool mkelem -c "Makefile" '.$file;
#    system $command;
#
#
#    #Now the file is in checkout state,
#    #Step 3) Open the file and write the contents to it.
#    open(CC,">$file");
#    print CC $copied_content;
#    close(CC);
#
#
#    #Step 4) Check in the file 
#    #	> cleartool checkin -nc test3.mak
#    $command = 'cleartool checkin -nc '.$file;
#    system $command;
#
#    #Step 5) Checkin the parent folder
#    #	> cleartool checkin -nc .
#    $command = 'cleartool checkin -nc .';
#    system $command;
#    
#    
#    # remove the file copied from LAB610
#    #$command = 'del '.$copied_path.'/'.$file;
#    #system $command;
#
}

