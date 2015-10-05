Const INSTALLMESSAGE_ACTIONSTART = &H08000000
Const INSTALLMESSAGE_ACTIONDATA  = &H09000000 
Const INSTALLMESSAGE_PROGRESS    = &H0A000000 

' ----------
' deferred action to increment ticks while action is taking place
'
Function AddProgressInfo( )

Set rec = Installer.CreateRecord(3)

rec.StringData(1) = "callAddProgressInfo"
rec.StringData(2) = "Uninstalling the Old Laboratory ..."
rec.StringData(3) = "Incrementing tick [1] of [2]"

Message INSTALLMESSAGE_ACTIONSTART, rec

rec.IntegerData(1) = 1
rec.IntegerData(2) = 1
rec.IntegerData(3) = 0

Message INSTALLMESSAGE_PROGRESS, rec

Set progrec = Installer.CreateRecord(3)

progrec.IntegerData(1) = 2
progrec.IntegerData(2) = 5000
progrec.IntegerData(3) = 0

rec.IntegerData(2) = 100000000

For i = 0 To 100000000 Step 5000
    rec.IntegerData(1) = i
    ' action data appears only if a text control subscribes to it
    Message INSTALLMESSAGE_ACTIONDATA, rec
    Message INSTALLMESSAGE_PROGRESS, progrec
Next ' i

' return success to MSI
AddProgressInfo = 0
End Function

' ----------
' immediate action that adds a number of "ticks" to the progress bar
'
Function AddTotalTicks( )

Set rec = Installer.CreateRecord(3)

rec.IntegerData(1) = 3
rec.IntegerData(2) = 500000000 ' total ticks to add
rec.IntegerData(3) = 0

Message INSTALLMESSAGE_PROGRESS, rec

Set rec = Nothing

' return success to MSI
AddTotalTicks = 0
End Function



Public function CheckOldInstall()

CheckOldInstall = 0
Set oMSI = CreateObject("WindowsInstaller.Installer")

sQt = Chr(34)

sProductVersion = Session.Property("ProductVersion")
On Error Resume Next
strtmp = "Setup has determined that an old version Radiology is installed on this system. If you continue with the installation, this version will be uninstalled and replaced with Radiology version " + sProductVersion + ". If you do not continue, the installation will be cancelled. Do you wish to continue?"
Dim MyVar

On Error Resume Next

sRegValue = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Radiology" 

Err.Clear
Session.Property("OLDLAB") = oMSI.RegistryValue(2, sRegValue, "UninstallString")

sRegValue = Session.Property("OLDLAB")
If Len(sRegValue) > 0 Then
	if Session.Property("UILevel") <> 4 Then
        MyVar = msgbox (strtmp, 4, "Question")

        If MyVar = 7 then
            CheckOldInstall = 1602
        End If
    End IF
End If

End Function

Public function checkdotnet11()
    Dim fso, temp
    Set fso = CreateObject("Scripting.FileSystemObject")
    pathspec = Session.Property("WindowsFolder") + "\Microsoft.NET\Framework\v1.1.4322\mscorcfg.dll"
    On Error Resume Next
    temp = fso.GetFileVersion(pathspec)
    If Len(temp) Then
        If temp = "1.1.4322.573" then
            checkdotnet11 = 0
        Else
            myvar = msgbox ("Please Install DOTNET framework 1.1 before installing Laboratory", 0, "Warning")
            checkdotnet11= 1602
        End If
    Else
        myvar = msgbox ("Please Install DOTNET framework 1.1 before installing Laboratory", 0, "Warning")
        checkdotnet11= 1602
    End If
End Function


Public function CheckOS()

Set oMSI = CreateObject("WindowsInstaller.Installer")

CheckOS = 0

On Error Resume Next
Err.Clear

If ( Session.Property("VersionNT") = 501 ) Then
    if ( Session.Property("ServicePackLevel") < 2 ) Then
		strtmp = "Service pack is less than the minimum supported value 2 on Windows XP. Installation cannot continue."
		MyVar = msgbox (strtmp, 0, "SEVERE")
		CheckOS= 1602
	Else
		CheckOS = 0
	End IF
Else
	If ( Session.Property("VersionNT") = 500 ) Then
		If ( Session.Property("ServicePackLevel") < 4 ) Then
			strtmp = "Service pack is less than the minimum supported value 4 on Windows 2000. Installation cannot continue."
			MyVar = msgbox (strtmp, 0, "SEVERE")
			CheckOS= 1602
		Else
			CheckOS = 0
		End If
	Else
		If ( Session.Property("VersionNT") = 502 ) Then
			If ( Session.Property("ServicePackLevel") < 1 ) Then
				strtmp = "Service pack is less than the minimum supported value 1 on Windows 2003. Installation cannot continue."
				MyVar = msgbox (strtmp, 0, "SEVERE")
				CheckOS= 1602
			Else
				CheckOS = 0
			End If
		Else
			strtmp = "The only supported OS is Windows 2000, Windows XP and Windows 2003. Installation cannot continue."
			MyVar = msgbox (strtmp, 0, "SEVERE")
			CheckOS= 1602
		End If
	End If
End If


End Function

Public function UninstallOldLab()
UninstallOldLab = 0

On Error Resume Next
Set oMSI = CreateObject("WindowsInstaller.Installer")

set oWSHShell = CreateObject("WScript.Shell")

sQt = Chr(34)

On Error Resume Next
sRegValue = Session.Property("OLDLAB")
'MsgBox sRegValue
If Len(sRegValue) > 0 Then
    On Error Resume Next
    Err.Clear
    MyPos = Instr(1, sRegValue, "-f", 1)
    firststr = Left ( sRegValue, MyPos -2)
    MyLen = Len (sRegValue)
    MyLen1 = MyLen - myPos - 2
    mystr = Right ( sRegValue, MyLen1 )
    MyLen = Len (mystr)
    sRegValue = Left ( mystr, MyLen -1 )
    mystr = firststr + " -a -f" + sQt + sRegValue + sQt
'MsgBox mystr
    Set oExec = oWSHShell.Exec(mystr)
    Do While oExec.Status = 0
	WScript.Sleep 100
    Loop
    sRegValue = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Radiology"
    sTmp1 = oMSI.RegistryValue(2, sRegValue, "UninstallString")
    If Len(sTmp1) > 0 Then
        MsgBox "Failed to uninstall Old Radiology"
        UninstallOldLab = 1602
    End If
End If

set oWSHShell = nothing

Set oMSI = nothing

End Function

Public function updateproduct()

Set oMSI = CreateObject("WindowsInstaller.Installer")

updateproduct = 0

On Error Resume Next
Err.Clear
szOldProductsValue = Session.Property("OLDPRODUCTS")
'msgbox szOldProductsValue
if Len(szOldProductsValue) > 0 then
sProductVersion = Session.Property("ProductVersion")

sRegValue = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" + szOldProductsValue
Err.Clear
svOldVersion = oMSI.RegistryValue(2, sRegValue,"DisplayVersion")

strtmp = "Setup has determined that Radiology version " + svOldVersion + " is installed on this system. If you continue with the installation, this version will be uninstalled and replaced with Radiology version " + sProductVersion + ". If you do not continue, the installation will be canceled. Do you wish to continue?"
Dim MyVar
	if Session.Property("UILevel") <> 4 Then
		MyVar = msgbox (strtmp, 4, "Question")

		If MyVar = 7 then
			updateproduct = 1602
		End If
	end if
end if

End Function


Public function Revertproduct()

Set oMSI = CreateObject("WindowsInstaller.Installer")

Revertproduct = 0

On Error Resume Next
Err.Clear
szNewProductsValue = Session.Property("NEWPRODUCTFOUND")
if Len(szNewProductsValue) > 0 then
	sProductVersion = Session.Property("ProductVersion")

	sRegValue = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" + szNewProductsValue
	Err.Clear
	svNewVersion = oMSI.RegistryValue(2, sRegValue,"DisplayVersion")

	strtmp = "Setup has determined that Radiology version " + svNewVersion + " is installed on this system. If you continue with the installation, this version will be uninstalled and replaced with Radiology version " + sProductVersion + ". If you do not continue, the installation will be canceled. Do you wish to continue?"
	Dim MyVar
	if Session.Property("UILevel") <> 4 Then
    	MyVar = msgbox (strtmp, 4, "Question")

	    If MyVar = 7 then
		     Revertproduct = 1602
    	End If
  	End If
end if

End Function


Public function GetInstallLevel()

Set oMSI = CreateObject("WindowsInstaller.Installer")

GetInstallLevel= 0

On Error Resume Next
Err.Clear
if Session.EvaluateCondition("&ADTO=3") <> 0 then
MsgBox 'The ADTO feature is being installed'
end if 

str = Session.Property("LABADTO")
msgbox str
str = Session.Property("LABBB")
msgbox str
str = Session.Property("LABBILLING_MAINTENANCE")
msgbox str
str = Session.Property("LABCALLBACK")
msgbox str
str = Session.Property("LABCCALLS")
msgbox str
str = Session.Property("LABDFK")
msgbox str
str = Session.Property("LABGENLAB")
msgbox str
str = Session.Property("LABIQ")
msgbox str
str = Session.Property("LABLARS")
msgbox str
str = Session.Property("LABMICRO")
msgbox str
str = Session.Property("LABSMART")
msgbox str
str = Session.Property("LABUAK")
msgbox str

Set oMSI = nothing

End Function

Public function GetDESKTOPSHORTCUT()
Dim sTemp
Set oMSI = CreateObject("WindowsInstaller.Installer")

On Error Resume Next

sRegValue = "SOFTWARE\Misys\Hosp\Radiology" 

Err.Clear
' Beginning of Siebel Change Request 1-27Y0MB-2
'Session.Property("MISYS_EXEC_SHORTCUT_NAME") = oMSI.RegistryValue(2, sRegValue, "AppDesktopShortcutName")
 sTemp = oMSI.RegistryValue(2, sRegValue, "AppDesktopShortcutName")
 MyPos = Instr(1, sTemp, "sqstart", 1)
If (MyPos > 0 ) Then
	Session.Property("MISYS_EXEC_SHORTCUT_NAME") = "Sunquest Radiology"
Else
	Session.Property("MISYS_EXEC_SHORTCUT_NAME") = oMSI.RegistryValue(2, sRegValue, "AppDesktopShortcutName")
End If
' End of Siebel Change Request 1-27Y0MB-2
'msgbox Session.Property("MISYS_EXEC_SHORTCUT_NAME")

Set oMSI = nothing

GetDESKTOPSHORTCUT = 0
End Function

Public function GetDESKTOPSHORTCUT1()

Set oMSI = CreateObject("WindowsInstaller.Installer")

On Error Resume Next

sRegValue = "SOFTWARE\Misys\Hosp\Radiology" 

Err.Clear

strtmp = oMSI.RegistryValue(2, sRegValue, "AppDesktopShortcutName")

On Error Resume Next

If Len(strtmp) > 0 Then
    Session.Property("MISYS_EXEC_SHORTCUT_NAME") = strtmp
    Session.Property("MISYS_ADD_EXEC_SHORTCUT") = 1
End IF

'msgbox Session.Property("MISYS_EXEC_SHORTCUT_NAME")

Set oMSI = nothing

GetDESKTOPSHORTCUT1 = 0
End Function

Public function SetAppDesktopShortcutName()

Set oMSI = CreateObject("WindowsInstaller.Installer")

On Error Resume Next

sRegValue = "SOFTWARE\Misys\Hosp\Radiology" 

Err.Clear

If Session.Property("MISYS_ADD_EXEC_SHORTCUT") <> 1 Then
	Session.Property("MISYS_EXEC_SHORTCUT_NAME") = ""
'msgbox "david"
End If

Set oMSI = nothing

SetAppDesktopShortcutName = 0
End Function

Public function CreateDesktopIcon()

'msgbox "david"
set oWSHShell = CreateObject("WScript.Shell")
'msgbox "david1"

sQt = Chr(34)

strtmp = Session.Property("MISYS_EXEC_SHORTCUT_NAME")

strDesktop = oWSHShell.SpecialFolders("AllUsersDesktop")

strtmp1 = strDesktop & "\" & strtmp & ".lnk"

dim oLink

set oLink = oWSHShell.CreateShortcut(strtmp1)

'msgbox "david1"

If StrComp(Session.Property("MISYSCLIENTUPDATERENABLED"), "1", 1) = 0 Then
	strtmp2 = Session.Property("CommonFilesFolder") + "Misys\Hosp\cu.exe"
	oLink.Arguments = "-aRadiology"
	oLink.IconLocation = Session.Property("NEW_DIRECTORY3") + "MrStart.exe"
Else
	strtmp2 = Session.Property("NEW_DIRECTORY3") + "MrStart.exe"
End if
oLink.TargetPath = strtmp2

'oLink.Arguments = strtmp3

oLink.WindowStyle = 1

oLink.IconLocation = Session.Property("CommonFilesFolder") + "Misys\Hosp\Sunquest.ico"

oLink.WorkingDirectory = Session.Property("NEW_DIRECTORY3")

oLink.Save

set oLink = nothing

set oWSHShell = nothing
'msgbox "david"

CreateDesktopIcon = 0
End Function


Public function DeleteDesktopIcon()

set oWSHShell = CreateObject("WScript.Shell")

sQt = Chr(34)

strtmp = Session.Property("MISYS_EXEC_SHORTCUT_NAME")
On Error Resume Next

If Len(strtmp) > 0 Then

	strDesktop = oWSHShell.SpecialFolders("AllUsersDesktop")

	strtmp1 = strDesktop & "\" & strtmp & ".lnk"

	Set fso = CreateObject("Scripting.FileSystemObject")

	fso.DeleteFile (strtmp1)

	set fso = nothing

End If

set oWSHShell = nothing
'msgbox "david"

DeleteDesktopIcon = 0
End Function

Public function DeleteDesktopIconR()

set oWSHShell = CreateObject("WScript.Shell")

sQt = Chr(34)

strtmp = Session.Property("MISYS_EXEC_SHORTCUT_NAME")
On Error Resume Next

If Len(strtmp) > 0 Then

	strDesktop = oWSHShell.SpecialFolders("AllUsersDesktop")

	strtmp1 = strDesktop & "\" & strtmp & ".lnk"

	Set fso = CreateObject("Scripting.FileSystemObject")

	fso.DeleteFile (strtmp1)

	set fso = nothing

End If

set oWSHShell = nothing
'msgbox "david"

DeleteDesktopIconR = 0
End Function


Public function reportproperties()
Set fso = CreateObject("Scripting.FileSystemObject")
Set w = fso.CreateTextFile("D:\david.txt", 2)
w.WriteLine Session.Property("LABKEY")
w.WriteLine Session.Property("MSIA")
w.WriteLine Session.Property("LABADTO")
w.WriteLine Session.Property("LABADTO1")
w.WriteLine Session.Property("INSTALLLEVEL")
w.WriteLine Session.Property("INSTALLDIR")
msgbox Session.Property("INSTALLDIR")

Set fso = nothing
reportproperties = 0
End Function

Public function CheckScriptHost()
set oWSHShell = CreateObject("WScript.Shell")

sVer = oWSHShell.Version
MyPos = Instr(1, sVer, ".", 1)
sTmp1 = mid (sVer, 1, MyPos - 1 )
sTmp2 = mid (sVer, MyPos + 1, Len(temp) - MyPos )
msgbox sVer
msgbox sTmp1
msgbox sTmp2

CheckScriptHost = 0

End Function


Public Function CheckIE()

	CheckIE = 0
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set oMSI = CreateObject("WindowsInstaller.Installer")

    sRegValue = "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\iexplore.exe"
    sTmp1 = oMSI.RegistryValue(2, sRegValue, "Path")
    If Len(sTmp1) = 0 Then
        MsgBox "Failed to locate iexplore.exe"
        CheckIE = 1602
    Else
        MyPos = Instr(1, sTmp1, ";", 1)
        If MyPos > 0 Then
			sTmp2 = mid (sTmp1, 1, Len(sTmp1) -1 )
			sTmp1 = sTmp2
		End If
		sTmp1 = sTmp1 & "\iexplore.exe"
        temp = fso.GetFileVersion(sTmp1)
        If Len(temp) = 0 Then
	        MsgBox "Failed to obtain the version of iexplore.exe"
		    CheckIE = 1602
		Else
	        MyPos = Instr(1, temp, ".", 1)
	        sTmp1 = mid (temp, 1, MyPos - 1 )
	        MyPos1 = Instr(MyPos + 1, temp, ".", 1)
	        sTmp2 = mid (temp, MyPos + 1, MyPos1 - MyPos - 1)
	        MyPos = Instr(MyPos1 + 1, temp, ".", 1)
	        sTmp3 = mid (temp, MyPos1 + 1, MyPos - MyPos1 - 1)
	        sTmp4 = mid (temp, MyPos + 1, Len(temp) - MyPos )
'msgbox temp
			bVersion = 0
' Beginning of Siebel Change Request 1-1B7GNN
			nTmp1 = Cint(sTmp1)
			nTmp2 = Cint(sTmp2)
			nTmp3 = Cint(sTmp3)
			nTmp4 = Cint(sTmp4)
			If nTmp1 > 6 Then
				bVersion = 1
			Else
				If nTmp1 = 6 Then
					If nTmp2 > 0 Then
						bVersion = 1
					Else
						If nTmp2 = 0 Then
							If nTmp3 > 2800 Then
								bVersion = 1
							Else
' Beginning of Siebel Change Request 1-1BUCFH-1
								If nTmp3 = 2800 Then
' End of Siebel Change Request 1-1BUCFH-1
									If nTmp4 >= 1106 Then
										bVersion = 1
									End If
								End If
							End If
						End If
					End If
				End If
			End If
        End If
'			If StrComp(sTmp1, "6", 1) >= 0 Then
'			If StrComp(sTmp1, "51", 1) >= 0 Then
'				If StrComp(sTmp2, "0", 1) >= 0 Then
'					If StrComp(sTmp3, "2800", 1) >= 0 Then
'					If StrComp(sTmp3, "3", 1) >= 0 Then
'						If StrComp(sTmp4, "1106", 1) >= 0 Then
'						If StrComp(sTmp4, "21", 1) >= 0 Then
'							bVersion = 1
'						End If
'					End If
'				End If
'			End If
'        End If
' End of Siebel Change Request 1-1B7GNN
'msgbox bVersion
        If bVersion = 0 Then
			sMinVersion = "6.0.2800.1106"
		    strtmp = "Internet Explorer version " & sMinVersion & " or above is required by Laboratory" & Chr(13) & Chr(10) & "Do you want to install the required components?" & Chr(13) & Chr(10)
		    MyVar = msgbox (strtmp, 4, "Question")

		    If MyVar = 7 then
				CheckIE = 1602
			Else
'	          	mystr = Session.Property("SourceDir") & "\..\..\3rd Party\IE6\ie6Setup.exe"
'	          	msgbox mystr		
'				set oWSHShell = CreateObject("WScript.Shell")
'				nreturn = oWSHShell.Run (mystr, 1, true)
'				nreturn = oWSHShell.Run ("notepad", 1, true)
'			    Set oExec = oWSHShell.Exec(mystr)
			    
'				Do While oExec.Status = 0
'					oWSHShell.Sleep 100
'				Loop
'			    set oWSHShell = nothing
				Session.Property ("NEEDSINSTALLIE") = "1"
		    End If
        End If
    End If
    
    Set oMSI = nothing
    set fso = nothing
    
End Function



Public Function CheckIE1()

	CheckIE1 = 0
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set oMSI = CreateObject("WindowsInstaller.Installer")

    sRegValue = "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\iexplore.exe"
    sTmp1 = oMSI.RegistryValue(2, sRegValue, "Path")
    If Len(sTmp1) = 0 Then
        MsgBox "Failed to locate iexplore.exe"
        CheckIE1 = 1602
    Else
        MyPos = Instr(1, sTmp1, ";", 1)
        If MyPos > 0 Then
			sTmp2 = mid (sTmp1, 1, Len(sTmp1) -1 )
			sTmp1 = sTmp2
		End If
		sTmp1 = sTmp1 & "\iexplore.exe"
        temp = fso.GetFileVersion(sTmp1)
        If Len(temp) = 0 Then
	        MsgBox "Failed to obtain the version of iexplore.exe"
		    CheckIE1 = 1602
		Else
	        MyPos = Instr(1, temp, ".", 1)
	        sTmp1 = mid (temp, 1, MyPos - 1 )
	        MyPos1 = Instr(MyPos + 1, temp, ".", 1)
	        sTmp2 = mid (temp, MyPos + 1, MyPos1 - MyPos - 1)
	        MyPos = Instr(MyPos1 + 1, temp, ".", 1)
	        sTmp3 = mid (temp, MyPos1 + 1, MyPos - MyPos1 - 1)
	        sTmp4 = mid (temp, MyPos + 1, Len(temp) - MyPos )
'msgbox temp
			bVersion = 0
' Beginning of Siebel Change Request 1-1B7GNN
			nTmp1 = Cint(sTmp1)
			nTmp2 = Cint(sTmp2)
			nTmp3 = Cint(sTmp3)
			nTmp4 = Cint(sTmp4)
			If nTmp1 > 6 Then
				bVersion = 1
			Else
				If nTmp1 = 6 Then
					If nTmp2 > 0 Then
						bVersion = 1
					Else
						If nTmp2 = 0 Then
							If nTmp3 > 2800 Then
								bVersion = 1
							Else
' Beginning of Siebel Change Request 1-1BUCFH-1
								If nTmp3 = 2800 Then
'								If nTmp3 = 0 Then
' End of Siebel Change Request 1-1BUCFH-1
									If nTmp4 >= 1106 Then
										bVersion = 1
									End If
								End If
							End If
						End If
					End If
				End If
			End If
        End If
'			If StrComp(sTmp1, "6", 1) >= 0 Then
'			If StrComp(sTmp1, "51", 1) >= 0 Then
'				If StrComp(sTmp2, "0", 1) >= 0 Then
'					If StrComp(sTmp3, "2800", 1) >= 0 Then
'					If StrComp(sTmp3, "3", 1) >= 0 Then
'						If StrComp(sTmp4, "1106", 1) >= 0 Then
'						If StrComp(sTmp4, "21", 1) >= 0 Then
'							bVersion = 1
'						End If
'					End If
'				End If
'			End If
'        End If
' End of Siebel Change Request 1-1B7GNN
        If bVersion = 0 Then
			sMinVersion = "6.0.2800.1106"
		    strtmp = "Internet Explorer was not installed correctly." & Chr(13) & Chr(10) & "Please rerun the IE install?" & Chr(13) & Chr(10)
		    MyVar = msgbox (strtmp, 0, "Error")
			CheckIE1 = 1602
        End If
    End If
    
    Set oMSI = nothing
    set fso = nothing
    
End Function


Public function CheckCrystall()
Dim fso
Set fso = CreateObject("Scripting.FileSystemObject")

CheckCrystall = 0
Set oMSI = CreateObject("WindowsInstaller.Installer")

sQt = Chr(34)

On Error Resume Next

sRegValue = "SOFTWARE\Crystal Decisions\9.0\Crystal Reports" 
strcrystall = oMSI.RegistryValue(2, sRegValue)
If strcrystall = "True" then
	sRegValue = "SOFTWARE\Crystal Decisions\9.0\Report Designer Component" 
	strcrystall1 = oMSI.RegistryValue(2, sRegValue)
	If strcrystall1 = "True" then
		Session.Property("MISYSINSTALLCRYSTALL") = "0"
	Else
		Session.Property("CRYSTALFILES") = Session.Property("CommonFilesFolder") & "Crystal Decisions\2.0\bin"
		Session.Property("NEW_DIRECTORY7") = Session.Property("CRYSTALFILES")
		Session.Property("MISYSINSTALLCRYSTALL") = "1"
	End If
Else
	Session.Property("CRYSTALFILES") = Session.Property("CommonFilesFolder") & "Crystal Decisions\2.0\bin"
	Session.Property("NEW_DIRECTORY7") = Session.Property("CRYSTALFILES")
	Session.Property("MISYSINSTALLCRYSTALL") = "1"
End If

strVariableValue = Session.Property("CommonFilesFolder") & "Crystal Decisions\2.0\bin"
Set WshShell = CreateObject("WScript.Shell")
Set WshSystemEnv = WshShell.Environment("SYSTEM")
oldstr = WshSystemEnv("PATH")
MyPos = Instr(1,oldstr, "Crystal Decisions\2.0\bin",1)
If MyPos = 0 Then
    WshSystemEnv("PATH") = oldstr & ";" & strVariableValue 
End If

End Function

Public function checkCache()
Set oMSI = CreateObject("WindowsInstaller.Installer")
checkCache = 0
On Error Resume Next

sRegValue = "SOFTWARE\InterSystems\Cache ODBC\3.2"

Err.Clear

strodp = oMSI.RegistryValue(2, sRegValue)

'msgbox strodp
	If strodp = "True" then
		Session.Property("MISYSCACHEODBC") = "0"
    Else
		Session.Property("MISYSCACHEODBC") = "1"
End If
End Function

Public function CreateProgramShortCut()

set oWSHShell = CreateObject("WScript.Shell")

sQt = Chr(34)

strDesktop = oWSHShell.SpecialFolders("AllUsersPrograms")

Set fso = CreateObject("Scripting.FileSystemObject")

strtmp1 = strDesktop & "\Misys"

If ( Not fso.FolderExists(strtmp1) ) Then
    If ( Not fso.FileExists(strtmp1) ) Then
	Set f = fso.CreateFolder(strtmp1)
    Else
        Exit Function
    End If
End IF

strtmp1 = strtmp1 & "\Hosp"

If ( Not fso.FolderExists(strtmp1) ) Then
    If ( Not fso.FileExists(strtmp1) ) Then
	Set f = fso.CreateFolder(strtmp1)
    Else
        Exit Function
    End If
End IF

strtmp1 = strtmp1 & "\Radiology"

If ( Not fso.FolderExists(strtmp1) ) Then
    If ( Not fso.FileExists(strtmp1) ) Then
	Set f = fso.CreateFolder(strtmp1)
    Else
        Exit Function
    End If
End If

' Beginning of Siebel Change Request 1-2C0NOG

sTmp = Session.Property("LIVEORTEST")

if sTmp = "1" Then   
	'Selected Live area.
	strtmp1 = strtmp1 & "\Live"  
else
	strtmp1 = strtmp1 & "\Test"
End If
If ( Not fso.FolderExists(strtmp1) ) Then
    If ( Not fso.FileExists(strtmp1) ) Then
	Set f = fso.CreateFolder(strtmp1)
    Else
        Exit Function
    End If
End If

' End of Siebel Change Request 1-2C0NOG
strtmp = "MrStart"

strtmp5 = strtmp1 & "\" & strtmp & ".lnk"

dim oLink

set oLink = oWSHShell.CreateShortcut(strtmp5)

oLink.Arguments = ""
If StrComp(Session.Property("MISYSCLIENTUPDATERENABLED"), "1", 1) = 0 Then
	strtmp2 = Session.Property("CommonFilesFolder") + "Misys\Hosp\cu.exe"
	oLink.Arguments = "-aRadiology"
	oLink.IconLocation = Session.Property("NEW_DIRECTORY3") + "MrStart.exe"
Else
	strtmp2 = Session.Property("NEW_DIRECTORY3") + "MrStart.exe"
End if
oLink.TargetPath = strtmp2

oLink.WindowStyle = 1

oLink.WorkingDirectory = Session.Property("NEW_DIRECTORY3")

oLink.Save

CreateProgramShortCut = 0
End Function

Public function DeleteProgramShortCut()

set oWSHShell = CreateObject("WScript.Shell")

sQt = Chr(34)

On Error Resume Next

strDesktop = oWSHShell.SpecialFolders("AllUsersPrograms") + "\Misys\Hosp\Radiology"

Set fso = CreateObject("Scripting.FileSystemObject")

strtmp1 = strDesktop & "\MrStart.lnk"

fso.DeleteFile (strtmp1)

strDesktop = oWSHShell.SpecialFolders("AllUsersPrograms") + "\Misys\Hosp\Radiology"

Set f = fso.GetFolder(strDesktop)
Set fc = f.Files
count = 0
For Each f1 in fc
	count = count + 1
Next

If count = 0 Then
    fso.DeleteFolder (strDesktop)
    strDesktop = oWSHShell.SpecialFolders("AllUsersPrograms") + "\Misys\Hosp"

    Set f = fso.GetFolder(strDesktop)
    count = 0
	Set sfc = f.SubFolders
	For Each f1 in sfc
	    count = count + 1
    Next
    Set fc = f.Files
    For Each f1 in fc
	    count = count + 1
    Next

    If count = 0 Then
        fso.DeleteFolder (strDesktop)
        strDesktop = oWSHShell.SpecialFolders("AllUsersPrograms") + "\Misys"

        Set f = fso.GetFolder(strDesktop)
       count = 0
       Set sfc = f.SubFolders
       For Each f1 in sfc
			count = count + 1
	   Next
      Set fc = f.Files
		For Each f1 in fc
			count = count + 1
		Next

		If count = 0 Then
		    fso.DeleteFolder (strDesktop)
		End If
	End If
End If



set fso = nothing


set oWSHShell = nothing
'msgbox "david"

DeleteProgramShortCut = 0
End Function


Public function GetWord()
GetWord = 0
Set oMSI = CreateObject("WindowsInstaller.Installer")
Set fso = CreateObject("Scripting.FileSystemObject")
On Error Resume Next

sRegValue = "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\WinWord.exe"


sTmp1 = oMSI.RegistryValue(2, sRegValue, "Path")  
c = mid ( sTmp1, len(sTmp1), 1 )
if strComp( c, "\" ) = 0 Then
	sTmp1 = mid ( sTmp1, 1, len(sTmp1) -1 )
end if
Session.Property("MISYSWORDFOLDER") =  sTmp1
Session.Property("MISYSWORDFOLDER1") =  sTmp1  & "\WinWord.exe"
Session.Property("MISYSTRANPACK") =  "WORD"
sTmp1 = sTmp1 & "\WinWord.exe"
If ( Not fso.FileExists(sTmp1) ) Then
	strtmp = "Word Processing Application " & Chr(13) & Chr(10) & sTmp1 & Chr(13) & Chr(10) & "File Not Found In Specified Path."
	MyVar = msgbox (strtmp, 0, "Error")
	GetWord = 1602
End If         
set fso = nothing
set oMSI = nothing
End Function

Public function CheckMamm()
CheckMamm = 0       
Set oMSI = CreateObject("WindowsInstaller.Installer")
Set fso = CreateObject("Scripting.FileSystemObject")
On Error Resume Next

sTmp1 = Session.Property("MISYSMAMMFOLDER") & "\mrs.exe"
If ( Not fso.FileExists(sTmp1) ) Then
	strtmp = "Mammography Reporting " & Chr(13) & Chr(10) & sTmp1 & Chr(13) & Chr(10) & "File Not Found In Specified Path."
	MyVar = msgbox (strtmp, 0, "Error")
	CheckMamm = 1602
End If         
set fso = nothing
set oMSI = nothing
End Function  

Public function CheckAdHoc()
CheckAdHoc = 0       
Set oMSI = CreateObject("WindowsInstaller.Installer")
Set fso = CreateObject("Scripting.FileSystemObject")
On Error Resume Next
                  
                  
If Session.Property("MISYSADHOC") = "1" Then
	sRegValue = "SOFTWARE\Crystal Decisions\9.0\Crystal Reports"
 	sTmp1 = oMSI.RegistryValue(2, sRegValue, "Path")
	c = mid ( sTmp1, len(sTmp1), 1 )
	if strComp( c, "\" ) = 0 Then
		sTmp1 = mid ( sTmp1, 1, len(sTmp1) -1 )
	end if
	Session.Property("MISYSADHOCPACK") =  "CRW"
	Session.Property("MISYSADHOCFOLDER") =  sTmp1
	Session.Property("MISYSADHOCFOLDER2") =  sTmp1 & "\crw32.exe"
	sTmp1 = sTmp1 & "\crw32.exe"
	If ( Not fso.FileExists(sTmp1) ) Then
		Session.Property("MISYSADHOCPACK") =  "NONE"
		strtmp = "Adhoc Application " & Chr(13) & Chr(10) & sTmp1 & Chr(13) & Chr(10) & "File Not Found In Specified Path."
		MyVar = msgbox (strtmp, 0, "Error")
		CheckAdHoc = 1602
	End If         
End If

If Session.Property("MISYSADHOC") = "2" Then
	sRegValue = "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\MSACCESS.exe"
 	sTmp1 = oMSI.RegistryValue(2, sRegValue, "Path")
	c = mid ( sTmp1, len(sTmp1), 1 )
	if strComp( c, "\" ) = 0 Then
		sTmp1 = mid ( sTmp1, 1, len(sTmp1) -1 )
	end if
	Session.Property("MISYSADHOCPACK") =  "ACCESS"
	Session.Property("MISYSADHOCFOLDER") =  sTmp1
	Session.Property("MISYSADHOCFOLDER2") =  sTmp1 & "\MSACCESS.exe"
	sTmp1 = sTmp1 & "\msaccess.exe"
	If ( Not fso.FileExists(sTmp1) ) Then
		Session.Property("MISYSADHOCPACK") =  "NONE"
		strtmp = "Adhoc Application " & Chr(13) & Chr(10) & sTmp1 & Chr(13) & Chr(10) & "File Not Found In Specified Path."
		MyVar = msgbox (strtmp, 0, "Error")
		CheckAdHoc = 1602
	End If         
End If

set fso = nothing
set oMSI = nothing
End Function

'Beginning of Siebel Change Request 1-39EYE7-1

Public Function CheckTranscription()

checkWord = 0

Set oMSI = CreateObject("WindowsInstaller.Installer")

Set fso = CreateObject("Scripting.FileSystemObject")

On Error Resume Next

sRegValue = "SOFTWARE\Misys\Hosp\Radiology\Transcription"

sTmp = oMSI.RegistryValue(2,sRegValue,"TRANPACK")

If sTmp <> "" Then 
   Session.Property("MISYSWORD") = "1"  
   GetWord()
'Beginning of Siebel Change Request 1-3EWBA1
   Session.Property("INSTALLLEVEL") = "120"
'End of Siebel Change Request 1-3EWBA1 
End If
 
End Function

'End of Siebel Change Request 1-39EYE7-1