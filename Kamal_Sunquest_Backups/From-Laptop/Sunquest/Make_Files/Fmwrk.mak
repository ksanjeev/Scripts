.SUFFIXES:  *.bas *.cls *.vb *.resX

.\RAD_BLD_VIEW\RAD_GUI\Solutions\Film\bin\FMWRK.dll:
        devenv.exe /build release Fmwrk.sln
