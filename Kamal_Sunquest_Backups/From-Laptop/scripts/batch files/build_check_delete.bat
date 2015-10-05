rem Author: Pavan Rayadurg (pavan.rayadurg@trianz.com)
rem Photosmart Essential Build Check Delete
echo ON

call "%VS80COMNTOOLS%vsvars32.bat"

REM ==========================================================================
rem format D: /V:Data /Q /X

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
cd \btbuild\scripts\release

nant -verbose /f:s:\btbuild\scripts\release\psp-bt-release.build -D:solution.config=Release -D:assembly.type="" -D:vendor.name=trianz delete.dpe_onyx.folders

CALL c:\Baloo\Scripts\build_check.bat

:end

