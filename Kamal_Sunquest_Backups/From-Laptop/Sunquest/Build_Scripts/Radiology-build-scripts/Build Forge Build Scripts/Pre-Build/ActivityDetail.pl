#!/usr/bin/perl -w
#
# ActivityDetail.pl
#
# Program gets the details of each activity for BOM in clearcase.
# 
# 
#
# Assumption: There is a view into the stream and component vobs have been mounted.
#
# Edit History:
#
# 1.00  RZD  09/19/2008
# Initial creation.

use strict;
use Spreadsheet::WriteExcel;
use Win32::OLE;
use Getopt::Long;
use Spreadsheet::WriteExcel;
use Date::Simple;
#require Font::TTFMetrics;
#Start: Constant Declrations
use constant CQ_LOGIN                    => 'auto_delivery';
use constant CQ_PASSWD                   => 'clearquest';
use constant CQ_RECORD_TYPE              => 'Defect';
use constant CQ_RECORD_TYPE_2            => 'UCMUtilityActivity';
use constant AD_PRIVATE_SESSION          => '2';
use constant EMPTY_STR                   => q{};
use constant HELP                        => <<'END_HELP';
Options:
    -c|-CQDataBase         ClearQuest Data base
    -d|-ProjectVob         Project Vob
    -l|-CompositVobList    Comma Seperated List of Composit Vobs
    -p|-Product            Name of the product we are pulling the report for
    -b|-BaseLineName       Name of the Base Line
    -i|-IntegrationStream  Integration Stream
    -v|-Version            Version Number
    
    -help              Display this summary
    -usage             Display a brief usage line
Example:
      ActivityDetail.pl -CQDataBase PHAZ1 -ProjectVob @\scenario2.5_pvob -CompositVobList MOBILE_TRANSFUSION_MGR_COMPOSITE,MOBILE_COMMON_MGR_COMPOSITE  -Product BUILDFORGE_TEST -BaseLineName LAB_6.3.0.99_03052008 -IntegrationStream BUILDFORGE_TEST_INT -Version 6.3.0.99
END_HELP

use constant USAGE => 'Usage: '
    . "\n"
    . "ActivityDetail.pl [/CQDataBase CQDataBase] [/CompositVobList  CompositVobList] [/Product Product] [/BaseLineName Baseline] [/IntegrationStream IntStream] [/Version BuildVersion]  [-help|-?] [-usage]\n"
    . "\n";
#End: Constant Declrations



my %myChangeSet;
my %myBaseLineActivitieID;
my $cqActivityID;
my $DEBUG = 0;
my $cqActivitiesIDList;
my $myProjectVob;
my $cqDatabase; 
my $baseLineLabel;

my $baselineActivityFileHTML;
my $baselineActivityFileExcel;
my $product;
my $intStream;
my $currVer;
my $myHeadLine;
my $myID;
my $myOwner;
my $myState;
my $myCR;
my $CompositVobList;
my @myCompositVobArray;

#EXCEL Spreadsheet variables
my $workbook;
my $worksheet;
my $headerFormat;
my $cellFormat;
my $currCellNum;

my $myDate = Date::Simple->new(); #creating new Date object and grabbing todays datemy $myDate = Date::Simple->new(); #creating new Date object and grabbing todays date
$myDate = $myDate->format("%y%m%d"); # formating date in month day year with no spaces

print "Instantiating CAL\n" if $DEBUG;
my ($myCCApp) = Win32::OLE->new ("ClearCase.Application") or
    die "Can't create ClearCase application object via call to Win32::OLE->new(): $!";
print "Processing Activity info\n" if $DEBUG;

# Create the ClearQuest session object.
my ($cqSession) = Win32::OLE->new('ClearQuest.Session') or
    die "Can't create ClearQuest application object via call to Win32::OLE->new(): $!";
    


# Log onto the session
#$cqSession->UserLogon(CQ_LOGIN , CQ_PASSWD, "$cqDatabase", AD_PRIVATE_SESSION, EMPTY_STR);


############################EXCEL FORMATTING: START########################################



###############################################################################
#
# This function uses an external module to get a more accurate width for a
# string. Note that in a real program you could "use" the module instead of
# "require"-ing it and you could make the Font object global to avoid repeated
# initialisation.
#
# Note also that the $pixel_width to $cell_width is specific to arial. For
# other fonts you should calculate appropriate relationships. A future verison
# of S::WE will provide a way of specifying column widths in pixels instead of
# cell units in order to simplify this conversion.
#
sub string_width {

    require Font::TTFMetrics;

    my $arial        = Font::TTFMetrics->new('c:\windows\fonts\arial.ttf');

    my $font_size    = 10;
    my $dpi          = 96;
    my $units_per_em = $arial->get_units_per_em();
    my $font_width   = $arial->string_width($_[0]);

    # Convert to pixels as per TTFMetrics docs.
    my $pixel_width  = 6 + $font_width *$font_size *$dpi /(72 *$units_per_em);

    # Add extra pixels for border around text.
    $pixel_width  += 6;

    # Convert to cell width (for Arial) and for cell widths > 1.
    my $cell_width   = ($pixel_width -5) /7;

    return $cell_width;

}



###############################################################################
###############################################################################
#
# Functions used for Autofit.
#

###############################################################################
#
# Adjust the column widths to fit the longest string in the column.
#
sub autofit_columns {

    my $worksheet = shift;
    my $col       = 0;

    for my $width (@{$worksheet->{__col_widths}}) {

        $worksheet->set_column($col, $col, $width) if $width;
        $col++;
    }
}


###############################################################################
#
# The following function is a callback that was added via add_write_handler()
# above. It modifies the write() function so that it stores the maximum
# unwrapped width of a string in a column.
#
sub store_string_widths {

    my $worksheet = shift;
    my $col       = $_[1];
    my $token     = $_[2];

    # Ignore some tokens that we aren't interested in.
    return if not defined $token;       # Ignore undefs.
    return if $token eq '';             # Ignore blank cells.
    return if ref $token eq 'ARRAY';    # Ignore array refs.
    return if $token =~ /^=/;           # Ignore formula

    # Ignore numbers
    return if $token =~ /^([+-]?)(?=\d|\.\d)\d*(\.\d*)?([Ee]([+-]?\d+))?$/;

    # Ignore various internal and external hyperlinks. In a real scenario
    # you may wish to track the length of the optional strings used with
    # urls.
    return if $token =~ m{^[fh]tt?ps?://};
    return if $token =~ m{^mailto:};
    return if $token =~ m{^(?:in|ex)ternal:};


    # We store the string width as data in the Worksheet object. We use
    # a double underscore key name to avoid conflicts with future names.
    #
    my $old_width    = $worksheet->{__col_widths}->[$col];
    my $string_width = string_width($token);

    if (not defined $old_width or $string_width > $old_width) {
        # You may wish to set a minimum column width as follows.
        #return undef if $string_width < 10;

        $worksheet->{__col_widths}->[$col] = $string_width;
    }


    # Return control to write();
    return undef;
}

############################EXCEL FORMATTING: END########################################

##############################################################################
# Usage       : addDataToExcelFile();
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

sub addDataToExcelFile
{
    my $activityCell = "\'" . "A$currCellNum" . "\'";
    my $crCell = "\'" . "B$currCellNum" . "\'";
    my $headLineCell = "\'" . "C$currCellNum" . "\'";
    my $stateCell = "\'" . "D$currCellNum" . "\'";
    my $ownerCell = "\'" . "E$currCellNum" . "\'";
    $worksheet->write($activityCell,"$cqActivityID", $cellFormat);
    $worksheet->write($crCell,"$myCR", $cellFormat);
    $worksheet->write($headLineCell,  "$myHeadLine", $cellFormat);
    $worksheet->write($stateCell,  "$myState", $cellFormat);
    $worksheet->write($ownerCell,  "$myOwner", $cellFormat);
    autofit_columns($worksheet);
    $currCellNum++;
}

##############################################################################
# Usage       : setupExcelFile();
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

sub setupExcelFile
{
    #my $headerFormat = $workbook->add_format();
    #my $cellFormat = $workbook->add_format();
    #rzd info
    #Format Detail for Excel SpreadSheet
    $workbook->set_custom_color(40, 201, 221,3);#Sunquest green
    $workbook->set_custom_color(41, 2, 29,119); #Sunquest blue
    $headerFormat->set_color(41);
    $headerFormat->set_bg_color(40);
    $headerFormat->set_bold();
    $headerFormat->set_center_across();
    $cellFormat->set_center_across();
    $cellFormat->set_color(41);
    $cellFormat->set_bold();
    
    $worksheet->add_write_handler(qr[\w], \&store_string_widths);
    $worksheet->merge_range('A1:A2', ' CQ ACTIVITY ID ', $headerFormat);
    $worksheet->merge_range('B1:B2', ' Siebel CR ', $headerFormat);
    $worksheet->merge_range('C1:C2', ' HEADLINE ', $headerFormat);
    $worksheet->merge_range('D1:D2', ' STATE ', $headerFormat);
    $worksheet->merge_range('E1:E2', ' OWNER ', $headerFormat);
    $worksheet->merge_range('F1:F2', " ", $headerFormat);
    $worksheet->merge_range('G1:G2', "BASELINE LABEL: $baseLineLabel", $headerFormat);
    autofit_columns($worksheet);
}


##############################################################################
# Usage       : finalizeLogFile();
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

sub finalizeLogFile
{
    open(OUT, ">>$baselineActivityFileHTML");
    print OUT "\t" . '</TABLE>' . "\n";
    print OUT "\t" . '</TABLE>' . "\n";
    print OUT '</HTML>' . "\n";    
    close(OUT);    
}

##############################################################################
# Usage       : addDataToLogFile();
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

sub addDataToLogFile
{
    open(OUT, ">>$baselineActivityFileHTML");
    print OUT "\t" . '<TR>'. "\n";
    print OUT "\t" . '<TD><H3>ClearQuest ID: ' . "$cqActivityID" . '</H3></TD>' ."\n";
    print OUT "\t" . '</TR>' . "\n";
    print OUT "\t" . '<TR>' . "\n";
    print OUT "\t" . '<TD><H4>HEADLINE: ' . "$myHeadLine" . '</H4></TD>' . "\n";
    print OUT "\t" . '</TR>' . "\n";
    print OUT "\t" . '<TR>' . "\n";
    print OUT "\t" . '<TD><H4>OWNER: ' . "$myOwner" . '</H4></TD>' . "\n";
    print OUT "\t" . '</TR>' . "\n";
    print OUT "\t" . '<TR>' . "\n";
    print OUT "\t" . '<TD><H4>STATE: ' . "$myState" .  '</H4></TD>' . "\n";
    print OUT "\t" . '</TR>' . "\n";
    print OUT "\t" . '<TR>' . "\n";
    print OUT "\t" . '<TD><H4>CR: ' . "$myCR " . '</H4></TD>' . "\n";
    print OUT "\t" . '</TR>' . "\n";
    print OUT "\t" . '<TR>' . "\n";
    print OUT "\t" . '<TD><H4>Change Set:</H4></TD>' . "\n";
    print OUT "\t" . '</TR>' . "\n";
    
    for my $myTempKey (keys %myChangeSet){
        my $myCurrChangeSet = $myChangeSet{$myTempKey};
        print OUT "\t" . '<TR>' . "\n";
        print OUT "\t" . '<TD><H5>' . "$myCurrChangeSet" . '</H5></TD>' . "\n";
        print OUT "\t" . '</TR>' . "\n";
    }
    close(OUT);    
}

##############################################################################
# Usage       : setupLogFile();
#
# Purpose     : Setups up Activities Baseline Log File.
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

sub setupLogFile
{
    open(OUT, ">$baselineActivityFileHTML");
    print OUT '<HTML>' . "\n";
    print OUT "\t" . '<HEAD>';
    print OUT "\t" . '<LINK REL="stylesheet" TYPE="text/css" HREF="\\\gemini\2kfp2-eldo\PC-DEV\Build Files\Sunquest Common\Build Forge Reports\SunquestCM.css" TITLE="Default">' . "\n";
    print OUT "\t" . '</HEAD>';
    print OUT "\t" . '<TABLE BORDER=0 WIDTH="80%" HEIGHT="80%" CELLPADDING=0 CELLSPACING=0 Align=Center>' . "\n";
    print OUT "\t" . '<TABLE BORDER=0 WIDTH="10%" HEIGHT="20%" CELLPADDING=0 CELLSPACING=0 Align=Left valign = top>' . "\n";
    print OUT "\t" . '<TR>';
    print OUT "\t" . '<TD><img src="\\\gemini\2kfp2-eldo\PC-DEV\Build Files\Sunquest Common\Build Forge Reports\Sunquest_Logo_RGB2.gif" alt="Angry" /></TD>'; 
    print OUT "\t" . '</TABLE>';
    print OUT "\t" . '<TABLE BORDER=0 WIDTH="80%" HEIGHT="10%" CELLPADDING=0 CELLSPACING=0 Align=Center bgcolor=#C9DD0 valign=top>'. "\n";
    print OUT "\t" . '<TR>'. "\n";
    print OUT "\t" . '<TD ALIGN=CENTER><H1>Baseline Activity Build Report</H1></TD>'. "\n";
    print OUT "\t" . '</TR>'. "\n";
    print OUT "\t" . '</TABLE>'. "\n";
    print OUT "\t" . '<TABLE BORDER=0 WIDTH="80%" HEIGHT="10%" CELLPADDING=0 CELLSPACING=0 Align=CENTER bgcolor=#C9DD0 VALIGN=bottom>'. "\n";
    print OUT "\t" . '<TR>'. "\n";
    print OUT "\t" . '<TD ALIGN=LEFT><H2>PRODUCT: ' . "$product" . '</H2</TD>'. "\n";
    print OUT "\t" . '<TD ALIGN=CENTER><H2>INT STREAM: ' . "$intStream" . '</H2</TD>'. "\n";
    print OUT "\t" . '<TD ALIGN=BOTTOM><H2>VERSION: ' . "$currVer" . '</H2</TD>'. "\n";
    print OUT "\t" . '</TR>'. "\n";
    print OUT "\t" . '</TABLE>'. "\n";
    print OUT "\t" . '<BR></BR>'. "\n";
    print OUT "\t" . '<TABLE BORDER=0 WIDTH="70%" HEIGHT="15%" CELLPADDING=0 CELLSPACING=0 Align=Center>'. "\n";
    close(OUT);
}

##############################################################################
# Usage       : getCQActivityFieldInfo();
#
# Purpose     : Gets CQ Activitys Field 
#               
# Returns     : Nothing.
#
# Parameters  : none
#               
# Throws      : No exceptions.
#
# Comments    : None.
#
# See Also    : N/A    
############################################################################## 

sub getCQActivityFieldInfo
{

    my $cqRecord;
    my $cqRecord2;
    my $fieldInfoObjHL;
    my $fieldInfoObjID;
    my $fieldInfoObjOwner;
    my $fieldInfoObjState;
    my $fieldInfoObjCR;
    my $fieldInfoObjHL_2;
    my $fieldInfoObjID_2;
    my $fieldInfoObjOwner_2;
    my $fieldInfoObjState_2;
    my $fieldInfoObjCR_2;
    
    open STDERR, ">NUL";
    $cqRecord = $cqSession->GetEntity(CQ_RECORD_TYPE,$cqActivityID);
    $cqRecord2 = $cqSession->GetEntity(CQ_RECORD_TYPE_2,$cqActivityID); 
    close STDERR;
    
        eval{$fieldInfoObjHL = $cqRecord->GetFieldValue("headline");};
        if($@)
        {
            #$@ = undef;
            eval{$fieldInfoObjHL_2 =  $cqRecord2->GetFieldValue("headline");};
            if($@)
            {
                #$myHeadLine = $fieldInfoObjHL_2->GetValue();
                $myHeadLine = 'ClearQuest record is not of type DEFECT.';
            } else {
                #$myHeadLine = 'ClearQuest record is not of type DEFECT.';
                $myHeadLine = $fieldInfoObjHL_2->GetValue();
            }
        } else{
            $myHeadLine = $fieldInfoObjHL->GetValue();
        }
        
        eval{$fieldInfoObjID = $cqRecord->GetFieldValue("id");};
        if($@){
            eval{$fieldInfoObjID_2 =  $cqRecord2->GetFieldValue("headline");};
            if($@){
                $myID = 'N/A';
            }else {
                $myID = $fieldInfoObjID_2->GetValue();    
            }
        } else{
            $myID = $fieldInfoObjID->GetValue();
        }
        
        eval{$fieldInfoObjOwner = $cqRecord->GetFieldValue("Owner");};
        if($@){
            eval{$fieldInfoObjOwner_2 = $cqRecord2->GetFieldValue("Owner");};
            if($@){
                $myOwner = 'N/A';
            } else {
                $myOwner = $fieldInfoObjOwner_2->GetValue();
            }
        } else {
            $myOwner = $fieldInfoObjOwner->GetValue();
        }
        
        eval{$fieldInfoObjState =  $cqRecord->GetFieldValue("State");};
        if($@){
            eval{$fieldInfoObjState_2 =  $cqRecord2->GetFieldValue("State");};
            if($@){    
                $myState  = 'N/A';
            } else {
                $myState = $fieldInfoObjState_2->GetValue();
            }
        } else {
            $myState = $fieldInfoObjState->GetValue();
        }
        
        
        eval{$fieldInfoObjCR = $cqRecord->GetFieldValue("CR_Number");};
        if($@){
            $myCR = 'N/A';
        } else{
            $myCR = $fieldInfoObjCR->GetValue();
            if(!$myCR){
                $myCR = 'N/A';
            }
        }    
}#getCQActivityFieldInfo


##############################################################################
# Usage       : getCQActivityChangeSet($cqActivityID);
#
# Purpose     : Puts CQ Activitys Change Set into a hash %myChangeSet
#               
# Returns     : Nothing.
#
# Parameters  : $currentActivityID - Current ClearQuest Activity ID
#               
# Throws      : No exceptions.
#
# Comments    : None.
#
# See Also    : N/A    
############################################################################## 

sub getCQActivityChangeSet
{
    %myChangeSet = ();
    my $myCurrActivityID = $cqActivityID . $myProjectVob ;
    #print "\n$myCurrActivityID\n";
    my $myCurrActivity = $myCCApp->Activity($myCurrActivityID);
    if (! $myCurrActivity ) {
            print "Can not resolve activity info in ClearCase\n";
        }#endif (! $myCurrAct )
        else {
            my $myView = $myCurrActivity->NameResolverView();
            #print "\n$myCurrAct\n";
            my $myCurrChangeSet = $myCurrActivity->ChangeSet($myView, "False");
            my $myCSCount = $myCurrChangeSet->Count;
            my $myIndex = 1;
            while($myIndex <= $myCSCount){
                my $myVersion = $myCurrChangeSet->Item($myIndex);
                #my $myVersionPath = $myVersion->PathInView('daniels_LAB_6.4_MHU_int');
                my $myVersionPath = $myVersion->ExtendedPath;
                #print "\nMyVersionPath: $myVersionPath\n";
                (my $myChangeSetPathTemp, my $temp) = split(/@/,$myVersionPath);
                (my $temp1, my $myTemp2, my $myChangeSetPath) = split(/\\/, $myChangeSetPathTemp,3);
                $myChangeSetPath = '\\' . $myChangeSetPath;
                if(!(exists $myChangeSet{$myChangeSetPath})){
                    $myChangeSet{$myChangeSetPath} = $myChangeSetPath;
                    #print "\nMyChangesetPath: $myChangeSetPath\n";
                } #end if(!(exists $myChangeSet{$myChangeSetPath}))
                $myIndex++;
            }#end while($myIndex <= $myCSCount)
        }#end else
    #}#end foreach my $myTempKey (keys (%myBaseLineActivitieID))  
}# end sub getCQActivityChangeSet

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
    my %myBaseLineActivitieID;
    foreach my $myTempVal(@myCompositVobArray){
        $myTempVal = "$myTempVal" . "_" .  "$myDate" . "_" . "$currVer" . "$myProjectVob";
        my $diffActs = `cleartool diffbl -pred -act $myTempVal`;
        #print "\nMyTempVal: $myTempVal\n";
        while($diffActs =~/>>\s(.+)@/g){
            if(!(exists $myBaseLineActivitieID{$1})){
                $myBaseLineActivitieID{$1} = $1;
            }#end (!(exists $myBaseLineActivitieID{$1}))
        } #end while($diffActs =~/>>\s(.+)@/g)
    }#end foreach my $myTempVal(@myComponentVobs)
    for my $myTempVals(keys %myBaseLineActivitieID){
        my $mytemp2 = $myBaseLineActivitieID{$myTempVals};
        if($cqActivitiesIDList){
            $cqActivitiesIDList = $cqActivitiesIDList . ',' . $mytemp2;
        } else {
            $cqActivitiesIDList = $mytemp2;
        }
        #$myActivityIDList = $myActivityIDList . ',';
    }# end foreach my $myTempVal(%myBaseLineActivitieID)
} #end sub getActivityIDs


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
    #Setting Command Line Options
    my $options_okay = GetOptions(
    'c|CQDataBase=s'        => \$cqDatabase,
    'd|ProjectVob=s'        => \$myProjectVob,
    'l|CompositVobList=s'   => \$CompositVobList,
    'p|Product=s'           => \$product,
    'b|BaseLineName=s'      => \$baseLineLabel,
    'i|IntegrationStream=s' => \$intStream,
    '-v|Version=s'          => \$currVer, 
    
    'help|?'                => sub{
        warn USAGE;
        warn HELP;
        $workbook->close();
        exit 0;
    },
    'Usage'                => sub {
      warn USAGE;
      $workbook->close();
      exit 0;
    }
    
);
    # Log onto the session
    $cqSession->UserLogon(CQ_LOGIN , CQ_PASSWD, "$cqDatabase", AD_PRIVATE_SESSION, EMPTY_STR);

    $baselineActivityFileHTML = $baseLineLabel . '.htm';
    $baselineActivityFileExcel = $baseLineLabel . '.xls';
    $workbook  = Spreadsheet::WriteExcel->new($baselineActivityFileExcel);
    $worksheet = $workbook->add_worksheet();
    $headerFormat = $workbook->add_format();
    $cellFormat = $workbook->add_format();
    $currCellNum = "4";
    setupLogFile;
    setupExcelFile;
    
    @myCompositVobArray = split(/,/,$CompositVobList);
    getActivityIDs;
    my @cqActivitiesIDArray = split(/,/,$cqActivitiesIDList);
    
    foreach my $tempVal(@cqActivitiesIDArray){
        $cqActivityID = $tempVal;
        getCQActivityChangeSet();
        getCQActivityFieldInfo();
        addDataToLogFile;
        addDataToExcelFile;
    }
    finalizeLogFile;
    $workbook->close();
}# end sub main


main;


