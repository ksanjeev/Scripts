rem Author: Pavan Kumar Rayadurg (pavan.rayadurg@trianz.com)
rem Company: Trianz Consulting Pvt Ltd.
rem Photosmart Essential Build Check batch file

echo ON
REM ==========================================================================
rem format D: /V:Data /Q /X

call "%VS80COMNTOOLS%vsvars32.bat"

c:

subst /D s:
subst /D q:
subst /D R:
subst /D T:

subst s: e:\viewstore\tzhpradm_PS_Onyx_BuildCheck_view
subst q: s:\dpe_onyx
subst R: D:\build-archive
subst T: D:\BuildTools
rem subst t: \\izfilesrv\RUBY\CodeBaseShared

s:  
cd s:\btbuild\scripts

nant -verbose -D:solution.config=Release -D:imgmgr.buildflag=true all


