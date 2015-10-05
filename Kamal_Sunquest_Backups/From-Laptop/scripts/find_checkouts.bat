subst /D s:
subst s: w:\tzhpradm_ruby_release_source_view
s:
cd btapp
cleartool lscheckout -all >> d:\Files_Info\Checkouts\checkouts_btapp.xls
cd ..
cd bttaj
cleartool lscheckout -all >> d:\Files_Info\Checkouts\checkouts_bttaj.xls
cd ..
cleartool lsprivate >> d:\Files_Info\Private_Files\privates.xls
