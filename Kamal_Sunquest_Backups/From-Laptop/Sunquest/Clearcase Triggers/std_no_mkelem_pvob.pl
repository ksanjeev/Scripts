@rem = ' PERL for Windows NT - ccperl must be in search path
@echo off
ccperl %0 %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
@rem ';

my $text = "Error : The Project VOB (PVOB) should not be used to version files or directories.";

my $status = system("clearprompt proceed -prompt \"$text\" -mask abort -prefer_gui");

exit 1;
# __END__
# :endofperl
