rem Author: Pavan Rayadurg (pavan.rayadurg@trianz.com)
rem Photosmart Essential Build
echo ON

call "%VS80COMNTOOLS%vsvars32.bat"

REM ==========================================================================
rem format D: /V:Data /Q /X

REM ======= start : vendor specific variables =========
set vendor_vob=btbuild
set vendor_name=trianz
set vendor=bt
REM ======= end : vendor specific variables =========

c:


set product_name=psp
set release_name=onyx

echo "Started the build for %product_name% : %release_name%"

set view_name=%USERNAME%_%vendor%_%release_name%_view
rem cleartool rmview -force -tag %view_name%
set msi_view_name=%USERNAME%_PS_Onyx_MSI_Release_View

cleartool mkview -tag %view_name% -tco "Dynamic View for %product_name% - %release_name%" -tmode insert_cr \\%COMPUTERNAME%\ViewStore\%view_name%.vws

cleartool mount \%vendor_vob%
cleartool mount \sdtajscripts
cleartool mount \dpe_onyx
cleartool mount \dcs_shared
cleartool mount \cuebin1
cleartool mount \ndbuild
cleartool mount \3rdparty3

cleartool setcs -tag %view_name% c:\Baloo\cspec\bt-onyx-release-bootstrap.cspec

w:

subst /D s:
subst /D q:
subst /D R:
subst /D T:

subst s: w:\%view_name%
subst q: s:\dpe_onyx
subst R: D:\build-archive
subst T: D:\BuildTools
rem subst t: \\izfilesrv\RUBY\CodeBaseShared

s:  
cd s:\sdtajscripts\scripts

nant /f:psp-release.build -l:nant_out_msm.log -verbose -D:vendor.name=trianz -D:solution.config=Release psp.build.msm

if errorlevel 1 goto failedBuild

:successBuild
nant /f:psp-release.build -D:logfile=nant_out_msm.log -D:param.access.type=internal -verbose -D:vendor.name=trianz -D:param.buildtype=msm -D:buildResult=Succeeded psp.archive.log

d:
subst /D s:
subst s: w:\%msi_view_name%
s:
cd s:\sdtajscripts\scripts
nant /f:psp-release.build -verbose -D:vendor.name=trianz psp.build.msi

c:
subst /D s:

CALL C:\Baloo\Scripts\trianz_source_labelling.bat

cleartool rmview -force -tag %view_name%
goto end

:failedBuild
nant /f:psp-release.build -D:logfile=nant_out_msm.log -D:param.access.type=internal -verbose -D:vendor.name=trianz -D:param.buildtype=msm -D:buildResult=Failed psp.archive.log

date /T
time /T
echo "Build failed !!!"
@pause

:end
