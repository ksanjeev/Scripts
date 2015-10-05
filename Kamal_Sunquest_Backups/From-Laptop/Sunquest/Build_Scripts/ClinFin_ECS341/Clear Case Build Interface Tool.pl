#!perl -w
use strict;
#use warnings;

use Cwd;
use Win32::GUI();
use Config::IniFiles;
use Net::FTP;
use Date::Simple;
use Mail::Mailer;
use IO::File;
use File::Copy;

use constant CLEARCASE_DIRECTORY => "/clearcase_builds/";

my $cfgfile = "CC_Build.cfg";
my $cfgref = new Config::IniFiles( -file => "$cfgfile" );


#my $buildMUMPS; # used to say if we want to build mumps.
#my $buildGUI;   # used to say if we want to build GUI.
my $preBuild;   # used to say if we want to run Pre-Build
#my $mumpsCheckboxValue = 1; # Set value to build mumps as default.
my $productFromIni = "Product To Build: ";
my $misysIcon;
my $myVersion;  # Hold value of verions read in from INI file
my $buildGui;   # used to say if we want to build GUI.
my $buildMumps; # used to say if we want to build mumps.
my $myProduct;
my $deskTopResolution; #Variable used to store desktop resolution
my $dw; #Variable used to store width of desktop
my $dh; #Variable used to store height of desktop
my $x;  #Variable used to store Height
my $y;  #Variable used to store width
my $statusBar;
my $buildButton;
my $updateBuildNumber = 0; #Used to indicate if we should update build number;


my $DOS = Win32::GUI::GetPerlWindow();
Win32::GUI::Hide($DOS);


$misysIcon = new Win32::GUI::Icon('App.ico');
$myProduct = $productFromIni . $cfgref->val('CLEARCASE','Product');
$myVersion = $cfgref->val( 'CLEARCASE', 'Build_No' );

$deskTopResolution = Win32::GUI::GetDesktopWindow();

$dw = Win32::GUI::Width($deskTopResolution);
$dh = Win32::GUI::Height($deskTopResolution);

$x = ($dw - 400) /2;
$y = ($dh - 150) /2;

my $main = Win32::GUI::Window->new(
    -name => 'Main',
    -text => 'Clear Case Build Interface Tool',
    -width => 400,
    -height => 175,
    -resizable => 0,
    -dialogui => 1,
    -icon => $misysIcon,
);

my $misysIcon2 = $main->ChangeSmallIcon($misysIcon);

$main->AddNotifyIcon(
    -name => "NI",
    -icon => $misysIcon,
    -tip => "Clear Case Build Interface Tool",
                              
                              
);
$main->AddLabel(
    -name => 'Product_Label',
    #-text => $productFromIni,
    -text => $myProduct,
    -pos => [5,5],
    -tabstop =>1,
                
);

 $preBuild = $main->AddCheckbox(
    -name => 'Pre Build',
    -text => 'RUN PRE BUILD ?',
   -checked => 1,
   #-checked => $mumpsCheckboxValue,
   # -pos  => [5,5],
   -pos => [5,35],
    -tabstop => 1,
    );

$buildMumps = $main->AddCheckbox(
    -name => 'MUMPS',
    -text => 'BUILD MUMPS ?',
    -checked => 1,
    -pos  => [5,65],
    -tabstop => 1,
    );

$buildGui = $main->AddCheckbox(
    -name => 'GUI',
    -text => 'BUILD GUI ?',
    -checked => 1,
    -pos => [5,95],
    -tabstop => 1,
    );

$myVersion = $main->AddTextfield(
	-name      => "Version",
	-text      => $myVersion,
	-prompt    => ["Version", -45],
	-multiline => 0,
	-vscroll   => 0,
	-left      => 100,
	-top       => 100,
	-height    => 20,
	-width     =>  100, 
        -pos => [250,5],
	-tabstop   => 1,
      #  -wantreturn =>1,
        -number => 0,
);

$buildButton = $main->AddButton(
    -name => 'Build',
    -text => '   Build   ',
    -pos => [250,90],
    -tabstop => 1,
                 
                 
                 
);

$main->AddButton(
    -name => 'Cancel',
    -text => '  Cancel  ',
    -pos => [320,90],
    -tabstop => 1,
                                
);

$statusBar = $main->AddStatusBar(
    -text => "Configuration Management",                    
                    
);

$main->Move($x,$y);
$main->Show();
Win32::GUI::Dialog();
#Win32::GUI::Show($DOS);
#exit(0);

sub Build_Click{
        
    $cfgref->setval( 'CLEARCASE', 'Build_No',$myVersion->Text() );
    $cfgref->WriteConfig($cfgfile);
    $statusBar->Text("Clicked Build Button");

    #Process_Build();
    &Process_Build;
}
sub Cancel_Click{
    return -1;             
                 
}


sub Main_Terminate {
    return -1;
}


sub Process_Build{
    $buildButton ->Disable();
    Win32::GUI::Show($DOS);
    
    if($preBuild->Checked() == 1){
        $statusBar->Text("Running Pre-Build Process");
        system "perl CC_Pre_Bld_Process.pl";
        if($? != 0){
            print "There was an error in the pre-build process please check log file.";
            $updateBuildNumber = 1;
            exit 1;
        }
    }
    
    if($buildMumps->Checked() == 1){
        my $myCfg = Config::IniFiles->new(-file => "CC_Build.cfg");
        my $product = $myCfg->val('CLEARCASE', 'Product');
        $statusBar->Text("Running MUMPS Build Process");
        if(index("LAB",uc($product)) >= 0) {
            
            &update_cmaddrsa();
        }
        system "perl Mumps_Build.pl";
        if($? == 0){
            &misys_ftp();
        } else{
                $updateBuildNumber = 1;
        }
        &misys_email("MUMPS");
        #system "pause";
    }
    
    if($buildGui->Checked() == 1){
        my $myCfg = Config::IniFiles->new(-file => "CC_Build.cfg");
        my $bom = $myCfg->val('CLEARCASE', 'BOM');
        $statusBar->Text("Running GUI Build Process");
        if(-e "master.config"){
             #print "file exist\n";
             &updateMasterConfigFile();
        }
        system "perl GUI_Bld_Gen.pl";
        if($? != 0){
            $updateBuildNumber = 1;
        }
	print "Hello in gui function.\n";
        if(index("YES",uc($bom)) >= 0){
            misys_bom();    
                
        }
        &misys_email("GUI_BLD");
        
    }
    
    $statusBar->Text("Build Process Complete");
    $buildButton ->Enable();
    
    
    Win32::GUI::Hide($DOS);
    
    if($updateBuildNumber == 0){
        &update_build_no;
    
    }
    
    
    return 0;    
}

sub misys_ftp{
    
    my $ftp;
    my $myDate;
    my $myCfg;
    my $myDir;
    my $myVersion;
    my $mainDir;
    my $myFile;
    my $myFileG; #full path and file name for global file 
    my $myFileName;
    my $myFileNameG; #global file name
    my $ftpFileR; # Hold file name for FTP script file name Routine file
    my $ftpFileG; # Hold file name for FTP script file name for Global file

    $myCfg = Config::IniFiles->new(-file => "CC_Build.cfg"); #Creating new Config::IniFiles object. opening config file
    $myDir = $myCfg->val('MUMPS', 'Barney_Dir'); #grabbing value for Barney main directory
    $myVersion = $myCfg->val('CLEARCASE', 'Build_No'); #getting current version
    $mainDir = CLEARCASE_DIRECTORY . $myDir;
    #print "Print main directory for product.\n";
    #print "$mainDir\n";
    $myDate = Date::Simple->new(); # Creating new Date object and grabbing todays date
    $myDate = $myDate->format("%m%d%Y");  #formating date in month day year with no spaces
    $myDir = $mainDir . "/" . $myCfg->val('CLEARCASE', 'Product'). "_" . $myVersion . "_" . $myDate;
    $myFileName = $myCfg->val('CLEARCASE', 'Product') . "_" . $myVersion . "_" . $myDate . ".ro";
    $myFileNameG = $myCfg->val('CLEARCASE', 'Product') . "_" . $myVersion . "_" . $myDate . ".go";
    $myFile = $myCfg->val('CLEARCASE', 'BuildDirectory') . $myCfg->val('MUMPS', 'MUMPS_Folder') . "\\" . $myFileName;
    $myFileG = $myCfg->val('CLEARCASE', 'BuildDirectory') . $myCfg->val('MUMPS', 'MUMPS_Folder') . "\\" . $myFileNameG;
    
    $ftpFileR = "ftpFileR.txt";
    $ftpFileG = "ftpFileG.txt";
    
        open OUT,">$ftpFileR" or die "Unable to open: $ftpFileR\Error: n$!\n";
	
    print OUT "open barney.dev.onemisys.com\n";
    print OUT "cmuser\n";
    print OUT "cmuser\n";
    print OUT "cd " . $mainDir ."\n";
    print OUT "mkdir " . $myDir . "\n";
    print OUT "cd " . $myDir . "\n";
    print OUT "ascii\n";
    print OUT "put " . $myFile . "\n";
    print OUT "bye\n";
    close OUT or die "Unable to close: $ftpFileR\nError: $!\n";
    system "ftp -v -s:$ftpFileR";
    system "exit";	
    unlink $ftpFileR;

    if (-e $myFileG){
	    open OUT,">$ftpFileG" or die "Unable to open: $ftpFileR\Error: n$!\n";
	
            print OUT "open barney.dev.onemisys.com\n";
            print OUT "cmuser\n";
            print OUT "cmuser\n";
            print OUT "cd " . $mainDir ."\n";
            print OUT "cd " . $myDir . "\n";
            print OUT "binary\n";
            print OUT "put " . $myFileG . "\n";
            print OUT "bye\n";
            close OUT or die "Unable to close: $ftpFileG\nError: $!\n";
            system "ftp -v -s:$ftpFileG";
	    system "exit";	
            unlink $ftpFileG;
    } 


    #return 0;
}

sub misys_email{
    my $mailer;
    my $body;
   # my $from_address;
   # my $to_address;
    my $subject;
    my $line;
    my $myCfg;
    my $myDir;
    my $myProduct;
    my $myLogFile;
    my $myErrorLogFile;
    my $myBuildType;
    my $myEmailAddress;
    my @allEmailAddress;
    my $myDate;
    my $myVersion;
    my $mySize;
    my $logFileLocation;
    my $myHostName;

    #$from_address = 'Robert.Lopez@misyshealthcare.com';
    #$to_address = 'Robert.Daniels@misyshealthcare.com';
    $myCfg = Config::IniFiles->new(-file => "CC_Build.cfg"); #Creating new Config::IniFiles object. opening config file
    $myDir = $myCfg->val('CLEARCASE', 'BuildDirectory');
    $myProduct = $myCfg->val('CLEARCASE', 'Product');
    @allEmailAddress = "";
    $myEmailAddress = $myCfg->val('CLEARCASE', 'Email_List');
    @allEmailAddress = split /,/, $myEmailAddress;

    $myBuildType = $_[0];
    
    $myErrorLogFile =$myDir . $myProduct . "_" . $myBuildType . "_ERROR" . ".log";
    
    open(TMP2,$myErrorLogFile) or die "Cannot open $myErrorLogFile: $!";

    $mySize = -s TMP2;

    #print "My Error Log file name " . "$myErrorLogFile\n";
    
    #print "My Error log file size " . $mySize . "\n";


    #$myVersion
    $myVersion = $myCfg->val('CLEARCASE', 'Build_No'); #getting current version
    $myDate = Date::Simple->new(); # Creating new Date object and grabbing todays date
    $myDate = $myDate->format("%m%d%Y");  #formating date in month day year with no spaces
    $myHostName = `hostname`;
    #$subject = $myCfg->val('CLEARCASE', 'Product') . $myBuildType . " " $myCfg->val('CLEARCASE', 'Build_No') . " " . $myBuildType . ;
    if($mySize > 0){
        $subject = $myCfg->val('CLEARCASE', 'Product') . "_" . $myVersion . "_" . $myDate . " " . $myBuildType . " FAILED";
    #print "$myEmailAddress\n";
    } else{
        $subject = $myCfg->val('CLEARCASE', 'Product') . "_" . $myVersion . "_" . $myDate . " " . $myBuildType . " COMPLETED SUCCESSFULLY";
    }
    
    #$myLogFile = $myDir . "\\" . $myProduct . "_" . $myBuildType . ".log";
    $myLogFile = $myDir . $myProduct . "_" . $myBuildType . ".log";
   # print "Log File Location: " . "$myLogFile\n";
    $logFileLocation = "Please Check Log Files at the following location:\n" . "Hostname: " . "$myHostName" ."Directory: " . "$myDir\n" . "\n" . "\n" ;
    $body = "";
    open(TMP,$myLogFile) or die "Cannot open $myLogFile $!";
    while ($line = <TMP>)
    {
       $body = $body . $line;
    }
    #print "$from_address\n";
    #print "$to_address\n";

   # eval{
   # $mailer = Mail::Mailer->new('smtp', Server=> 'AZMAILBE1.OneMisys.com');
    
  #  };
   # if($@){
   #     print "Couldn't send mail: $@\n";    
   # } 
    $myEmailAddress = "";
    foreach $myEmailAddress(@allEmailAddress){
        #print "current email address "."$myEmailAddress\n";
        $mailer = Mail::Mailer->new('smtp', Server=> 'AZMAILBE1.OneMisys.com');
        $mailer->open({ 'From'    => $myEmailAddress,
                        'To'      => $myEmailAddress,
                        'Subject' => $subject,
                  })
            or die "Can't open: $!\n";
    
    print $mailer $logFileLocation . $body;
    $myEmailAddress = " ";
    #$mailer = "";
    $mailer->close();
    $mailer = "";
    }    
    #$mailer->close();
    return 0;
} 
sub update_build_no {
        my $myVersion;
        my $path;
        $myVersion = $cfgref->val( 'CLEARCASE', 'Build_No' );
        my @build_num = split /\./, $myVersion;
        $build_num[-1]++;
        my $build_num = join "\.", @build_num;
        $cfgref->setval( 'CLEARCASE', 'Build_No',$build_num );
        $cfgref->WriteConfig($cfgfile);
}
#routine cmaddrsa creates a CONFIGURATIONMANAGEMENTADDITION.RSA file copies it to mumps folder so it's included in build of mumps file.
sub update_cmaddrsa{
    my $myVersion = $cfgref->val( 'CLEARCASE', 'Build_No' );
    my $nlcr = "\x0d\x0a";
    my $file = "CONFIGURATIONMANAGEMENTADDITION.RSA";
    my $path;

    my @myValues = split('\.', $myVersion);

    $myVersion = $myValues[0] . '.' . $myValues[1] . '.' . $myValues[2] . $myValues[3];
    open OUT,">$file" or die "Unable to open: $file\Error: n$!\n";
 
    #print OUT qq(Cache for UNIX^INT^^~Format=Cache.S~),$nlcr;
    print OUT qq(Cache for Windows NT^INT^Routine Exported from TST53^~Format=Cache.S~),$nlcr;
#    print OUT qq(%RO on 1 Jan 2006   6:30 AM),$nlcr;
    print OUT qq(%RO on Jun 2 2000   9:25 PM),$nlcr;
    print OUT qq(ConfigurationManagementAddition^INT^1^59973,59905^0),$nlcr;
    print OUT qq( ;;),$nlcr;
    print OUT qq( ;; ConfigurationManagementAddition.RSA - This routine is );
    print OUT qq(generated during the build process),$nlcr;
    print OUT qq( ;;),$nlcr;
    print OUT qq( ;; RESTRICTED RIGHTS NOTICE),$nlcr;
    print OUT qq( ;; Use, reproduction or disclosure subject to restrictions );
    print OUT qq(set forth in Software License Agreement and FAR 52.227-19, © );
    print OUT qq((1) and (2).  Unpublished works ? ALL RIGHTS RESERVED under );
    print OUT qq(Copyright Laws of the USA.),$nlcr;
    print OUT qq( ;; NOT GOVERNMENT PROPERTY),$nlcr;
    print OUT qq( ;;),$nlcr;
    print OUT qq( ;; Copyright © 1983-2005 Misys Hospital Systems, Inc., );
    print OUT qq(d/b/a Misys Healthcare Systems. All Rights Reserved.),$nlcr;
    print OUT qq( ;;),$nlcr;
    print OUT qq(LabProductVersion() ;),$nlcr;
    print OUT qq( Q "$myVersion"),$nlcr;
    print OUT "$nlcr$nlcr$nlcr";
    #print OUT "\n";
    #print OUT "\n";
    #print OUT "\n";
    close OUT or die "Unable to close: $file\nError: $!\n";
    #my $myVersion = $cfgref->val( 'CLEARCASE', 'Build_No' );
    
    $path = $cfgref->val('CLEARCASE','BuildDirectory') .  $cfgref->val('MUMPS','MUMPS_Folder');
    system "copy CONFIGURATIONMANAGEMENTADDITION.RSA $path";
    unlink $file;
    
    return 0;
    
}

# rzd }

sub updateMasterConfigFile{
    my $line = 0;
    my @data = "";
    my $word_find = "";
    my $count = 0;
    my $update = 0;
    my $myVersion = 0;
    #print "Running updateMasterConfigFile subroutine\n";
    # Open a master.config file for reading and store the data into an array.
    open OUT, "<master.config" or die "\nUnable to open file\nError: $!\n";
    #@data holds all the elements of master.config file.
    @data = <OUT>;
    close(OUT);
    $myVersion = $cfgref->val( 'CLEARCASE', 'Build_No' );
    #print "current version: " . $myVersion . "\n";
    open VERSION, "<Versions.txt" or die "\nUnable to open Version.txt\nError: $!\n";
    
    while ($line = <VERSION>){
            chomp($line);
           for (my $i=0;$i<@data;$i++)
            {
                # If assembly name found in the previous row.
                if ($update == 1)
                {
                    #Update the version number with the new one.
                    $data[$i] =~ s/version=\"(\d+(?:\.\d+)*)\"/version=\"$myVersion\"/g;
                    $update = 0;
                    last;
                }
                # Holds the actual word which has to find.
                $word_find = '"'. $line. '"';
                #If word found then modify the $update value to 1.
                if (substr($data[$i], 0) =~ $word_find)
                {
                    # This is just for testing, remove after testing
                    #$data[$i] =~ s/$word_find/$word_find\"Hello\"/g;
                    $update = 1;
                }
            }   
    }
    
    close (VERSION) or die "\nCan't close version file";

    #Print the data onto the standard output
    #print @data;
    # Open a master.config file for writing
    # Write the whole array to the file.
    open OUT, ">master.config" or die "\nUnable to open file\nError: $!\n";

    print OUT @data;

    close(OUT);
    my $temp = "c:\\temp\\";
    mkdir($temp) unless (-d $temp);

    copy("master.config", $temp)
    or die "copy failed: $!";

    
}

sub misys_bom{
    
    if(-e "./Scan/AardvarkScan.exe"){
	chdir '.\Scan';
        system 'AardvarkScan.exe';
        
    } else{
        
        print "Can't locate Scan utility.\n";
        exit 1;
      }
    
    if(-e "AardvarkResults.bat"){
        system 'AardvarkResults.bat';
    } else{
        
        print "Can't locate AardvarkResults.bat file.\n";
        exit 1;
    }
    
    
    chdir '../';
    
}

