REM
REM Trigger to change element ownership
REM 
cleartool rmtype -rmall trtype:STD_CHANGE_OWNER
cleartool mktrtype -c "Trigger to change element ownership" -element -all -postop mkelem -execwin "ccperl \\azclearcase1\Trigger_Storage\std_change_owner.pl" STD_CHANGE_OWNER

