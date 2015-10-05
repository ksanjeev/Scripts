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

use constant CLEARCASE_DIRECTORY => "/clearcase_builds/";

my $cfgfile = "cc_build.cfg";
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
            $updateBuildNumber = 1;
        }
    }
    
    if($buildMumps->Checked() == 1){
        $statusBar->Text("Running MUMPS Build Process");
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
        $statusBar->Text("Running GUI Build Process");
        system "perl GUI_Bld_Gen.pl";
        if($? != 0){
            $updateBuildNumber = 1;
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
    my $myFileName;

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
    $myFile = $myCfg->val('CLEARCASE', 'BuildDirectory') . $myCfg->val('MUMPS', 'MUMPS_Folder') . "\\" . $myFileName;


    #print "New Dir\n";
    #print "$myDir\n";
    #print "\n";
    #print "myFile\n";
    #print "$myFile\n";

    $ftp = Net::FTP->new("barney.dev.onemisys.com",Debug => 0)
        or die "Cannot connect to barney: $@";
    $ftp->login("cmuser",'cmuser')
    #$ftp->login("build",'rubble')
        or die "Cannot Login ", $ftp->message;
    $ftp->cwd($mainDir)
       or die "Cannot change working directory ", $ftp->message;
    $ftp->mkdir($myDir)
        or die "Cannot make directory ", $ftp->message;
    $ftp->cwd($myDir)
       or die "Cannot change working directory ", $ftp->message;
    $ftp->ascii;
    $ftp->put($myFile)
        or die "Can't upload file ", $ftp->message; 
    
    return 0;
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
    
sub update_build_no {
        my $myVersion;
        $myVersion = $cfgref->val( 'CLEARCASE', 'Build_No' );
        my @build_num = split /\./, $myVersion;
        $build_num[-1]++;
        my $build_num = join "\.", @build_num;
        $cfgref->setval( 'CLEARCASE', 'Build_No',$build_num );
        $cfgref->WriteConfig($cfgfile);
}

}
