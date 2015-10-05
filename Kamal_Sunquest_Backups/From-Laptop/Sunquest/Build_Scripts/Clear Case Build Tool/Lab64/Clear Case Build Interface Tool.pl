#!perl -w
use strict;
#use warnings;

use Cwd;
use Win32::GUI();
use Config::IniFiles;
use Net::FTP;
use Net::Telnet ();
use Date::Simple;
use Mail::Mailer;
use IO::File;
use File::Copy;

#Start: Constant Declrations
use constant CLEARCASE_DIRECTORY => "/clearcase_builds/";
use constant EMAIL_SERVER => 'smtp.sunquestinfo.com';
use constant FTP_SERVER => 'barney.sqdev.sunquestinfo.com';
use constant SRM_SERVER => 'porter.sqdev.sunquestinfo.com';
use constant FTP_SERVER_USERNAME => 'cmuser';
use constant FTP_SERVER_PASSWORD => 'cmuser';
use constant MUMPS_LOG_FILE => "BuildLogFile.txt";
#End: Constant Declrations

# Start: Variable Declrations and Initilizations
my $cfgfile = "cc_build.cfg";
my $cfgref = new Config::IniFiles( -file => "$cfgfile" );
my $myBuildDir = $cfgref->val('CLEARCASE', 'BuildDirectory'); # Hold value of main build directory 
my $myProduct = $cfgref->val('CLEARCASE','Product');# hold product we are building
my $myVersion = $cfgref->val( 'CLEARCASE', 'Build_No' );# Hold value of verion read in from INI file
my $myBuildSRM = $cfgref->val('CLEARCASE', 'SRM'); #Hold Value to build SRM.
my $bom = $cfgref->val('CLEARCASE', 'BOM'); #Hold value to build BOM report
my $myDate = Date::Simple->new(); #creating new Date object and grabbing todays date

my $homeDirectory = getcwd(); # initial working directory
my $preBuild;   # used to say if we want to run Pre-Build
my $productFromIni = "Product To Build: ";
my $sunquestIcon;
my $buildGui;   # used to say if we want to build GUI.
my $buildMumps; # used to say if we want to build mumps. 
my $deskTopResolution; #Variable used to store desktop resolution
my $dw; #Variable used to store width of desktop
my $dh; #Variable used to store height of desktop
my $x;  #Variable used to store Height
my $y;  #Variable used to store width
my $statusBar;
my $buildButton;
my $updateBuildNumber = 0; #Used to indicate if we should update build number;
my $validateMumpsEmailBody; # Used to hold body of e-mail 
my $DOS = Win32::GUI::GetPerlWindow();
$myDate = $myDate->format("%m%d%Y"); # formating date in month day year with no spaces
# END: Variable Declrations and Initilizations



# START: GUI SETUP
Win32::GUI::Hide($DOS);
$sunquestIcon = new Win32::GUI::Icon('App.ico');
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
    -icon => $sunquestIcon,
);

my $sunquestIcon2 = $main->ChangeSmallIcon($sunquestIcon);

$main->AddNotifyIcon(
    -name => "NI",
    -icon => $sunquestIcon,
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
# End: GUI SETUP

sub Build_Click{
        
    $cfgref->setval( 'CLEARCASE', 'Build_No',$myVersion->Text() );
    $cfgref->WriteConfig($cfgfile);
    $statusBar->Text("Clicked Build Button");
    $myVersion = $cfgref->val( 'CLEARCASE', 'Build_No' );

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
        $statusBar->Text("Running MUMPS Build Process");
        if(index("LAB",uc($myProduct)) >= 0) {
            
            &update_cmaddrsa();
        }
        system "perl Mumps_Build.pl";
        if($? == 0){
            &sunquest_ftp();
            if(index("LAB",uc($myProduct)) >= 0){
                validate_mumps();
            } # end if
            if(index("YES",uc($myBuildSRM)) >= 0){
                srm();
            } # end if
        } else{
                $updateBuildNumber = 1;
        }
        &sunquest_email("MUMPS");
        #system "pause";
    }
    
    if($buildGui->Checked() == 1){
        $statusBar->Text("Running GUI Build Process");
        if(-e "master.config"){
             #print "file exist\n";
             &updateMasterConfigFile();
        }
        system "perl GUI_Bld_Gen.pl";
        if($? != 0){
            $updateBuildNumber = 1;
        }
	#print "Hello in gui function.\n";
        if(index("YES",uc($bom)) >= 0){
            sunquest_bom();    
                
        }
        &sunquest_email("GUI_BLD");
        
    }
    
    $statusBar->Text("Build Process Complete");
    $buildButton ->Enable();
    
    
    Win32::GUI::Hide($DOS);
    
    if($updateBuildNumber == 0){
        &update_build_no;
    
    }
    
    
    return 0;    
}

sub sunquest_ftp{
    
    
    my $ftp;
    my $myFile;
    my $myFileG; #full path and file name for global file 
    my $myFileName;
    my $myFileNameG; #global file name
    my $cacheObjectsExist = "FALSE";
    my $ftpFileR = "ftpFileR.txt" ; # Hold file name for FTP script file name Routine file
    my $ftpFileG = "ftpFileG.txt"; # Hold file name for FTP script file name for Global file
    my $counter; # counter used for looping
    my @cacheObjectsDirFiles; #Array to hold files or dir LAB_CACHE_OBJECTS
    my $myCacheObjectsIncludesDir; # hold name of Includes Dir
    my @cacheObjectsIncludesDirFiles; #hold name of Includes Dir File contents
    my $myCfg = Config::IniFiles->new(-file => "CC_Build.cfg"); #Creating new Config::IniFiles object. opening config file
    my $myCacheObjectsDir = $myBuildDir . "LAB_CACHE_OBJECTS"; # added by rzd
    my $mycacheObjectsDirRemote; #holds directory to create on Barney
    my $myCacheObjectsIncludesDirRemote; #holds directory to create on Barney for Include files.
    my $myRemoteDir = $myCfg->val('MUMPS', 'Barney_Dir'); #grabbing value for Barney main directory
    my  $mainDir = CLEARCASE_DIRECTORY . $myRemoteDir;
    #print "Print main directory for product.\n";
    #print "$mainDir\n";
    $myRemoteDir = $mainDir . "/" . $myCfg->val('CLEARCASE', 'Product'). "_" . $myVersion . "_" . $myDate;
    $myFileName = $myCfg->val('CLEARCASE', 'Product') . "_" . $myVersion . "_" . $myDate . ".ro";
    $myFileNameG = $myCfg->val('CLEARCASE', 'Product') . "_" . $myVersion . "_" . $myDate . ".go";
    $myFile = $myCfg->val('CLEARCASE', 'BuildDirectory') . $myCfg->val('MUMPS', 'MUMPS_Folder') . "\\" . $myFileName;
    $myFileG = $myCfg->val('CLEARCASE', 'BuildDirectory') . $myCfg->val('MUMPS', 'MUMPS_Folder') . "\\" . $myFileNameG;
    
    # START: added by RZD on Jan 11th for automatic FTP of Cache_Objects to Barney
    if (index("YES",uc($myBuildSRM)) >= 0)
    {
        my $tempFileName; # temp variable to hold name of file
        $myCacheObjectsIncludesDir = $myCacheObjectsDir . "/Includes";
        $mycacheObjectsDirRemote = $myRemoteDir . "/CACHE_OBJECTS"; #holds remote directory to create on Barney
        $myCacheObjectsIncludesDirRemote = $mycacheObjectsDirRemote . "/includes"; # holds remote directory to create on Barney
        $cacheObjectsExist = "TRUE";
    
        #print "$cacheObjectsExist\n";
        chdir($myCacheObjectsDir) || die "cannot cd to $myCacheObjectsDir ($!)";
        opendir(NT,$myCacheObjectsDir) || die "Cannot opendir $myCacheObjectsDir: $!";
        $counter = 0;
        foreach $tempFileName (sort readdir(NT))
        { 
            if($tempFileName=~/\.xml/)
            {
            
                $cacheObjectsDirFiles[$counter] = $myCacheObjectsDir . "\\" . $tempFileName;
                $counter++;
            }#close if
        } # close foreach
        closedir(NT);
    } #close if
    
    if (-e $myCacheObjectsIncludesDir)
    {
        my $tempFileName;; # temp variable to hold name of file
        opendir(NT,$myCacheObjectsIncludesDir) || die "Cannot opendir $myCacheObjectsIncludesDir: $!";
        $counter = 0;
        foreach $tempFileName (sort readdir(NT))
        { 
            if($tempFileName=~/\.xml/)
            {
            
                $cacheObjectsIncludesDirFiles[$counter] = $myCacheObjectsIncludesDir . "\\" . $tempFileName;
                $counter++;
            }
        }
        closedir(NT);
    }
    # END RZD on Jan 11th
    
        open OUT,">$ftpFileR" or die "Unable to open: $ftpFileR\Error: n$!\n";
        
    #if($cacheObjectsExist eq "TRUE")
     if ($cacheObjectsExist eq 'TRUE')
    {
        #print "\ngoing to write file TRUE\n";
        my $fileName; #temp variable to hold file name
        print OUT "open barney.sqdev.sunquestinfo.com\n";
        print OUT "cmuser\n";
        print OUT "cmuser\n";
        print OUT "cd " . $mainDir ."\n";
        print OUT "mkdir " . $myRemoteDir . "\n";
        print OUT "mkdir " . $mycacheObjectsDirRemote . "\n";
        print OUT "mkdir " . $myCacheObjectsIncludesDirRemote . "\n";
        print OUT "cd " . $myRemoteDir . "\n";
        print OUT "ascii\n";
        print OUT "put " . $myFile . "\n";
        print OUT "cd " . $mycacheObjectsDirRemote . "\n";
        
        foreach $fileName (@cacheObjectsDirFiles)
        {
            print OUT "put " .  $fileName . "\n";    
        }
        
        print OUT "cd " . $myCacheObjectsIncludesDirRemote . "\n";
        
                
        foreach $fileName (@cacheObjectsIncludesDirFiles)
        {
            print OUT "put " .  $fileName . "\n";    
        }
        print OUT "bye\n";
        close OUT or die "Unable to close: $ftpFileR\nError: $!\n";
        system "ftp -v -s:$ftpFileR";
        system "exit";	
        unlink $ftpFileR;
        
        
    }
    else
    {
       # print "\ngoing to write file FALSE\n";
        print OUT "open barney.sqdev.sunquestinfo.com\n";
        print OUT "cmuser\n";
        print OUT "cmuser\n";
        print OUT "cd " . $mainDir ."\n";
        print OUT "mkdir " . $myRemoteDir . "\n";
        print OUT "cd " . $myRemoteDir . "\n";
        print OUT "ascii\n";
        print OUT "put " . $myFile . "\n";
        print OUT "bye\n";
        close OUT or die "Unable to close: $ftpFileR\nError: $!\n";
        system "ftp -v -s:$ftpFileR";
        system "exit";	
        unlink $ftpFileR;
    }
    if (-e $myFileG){
	    open OUT,">$ftpFileG" or die "Unable to open: $ftpFileR\Error: n$!\n";
	
            print OUT "open barney.sqdev.sunquestinfo.com\n";
            print OUT "cmuser\n";
            print OUT "cmuser\n";
            print OUT "cd " . $mainDir ."\n";
            print OUT "cd " . $myRemoteDir . "\n";
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

sub sunquest_email{

my $mailer;
    my $subject;
    my $line;
    my $myLogFile;
    my $mySize;
    my $logFileLocation;
    my $myHostName;
    my @allEmailAddress = "";
    my $myEmailAddress = $cfgref->val('CLEARCASE', 'Email_List');
    my $myErrorLogFile;
    my $body = "";  
    @allEmailAddress = split /,/, $myEmailAddress;

    my $myBuildType = $_[0];
    #print "\n$myBuildType\n";
    if(!(($myBuildType=~/SRM/i) || ( $myBuildType=~/VALIDATE/i)))
    {
        $myErrorLogFile = $myBuildDir . $myProduct . "_" . $myBuildType . "_ERROR" . ".log";
    
        open(TMP2,$myErrorLogFile) or die "Cannot open $myErrorLogFile: $!";

        $mySize = -s TMP2;
        $myHostName = `hostname`;
    
    
        if($mySize > 0){
            $subject = $myProduct . "_" . $myVersion . "_" . $myDate . " " . $myBuildType . " FAILED";
            $myLogFile = $myErrorLogFile;
        #print "$myEmailAddress\n";
        } else{
            if(index("LAB",uc($myProduct)) >= 0)
            {
                $subject = $myProduct . "_" . $myVersion . "_" . $myDate . " " . $myBuildType . " COMPLETED\.";
                $myLogFile = $myBuildDir . $myProduct . "_" . $myBuildType . ".log";
            }# end if
            else
            {
               $subject = $myProduct . "_" . $myVersion . "_" . $myDate . " " . $myBuildType . " COMPLETED SUCCESSFULLY";
               $myLogFile = $myBuildDir . $myProduct . "_" . $myBuildType . ".log";
            }# end if
        }
        
        
        # print "Log File Location: " . "$myLogFile\n";
        $logFileLocation = "Please Check Log Files at the following location:\n" . "Hostname: " . "$myHostName" ."Directory: " . "$myBuildDir\n" . "\n" . "\n" ;
    
        open(TMP,$myLogFile) or die "Cannot open $myLogFile $!";
        while($line = <TMP>)
        {
            $body = $body . $line;
        }# end while
    }
    
    if($myBuildType=~/SRM_CACHE_INCLUDE/i)
    {
        if($_[2]=~/SUCCESS/)
        {
            $subject = "Cache Include files successfully imported";
            
        }#end if
        else
        {
            $subject = "Cache Include files import failed.";
        }# end else
        
        $body = $_[1];  
    }# end if
    
    
    if($myBuildType=~/SRM_CACHE_OBJECT_LOAD/i)
    {
        if($_[2]=~/SUCCESS/)
        {
            $subject = "Cache Objects Loaded Successfully.";
            
        }#end if
        else
        {
            $subject = "Cache Objects Load Failed.";
        }# end else
        
        $body = $_[1];  
    }# end if
    
    if($myBuildType=~/SRM_CACHE_OBJECT_COMPILE/i)
    {
        if($_[2]=~/SUCCESS/)
        {
            $subject = "Cache Objects Compiled Successfully.";
            
        }#end if
        else
        {
            $subject = "Cache Objects Compile Failed.";
        }# end else
        
        $body = $_[1];  
        }# end if
    
    if($myBuildType=~/SRM_RO_LOAD/i)
    {
        $subject = "Routines were loaded into SRMTEST64 area for CACHE OBJECT LOAD and COMPILE."; 
        $body = $_[1];  
    }# end if
    
    if($myBuildType=~/VALIDATE/i)
    {
        $subject = "MUMPS VALIDATION COMPLETE."; 
        $body = $_[1];  
    }# end if
    
    
    
    $myEmailAddress = "";
    foreach $myEmailAddress(@allEmailAddress){
        #print "current email address "."$myEmailAddress\n";
        $mailer = Mail::Mailer->new("smtp", Server=> EMAIL_SERVER);
        $mailer->open({ 'From'    => $myEmailAddress,
                        'To'      => $myEmailAddress,
                        'Subject' => $subject,
                  })
            or die "Can't open: $!\n";
            
    if(!(($myBuildType=~/SRM/i) || ( $myBuildType=~/VALIDATE/i)))
    {
        print $mailer $logFileLocation . $body;
    }
    else
    {
        print $mailer $body;    
    }
    $myEmailAddress = " ";
    $mailer->close();
    $mailer = "";
    }    
    return 0;    

} 
sub update_build_no {
        my @build_num = split /\./, $myVersion;
        $build_num[-1]++;
        my $build_num = join "\.", @build_num;
        $cfgref->setval( 'CLEARCASE', 'Build_No',$build_num );
        $cfgref->WriteConfig($cfgfile);
}
#routine cmaddrsa creates a CONFIGURATIONMANAGEMENTADDITION.RSA file copies it to mumps folder so it's included in build of mumps file.
sub update_cmaddrsa{
    my $nlcr = "\x0d\x0a";
    my $file = "CONFIGURATIONMANAGEMENTADDITION.RSA";
    my $path;
    my $tempLength;
    my $localVersion; # local copy of version
    my @myValues = split('\.', $myVersion);
    $tempLength = length($myValues[3]);
    
    if($tempLength == 1){
        $myValues[3] = "00" . $myValues[3];    
    }
    
    if($tempLength == 2){
        $myValues[3] = "0" . $myValues[3];    
    }
    
    $localVersion = $myValues[0] . '.' . $myValues[1] . '.' . $myValues[2] . $myValues[3];
    open OUT,">$file" or die "Unable to open: $file\Error: n$!\n";
    print OUT qq(Cache for Windows NT^INT^Routine Exported from TST53^~Format=Cache.S~),$nlcr;
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
    print OUT qq( Q "$localVersion"),$nlcr;
    close OUT or die "Unable to close: $file\nError: $!\n";
    $path = $cfgref->val('CLEARCASE','BuildDirectory') .  $cfgref->val('MUMPS','MUMPS_Folder');
    system "copy CONFIGURATIONMANAGEMENTADDITION.RSA $path";
    unlink $file;
    
    return 0;
    
}

sub updateMasterConfigFile{
    my $line = 0;
    my @data = "";
    my $word_find = "";
    my $count = 0;
    my $update = 0;
    #print "Running updateMasterConfigFile subroutine\n";
    # Open a master.config file for reading and store the data into an array.
    open OUT, "<master.config" or die "\nUnable to open file\nError: $!\n";
    #@data holds all the elements of master.config file.
    @data = <OUT>;
    close(OUT);
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

sub sunquest_bom{
    
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


sub validate_mumps{
    
    chdir($homeDirectory);
    
    my $cfgfile = "cc_build.cfg";
    my $myCfg = new Config::IniFiles( -file => "$cfgfile" );
    
    my $myDir = $myCfg->val('MUMPS', 'Barney_Dir'); #grabbing value for Barney main directory
    my $mainDir = CLEARCASE_DIRECTORY . $myDir;
    
    $myDir = $mainDir . "/" . $myProduct. "_" . $myVersion . "_" . $myDate;
    
    my $myFileName = $myCfg->val('CLEARCASE', 'Product') . "_" . $myVersion . "_" . $myDate . ".ro";
    
    my $myFilePath = $myDir . '/' .  $myFileName;
    my $tmpLine;
    my @lines;    
    my $myPrompt = '/\$/';
    my $myCommand = './checkmumps' . " " . $myFilePath ." it53" . " C"; 
    my $myCommand1 = './loadRO' . " " . $myFilePath . " " . "it53" . " " .  MUMPS_LOG_FILE;
    my $myTelnetSession = new Net::Telnet (Timeout => 7200,
                          Prompt => $myPrompt);
    #print "\n$myCommand\n";
    #print "\n$myCommand1\n";
    my $myFtpSession = Net::FTP->new(FTP_SERVER) or die "Cannot connect to FTP_SERVER: $@";
    print "Validating Lab mumps build\n";
    $myTelnetSession->open(FTP_SERVER);
    $myTelnetSession->login(FTP_SERVER_USERNAME, FTP_SERVER_PASSWORD);
    @lines = $myTelnetSession->cmd($myCommand);
    $myTelnetSession->cmd($myCommand1);
    $myTelnetSession->close;
    if(-e MUMPS_LOG_FILE){
        unlink(MUMPS_LOG_FILE);
    }# end if
    $myFtpSession->login(FTP_SERVER_USERNAME, FTP_SERVER_PASSWORD) or die "Cannot login ", $myFtpSession->message;
    $myFtpSession->ascii;
    $myFtpSession->get(MUMPS_LOG_FILE);
    $myFtpSession->delete(MUMPS_LOG_FILE);
    $myFtpSession->quit;
     
     $validateMumpsEmailBody = "";

    foreach(@lines)
    {
        $validateMumpsEmailBody = $validateMumpsEmailBody . $_;
    }# end foreach
    
    $validateMumpsEmailBody = $validateMumpsEmailBody . "\n\n";
    open(TMP,MUMPS_LOG_FILE) or die "Cannot open MUMPS_LOG_FILE $!";
    while ($tmpLine = <TMP>)
    {
       $validateMumpsEmailBody = $validateMumpsEmailBody . $tmpLine;
    }
    sunquest_email("VALIDATE", "$validateMumpsEmailBody");
    
} # end sub validate_mumps

sub srm{
    
my $myTempValue;
my $tempFileName;
my $counter;
my $myWorkingDirectory;

my @cacheObjectsIncludesDirFiles="";
my @cacheObjectsDirFiles="";
my @myLines;


my $myPrompt = '/\$/';

my $ftpFileC = "ftpFileC.txt";
my $ftpFileRO = "ftpFileRO.txt";
my $ftpFileGetROLog = "ftpFileGetROLog.txt";
my $myLoadROLogFile = 'loadROLog.txt';
my $ftpFileGetJavaProjections = "ftpFileGetJavaProjections.txt";

my $myCommand1 = './CacheIncludeLoad';
my $myCommand2 = './CacheObjectLoad';
my $myCommand3 = './CacheObjectCompile';
my $myLoadRoCommand = './loadRO';

my $myCacheObjectsDir="C:\\LAB_BLD_VIEW\\LAB_CACHE_OBJECTS";
my $myCacheObjectsIncludesDir = "C:\\LAB_BLD_VIEW\\LAB_CACHE_OBJECTS\\Includes";
my $myCacheObjectsIncludesDirRemote='/home/cmuser/mlar/CACHE_OBJECTS/includes';
my $javaProjectionsDir="C:\\LAB_BLD_VIEW\\LAB_CACHE_OBJECTS\\Java Projections";


my $mumpsRoutineFile = $cfgref->val('CLEARCASE', 'BuildDirectory') . $cfgref->val('MUMPS', 'MUMPS_Folder') . "\\" . $cfgref->val('CLEARCASE', 'Product') . "_" . $myVersion . "_" . $myDate . ".ro";
my $mumpsRoutineFileName = $cfgref->val('CLEARCASE', 'Product') . "_" . $myVersion . "_" . $myDate . ".ro";
$myLoadRoCommand = $myLoadRoCommand . " " . '/home/cmuser/mlar/mumps/' . $mumpsRoutineFileName; 

if(-e $myCacheObjectsDir)
{
    opendir(NT,$myCacheObjectsDir) || die "cannot opendir $myCacheObjectsDir: $1";
    $counter = 0;
    foreach $tempFileName (sort readdir(NT))
    {
        if($tempFileName=~/\.xml/)
        {
            $cacheObjectsDirFiles[$counter] = $myCacheObjectsDir . "\\" . $tempFileName;
            $counter++;
        }# end if
        
    }# end foreach
    closedir(NT);
    
}# end if

if(-e $myCacheObjectsIncludesDir)
{
    opendir(NT,$myCacheObjectsIncludesDir) || die "cannot opendir $myCacheObjectsIncludesDir: $1";
    $counter = 0;
    foreach $tempFileName (sort readdir(NT))
    {
        if($tempFileName=~/\.xml/)
        {
            $cacheObjectsIncludesDirFiles[$counter] = $myCacheObjectsIncludesDir . "\\" . $tempFileName;
            $counter++;
        }# end if
    }#end foreach
    closedir(NT);
}# end if



my $myTelnetSession = new Net::Telnet (Timeout => 7200,
                          Prompt => $myPrompt);
my $myFtpSession = Net::FTP->new(SRM_SERVER) or die "Cannot connect to SRM_SERVER: $@";


$myFtpSession->login(FTP_SERVER_USERNAME, FTP_SERVER_PASSWORD) or die "Cannot login ", $myFtpSession->message;


$myTelnetSession->open(SRM_SERVER);
$myTelnetSession->login(FTP_SERVER_USERNAME, FTP_SERVER_PASSWORD);

#start: Cleaning out includes and CACHE_OBJECTS directory
$myTelnetSession->cmd("rm loadROLog.txt");
$myTelnetSession->cmd('cd ./mlar/CACHE_OBJECTS/includes');
$myTelnetSession->cmd("rm *.xml");
$myTelnetSession->cmd('cd ../');
$myTelnetSession->cmd("rm *.xml");
#end: Cleaning out includes and CACHE_OBJECTS directory

#FTP FILES

open OUT,">$ftpFileC" or die "Unable to open: $ftpFileC\Error: n$!\n";
        
    
        #print "\ngoing to write file TRUE\n";
        my $fileName; #temp variable to hold file name
        print OUT "open porter.sqdev.sunquestinfo.com\n";
        print OUT "cmuser\n";
        print OUT "cmuser\n";
        print OUT "ascii\n";
        print OUT "cd " . './mlar/CACHE_OBJECTS' ."\n";
        
        foreach $fileName (@cacheObjectsDirFiles)
        {
            print OUT "put " .  $fileName . "\n";    
        }
        
        print OUT "cd " . $myCacheObjectsIncludesDirRemote . "\n";
        
                
        foreach $fileName (@cacheObjectsIncludesDirFiles)
        {
            print OUT "put " .  $fileName . "\n";    
        }
        print OUT "bye\n";
        close OUT or die "Unable to close: $ftpFileC\nError: $!\n";
        system "ftp -v -s:$ftpFileC";
        system "exit";	
        unlink $ftpFileC;
        
         
        
        open OUT,">$ftpFileRO" or die "Unable to open: $ftpFileRO\Error: n$!\n";
        
    
        #print "\ngoing to write file TRUE\n";
        #my $fileName; #temp variable to hold file name
        print OUT "open porter.sqdev.sunquestinfo.com\n";
        print OUT "cmuser\n";
        print OUT "cmuser\n";
        print OUT "ascii\n";
        print OUT "cd " . './mlar/mumps' ."\n";
        print OUT " put " . $mumpsRoutineFile . "\n" ;
        print OUT "bye\n";
        close OUT or die "Unable to close: $ftpFileRO\nError: $!\n";
        system "ftp -v -s:$ftpFileRO";
        system "exit";	
        unlink $ftpFileRO;
        
#End FTP FILES

#Loading includes *.xml files
$myTelnetSession->cmd("cd ~");
#print "\n$myLoadRoCommand\n";
my $myTemp = $myTelnetSession->cmd($myLoadRoCommand);

#get RO LOG FILE
        open OUT,">$ftpFileGetROLog" or die "Unable to open: $ftpFileGetROLog\Error: n$!\n";
        
    
        #print "\ngoing to write file TRUE\n";
        #my $fileName; #temp variable to hold file name
        print OUT "open porter.sqdev.sunquestinfo.com\n";
        print OUT "cmuser\n";
        print OUT "cmuser\n";
        print OUT "ascii\n";
        print OUT "get " . 'loadROLog.txt' ."\n";
        print OUT "bye\n";
        close OUT or die "Unable to close: $ftpFileGetROLog\nError: $!\n";
        system "ftp -v -s:$ftpFileGetROLog";
        system "exit";	
        unlink $ftpFileGetROLog;

#end get RO LOG FILE

#Read contents of Log File
open IN,"loadROLog.txt" or die "Unable to open: loadROLog.txt\Error: n$!\n";
@myLines = <IN>;
close IN or die "Unable to close: loadROLog.txt\nError: $!\n";
foreach(@myLines)
{
    
    $myTempValue = $myTempValue .  $_;
}# end foreach
sunquest_email("SRM_RO_LOAD", "$myTempValue", "SUCCESS");
@myLines = "";
$myTempValue = "";

#print "\n$myCommand1\n";

@myLines = $myTelnetSession->cmd($myCommand1);


foreach(@myLines)
{
    
    $myTempValue = $myTempValue .  $_;
}# end foreach   
    if($myTempValue=~/^error/i)
    {
        #print "\nERROR\n";
        #print $myTempValue;
        sunquest_email("SRM_CACHE_INCLUDE", "$myTempValue", "ERROR");
        exit 1;
       # print OUT1 "$myTempValue";
        
        
    }
    else
    {
        #print "\nNoError\n";
       # print $myTempValue;
        sunquest_email("SRM_CACHE_INCLUDE", "$myTempValue", "SUCCESS");
        
        #print OUT "$myTempValue";    
    }
    
    @myLines = "";
    $myTempValue = "";
    
   @myLines = $myTelnetSession->cmd($myCommand2);
    
    foreach(@myLines)
    {
    
        $myTempValue = $myTempValue .  $_;
    }# end foreach   
    if($myTempValue=~/^error/i)
    {
        #print "\nERROR\n";
        #print $myTempValue;
        sunquest_email("SRM_CACHE_OBJECT_LOAD", "$myTempValue", "ERROR");
        exit 1;
       # print OUT1 "$myTempValue";
        
        
    }
    else
    {
        #print "\nNoError\n";
       # print $myTempValue;
        sunquest_email("SRM_CACHE_OBJECT_LOAD", "$myTempValue", "SUCCESS");
        
        #print OUT "$myTempValue";    
    }
    
    @myLines = "";
    $myTempValue = "";
    print "\nCompiling Cache Objects, this process could take up to a hour and a half.\n";
    @myLines = $myTelnetSession->cmd($myCommand3);
    
    foreach(@myLines)
    {
    
        $myTempValue = $myTempValue .  $_;
    }# end foreach   
    if($myTempValue=~/^error/i)
    {
        #print "\nERROR\n";
        #print $myTempValue;
        sunquest_email("SRM_CACHE_OBJECT_COMPILE", "$myTempValue", "ERROR");
        exit 1;
       # print OUT1 "$myTempValue";
        
        
    }
    else
    {
        #print "\nNoError\n";
       # print $myTempValue;
        sunquest_email("SRM_CACHE_OBJECT_COMPILE", "$myTempValue", "SUCCESS");
        
        #print OUT "$myTempValue";    
    }
    

$myTelnetSession->close;

# START: bring java projections back to build box
$myWorkingDirectory = getcwd();
chdir($javaProjectionsDir) || die "cannot cd to $javaProjectionsDir ($!)";
$ftpFileGetJavaProjections = "ftpFileGetJavaProjections.txt";

        open OUT,">$ftpFileGetJavaProjections" or die "Unable to open: $ftpFileGetJavaProjections\Error: n$!\n";
        
    
        #print "\ngoing to write file TRUE\n";
        #my $fileName; #temp variable to hold file name
        print OUT "open porter.sqdev.sunquestinfo.com\n";
        print OUT "cmuser\n";
        print OUT "cmuser\n";
        print OUT "ascii\n";
        print OUT "cd " . '/sunquest/java/MLAR' . "\n";
        print OUT "get " . 'DeviceMaintenance.java' ."\n";
        print OUT "get " . 'dFaxServers.java' ."\n";
        print OUT "get " . 'dPhoneNumber.java' ."\n";
        print OUT "get " . 'FaxServer.java' ."\n";
        print OUT "get " . 'Job.java' ."\n";
        print OUT "get " . 'LabPatient.java' ."\n";
        print OUT "get " . 'ReportFile.java' ."\n";
        print OUT "get " . 'ReportFileActivity.java' ."\n";
        print OUT "get " . 'ReportFileLog.java' ."\n";
        print OUT "get " . 'ReportScheduleLog.java' ."\n";
		print OUT "get " . 'Location.java' ."\n";

		print OUT "get " . 'CDBClient.java' ."\n";
        print OUT "get " . 'Client.java' ."\n";
        print OUT "get " . 'Gender.java' ."\n";
		print OUT "get " . 'dHospital.java' ."\n";
        print OUT "get " . 'LabPatientOrder.java' ."\n";
        print OUT "get " . 'MLARUtility.java' ."\n";
        print OUT "get " . 'PhoneNumber.java' ."\n";
        print OUT "get " . 'Physician.java' ."\n";
        print OUT "get " . 'ReportAccess.java' ."\n";
        print OUT "get " . 'ReportError.java' ."\n";
        print OUT "get " . 'UserMaintenance.java' ."\n";
		print OUT "get " . 'UserMaintenanceHistory.java' ."\n";
		print OUT "get " . 'UserMaintenanceTokens.java' ."\n";

        print OUT "bye\n";
        close OUT or die "Unable to close: $ftpFileGetJavaProjections\nError: $!\n";
        system "ftp -v -s:$ftpFileGetJavaProjections";
        system "exit";	
        unlink $ftpFileGetJavaProjections;


chdir($myWorkingDirectory) || die "cannot cd to $myWorkingDirectory ($!)";

# END: bring java projections back to build box
} # end SRM sub 