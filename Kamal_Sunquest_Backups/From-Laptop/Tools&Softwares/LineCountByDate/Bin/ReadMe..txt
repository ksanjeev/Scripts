Name: lineCountByDate.exe

usage:  lineCountByDate.exe [-options] <path> startDate [endDate]

	*path is the full path of an individual file or a directory.  It is mandatory unless a configuration file is passed
	'startDate' the beginning date of the search. It is mandatory.
	'endDate' is optional. If it is not provided, it defaults to the current date/time.
	Dates need to be in the format of month/date/year, i.e. 2/10/06
         
options:
	-h, --help            show this help message and exit
	-i, --include         comma separated extensions of the files you wish to
                        diff (ie. c,CPP,ini).  This list need to be included in
                        the configuration file with the key='extList'
	-c CONFIGFILE, --configFile=CONFIGFILE
                        File containing information used to run this script.
                        All files and folders needs to be within the section
                        "[folders and files]".
	-s, --showDetails     shows the diffs between each and everyone of the file versions

Output file:
The tool will output a tab delimited .out based on the date and time the tool was run.  i.e. 2006_02_28_10_59_15.out


Examples:

1. To see how many lines has been change in the "s:\ice\Setup\Setup.cpp" file between 1/1/06 and 2/28/06. run:

	lineCountByDate.exe s:\ice\Setup\Setup.cpp 1/1/06 2/28/06


2. To see how many line has been changes in the files in the "s:\sdui\CUEStatusImp\ini" folder since 12/1/05. Run:

	lineCountByDate.exe s:\sdui\CUEStatusImp\ini 12/1/05


3. To see how many line change in the following folders and files since 2/1/06 in the lleung_dcs_tron_stab_view view.  Place the the folders and file in a configuration file, say "Diff.ini", section  [folders and files] like:

 [folders and files]
 W:\lleung_dcs_tron_stab_view\sdbuild\codebases\CUE\
 W:\lleung_dcs_tron_stab_view\ice\Setup\Setup.cpp

and run:

	lineCountByDate.exe -c Diff.ini 2/1/06


4. If in above example, you want to limited the file types to .c .cpp .h and .ini files only.  Add line "extList=c,CPP,h,ini" in the configuration file outside of the [folders and files] section, and run:

	lineCountByDate.exe -i -c Diff.ini 2/1/06

5. If you wanted to see every versions of the files changes, you need to add the '-s' options to the command:

	lineCountByDate.exe -i -c Diff.ini -s 2/1/06



