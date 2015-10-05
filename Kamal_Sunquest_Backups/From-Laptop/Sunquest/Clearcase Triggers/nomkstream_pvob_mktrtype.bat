REM
REM TEMPORARY - Trigger to prevent users to create a private development stream
REM 
cleartool rmtype -rmall trtype:NO_MKSTREAM_PVOB
cleartool mktrtype -c "Trigger to avoid mkelem command on a PVOB" -ucmobject -all -preop mkstream -nuser outram,laconico,vob_admin -execwin "ccperl \\az-ccvob1\Trigger_Storage\no_mkstream_pvob.pl" NO_MKSTREAM_PVOB