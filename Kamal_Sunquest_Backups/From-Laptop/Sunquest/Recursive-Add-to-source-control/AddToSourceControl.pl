@rem= 'PERL for Windows NT -- ccperl must be in search path 
@echo off 
ccperl %0 %1 %2 %3 %4 %5 %6 %7 %8 %9 
goto endofperl 
@rem '; 

########################################### 
# Begin of Perl section 


$start_dir = $ARGV[0]; 

# 
# Fixed variable 
# 
$S = "\\"; 
$list_file = "c:".$S."list_file"; 
$list_add = "c:".$S."list_add"; 
$choosed = "c:".$S."choosed"; 


sub clean_file 
{ 
$status = system("del $list_file > NUL 2> NUL"); 
$status = system("del $list_add > NUL 2> NUL"); 
$status = system("del $choosed > NUL 2> NUL"); 
} 

# 
# Start of the script... 
# 

printf("add-to-src-control $start_dir...\n"); 

clean_file(); 
$status = system("cleartool ls -view_only -r -s $start_dir > $list_file"); 
open(LIST_ELEMENT,$list_file); 
while ($element=<LIST_ELEMENT>) 
{ 
chop $element; 
# printf " Processing $element "; 
if ($element =~ /CHECKEDOUT/) 
{ 
# printf(" checkedout file \n"); 
} 
else 
{ 
# printf " view private \n"; 
printf " Processing $element ...\n"; 

# 
# For files with spaces... 
# 
if ($element =~ / /) 
{ 
$status = system("cmd /c echo \"$element\" >> $list_add"); 
} 
else 
{ 
$status = system("cmd /c echo $element >> $list_add"); 
} 
} 
} 
close(LIST_ELEMENT); 

if (-e $list_add) 
{ 
$listelement = `type $list_add`; 
$listelement =~ s/\n/,/g; 
$status = `echo $listelement > $list_add`; 

$status = system("clearprompt list -outfile $choosed -dfile $list_add -choices 
-prompt \"Choose element(s) to put over version control : \" -prefer_gui"); 

if ($status != 0) 
{ 
# printf("\n Aborting ...\n"); 
clean_file(); 
exit $status; 
} 

# 
$listtoadd = `type $choosed`; 
$listtoadd =~ s/\n//g; 
printf("\n cleardlg /addtosrc $listtoadd"); 
$status = system("cleardlg /addtosrc $listtoadd"); 

clean_file(); 
exit $status; 
} 
else 
{ 
# printf("\n No files founded...\n"); 
clean_file(); 
exit $status; 
} 

# End of Perl section 

__END__ 
:endofperl