#! /usr/bin/perl -w
use strict;

my $backupOption;
my $specialConfig;
my @specialConfig;
 
system("query process > tivoli_list");

if ($? == 0)
{
my $backupOption = "Tivoli";
print " Tivoli is found\n";
}
else
{
my $backupOption = "";
print "Tivoli is not found\n";
}
print "The Backup Option is $backupOption\n";

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
print "The special config in the server is @specialConfig";
}
}
print "The Special configuration is not found in the server\n";

my @dataredundancy;

system("lsdev -C | grep 'RAID 5' > raid ");
if ($? == 0)
{
push @dataredundancy, "RAID 5";
}
else
{
print " No data Redundancy is present\n";
}
print "The dataredundancy list is @dataredundancy\n";
