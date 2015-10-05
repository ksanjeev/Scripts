

Option Explicit


Dim gLogFile
Const cLogFileName = "prereqreport.log"

' Error Return Values
' Refer to RunPreReqChecks\RunPreReqChecks.h
Const cSuccess = 0
Const cInvalidParametersNoOutput = -2
Const cInvalidParameters = -3
Const cRegularExpressionFailure = -9

' *************************************************************************
' This function attempts to open a file at the specified path.  If it
' succeeds, True is returned.  Else, false is returned.
' *************************************************************************
Function HasWriteAccess(path)
	Dim FSO, fileName
	Dim fileObject

	On Error Resume Next

	Set FSO = createobject("Scripting.FileSystemObject")

	fileName = FSO.GetTempName

	set fileObject = FSO.CreateTextFile(path & fileName)

	If Err Then
		HasWriteAccess = False
		WriteLog("VBSTEST.VBS: HasWriteAccess - WARNING. Path " & path & " does not have write access")
	Else
		fileObject.Close
		FSO.DeleteFile(path & fileName)
		HasWriteAccess = True
		WriteLog("VBSTEST.VBS: HasWriteAccess. Path " & path & " does have write access")
	End If

	On Error Goto 0

End Function

' *************************************************************************
' This function provides a temp path.  To be used by the ExecuteCmd function.
' *************************************************************************
Function GetTempPath
	Dim WshShell, FSO
	Dim tempFile
	Dim tempPath, tmpPath
	Dim file

	Set WshShell = CreateObject("WScript.Shell")

	' Expand the environment variables and test each for write access

	tempPath = WshShell.ExpandEnvironmentStrings("%TEMP%") & "\"
	tmpPath = WshShell.ExpandEnvironmentStrings("%TMP%") & "\"

	if tempPath <> "%TEMP%\" and HasWriteAccess(tempPath) then
		GetTempPath = tempPath
	elseif tmpPath <> "%TMP%\" and HasWriteAccess(tmpPath) then
		GetTempPath = tmpPath
	else
		' we know this is writable by the user...it's his directory!
		GetTempPath = WshShell.ExpandEnvironmentStrings("%USERPROFILE%") & "\"
	end if

	WriteLog("VBSTEST.VBS: GetTempPath - Returning temporary path " & GetTempPath)

End Function

' ***************************************************************************
' Initialize the log file
' ***************************************************************************
Function InitLog
	Dim logFSO, logFileName, logPath

	Set logFSO = createobject("Scripting.FileSystemObject")

	logPath = GetTempPath()

	logFileName = logPath & "\" & cLogFileName

	set gLogFile = logFSO.OpenTextFile(logFileName, 8, true)

End Function

' ***************************************************************************
' Writes string to log file, preprending time stamp info
' ***************************************************************************
Function WriteLog(logString)
        Dim myTime

        myTime = Time

        If IsObject(gLogFile) Then
                gLogFile.WriteLine (myTime & ": " & logString)
        End If

End Function

' ***************************************************************************
' Close the log file
' ***************************************************************************
Function CloseLog()
        gLogFile.Close
End Function

' ***************************************************************************
' Initialize logs and call the main function
' ***************************************************************************
Function Main()

	On Error Resume Next

	Dim rCode, argList
	Dim iCount
	Dim cmdOutput

	' Default error value
	rCode = cInvalidParametersNoOutput

	InitLog()
	WriteLog (" ")
	WriteLog (" ")
	WriteLog ("VBSTEST.VBS: Main - Entry *********************************")


	Set argList = WScript.Arguments

	WriteLog ("VBSTEST.VBS: Main - Parameters:")
	For iCount = 0 To (argList.length - 1)
	        WriteLog ("VBSTEST.VBS: Main - arg(" & iCount & ") = " & argList(iCount))
	Next

	' Test regular expression operation
	Dim RegEx, Matches, Match
	Set RegEx = new RegExp
	RegEx.Global = True
	RegEx.Pattern = "\w+=\w+\S*"
	cmdOutput = "Status=5"

	Set Matches = RegEx.Execute(cmdOutput)
	For Each Match in Matches
		Dim splitArray, name, value

		splitArray = split(Match.value,"=")
		name = splitArray(0)
		value = splitArray(1)
	Next

	If value <> 5 Then
		WriteLog ("VBSTEST.VBS: Main - Regular Expression Failed")
		rCode = cRegularExpressionFailure
	Else
		rCode = cSuccess
		'rCode = cRegularExpressionFailure	'Unit Test
		'rCode = cInvalidParametersNoOutput	'Unit Test
	End If

	' Return
	WriteLog ("VBSTEST.VBS: Main - Return Code:" & rCode)
	WriteLog ("VBSTEST.VBS: Main - Exit  *********************************")
	CloseLog()
	WScript.Quit (rCode)
End Function

Main()
