#! /usr/bin/perl -w
use strict;
use Shell;

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
my @gccVersion1;
my @tapeDrive;
my @sqnsvVersion;
my @mzfVersion;
my $backupOption;
my $specialConfig;
my @specialConfig;
my @dataredundancy;

# to print the node name or the Server name 
chomp(my $osN=qx!uname -n!);

print " Server Name :	$osN\n\n";

print " Field Name 	Possible Values        \n";
print "----------------------------------------\n";

#print "This method gets the version stored in a variable and put into an array\n\n";

# To capture the output of the Cache version into a variable
chomp(my $cache_vers = qx!cache "^VERSION"!);

# converting the string into an array
my @cache_vers = split(/\s/,$cache_vers);

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

print " dbType		@dbType\n";
print " dbVersion	@dbVersion\n";

#print "It gets the version of the Operating System and stores in a array\n\n";

# To print the version of the operating system
chomp(my $osVr1=qx!oslevel!);

# To push the osVersion type into an array
push @osVersion1, "$osVr1"; 

print " osVersion	@osVersion1\n";

# to print the architecture of the system processor
chomp(my $osP=qx!uname -p!);

# to print the system name or the operating System 
chomp(my $osOS=qx!uname -s!);

# to push the operating system name into the array
push @osName, "$osOS";
print " osName		@osName\n";

# To assign operating Type as Unix if OS is AIX
if ($osOS eq "AIX" || $osOS eq "aix")
{
my $osType = "UNIX";
push @osType, "$osType";
}

print " osType		@osType\n";

# To capture the patch names in a file
system("sh patch.sh");

# To get the contents of the file into an array
my $patch = "patch_names";
open(DAT,$patch) || die("Could not open the file");
@patch = <DAT>;
close(DAT);

# To delete the newline
chomp(@patch);

# To print the patches
print " patch";
foreach my $i (@patch)
{
print "\t\t$i\n";
}

# To find out the machine type in a variable
chomp(my $hwModel=qx!sh machine1.sh!);

# To push the Hardware model into an array
push @hwModel, "$hwModel";

print " hwModel	@hwModel\n";

#print "It makes use of the machine type to capture the hardware type of the server into an array\n\n";

my $hwType;

if ($hwModel eq ("43P" ||"42P") )
{
  $hwType = "IBM-RISC";
}

# To push the hardware type into an array
push @hwType, "$hwType";

print " hwType		@hwType\n";

# To find out the number of processors 
chomp(my $numProc=qx!lscfg | grep -c "^+ proc"!);

print " numProc	$numProc\n";

# To get the sqnsv version into an variable
chomp(my $sqnsvVersion = qx!sh sqnsv.sh!);

# To push the contents into an array
push @sqnsvVersion,"$sqnsvVersion";

print " sqnsvVersion	@sqnsvVersion\n"; 

# To get the mzf version into an variable
chomp(my $mzfVersion = qx!sh mzfVersion.sh!);

# To push the contents into an array
push @mzfVersion,"$mzfVersion";

print " mzfVersion	@mzfVersion\n"; 

# To capture the patch names in a file
system("sh tape.sh");

# To get the contents of the file into an array
my $tape = "tapes";

open(DAT, $tape) || die("cannot open file");
@tapeDrive = <DAT>;
close(DAT);

print " tapeDrive";
foreach my $i (@tapeDrive)
{
  $i =~ s/\s+/:/g;
  $i =~ s/:/ /g;
  print "\t$i\n";
}

# To get the output in a file
system("sh gcc.sh");

# to get the file into an array
my $gccVersion = "gccversion";

open(DAT,$gccVersion) || die ("Could not open the file");
@gccVersion=<DAT>;
close(DAT);

#To push the gcc Version into an array
push @gccVersion1,"$gccVersion[0]"; 

print " gccVersion 	@gccVersion1\n";

system("query process > tivoli_list");

if ($? == 0)
{
my $backupOption = "Tivoli";
}
else
{
my $backupOption = " ";
}

print " backupOption 	$backupOption\n";

system("lsdev -S available -Cchdisk -Fname > physical");

my $hdisk = "physical";

open(DAT,$hdisk) || die("Could not open the file");
my @hdisk = <DAT>;
close(DAT);

foreach my $i (@hdisk)
{
system("ssaidentify -l $i -y > ssaidentity");
if ($? == 0)
{
push @specialConfig, "SSA";
last;
}
}

print " specialConfig	@specialConfig\n";

system("lsdev -C | grep 'RAID 5' > raid");
if ($? == 0)
{
push @dataredundancy, "RAID 5";
}

print " dataredundancy	@dataredundancy\n";
