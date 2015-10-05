@rem= 'PERL for Windows NT - ccperl must be in search path
@echo off
ccperl %0 %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
@rem ';

$COMPUTERNAME   = $ENV{COMPUTERNAME};
$VOB            = $ENV{CLEARCASE_VOB_PN};
$filename       = $ENV{CLEARCASE_PN};

$owner = `cleartool describe -long vob:$VOB | findstr owner | findstr \/v ownership`;
$owner =~ s/owner //g;
$owner =~ s/ //g;
chop $owner;

$group = `cleartool describe -long vob:$VOB | findstr group | findstr \/v ownership`;
$group =~ s/group //g;
$group =~ s/ //g;
chop $group;

if (!($owner eq "") and !($group eq "")) {
        $status = system("cleartool protect -chown $owner -chgrp $group \"$filename\"");
        exit $status;
} fi


# End of Perl section

__END__
:endofperl
