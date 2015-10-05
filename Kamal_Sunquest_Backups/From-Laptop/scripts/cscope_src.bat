@echo off
rem - cscope tool is used to build the cscope database for faster lookup of c/c++ functions/variables/call graph etc.
rem - It can be used with Vim7, Emacs and standalone also.
rem - download windows version of cscope from http://iamphet.nm.ru/cscope/index.html
rem - Enter ":help cscope" in Vim to get details on how to use cscope.
rem - Unix utils at : http://unxutils.sourceforge.net/
echo "Build cscope database.."
d:\vim\vim7\vim\vim70\cscope -b -R -s s:\btapp -s s:\bttaj -I q:\cue-components\nd\SharedInc -I q:\cue-components\SharedInc -v
echo "Build cscope database completed successfully.."
