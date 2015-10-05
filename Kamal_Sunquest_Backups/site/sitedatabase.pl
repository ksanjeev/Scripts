#! /usr/bin/perl -w
use strict;
use Shell;

# Prerequisites for this script
# We need files machine1.sh and patch.sh to be loaded in the current directory to work properly 

# defining the Parameters
my @osName;
my @osVersion;
my @osVersion1;
my @dbType;
my @dbVersion;
my @dbType1;
my @dbVersion1;
my @osType;
my @patch;
my @numProc;
my @hwModel;
my @hwType;
my @gccVersion;
my @tapeDrive;

print "Make sure that 'machine1.sh' and 'patch.sh' are present in the current directory\n\n";


print " Field Name 		Possible Values\n";
print "----------------------------------------\n";

#print "\t---------------------------------------------------------------\n";

#print "This method gets the version stored in a variable and put into an array\n\n";
# METHOD 1 
# --------
# To capture the output of the Cache version into a variable
chomp(my $cache_vers = qx!cache "^VERSION"!);
#print $cache_vers,"\n";

# converting the string into an array
my @cache_vers = split(/\s/,$cache_vers);

# To print the number of element in the array
#print "The number of elements in the array is = $#cache_vers\n";

# To print the Database Type and version of Cache
for (my $i = 0; $i < @cache_vers; $i++) 
{
 if ($cache_vers[$i] eq "Cache" || $cache_vers[$i] eq "cache" )   
{
 push @dbType, $cache_vers[$i];
}
 elsif ($cache_vers[$i] eq "4.1.16" || $cache_vers[$i] eq "4.1.12" || $cache_vers[$i] eq "4.1.4" || $cache_vers[$i] eq "3.2.1" || $cache_vers[$i] eq "2.1.6" || $cache_vers[$i] eq "5.0.12" || $cache_vers[$i] eq "5.0.15"|| $cache_vers[$i] eq "5.0.18") 

{
 push @dbVersion, $cache_vers[$i];
}
}
#print "The database type is =  @dbType\n";
#print "The database version is =  @dbVersion\n\n";

print " dbType			@dbType\n";
print " dbVersion		@dbVersion\n";

#print "\tTHE OUPUT OF THE CACHE VERSION AND DATABASE TYPE USING METHOD 2\n";
#print "\t---------------------------------------------------------------\n";

#print "This method gets the version stored in a file called 'mumver' and put into an array, it is also able to set to check the file permissions\n\n";

# METHOD 2
# --------
# To capture the output of the Cache version into a file - mum_ver using a Shell command
qx!cache "^VERSION" > mumver!;

# Reading the file containing the Mumps version into a string
if (-r "mumver" and -w "mumver" and -x "mumver") 
{
open(MV,"<mumver") || die "Cannot open the file\n";
my $cache_ver = <MV>;
close MV;

# To print the values of the Mumps version string
#print "The contents of the Mumps version string is =  \t$cache_ver\n";

# converting the string into an array
my @cache_ver = split(/\s/,$cache_ver);

# To print the number of element in the array
#print "The number of elements in the array is = $#cache_ver\n";

# To print the Database Type and version of Cache
for (my $i = 0; $i < @cache_ver; $i++) 
{
if ($cache_vers[$i] eq "Cache" || $cache_vers[$i] eq "cache" )   
{
 push @dbType1, $cache_ver[$i];
}
elsif ($cache_vers[$i] eq "4.1.16" || $cache_vers[$i] eq "4.1.12" || $cache_vers[$i] eq "4.1.4" || $cache_vers[$i] eq "3.2.1" || $cache_vers[$i] eq "2.1.6" || $cache_vers[$i] eq "5.0.12" || $cache_vers[$i] eq "5.0.15"|| $cache_vers[$i] eq "5.0.18") 
{
 push @dbVersion1, $cache_ver[$i];
}
}
#print "The database type is =  @dbType1\n";
#print "The database version is =  @dbVersion1\n\n";
}
else
{
#print "You do not have the required execution permissions\n\n";
}

#print "\tTHE OUPUT OF THE OPERATING VERSION\n";
#print "\t----------------------------------\n";

#print "It gets the version of the Operating System and stores in a array\n\n";

# To print the version of the operating system
chomp(my $osVr1=qx!oslevel!);
#print "The version of the operating system is =  $osVr1\n"; 

# To push the osVersion type into an array
push @osVersion1, "$osVr1"; 

# The contents of the operating system version array is
#print "The contents of Operating System Version array is =  @osVersion1\n\n"; 

print " osVersion		@osVersion1\n";

#print "\tTHE OUPUT OF THE SYSTEM ARCHITECTURE\n";
#print "\t------------------------------------\n";

#print "To print the system processor architecture\n\n";

# to print the architecture of the system processor
chomp(my $osP=qx!uname -p!);
#print "The architecture of the system processor is = $osP\n\n"; 

#print "\tTHE OUPUT OF THE OPERATING SYSTEM\n";
#print "\t---------------------------------\n";

#print "To push the operating system name into an array\n\n";

# to print the system name or the operating System 
chomp(my $osOS=qx!uname -s!);
#print "The operating system is = $osOS\n"; 

# to push the operating system name into the array
push @osName, "$osOS";

# The contents of the operating system array is 
#print "The contents of Operating System array is = @osName\n\n"; 

print " osName			@osName\n";

#print "\tTHE OUPUT OF THE OPERATING SYSTEM TYPE\n";
#print "\t--------------------------------------\n";

#print "To push the operating system type into an array\n\n";

# To assign operating Type as Unix if OS is AIX
if ($osOS eq "AIX" || $osOS eq "aix")
{
my $osType = "UNIX";
push @osType, "$osType";
}
#print "The contents of the Operating System Type is =  @osType\n\n";

print " osType			@osType\n";

#print "\tTHE OUPUT OF THE OPERATING SYSTEM SERVER NAME\n";
#print "\t---------------------------------------------\n";

#print "To print the operating system server name\n\n";

# to print the node name or the Server name 
chomp(my $osN=qx!uname -n!);
#print "The Server name is = $osN\n\n"; 


#print "\tTHE OUPUT OF THE PATCHES INSTALLED IN THE OPERATING SYSTEM\n";
#print "\t----------------------------------------------------------\n";

#print "It makes use of the shell script 'patch.sh' to identify the patches into a file named 'newpatch' and captures the patch needed into a array\n\n";

# To capture the patch names in a file
system("sh patch.sh");

# To get the contents of the file into an array
my $patch = "patch_names";

open(DAT, $patch) || die("cannot open file");
@patch = <DAT>;
close(DAT);

# To print the array of patches
#print "The contents of Patches array is \n@patch\n";
 
chomp(@patch); 

#print "\tTHE OUPUT OF THE HARDWARE MODEL AND HARDWARE TYPE\n";
#print "\t-------------------------------------------------\n";

#print "It makes use of the file 'machine1.sh' to capture the hardware model of the server into an array\n\n";

# To find out the machine type in a variable
chomp(my $hwModel=qx!sh machine1.sh!);

# To push the Hardware model into an array
push @hwModel, "$hwModel";

# To print the contents os the array
#print "The array containing the machine type is = @hwModel\n\n";

print " hwModel		@hwModel\n";

#print "It makes use of the machine type to capture the hardware type of the server into an array\n\n";

my $hwType;

if ($hwModel eq ("43P" ||"42P") )
{
  $hwType = "IBM-RISC";
}

#print "The hardware type is =  $hwType\n";

# To push the hardware type into an array
push @hwType, "$hwType";

# To print the contents of Hardware Type array
#print "The contents of the hwType array is = @hwType\n\n"; 

print " hwType			@hwType\n";

#print "\tTHE OUPUT OF NUMBER OF PROCESSORS\n";
#print "\t---------------------------------\n";

#print "To print the number of processors in the server\n\n";

# To find out the number of processors 
chomp(my $numProc=qx!lscfg | grep -c "^+ proc"!);
#print "The number of processors are = $numProc\n\n";

print " numProc		$numProc\n";

#print "\tTHE OUPUT OF THE TAPE DRIVES USED\n";
#print "\t---------------------------------\n";

#print "To Print the tape Drives found in the Server\n\n";

# To find out the tape drives in the Server

#print "It makes use of the shell script 'tape.sh' to identify the tape drives from a file named 'tapes' and captures the tapes needed into a array\n\n";

# To capture the patch names in a file
system("sh tape.sh");

# To get the contents of the file into an array
my $tape = "tapes";

open(DAT, $tape) || die("cannot open file");
@tapeDrive = <DAT>;
close(DAT);

#chomp(my $tapeDrive = qx!lsdev -l rmt*!);
#print "The Tape Drives found in the server = $tapeDrive\n\n"; 

#print " tapeDrive		$tapeDrive\n";
chomp(@tapeDrive);
print " tapeDrive		@tapeDrive\n";

#print "\tTHE OUPUT OF gcc Version used\n";
#print "\t-----------------------------\n";

#print "To capture the gcc Version in the Operating System\n\n";

# To find out the gcc Version in the OS

#chomp(my $gccVersion = qx!gcc -v!);
#print " The gcc version is $gccVersion";

print " patch 			@patch\n";

print " Server Name		$osN\n";
