#!/usr/bin/perl -w
#
# bf_prebuild.pl
#
# This program takes the diff between most recent baseline and it's predecessor using
# cleartool command diffbl -pred -act <baseline>@\<project vob> and copies over
# changed or new components to build directory.
#
# Assumption: There is a view into the stream and component vobs have been mounted.
#
# Edit History:
#
# 1.00  RZD  08/28/2008
# Initial creation.

use strict;
use diagnostics;
use Win32::OLE;
use Cwd;
use File::Basename;
use File::Spec;
use Getopt::Long;
use Date::Simple;

my $DEBUG = 0;

my %myBaseLineActivitieID;
my %myChangeSet;
my @myComponentVobs;
my $myActivityIDList;

my ($myProjectVob,$myVersion,$myBuildDir,$componentVobList,$help );

my $myDate = Date::Simple->new(); #creating new Date object and grabbing todays datemy $myDate = Date::Simple->new(); #creating new Date object and grabbing todays date
$myDate = $myDate->format("%y%m%d"); # formating date in month day year with no spaces
#$myDate = '080905';

print "Instantiating CAL\n" if $DEBUG;
my ($myCCApp) = Win32::OLE->new ("ClearCase.Application") or
        die "Can't create ClearCase application object via call to Win32::OLE->new(): $!";
print "Processing Activity info\n" if $DEBUG;

use constant HELP                        => <<'END_HELP';
Options:
    -p|-ProjectVob         Project Vob you are performing the build on.
    -v|-BuildVersion       Version of the Build.
    -d|-BuildDir           Directory the build is being performed in.
    -c|-ComponentVobs      Comma seperated list of component vobs contained in Project Vob
    
    -help              Display this summary
    -usage             Display a brief usage line
Example:
      bf_prebuild.pl -ProjectVob '@\LAB_PVOB' -BuildVersion '6.4.0.129' -BuildDir 'c:\LAB_BLD_VIEW' -ComponentVobs 'LAB_CS,LAB_M,LAB_CACHE_OBJECTS'
END_HELP

use constant USAGE => 'Usage: '
    . "\n"
    . "testdate.pl [/ProjectVob ProjectVob] [/BuildVersion Version] [/BuildDir Build Directory] [/Component_Vobs Component Vobs]  [-help|-?] [-usage]\n"
    . "\n";



##############################################################################
# Usage       : getActivityIDs();
#
# Purpose     : Get ClearQuest activity ID's for new activities in baseline
#               
# Returns     : Nothing.
#
# Parameters  : N/A
#               
# Throws      : No exceptions.
#
# Comments    : None.
#
# See Also    : N/A
##############################################################################
sub getActivityIDs()
{
    foreach my $myTempVal(@myComponentVobs){
        $myTempVal = "$myTempVal" . "_" .  "$myDate" . "_" . "$myVersion" . "$myProjectVob";
        my $diffActs = `cleartool diffbl -pred -act $myTempVal`;
        #print "\nMyTempVal: $myTempVal\n";
        while($diffActs =~/>>\s(.+)@/g){
            if(!(exists $myBaseLineActivitieID{$1})){
                $myBaseLineActivitieID{$1} = $1;
            }#end (!(exists $myBaseLineActivitieID{$1}))
        } #end while($diffActs =~/>>\s(.+)@/g)
    }#end foreach my $myTempVal(@myComponentVobs)
  #  for my $myTempVals(keys %myBaseLineActivitieID){
   #     my $mytemp2 = $myBaseLineActivitieID{$myTempVals};
   #     if($myActivityIDList){
   #         $myActivityIDList = $myActivityIDList . ',' . $mytemp2 ;
   #     } else {
   #         $myActivityIDList = $mytemp2;
   #     }
        #$myActivityIDList = $myActivityIDList . ',';
  #  }# end foreach my $myTempVal(%myBaseLineActivitieID)
} #end sub getActivityIDs


##############################################################################
# Usage       : getChangeSet();
#
# Purpose     : Gets change set for each activity ID in baseline.
#               
# Returns     : Nothing.
#
# Parameters  : N/A
#               
# Throws      : No exceptions.
#
# Comments    : None.
#
# See Also    : N/A
##############################################################################

sub getChangeSet()
{
    for my $myTempKey (keys (%myBaseLineActivitieID)){
        my $myCurrActID = $myBaseLineActivitieID{$myTempKey} . $myProjectVob;
        my $myCurrAct = $myCCApp->Activity($myCurrActID);
        if (! $myCurrAct ) {
            print "Can not resolve activity info in ClearCase\n";
        }#endif (! $myCurrAct )
        else {
            my $myView = $myCurrAct->NameResolverView();
            #print "\n$myCurrAct\n";
            my $myCurrChangeSet = $myCurrAct->ChangeSet($myView, "False");
            my $myCSCount = $myCurrChangeSet->Count;
            my $myIndex = 1;
            while($myIndex <= $myCSCount){
                my $myVersion = $myCurrChangeSet->Item($myIndex);
                #my $myVersionPath = $myVersion->PathInView('daniels_LAB_6.4_MHU_int');
                my $myVersionPath = $myVersion->ExtendedPath;
                (my $myChangeSetPath, my $temp) = split(/@/,$myVersionPath);
                if(!(exists $myChangeSet{$myChangeSetPath})){
                    $myChangeSet{$myChangeSetPath} = $myChangeSetPath;
                } #end if(!(exists $myChangeSet{$myChangeSetPath}))
                $myIndex++;
            }#end while($myIndex <= $myCSCount)
        }#end else
    }#end foreach my $myTempKey (keys (%myBaseLineActivitieID))        
}#end sub getChangeSet
 
##############################################################################
# Usage       : copyChangeSet();
#
# Purpose     : Copies  change set from M drive to build directory.
#               
# Returns     : Nothing.
#
# Parameters  : N/A
#               
# Throws      : No exceptions.
#
# Comments    : None.
#
# See Also    : N/A    
##############################################################################     
sub copyChangeSet()
{
    my $myOffSet = '3';
    my $myPos;
    
    for my $myTempKey(keys %myChangeSet){
        my $myChangePath = $myChangeSet{$myTempKey};
        #print "My Change Set: $myChangePath\n";
        if(-d $myChangePath){
            $myPos = index($myChangePath, '\\', $myOffSet);
            my $tempDir = $myBuildDir . substr($myChangePath,$myPos);
            my $myCommand = "xcopy /E /Y /I /R  \"$myChangePath\" \"$tempDir\"";
            #my $myCommand = "xcopy /E /Y /I /R  \"$myChangePath\" \"$tempDir\"" .  '>' . ' temp.txt';
            #print "\n MyCommand equals: $myCommand \n";
            my $result = system($myCommand);
            if ($result != 0){
               die "system error: $?";
            }
            #print "\nMy Rusult equals: $result\n";
        }#end if(-d $myChangePath)
        elsif(-e $myChangePath){
            $myPos = index($myChangePath, '\\', $myOffSet);
            my $tempDir = $myBuildDir . substr($myChangePath,$myPos);
            my @tempArray = split(/\\/,$tempDir);
            $tempArray[-1] = "";
            $tempDir = join("\\",@tempArray);
            my $myCommand = "xcopy /Y /R \"$myChangePath\" \"$tempDir\"";
            #my $myCommand = "xcopy /Y /R \"$myChangePath\" \"$tempDir\"" .  '>' . ' temp.txt';
           #print "\n MyCommand equals: $myCommand \n";
           my $result = system($myCommand);
           if ($result != 0){
               die "system error: $?";
           }
           #print "\nMy Rusult equals: $result\n";
        }#end elsif(-e $myChangePath)
        else{
            print "\n In Die\n";
            die "Can't copy over Change set";
        }
            
    }# end foreach my $myTempVal(%myBaseLineActivitieID)
} #end sub copyChangeSet


##############################################################################
# Usage       : main();
#
# Purpose     : Controls flow of program
#               
# Returns     : Nothing.
#
# Parameters  : N/A
#               
# Throws      : No exceptions.
#
# Comments    : None.
#
# See Also    : N/A    
############################################################################## 

sub main
{
    #Setting Command Line Options
    my $options_okay = GetOptions(
    'p|ProjectVob=s'    => \$myProjectVob,
    'v|BuildVersion=s'  => \$myVersion,
    'd|BuildDir=s'      => \$myBuildDir,
    'c|ComponentVobs=s' => \$componentVobList,
    
    'help|?'            => sub{
        warn USAGE;
        warn HELP;
        exit 0;
    },
    'Usage'            => sub {
      warn USAGE;
      exit 0;
    }
    
);
    
    @myComponentVobs = split(/,/,$componentVobList);
    
    &getActivityIDs();
    &getChangeSet();
    &copyChangeSet();
    #return $myActivityIDList;
}# end sub maina


main;
 