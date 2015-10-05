REM
REM Trigger to prevent users to version a file or directory in the PVOB
REM 
cleartool rmtype -rmall trtype:STD_NO_MKELEM_PVOB
cleartool mktrtype -c "Trigger to avoid mkelem command on a PVOB" -element -all -preop mkelem -execwin "ccperl \\azclearcase1\Trigger_Storage\std_no_mkelem_pvob.pl" STD_NO_MKELEM_PVOB

