rem Batch file to remove and apply labels on the latest versions 
rem Author: Pavan Rayadurg (pavan.rayadurg@trianz.com}
rem Note: This batch file is not intended to be modified by anyone other than the Trianz Build Team members.
rem ==========================================================================================================

w:
cd tzhpradm_PS_Onyx_MSI_Release_view
cd btapp
cleartool rmtype -rmall -force lbtype:TRIANZ_CODECLEANUP_SOURCE_LATEST
cleartool mklbtype -nc TRIANZ_CODECLEANUP_SOURCE_LATEST
cleartool mklabel -replace -recurse TRIANZ_CODECLEANUP_SOURCE_LATEST w:\tzhpradm_PS_Onyx_MSI_Release_view\btapp
cd ..
cd bttaj
cleartool rmtype -rmall -force lbtype:TRIANZ_CODECLEANUP_SOURCE_LATEST
cleartool mklbtype -nc TRIANZ_CODECLEANUP_SOURCE_LATEST
cleartool mklabel -replace -recurse TRIANZ_CODECLEANUP_SOURCE_LATEST w:\tzhpradm_PS_Onyx_MSI_Release_view\bttaj
cd ..
cd btbuild
cleartool rmtype -rmall -force lbtype:TRIANZ_CODECLEANUP_SOURCE_LATEST
cleartool mklbtype -nc TRIANZ_CODECLEANUP_SOURCE_LATEST
cleartool mklabel -replace -recurse TRIANZ_CODECLEANUP_SOURCE_LATEST w:\tzhpradm_PS_Onyx_MSI_Release_view\btbuild
cd ..
cd sdtajscripts
cleartool rmtype -rmall -force lbtype:TRIANZ_CODECLEANUP_SOURCE_LATEST
cleartool mklbtype -nc TRIANZ_CODECLEANUP_SOURCE_LATEST
cleartool mklabel -replace -recurse TRIANZ_CODECLEANUP_SOURCE_LATEST w:\tzhpradm_PS_Onyx_MSI_Release_view\sdtajscripts
