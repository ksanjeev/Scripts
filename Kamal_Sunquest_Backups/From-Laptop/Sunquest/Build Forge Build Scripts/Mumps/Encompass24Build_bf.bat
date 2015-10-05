@echo off
setlocal

set AntHome=D:\apache-ant-1.6.1
set AntBin=%AntHome%\bin

set EncVer=%1
set DistVer=V%1
set RootDir=C:\ENCOMPASS_BLD_VIEW

echo Encver=%Encver%
echo DistVer=%DistVer%
     
set ScriptDir=%CD%
echo ScriptDir=%ScriptDir%

set EncompassDir=%RootDir%\Encompass%EncVer%
echo EncompassDir=%EncompassDir%


set BackupDir=%RootDir%\Backup%EncVer%
echo BackupDir=%BackupDir%

rem set OutputDir=%EncompassDir%\Code\Application\Output
rem set OutputDir=%RootDir%\Encompass_Code\Encompass\Application\Output
set OutputDir=C:\Builds\Encompass\AppDeploy\Encompass24\Code\Application\Output
echo OutputDir=%OutputDir%


rem set SourceDir=%EncompassDir%\Code\Application\Source
set SourceDir=%RootDir%\Encompass_Code\Encompass\Application\Source
echo SourceDir=%SourceDir%


set ZipDir=%EncompassDir%\ZipBuild
echo ZipDir=%ZipDir%


set ZipFile=%ZipDir%\Encompass%EncVer%.zip
echo ZipFile=%ZipFile%

set ZipFileName=Encompass%EncVer%.tar
echo ZipFileName=%ZipFileName%


set CompareReport=%ScriptDir%\Enc%EncVer%Diff.txt
echo CompareReport=%CompareReport%


set Common=\\Cmbf-encompass\Encompass_ZIP

rem cls

set Cont=%2

::set /P Cont=Would you like to continue with this build? (Y/N) : 

If "%Cont%"=="Y" goto ChangesFound
::Pause
Exit

:ChangesFound



echo Proceeding for the build.....

set TM=%TIME%

echo %TM%
set DT=%DATE%
set AP=PM


set HH=%TM:~0,2%
set MM=%TM:~3,2%
set SS=%TM:~6,2%
set HN=%TM:~9,2%
set SA=%SS%.%HN%

set /a H=%HH%
if %H% LSS 10 set HH=0%H%
IF "%HH%" LSS "12" set AP=AM
IF "%HH%" GTR "12" set /a H=%H%-12
IF %H% EQU 0 set H=12


set DY=%DT:~0,3%
set NN=%DT:~4,2%
set DD=%DT:~7,2%
set CC=%DT:~10,2%
set YY=%DT:~12,2%
set YYYY=%CC%%YY%

set BuildNum=%YYYY%%NN%%DD%_%HH%%MM%
echo %BuildNum%
::pause



echo function getVersion(){return "%DistVer% Build %BuildNum%";} > "%sourceDir%\JSP\version.js"



rmdir /S /Q "%SourceDir%\testing"


cd %ScriptDir%
rem pause
echo about to call ant build

call %AntBin%\ant -buildfile "%ScriptDir%\build.xml"
call %AntBin%\ant -buildfile "%RootDir%\build.xml"
echo done with ant build!


rmdir /S /Q "%ZipDir%"
mkdir "%ZipDir%"

echo Moving files to appropriate locations
xcopy /E /R /Y /I /Q "%SourceDir%\com\diagnostix\utility\*.properties" "%ZipDir%\webapps\Encompass\WEB-INF\classes\com\diagnostix\utility"
xcopy /E /R /Y /I /Q "%OutputDir%\com\*.*" "%ZipDir%\webapps\Encompass\WEB-INF\classes\com"
xcopy /E /R /Y /I /Q "%SourceDir%\HTML\*.*" "%ZipDir%\webapps\Encompass"
xcopy /E /R /Y /I /Q "%SourceDir%\JSP\*.*" "%ZipDir%\webapps\Encompass"

echo Creating deploy zip
"D:\Program Files\7-Zip\7z" a -tzip "%ZipFile%" -r "%ZipDir%\*"

echo copying deploy zip to repository
xcopy /Y /Q "%ZipFile%" "%Common%"

xcopy /Y /Q "%ZipFile%" "%DistDir%"

echo *** Build of Encompass %DistVer% build %BuildNum% Complete ***
::pause

exit 

:errlev
echo.
echo ***
echo *** BUILD ABORTED -- BUILD ABORTED -- BUILD ABORTED
echo ***
echo.
echo ***
echo *** BUILD ABORTED -- ErrorLevel is non-zero!
echo ***
echo.
echo ***
echo *** BUILD ABORTED -- BUILD ABORTED -- BUILD ABORTED
echo ***

net start McShield
::pause

