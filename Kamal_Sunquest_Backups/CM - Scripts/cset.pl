#!/usr/bin/perl
###########################################################################
#  A script to undo, redo, findmerge, or print an activity
#
#  Created:  05/17/01
#  Author:   David E. Bellagio    dbellagio@us.ibm.com
#
#  Please send all comments, bugs, enhancements to: dbellagio@us.ibm.com
#
#  Update Log:
#  
#  3/3/03 - Dave Bellagio (dbellagio@us.ibm.com)
#  Updated to also perform a redo operation and a print operation.
#  Renamed the script to cset.pl from undo_activity.pl.
#
#  7/31/03 - Dave Bellagio (dbellagio@us.ibm.com)
#  Added a poor man's clearprompt GUI interface.  Included functions
#  from Clearcase.pm.  Added -graphical option for merge.
#
#  6/19/04 - Dave Bellagio (dbellagio@us.ibm.com)
#  Fixed issue with cset info being displayed differently on Unix and Windows
#
#  7/23/04 - Dave Bellagio (dbellagio@us.ibm.com)
#  Worked around buffer overflow with large cset and using -fmt option to lsactivity.
#  From customer feedback, the following two features (thank you patrick.renaud@ericsson.com):
#    1) Renamed move action to redo.  
#    2) Implemented a new operation called findmerge.  This will do a real merge
#       of the cset (not a redo). Used "findmerge" instead of "merge" to 
#       avoid older customers accidentally using a -m option and getting
#       different functionality. 
#
###########################################################################

#--------------------------------------------------------------------------
#  Iteration #1.   Lets just undo an
#  activity's change set by doing a subtractive merge.  Assume that
#  the script needs to be run in a view and that the view must already
#  be set to an activity in the same stream of the activity to be undone.
#
#  Iteration #2.   Lets also redo and print activities.  Note, the redo
#                  uses the additive merge.  No hyperlinks are created
#                  and no other processing occurs outside of what comes
#                  with the merge command.
#
#  Iteration #3.   I need a GUI and more testing of corner cases.
#--------------------------------------------------------------------------
require 5.000;

use Getopt::Long;

$| = 1;

$VERSION = "6.0"; # Workaround bug with 64k limit using -fmt option.  Support regular merge option.  Rename move command to redo
# $VERSION = "5.5"; # Fixed bug with Unix and Windows returning different cset info for directory elements.  This causes problem on Unix.
# $VERSION = "5.4"; # Fixed bug with -print option ignoring current stream when prompting.  How did I miss this!
# $VERSION = "5.3"; # Added support for spaces in change set elements.  How did I miss this!
# $VERSION = "5.2"; # tested on Linux.  Prompts work on Linux


#-----------------------------------------------------------------------
# Set some globals here
#-----------------------------------------------------------------------
if ( $ENV{'OS'} eq "Windows_NT" ) {
   $TMPDIR = $ENV{'TMP'} or $ENV{'TEMP'} or "C:\\temp";
   $DEVNULL = "NUL";
   $SLASH = "\\";
   $QUOTE = "\"";
   open (NETWORK,"net use |");
   while (<NETWORK>) {   
      if ( m/^\s+([A-Z]:)\s+\\\\view\s+/i ) {
         $VIEWROOT = "$1";
      }
   }
   close(NETWORK);
   $COPY = "copy";
   $PWD = "chdir";
} else {
   $TMPDIR = "/tmp";
   $DEVNULL = "/dev/null";
   $SLASH = "/";
   $QUOTE = "'";
   $VIEWROOT = "/view";
   $COPY = "cp";
   $PWD = "pwd";
}
$CLEARTOOL = "cleartool";
$MULTITOOL = "multitool";


# $env_dump = "c:\\env_dump.txt";
# if ( ! open (DUMP, ">$env_dump" )) {
#   die "Can't open file $env_dump: $!\n";
# }
# foreach ( sort(keys %ENV) ) {
#   print (DUMP "$_ = $ENV{$_}\n");
# }
# exit(1);


($NAME, $THISDIR) = ($0 =~ m#^(.*)[/\\]([^/\\]+)$#o) ? ($2, $1) : ($0, '.');

$SYNOPSIS = "$NAME [-help] [-ignore] [-graphical] 
               {-redo | -print | -undo | -findmerge} [activity]";

$ARGUMENTS = "
  help        Displays this message and exits.
  ignore      Ignore check for checked-out files.
  graphical   If specified, will always use the graphical diffmerge tool.
  redo        Will redo the change set specified by activity.
  print       Will print out the change set specified by activity.
  undo        Will undo the change set specified by activity.
  findmerge   Will merge the change set from activity (this is not redo).
  activity    The specified activity-object-selector to redo, print, or undo.
              If not specified, then you will be prompted for an activity.
";

$DESCRIPTION = "
$NAME will redo, print or undo the activity specified by the passed activity-object-selector.
If -ignore is specified, no check will occur to see if you have checkedout 
files in this view.

Undo does a subtractive merge on the cset, so it will only undo the deltas of that activity.
Undo requires that the activity be in the same stream your view is connected to.

Redo will do an additive merge of the cset, and will only redo the deltas of that activity.
Redo requires that the activity be on a different stream than your current view.

Both redo and undo use the merge command, so all requirements of merge are requirements of
redo and undo.  No hyperlink will be created.  Future redos and undos from/to the same stream
will function just like an underlying merge would.

Print simply prints out the change set info.

Findmerge will do a regular merge from the activity to the stream.   Note, this will draw
a hyperlink and process prior history of the activity's change set.  This is not the same
as redo.  Redo does an additive merge of the activity's cset.  Undo does a subtractive merge.
Findmerge requires that activity be on a different stream than your view.

C-Set Version = $VERSION

";
# Commented by Kamalakannan Sanjeevan on 30th Jan 2008
# Modified to skip the restun status values -undo and -findmerge options
# Added the next line and commented the original line 
$return_status = GetOptions("help","ignore", "graphical", "redo", "print");
#$return_status = GetOptions("help","ignore", "graphical", "redo", "undo", "findmerge", "print");
usage(1) if ($opt_help);

usage(2) if ( ! $return_status );

if ( @ARGV > 1 ) {
  print (STDERR "$NAME: One, and only one activity must be specified\n");
  usage(2);
}

# Added by Kamalakannan Sanjeevan on 30th Jan 2008
# The changes are made to skip checking for -undo and -findmerge functionalities
# Added the next 2 lines and commented the original 2 lines

if ( ( $opt_redo + $opt_print ) > 1 ) {
   print (STDERR "$NAME: Must specify only one of -redo or -print\n");
#if ( ($opt_undo + $opt_redo + $opt_print + $opt_findmerge) > 1 ) {
#   print (STDERR "$NAME: Must specify only one of -redo, -print, -undo, or -findmerge\n");
   usage(2);
}

# Added by Kamalakannan Sanjeevan on 30th Jan 2008
# The changes are made to skip checking for -undo and -findmerge functionalities
# Added the next 2 lines and commented the original 2 lines

if ( ! $opt_redo and ! $opt_print ) {
   print (STDERR "$NAME: Must specify one of -redo or -print\n");
#if ( ! $opt_undo and ! $opt_redo and ! $opt_findmerge and ! $opt_print ) {
#   print (STDERR "$NAME: Must specify one of -redo, -print, -undo, or -findmerge\n");
   usage(2);
}
if ( $opt_redo ) {
   $operation = "redo";
}
# Commented by Kamalakannan Sanjeevan on 30th Jan 2008
# Commented the next 5 lines to disable the -undo and -findmerge option 
#elsif ( $opt_undo ) {
#   $operation = "undo";
#} elsif ( $opt_findmerge ) {
#   $operation = "findmerge";
#}
else {
   $operation = "print";
}

if ( $opt_graphical ) {
   $graphical = "-graphical";
} else {
   $graphical = "";
}


#-------------------------------------------
# Verify in view/VOB
#
# Print only needs to be in a view context
#-------------------------------------------
$view_tag = GetCurView();
if ( ! $view_tag ) {
   fatal ("Must be in a ClearCase view");
}

if ( ! $opt_print ) {
   $vob_tag = GetCurVOB();
   if ( ! $vob_tag ) {
      fatal ("Must be in a ClearCase VOB");
   }
}


if ( @ARGV ) {
   $activity = shift(@ARGV);
}

# Commented by Kamalakannan Sanjeevan on 30th Jan 2008
# Commented the next 3 lines to disable the -undo option 
#elsif ( $opt_undo ) {
#   $activity = prompt_for_activity();
#  print "\nActivity is $activity\n";
# }
else {
   ($project, $pvob) = prompt_for_project();
#   print ("\nProject = $project, PVOB = $pvob\n");
   $stream = prompt_for_stream($project,$pvob);
#   print ("\nStream = $stream\n");
   $activity = prompt_for_activity($stream,$pvob);
#   print ("\nActivity = $activity\n");
}

#--------------------------------------------------
# Verify activity passed in is an activity
#--------------------------------------------------
$cmd = "lsactivity -short $activity";
$work_activity = ClearTool(cmd => \$cmd);
if ( ! $work_activity ) {
   fatal ("$activity is not an activity");
}

if ( $opt_print ) {
   #--------------------------------------------------
   #  Just print the cset and exit
   #--------------------------------------------------
   #  Get change set
   #---------------------------------------------------
   @cset = GetCset(activity => $activity);
   if ( $cset[0] eq "##ERROR##" ) {
      fatal ("Could not get cset info on activity $activity");
   }
   print ("Change Set for activity $activity\n\n");
   foreach ( @cset ) {
      next if ( ! "$_" );
      print ("$_\n");
   }
   exit(0);
}

#--------------------------------------------------
# For undo and redo, verify we are in an activity
#--------------------------------------------------
$cmd = "lsactivity -cact -short";
$cur_activity = ClearTool(cmd => \$cmd);
if ( ! $cur_activity ) {
   fatal ("Must be in an activity to accept $operation of activity $activity");
}
#-------------------------------------------------
# Can't redo or undo the current activity
#-------------------------------------------------
if ( $cur_activity eq $work_activity ) {
   fatal ("Can't $operation the current activity");
}


$cmd = "lsstream -short";
$stream = ClearTool(cmd => \$cmd);
$cmd = "lsactivity -fmt \"\%[stream]p\\n\" $activity";
$act_stream = ClearTool(cmd => \$cmd);
if ( $? ) {
   fatal ("$activity is not an activity");
}
# Commented by Kamalakannan Sanjeevan on 30th Jan 2008
# Commented the next if tag to disable the -undo option 
#if ( $opt_undo ) {
   #------------------------------------------------
   #  Verify stream is the same as activity's stream
   #------------------------------------------------
#  if ( $stream ne $act_stream ) {
#     print (STDERR "$NAME: Current view's stream does not match activity's stream\n");
#     fatal ("$stream is not equal to $act_stream");
#  }
#} else {
   #----------------------------------------------------
   #  Verify stream is not the same as activity's stream
   #----------------------------------------------------
#   if ( $stream eq $act_stream ) {
#      print (STDERR "$NAME: Current view's stream matches activity's stream\n");
#      fatal ("$stream is equal to $act_stream");
#   }
#}   

#-----------------------------------------
#  Verify no checkouts are here
#-----------------------------------------
if ( ! $opt_ignore ) {
   #-------------------------------------------------
   # make sure nothing is checked-out to view
   #----------------------------------------------------
   # For LT, you might have to set CLEARCASE_AVOBS here
   #
   # $ENV{'CLEARCASE_AVOBS'} = "\\vob1,\\vob2,\\vob3";
   #----------------------------------------------------
   $cmd = "lsco -cview -short -avobs";
   @co_files = ClearTool(cmd => \$cmd);
   if ( @co_files ) {
      print (STDERR "$NAME: There are files checked out to this view\n");
      fatal ("Can't proceed until these files are checked in:\n" . join("\n",@co_files) . "\n");
   }
}

#---------------------------------------------------
# Get change set
#---------------------------------------------------
@cset = GetCset(activity => $activity);
if ( $cset[0] eq "##ERROR##" ) {
   fatal ("Could not get cset info on activity $activity");
}

#----------------------------------------------
# Check change set to see if any checkouts
# are in there.  If so, abort
#----------------------------------------------
if ( grep /CHECKEDOUT\.\d+$/ , @cset ) {
   fatal ("There are currently checkouts against activity $activity");
}

#------------------------------------------------
# sort forward for redo and reverse for undo
#------------------------------------------------
# Commented by Kamalakannan Sanjeevan on 30th Jan 2008
# Commented the next 3 lines to disable reversing used by -undo option 
#if ( $opt_undo ) {
#   @cset = reverse @cset;
#}

#------------------------------------------------
# Redo/Undo the activity in this view's activity
#------------------------------------------------
foreach ( @cset ) {
   next if ( ! "$_" );
   # Commented by Kamalakannan Sanjeevan on 30th Jan 2008
   # Commented the next 3 lines to skip printing version based on the option 
   #if ( $opt_undo ) {
   #   print ("$NAME: Subtracting version $_\n");
   #} else {
   # Added by Kamalakannan Sanjeevan on 30th Jan 2008
   # Added the next line to printing version for the -redo option
   if ($opt_redo) {
      print ("$NAME: Inserting version $_\n");
   } 
  
   #------------------------------------
   # Initialize some variables
   #------------------------------------
   $discard_next_entry = 0;
   undef @element_name;

   #----------------------------------------------
   #  First do a split to get most of element name
   #----------------------------------------------
   ($element, $version) = split /\@\@/;

   #-----------------------------------------------
   # Then count number of main's on the right side.
   #-----------------------------------------------
   @mains = split /[\/\\]main[\/\\]/, $version;
   if ( @mains == 2 ) {
      #--------------------------------------
      #  Normal looking cset entry
      #--------------------------------------
   } else {
      #-------------------------------------------------
      # Looks like a version extended looking cset entry
      #---------------------------------------------------
      # Already got the front element, should be directory
      #--------------------------------------------------- 
      # Ignore the first entry, already have it from above
      #-----------------------------------------------------
      shift(@mains);
      #-----------------------------------------------------
      # get the last entry and add /main onto it
      #-----------------------------------------------------
      $version = pop(@mains);
      if ( $version =~ m#^main[/\\]#o ) {
         #-------------------------------------------
         # Looks like someone added a main directory
         #-------------------------------------------
         $version = "$SLASH${version}";
         unshift(@element_name, "main");
         $discard_next_entry = 1;
      } else {
         $version = "${SLASH}main${SLASH}$version";
      }         
      #-----------------------------------------------------------
      # Loop through from bottom, and build up element and version
      #-----------------------------------------------------------
      while ( @mains ) {
         $entry = pop(@mains);
         if ( $discard_next_entry ) {
            $discard_next_entry = 0;
            #--------------------------------------
            #   First check for another main
            #--------------------------------------
            if ( $entry =~ m#^main[/\\]#o ) {
               #-------------------------------------------
               # Looks like someone added a main directory
               #-------------------------------------------
               unshift(@element_name, "main");
               $discard_next_entry = 1;
            }
         } else {
            #----------------------------------------------
            # element name should be at end
            #----------------------------------------------
            @parts = split /[\/\\]/,$entry;
            unshift(@element_name, $parts[$#parts]);
            #--------------------------------------------
            # check for main again
            #--------------------------------------------
            if ( $parts[0] eq "main" ) {
               unshift(@element_name, "main");
               $discard_next_entry = 1;
            }
         }       
      }
      #-----------------------------------------------------------
      #  Build element name
      #-----------------------------------------------------------
      $element = "$element${SLASH}" . join(${SLASH}, @element_name);
   }
   #----------------------------------------------------
   # time to checkout if not already done
   #----------------------------------------------------
   if ( ! $element_checkedout{"$element"} ) {
      #-------------------------------------
      # Checkout the element
      #-------------------------------------
      $cmd = "co -c \"$NAME performing $operation of activity $activity\" ${QUOTE}${element}${QUOTE}";
# print ("\ncmd = $cmd\n");
      if ( ClearTool(cmd => \$cmd, output => 'status') ) {
         fatal ("Can't checkout $element");
      }
      $element_checkedout{"$element"} = 1;
   }

   #-------------------------------------
   # Subtract or add the version.
   # 6.0 - added a regular merge
   #-------------------------------------
   # Commented by Kamalakannan Sanjeevan on 30th Jan 2008
   # Commented the next 7 lines to skip performing merge based on -undo and -findmerge option 
   #if ( $opt_undo ) {
   #   $cmd = "merge -to ${QUOTE}$element${QUOTE} $graphical -delete -nc -version $version";
   #   $message = "Can't perform subtractive merge on ${QUOTE}$element${QUOTE} of version $version";
   #} elsif ( $opt_findmerge ) {
   #   $cmd = "merge -to ${QUOTE}$element${QUOTE} $graphical -nc -version $version";
   #   $message = "Can't perform a regular merge on ${QUOTE}$element${QUOTE} of version $version";
   #} else {
   # Added by Kamalakannan Sanjeevan on 30th Jan 2008
   # Added the next line to perform merge based on -redo option
   if ($opt_redo) {
      $cmd = "merge -to ${QUOTE}$element${QUOTE} $graphical -insert -nc -version $version";
      $message = "Can't perform additive merge on ${QUOTE}$element${QUOTE} of version $version";
   }
   if ( ClearTool(cmd => \$cmd, output => 'status') ) {
      fatal ("$message");
   }   
}

#-----------------------------------------------------------
#  Leave files checkedout
#-----------------------------------------------------------
print ("\n$NAME: Successful $operation of activity $activity into activity $cur_activity\n");
print ("$NAME: Please test before checking in elements\n");

exit(0);

#---------------------------------------------------------
# print out help if needed
#---------------------------------------------------------
sub usage {
   my ($level) = @_;

   $level = 2 unless ( $level =~ /^\d+$/o );

   print "\nUsage: ${SYNOPSIS}\n";
   print "\nArguments:${ARGUMENTS}${DESCRIPTION}\n" unless ( $level > 1 );
   exit($level);
}


#---------------------------------------------------------
#  Prompt for activity to use
#---------------------------------------------------------
sub prompt_for_activity {
   my ($stream, $pvob) = @_;

   my $cmd;
   my @choicelist;
   my @activities;
   my $curact;
   my $items;
   my $activity;
   my $headline;
   my $crm_id;
   my $activity_string;
   my $cmd_result;

   my $outfile = "${TMPDIR}${SLASH}cprompt.txt";

   #-----------------------------
   # Lets get the activities
   #-----------------------------

   #--------------------------------------------------------------------------------------------------
   #  We are going to get the ID's and headlines and
   #  prompt with headline or ID and headline if CRM enabled
   #
   # All the format options here of -fmt \"\%[activities]\\n:::\%[crm_record_id]p:::\%[headline]p\\n\"
   # return something like this:
   #
   # SAMPL00000055:::SAMPL00000055:::rebase alex_WebCatalog on 8/28/2003 5:57:14 PM.
   #
   # If the stream was not CRM enabled it would return something like this:
   #
   # redo_test3_bugfix::::::redo_test3_bugfix
   #--------------------------------------------------------------------------------------------------
   if ( $stream ) {
      #-----------------------------------------------------
      # Must be a redo
      #-----------------------------------------------------
      $cmd = "lsactivity -fmt \"\%[activities]\\n:::\%[crm_record_id]p:::\%[headline]p\\n\" -in stream:$stream\@$pvob";
  } else {
      #-----------------------------------------------------
      # Must be an undo.  Get current activity so not to
      # show as a valid candidate.
      #-----------------------------------------------------
      $cmd = "lsactivity -fmt \"\%[activities]\\n:::\%[crm_record_id]p:::\%[headline]p\\n\" -cact";
      $curact = ClearTool(cmd => \$cmd);
      if ( $? ) {
         fatal("Can't execute cleartool $cmd");
      }
      $cmd = "lsactivity -fmt \"\%[activities]\\n:::\%[crm_record_id]p:::\%[headline]p\\n\"";
   }
   @activities = ClearTool(cmd => \$cmd);
   if ( $? ) {
      fatal("Can't execute cleartool $cmd");
   }
   
   foreach $activity_string ( @activities ) {
      next if ( $activity_string eq $curact );
      #-------------------------------------------------------
      # break out into pieces and build choicelist accordingly
      #-------------------------------------------------------
      ($activity,$crm_id,$headline) = split(/:::/, $activity_string);
      if ( $activity ne $crm_id ) {
         #----------------------------------------------
         # Just prompt with activity
         #----------------------------------------------
         push(@choicelist,"$QUOTE$activity$QUOTE");
      } else {
         if ( ! $headline ) {
            #------------------------------------------------------------------
            # Must be a pre-2003 install.  Use lsact to
            # get headline
            #
            # Format is:
            # 18-Nov-03.00:20:36  CLSIC00000120  pat   "Need to add new stuff"
            #------------------------------------------------------------------
            $cmd = "lsactivity $activity";
            $cmd_result = ClearTool(cmd => \$cmd);
            if ( $? ) {
               fatal("Can't execute cleartool $cmd");
            }
            chomp($cmd_result);
            if ( $cmd_result =~ /\S+\s+\S+\s+\S+\s+\"(.*)\"\s*$/o ) {
               $headline = $1;
            }
         }
         #------------------------------------------------
         # In headline, 
         # replace comma's with a semi-colon as clearprompt
         # won't process commas in a list
         #------------------------------------------------
         $headline =~ s/,/\;/g;
         #------------------------------------------------
         # Also, preserve any quotes in headline
         #------------------------------------------------
         $headline =~s /$QUOTE/$QUOTE$QUOTE/g;
         #------------------------------------------------
         # Prompt with activity: headline
         #------------------------------------------------
         push(@choicelist,"$QUOTE$activity: $headline$QUOTE");
      }
   }

   if ( ! @choicelist ) {
      if ( $stream ) {
         #---------------------------------------------
         # No activites in stream to redo
         #---------------------------------------------
         fatal("No candidate activities to redo in stream $stream");
      } else {
         #---------------------------------------------
         # No activites in view to undo
         #---------------------------------------------
         fatal("No candidate activities to undo in view $view_tag");
      }
   }

   if ( @choicelist == 1 ) {
      $items = "$choicelist[0]";
   } else {              
      $items = join(",", @choicelist);
   }

   $cmd = "clearprompt list -outfile $outfile -items $items -prompt \"Activities in view $view_tag\" -prefer_gui";

# $env_dump = "c:\\env_dump.txt";
# if ( ! open (DUMP, ">$env_dump" )) {
#   die "Can't open file $env_dump: $!\n";
# }
# foreach ( sort(keys %ENV) ) {
#   print (DUMP "$_ = $ENV{$_}\n");
# }
# print (DUMP "\n\ncmd = $cmd\n");
# print (DUMP "\noutfile = $outfile\n");
# print (DUMP "\nitems = $items\n");
# close (DUMP);
# exit(1);

   system($cmd);
   if ( $? ) {
      exit(1);
   }
   #--------------------------
   # get value in file
   #--------------------------
   if ( ! open(FILE,"<$outfile") ) {
      fatal("Can't open file $outfile for reading: $!");
   }
   chomp($activity = <FILE>);

   if ( $activity =~ /^(\S+):\s+\S+/o ) {
      #----------------------------------------
      # Was a formatted activity: headline
      #----------------------------------------
      $activity = $1;
   }

   close(FILE);
   unlink("$outfile");

   return($activity);
}


#---------------------------------------------------------
#  Prompt for stream to use
#---------------------------------------------------------
sub prompt_for_stream {
   my ($proj, $pvob) = @_;

   my $cmd;
   my @choicelist;
   my @streams;
   my $items;
   my $stream;
   my $curstream;
   my $outfile = "$TMPDIR${SLASH}cprompt.txt";
   local ($_);


   #----------------------------------------------------
   #  Need the current stream
   #----------------------------------------------------
   $cmd = "lsstream -short -cview";
   $curstream = ClearTool(cmd => \$cmd);
   if ( $? ) {
      fatal("Can't execute cleartool $cmd\n");
   }
   if ( ! $curstream ) {
      fatal("Can't find current stream\n");
   }

   #-------------------------------------
   # Lets get the streams in the project
   #-------------------------------------
   $cmd = "lsstream -short -in project:$proj\@$pvob";

   @streams = ClearTool(cmd => \$cmd);
   if ( $? ) {
      fatal("Can't execute cleartool $cmd\n");
   }

   #---------------------------------------------------
   # If this is a redo/findmerge operation, 
   # don't allow current stream as a selection.
   #---------------------------------------------------
   # Loop through streams
   #---------------------------------------------------
   foreach $stream ( @streams ) {
      # Commented by Kamalakannan Sanjeevan on 30th Jan 2008
      # Commented the next line and added a new line to skip checking for -findmerge option 
      #if (( $stream eq $curstream ) and ( $opt_redo or $opt_findmerge )) {
      if (( $stream eq $curstream ) and ( $opt_redo )) {
         next;
      } else {
         push(@choicelist,"$QUOTE$stream");
      }
   }

   if ( ! @choicelist ) {
      #---------------------------------------------
      # No streams, die
      #---------------------------------------------
      fatal("No streams found in project $proj suitable for a $operation operation");
   }

   if ( @choicelist == 1 ) {
      $items = "$choicelist[0]";
   } else {              
      $items = join("$QUOTE,", @choicelist);
   }
   $items = $items . "$QUOTE";

   $cmd = "clearprompt list -outfile $outfile -items $items -prompt \"Streams in project $proj\" -prefer_gui";

   system($cmd);
   if ( $? ) {
      exit(1);
   }
   #--------------------------
   # get value in file
   #--------------------------
   if ( ! open(FILE,"<$outfile") ) {
      fatal("Can't open file $outfile for reading: $!");
   }
   chomp($stream = <FILE>);


   close(FILE);
   unlink($outfile);

   return($stream);
}



#---------------------------------------------------------
#  Prompt for project to use
#---------------------------------------------------------
sub prompt_for_project {
   my $cmd;
   my @choicelist;
   my @projects;
   my @lines;
   my $items;
   my $project;
   my $pvob;
   my $outfile = "$TMPDIR${SLASH}cprompt.txt";
   local ($_);


   #----------------------------------------------------
   #  Need the PVOB, lets try describe and get AdminVOB
   #----------------------------------------------------
   $cmd = "describe vob:.";
   @lines = ClearTool(cmd => \$cmd);
   if ( $? ) {
      fatal("Can't execute cleartool $cmd\n");
   }
   while ( @lines ) {
      $_ = shift(@lines);
      if ( /^\s+project\s+VOB/o ) {
         $pvob = ".";
         last;
      }
      if ( /^\s+AdminVOB\s+->\s+vob:(\S+)/o ) {
         $pvob = $1;
         last;
      }
   }
   if ( ! $pvob ) {
      fatal("Can't find PVOB\n");
   }

   #--------------------------------
   # Lets get the projects
   #-----------------------------
   $cmd = "lsproject -short -invob $pvob";
   @projects = ClearTool(cmd => \$cmd);
   if ( $? ) {
      fatal("Can't execute cleartool $cmd\n");
   }
   
   #---------------------------------------------------
   # Loop through projects
   #---------------------------------------------------
   foreach $project ( @projects ) {
      push(@choicelist,"$QUOTE$project");
   }

   if ( ! @choicelist ) {
      #---------------------------------------------
      # No projects, die
      #---------------------------------------------
      fatal("No projects found in PVOB $pvob\n");
   }

   if ( @choicelist == 1 ) {
      $items = "$choicelist[0]";
   } else {              
      $items = join("$QUOTE,", @choicelist);
   }
   $items = $items . "$QUOTE";
 
   $cmd = "clearprompt list -outfile $outfile -items $items -prompt \"Projects in PVOB $pvob\" -prefer_gui";

#   print ($cmd);

   system($cmd);
   if ( $? ) {
      exit(1);
   }
   #--------------------------
   # get value in file
   #--------------------------
   if ( ! open(FILE,"<$outfile") ) {
      fatal("Can't open file $outfile for reading: $!");
   }
   chomp($project = <FILE>);


   close(FILE);
   unlink($outfile);

   return("$project","$pvob");
}


#----------------------------------------------------
#  Fatal error, clearprompt with message and exit
#----------------------------------------------------
sub fatal {
   my ($mes) = @_;

   $cmd = "clearprompt proceed -type error -default abort -mask abort -prompt \"$NAME: $mes\" -prefer_gui";

#    print ($cmd);

   system($cmd);
   exit(1);
}

  
#-------------------------------------------------------------------------
#
#  GetCset - Get change set versions of Activity and return as a list.
#          
#  Example:
#
#      @cset = GetCset(activity => $activity);
#      foreach ( @cset ) {
#         print ("$_ is a change set version of $activity\n");
#      }
#      
#  Parameters:
#
#      activity - If specified, will return the cset for that activity
#                 If not specified, will return the cset for the current activity
#
#  Side Effects:
#
#      If there is no current activity, then an empty list will be returned.
#      If an invalid activity is passed in, a list containing ##ERROR## is returned.
#      I needed to fixup the output of the cset to be consistent across Unix and
#      windows.  Otherwise, Unix does not render directories with a ., but 
#      windows does.
#
#  Return Value:
#
#      A list of change set versions.
#      If an invalid activity is passed in, a list containing ##ERROR## is returned.
#
#  Author:
#    David E. Bellagio (dbellagio@us.ibm.com)
#
#-------------------------------------------------------------------------
sub GetCset {
   my %args = (
      'activity' => "",
      @_,
   );

   #-----------------------------------------------
   # Use lsactivity or describe to get cset as
   # -fmt does not support cset option yet.
   # Maybe in 4.2.
   #
   # Version 5.3 - Note, need to use Cp modifier
   # to detect spaces in filenames.  Don't know
   # if this is in 2002 or not.  Will check.
   #
   # Version 6.0.  remove -fmt option to avoid
   # buffer overflow with large csets at 64k.
   # Go back to using describe and parse.
   #-----------------------------------------------
   my $cmd = "lsactivity -long";
#   my $cmd = "lsactivity -fmt \"%[versions]Cp\"";
   my @cset;
   my $ver;
   my $ele;
   my $verstr;
   my @new_cset;

   #--------------------------------------------
   # process any supported options
   #--------------------------------------------
   if ( $args{'activity'} ) {
      $cmd = "$cmd $args{'activity'}";
   } else {
      $cmd = "$cmd -cact";
   }

#   my ($result) = ClearTool(cmd => \$cmd);
   my (@result) = ClearTool(cmd => \$cmd);
   if ( $? ) {
      push (@cset, "##ERROR##");
      return (@cset);
   }

#   @cset = split(/,\s/,$result);
   #----------------------------------------------------
   # 6.0 - Need to loop through the output and parse for
   # the cset.  This will avoid the 64k buffer problem
   #----------------------------------------------------
   local($_);
   my ($cset_found) = 0;

   foreach (@result) {
      if ( $cset_found ) {
         last if ( /^\s*clearquest record id:/ );
         last if ( /^\s*$/ );
         if ( /^\s*(\S.*)$/ ) {
            push(@cset, $1);
         }
      } elsif (/^\s*change set versions:\s*$/) {
         $cset_found = 1;
      }
   }

   #-----------------------------------------------------------------------
   # If Unix, format the cset to avoid problem
   #-----------------------------------------------------------------------
   if ( $ENV{'OS'} ne "Windows_NT" ) {
      #----------------------------------------------------------------------
      #  For directory elements, make sure they are formatted with a 
      #  \. or /. at the end.   Windows returns info like this, but Unix
      #  does not.   And, this causes a problem for the cset script.
      #----------------------------------------------------------------------
      foreach $ver ( @cset ) {
         ($ele, $verstr) = split("\@\@", $ver);
         if ( -d "$ele" ) {
            #----------------------------------------------------------------
            # Found a directory
            #----------------------------------------------------------------
            if ( $ele =~ m#^(.*)[/\\]([^/\\]+)$#o ) {
               if ( $2 ne "." ) {
                  $ele = "$ele${SLASH}.";
               }
            }
            push (@new_cset, "$ele\@\@$verstr");
         } else {
            #-------------------------------------------
            # cset should be OK, just put back in list
            #-------------------------------------------
            push (@new_cset, "$ver");
         }
      }
      return(sort(@new_cset)); 
   } else {
      #---------------------------------------------
      # On Windows just sort and return
      #---------------------------------------------
      return(sort(@cset));
   }
}


#-------------------------------------------------------------------------
#
#  GetCurView - Get current view tag.  Return a string.
#
#  Example:
#
#      $view_tag = GetCurView();
#      if ( ! $view_tag ) {
#         die "Not in a ClearCase view";
#      }
#      
#  Parameters:
#
#      None.
#
#  Side Effects:
#
#      None.
#
#  Return Value:
#
#      View tag - if you are in a view.
#      ()       - if you are not.
#
#  Author:
#    David E. Bellagio (dbellagio@us.ibm.com)
#
#-------------------------------------------------------------------------
sub GetCurView {
   my $cmd = "pwv -short";

   my ($result) = ClearTool(cmd => \$cmd);
   chomp($result);
   if ( $result =~ /^\s*\*+\s*NONE\s*\*+\s*$/o ) {
      return();
   }
   $result;
}


#-------------------------------------------------------------------------
#
#  GetCurVOB - Get the current VOB tag.  Return a string.
#
#  Example:
#
#      $view_tag = GetCurView();
#      if ( ! $view_tag ) {
#         die "Not in a ClearCase view";
#      }
#      $vob_tag = GetCurVOB();
#      if ( ! $vob_tag ) {
#         die "Not in a ClearCase VOB";
#      }
#      $path = "I:\\my_vob";
#      $vob_tag = GetCurVOB(path => "$path");
#      if ( ! $vob_tag ) {
#         die "I:\\my_vob is not a valid VOB path";
#      }
#      
#  Parameters:
#
#      path - A valid VOB path.  If used, will return the VOB tag of this
#             path, not the current path.
#
#  Side Effects:
#
#      The current directory is used for path, if none is specified.
#
#  Return Value:
#
#      VOB tag  - if you are in a VOB.
#      ()       - if you are not.
#
#  Author:
#    David E. Bellagio (dbellagio@us.ibm.com)
#
#-------------------------------------------------------------------------
sub GetCurVOB {
   my %args = (
      'path' => ".",
      @_,
   );

   my $cmd = "describe -short vob:$args{'path'}";

   my (@result) = ClearTool(cmd => \$cmd);
   $result[0];
}


#-------------------------------------------------------------------------
#
#  ClearTool - Execute a cleartool command, return status or output.
#
#  Example:
#
#      $cmd = "lsstorage -view -host $ENV{'COMPUTERNAME'}";
#      @viewstorage = ClearTool(cmd => \$cmd);
#      if ( $? ) {
#         die "Can't execute command $cmd\n";
#      }
#
#      $cmd = "co -nc $file";
#      if ( ClearTool(cmd => \$cmd,output => 'status') ) {
#         die "Can't checkout file $file with command $cmd\n";
#      }
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
#    David E. Bellagio (dbellagio@us.ibm.com)
#
#-------------------------------------------------------------------------
sub ClearTool {
   my %args = (
      'output' => "output",
      @_,
   );
   my $type = ref($args{'cmd'}) or fatal("Reference to cleartool command not passed to ClearTool");    
   local($_);
   
   if ( $args{'output'} =~ /status/o ) {
      system("$CLEARTOOL ${$args{'cmd'}}");
      $? / 256;
   } else {
      $_ = `$CLEARTOOL ${$args{'cmd'}}`;
      chomp($_);
      if ( wantarray ) {
         split("\n");
      } else {
         $_;
      }
   }
} 

