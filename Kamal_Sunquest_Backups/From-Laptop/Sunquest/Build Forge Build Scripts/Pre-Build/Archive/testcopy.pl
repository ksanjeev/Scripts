#!/usr/bin/perl -w
#
# testcopy.pl

use strict;

my $myCommand='xcopy /Y "M:\AutoBuild_SRM_TEST_INT\BF_LAB_CACHE_OBJECTS\RobertTest.xml" "C:\LAB_BLD_VIEW\BF_LAB_CACHE_OBJECTS\" ';

print "\nMyCommand equals: $myCommand\n";

my $myResult = system($myCommand);

print "\nMyResult equals: $myResult\n";

#return 0;


