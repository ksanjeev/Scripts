@echo off
set EncVer=%1

cd C:\ENCOMPASS_BLD_VIEW\ENCOMPASS_CODE\Encompass\Database


"c:\Program Files\7-Zip\7z.exe" a -tzip views_%EncVer%.zip views -r 

"c:\Program Files\7-Zip\7z.exe" a -tzip DDL_%EncVer%.zip DDLFiles -r 

move *.zip C:\ENCOMPASS_BLD_VIEW

