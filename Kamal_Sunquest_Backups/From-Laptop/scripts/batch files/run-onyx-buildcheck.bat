rem Author: Pavan Rayadurg (pavan.rayadurg@trianz.com)
rem Photosmart Essential Doxygen API generation
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

rem cleartool update -print -log e:\update-logs\log.txt e:\ViewStore\tzhpradm_Onyx_Doxygen_view

echo "Started the BuildCheck for PSE - ONYX"

subst /D s:
subst /D q:
subst /D R:
subst /D T:

subst s: e:\viewstore\tzhpradm_PS_Onyx_BuildCheck_view
subst q: s:\dpe_onyx
subst R: D:\build-archive
subst T: D:\BuildTools

s:
cd s:\btbuild\scripts

echo " Updating the snapshot view folders before generating doxygen..."
cleartool update -force -overwrite -ptime -log NUL s:\btapp
cleartool update -force -overwrite -ptime -log NUL s:\bttaj
cleartool update -force -overwrite -ptime -log NUL s:\btbuild

nant /f:s:\btbuild\scripts\default.build -D:folder.name=s:\dpe_onyx\cue-components\bt -D:delete.private.flag=true ccase.findcheckouts
nant /f:s:\btbuild\scripts\default.build -D:folder.name=s:\dpe_onyx\btapp -D:delete.private.flag=true ccase.findcheckouts
nant /f:s:\btbuild\scripts\default.build -D:folder.name=s:\dpe_onyx\bttaj -D:delete.private.flag=true ccase.findcheckouts
nant /f:s:\btbuild\scripts\default.build psp.delete.deploy.buildlogs.folders

rem nant -verbose -D:solution.config=Release -D:imgmgr.buildflag=true all

if errorlevel 1 goto failedBuild

:successBuild
nant /f:s:\sdtajscripts\scripts\psp-release.build -D:logfile=nant_out_msm.log -D:param.access.type=internal -verbose -D:vendor.name=trianz -D:param.buildtype=msm -D:buildResult=Succeeded psp.archive.log

goto end

:failedBuild
rem nant /f:s:\sdtajscripts.scripts\psp-release.build -D:logfile=nant_out_msm.log -D:param.access.type=internal -verbose -D:vendor.name=trianz -D:param.buildtype=msm -D:buildResult=Failed psp.archive.log
nant /f:s:\sdtajscripts.scripts\psp-release.build -D:logfile=nant_out_msm.log -D:param.access.type=internal -verbose -D:vendor.name=trianz -D:param.buildtype=msm -D:buildResult=Failed task.version.read psp.debug-build-notification.send

date /T
time /T
echo "Build failed !!!"
@pause


date /T
time /T



