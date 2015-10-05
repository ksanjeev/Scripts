 GetFileElimentFromClearCase.PL



 Deascription:

      This script fetches the versions of an element associated with a activity from Clearcase.
      The script gets input from the configuration file ( GetFileElimentFromClearCase.CFG ). 


 Usage:
	1) Edit the configuration file ( GetFileElimentFromClearCase.CFG )
	2) Run this script at command prompt as 'perl GetFileElimentFromClearCase.PL' 


 Returns:
	1) It creates folder for each activity specified in the "GetFileElimentFromClearCase.CFG" 
	   file and copies the associated versions of elements as per the change set.

	2) It builds the error log and event log files. If the size of the error log file is more 
	   than 0kb then we have an error. 


	3) Added as per edit history (2) below . 
	   It creates the directory tree for the element as how it exists in clearcase
           and copies the associated latest version for the element.



 Released on 11th April 2007 as  VersionScripts-04112007-1637.zip.




 Edit history:

1) Initial creation on 04/03/07
	Zipfile : VersionScripts-04032007-1657.zip

2) Modified and released on 04/11/07 
	Modification done:
		1) Added the feature for creating the directory tree according to ther clearcase 
		   for the element in change set of a given activity.
		2) Describing all the events in log files.
		3) Handles the file and folder names with space.


	Zipfile : VersionScripts-04112007-1637.zip

3) Modified and released on 04/13/07 
	Modification done:
		1) Fixing the error: ( Activity was repeated in the @activities array, because of the addition of activity by finding child activity)
		2) Finding the child activities for the contributing activities.
		3) Adding the feature to display on the console the list of events being carried out.


	Zipfile : VersionScripts-04132007-2107.zip





 Files and folders in the archive :
	1) GetFileElimentFromClearCase.pl
	2) GetFileElimentFromClearCase.CFG
	3) README.txt




 For any queries contact :
	Ashwinkumar Deshmukh at Ashwinkumar.Deshmukh@misyshealthcare.com
	T Saju Carlos at saju.thazchail@misyshealthcare.com
	Sharad Agrawal at Sharad.Agarwal@misyshealthcare.com
