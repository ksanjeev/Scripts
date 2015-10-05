@rem = ' PERL for Windows NT -- ccperl must be in search path 
@echo off 
ccperl %0 %1 %2 %3 %4 %5 %6 %7 %8 %9 
goto endofperl 
@rem '; 
# 
# 
# Variable to be modified 
# 
$targetPATH = 'D:\Scripts\Utilities\UnderProduction\Backup_VOB'; 
# 
# End Variable to be modified 
# 
############################################################################## 
# 
# 
# Global variable definition 
# 
#if ($ENV{TEMP}) { 
#$TDIR=$ENV{TEMP}; } 
#else { 
#$TDIR="c:${S}temp";}


my $TDIR = 'D:\Scripts\Utilities\UnderProduction\Backup_VOB'; 


#$COMPUTERNAME = $ENV{COMPUTERNAME};
$COMPUTERNAME = 'MHICC-TST1';

$S = "\\"; 
$PERL = "perl"; 
$NULL = $TDIR . $S . "null"; 
$JUNK = $TDIR . $S . "junk"; 
$TMPFX = $TDIR . $S . "." . $$; 

$TMP_VOBINFO = $TMPFX . ".VOBstuff";



$COPYCMD = "ccopy "; 
$MDEP_TIME_STAMP = 'cmd /c echo y | cmd /c time'; 
$MDEP_DATE_STAMP = 'cmd /c echo y | cmd /c date'; 
$MDEP_RMDIR_COMMAND = 'cmd /c rmdir /s '; 
$MDEP_RMFILE_COMMAND = 'cmd /c del'; 
$MDEP_ECHO = 'cmd /c echo'; 
# 
# 
# End of global variable definition 
# 
############################################################################## 
# 
# 
# Function definition 
# 
sub system_redirect { 
local($command) = @_[0]; 
local($ret_status); 
local($tmpname); 
$tmpname = &mdep_get_tmpname(); 
$ret_status = system("$command > $tmpname 2>&1"); 
# 
# Don't call mdep_rmfile - it calls system_redirect. 
# 
system("$MDEP_RMFILE_COMMAND $tmpname"); 
return $ret_status; 
}





sub mdep_rmfile { 
local($file) = @_[0]; 
local($status); 
if($file eq "") { 
return $RTN_PATH_NULL; 
} 
$status = &system_redirect("$MDEP_RMFILE_COMMAND \"$file\""); 
if($status) { 
return $RTN_NOT_OK; 
} 

return $RTN_OK; 
}




sub mdep_rmdir { 
local($dirpath) = @_[0]; 
local($status); 
if($dirpath eq "") { 
print "null directory\n"; 
return(-1); 
} 
if(! -d $dirpath) { 
print "directory $dirpath doesn't exist\n"; 
return(-1); 
} 
$status = &system_redirect("$MDEP_ECHO Y | $MDEP_RMDIR_COMMAND \"$dirpath\""); 
return($status); 
}



sub mdep_get_tmpname { 
$VOB_recover_tmpseq++; 
return "${TDIR}\\backupVOB.$$.${VOB_recover_tmpseq}"; 
}




sub mdep_get_time { 
local($tmpname); 
local($line); 
local($date); 
local($time); 
local($r_string) = ""; 
$tmpname = &mdep_get_tmpname(); 
system("$MDEP_DATE_STAMP > $tmpname"); 
open(GETDATE,$tmpname); 
foreach $line (<GETDATE>) { 
chop $line; 
if($line =~ /The current date is:\s+[a-zA-Z]+\s+(.*)/) { 
$date = $1; last; 
} 
} 
close(GETDATE); 
system("$MDEP_TIME_STAMP > $tmpname"); 
open(GETTIME,$tmpname); 
foreach $line (<GETTIME>) { 
chop $line; 
if($line =~ /The current time is:\s+(.*)/) {$time = $1; last} 
} 
close(GETTIME); 
&mdep_rmfile($tmpname); 
$r_string = "$date $time"; 
return($r_string); 
}




# 
# 
# End of function definition 
# 
############################################################################## 
$tstamp = &mdep_get_time(); 
printf "Backup script started : $tstamp \n"; 

system("cleartool lsvob -host $COMPUTERNAME > $TMP_VOBINFO 2> $JUNK"); 

open(VOBS,$TMP_VOBINFO); 
while ($VOB=<VOBS>)
{ 
    my ($active, $VOBtag, $VOBstrg) = split(/\s+/,$VOB); 
    print "\nCopying up : $VOBtag to $targetPATH$VOBtag \n"; 

    my $cmd = "cleartool lock VOB:$VOBtag";
    system($cmd); 

    if( -d $targetPATH.$VOBtag)
    { 
        mdep_rmdir($targetPATH.$VOBtag);
    } 

    $cmd = "mkdir $targetPATH$VOBtag";
    system($cmd); 
    print ".";

    $cmd = "$COPYCMD $VOBstrg\\groups.sd $targetPATH$VOBtag\\groups.sd";
    system($cmd); 
    print ".";

    $cmd = "$COPYCMD $VOBstrg\\identity.sd $targetPATH$VOBtag\\identity.sd";
    system($cmd); 
    print ".";

    $cmd = "$COPYCMD $VOBstrg\\replica_uuid $targetPATH$VOBtag\\replica_uuid";
    system($cmd); 
    print ".";

    $cmd = "$COPYCMD $VOBstrg\\VOB_oid $targetPATH$VOBtag\\VOB_oid";
    system($cmd); 
    print ".";

    $cmd = "$COPYCMD $VOBstrg\\VOB_server.conf $targetPATH$VOBtag\\VOB_server.conf";
    system($cmd); 
    print ".";

    $cmd = "$COPYCMD $VOBstrg\\admin $targetPATH$VOBtag\\admin";
    system($cmd); 
    print ".";

    $cmd = "$COPYCMD $VOBstrg\\c $targetPATH$VOBtag\\c";
    system($cmd); 
    print ".";

    $cmd = "$COPYCMD $VOBstrg\\d $targetPATH$VOBtag\\d";
    system($cmd); 
    print ".";

    $cmd = "$COPYCMD $VOBstrg\\db $targetPATH$VOBtag\\db";
    system($cmd); 
    print ".";

    $cmd = "$COPYCMD $VOBstrg\\s $targetPATH$VOBtag\\s";
    system($cmd); 
    print "\n";

    $cmd = "cleartool unlock VOB:$VOBtag";
    system($cmd); 
    print "\n"; 
} 
close(VOBS); 

&mdep_rmfile($TMP_VOBINFO); 
&mdep_rmfile($JUNK); 
$tstamp = &mdep_get_time(); 
printf "Backup script stopped : $tstamp \n"; 
__END__ 
:endofperl