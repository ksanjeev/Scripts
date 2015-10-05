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

On Error Resume Next
strtmp = "Setup has determined that an old version Laboratory is installed on this system. If you continue with the installation, this version will be uninstalled and replaced with Laboratory version " + sProductVersion + ". If you do not continue, the installation will be canceled. Do you wish to continue?"
Dim MyVar

On Error Resume Next

sRegValue = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Laboratory" 

Err.Clear
Session.Property("OLDLAB") = oMSI.RegistryValue(2, sRegValue, "UninstallString")

sRegValue = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\FlexiLab"

Err.Clear
Session.Property("OLDFLEX") = oMSI.RegistryValue(2, sRegValue, "UninstallString")

sRegValue = Session.Property("OLDLAB")
If Len(sRegValue) > 0 Then
    MyVar = msgbox (strtmp, 4, "Question")

    If MyVar = 7 then
        CheckOldInstall = 1602
    End If

    sRegValue = "SOFTWARE\Misys\Hosp\Laboratory" 
    Err.Clear
    Session.Property("LAB_PRODUCT_CODES") = oMSI.RegistryValue(2, sRegValue, "Logfile Setting")
    
Else
    sRegValue = Session.Property("OLDFLEX")
    If Len(sRegValue) > 0 Then
        MyVar = msgbox (strtmp, 4, "Question")
        If MyVar = 7 then
            CheckOldInstall = 1602
        End If

		sRegValue = "SOFTWARE\Sunquest\FlexiLab" 
		Err.Clear
		Session.Property("LAB_PRODUCT_CODES") = oMSI.RegistryValue(2, sRegValue, "Logfile Setting")
	Else
		sRegValue = "SOFTWARE\Misys\Hosp\Laboratory" 
		Err.Clear
		Session.Property("LAB_PRODUCT_CODES") = oMSI.RegistryValue(2, sRegValue, "Logfile Setting")
'		msgbox Session.Property("LAB_PRODUCT_CODES")
    End If
End If

End Function

Public function checkdotnet11()
    Dim fso, temp
    Set fso = CreateObject("Scripting.FileSystemObject")
    pathspec = Session.Property("WindowsFolder") + "\Microsoft.NET\Framework\v1.1.4322\mscorcfg.dll"
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

Public function checkodp()
Set oMSI = CreateObject("WindowsInstaller.Installer")

On Error Resume Next

sRegValue = "SOFTWARE\Oracle\ODP.NET" 

Err.Clear

strodp = oMSI.RegistryValue(2, sRegValue)

'msgbox strodp
	If strodp = "True" then
		checkodp = 0
    Else
        myvar = msgbox ("Please Install Oracle ODP before installing Pharmacy", 0, "Warning")
        checkodp= 1602
    End If
End Function

Public function checkpserver()
Set oMSI = CreateObject("WindowsInstaller.Installer")

On Error Resume Next

sRegValue = "SOFTWARE\Misys\Hosp\Pharmacy Server" 

Err.Clear

strodp = oMSI.RegistryValue(2, sRegValue, "InstallPath")

If Len(strodp) = 0 Then
'msgbox strodp
'msgbox Session.Property("MNET")
	Session.Property("MNET") = "1"
'msgbox Session.Property("MNET")
End If
checkpserver = 0
End Function

Public function CheckOS()

Set oMSI = CreateObject("WindowsInstaller.Installer")

CheckOS = 0

On Error Resume Next
Err.Clear

If ( Session.Property("VersionNT") = 501 ) Then
	If ( Len(Session.Property("Version9X")) > 0 ) Then
		strtmp = "The only supported OS is Windows 2000, Windows XP and Windows 2003. Installation cannot continue."
		MyVar = msgbox (strtmp, 0, "SEVERE")
		CheckOS= 1602
	Else
		CheckOS = 0
	End IF
Else
	If ( Session.Property("VersionNT") = 500 ) Then
		If ( Session.Property("ServicePackLevel") < 3 ) Then
			strtmp = "Service pack is less than the minimum supported value 3 on Windows 2000. Installation cannot continue."
			MyVar = msgbox (strtmp, 0, "SEVERE")
			CheckOS= 1602
		Else
			CheckOS = 0
		End If
	Else
'Start of Siebel Change Request 1-45AE7M
	If ( Session.Property("VersionNT") = 502) Then
	     	CheckOS = 0
		Else
			strtmp = "The only supported OS is Windows 2000, Windows XP and Windows 2003. Installation cannot continue."
			MyVar = msgbox (strtmp, 0, "SEVERE")
			checkOS= 1602
'End of Siebel Change Request 1-45AE7M
	End If
	End If
End If

End Function

Public function UninstallOldLab()
UninstallOldLab = 0

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
    sRegValue = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Laboratory"
    sTmp1 = oMSI.RegistryValue(2, sRegValue, "UninstallString")
    If Len(sTmp1) > 0 Then
        MsgBox "Failed to uninstall Old Laboratory"
        UninstallOldLab = 1602
    End If
Else
    sRegValue = Session.Property("OLDFLEX")
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
        Set oExec = oWSHShell.Exec(mystr)
        Do While oExec.Status = 0
	    WScript.Sleep 100
        Loop
        sRegValue = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Flexilab"
        sTmp1 = oMSI.RegistryValue(2, sRegValue, "UninstallString")
        If Len(sTmp1) > 0 Then
            MsgBox "Failed to uninstall FlexiLab"
            UninstallOldLab = 1602
        End If
    End If
End If

'set oWSHShell = nothing

'Set oMSI = nothing

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

strtmp = "Setup has determined that Laboratory version " + svOldVersion + " is installed on this system. If you continue with the installation, this version will be uninstalled and replaced with Laboratory version " + sProductVersion + ". If you do not continue, the installation will be canceled. Do you wish to continue?"
Dim MyVar
MyVar = msgbox (strtmp, 4, "Question")

If MyVar = 7 then
    updateproduct = 1602
End If
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

	strtmp = "Setup has determined that Laboratory version " + svNewVersion + " is installed on this system. If you continue with the installation, this version will be uninstalled and replaced with Laboratory version " + sProductVersion + ". If you do not continue, the installation will be canceled. Do you wish to continue?"
	Dim MyVar
	MyVar = msgbox (strtmp, 4, "Question")

	If MyVar = 7 then
		Revertproduct = 1602
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

Set oMSI = CreateObject("WindowsInstaller.Installer")

On Error Resume Next

sRegValue = "SOFTWARE\Misys\Hosp\Pharmacy Client" 

Err.Clear

Session.Property("MISYS_EXEC_SHORTCUT_NAME") = oMSI.RegistryValue(2, sRegValue, "AppDesktopShortcutName")

'msgbox Session.Property("MISYS_EXEC_SHORTCUT_NAME")

Set oMSI = nothing

GetDESKTOPSHORTCUT = 0
End Function

Public function SetAppDesktopShortcutName()

Set oMSI = CreateObject("WindowsInstaller.Installer")

On Error Resume Next

sRegValue = "SOFTWARE\Misys\Hosp\Pharmacy Client" 

Err.Clear

If Session.Property("MISYS_ADD_EXEC_SHORTCUT") <> 1 Then
	Session.Property("MISYS_EXEC_SHORTCUT_NAME") = ""
'msgbox "david"
End If

Set oMSI = nothing

SetAppDesktopShortcutName = 0
End Function

Public function CreateDesktopIcon()

set oWSHShell = CreateObject("WScript.Shell")

sQt = Chr(34)

strtmp = Session.Property("MISYS_EXEC_SHORTCUT_NAME")

strDesktop = oWSHShell.SpecialFolders("AllUsersDesktop")

strtmp1 = strDesktop & "\" & strtmp & ".lnk"

dim oLink

set oLink = oWSHShell.CreateShortcut(strtmp1)

'msgbox "david1"

strtmp2 = Session.Property("NEW_DIRECTORY4") + "\SunquestPharmMES.exe"
'msgbox strtmp2
'strtmp3 = "-aLaboratory"
'msgbox strtmp2
'msgbox oLink.TargetPath
oLink.TargetPath = strtmp2
'oLink.Arguments = strtmp3

oLink.WindowStyle = 1

oLink.IconLocation = Session.Property("NEW_DIRECTORY4") + "\Sunquest.ico"

oLink.WorkingDirectory = Session.Property("NEW_DIRECTORY4")

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

Public function reportproperties()
Set fso = CreateObject("Scripting.FileSystemObject")
Set w = fso.CreateTextFile("e:\david.txt", 2)
w.WriteLine Session.Property("LABKEY")
w.WriteLine Session.Property("MSIA")
w.WriteLine Session.Property("INSTALLLEVEL")
msgbox Session.Property("INSTALLLEVEL")

Set fso = nothing
reportproperties = 0
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
			
			bVersion = 0
			If StrComp(sTmp1, "6", 1) >= 0 Then
'			If StrComp(sTmp1, "51", 1) >= 0 Then
				If StrComp(sTmp2, "0", 1) >= 0 Then
'					If StrComp(sTmp3, "2800", 1) >= 0 Then
					If StrComp(sTmp3, "3", 1) >= 0 Then
						If StrComp(sTmp4, "1106", 1) >= 0 Then
'						If StrComp(sTmp4, "21", 1) >= 0 Then
							bVersion = 1
						End If
					End If
				End If
			End If
        End If
        
        If bVersion = 0 Then
			sMinVersion = "6.0.2800.1106"
		    strtmp = "Internet Explorer version " & sMinVersion & " or above is required by Laboratory" & Chr(13) & Chr(10) & "Do you want to install the required components?" & Chr(13) & Chr(10)
		    MyVar = msgbox (strtmp, 4, "Question")

		    If MyVar = 7 then
				CheckIE = 1602
			Else
	          	mystr = Session.Property("SourceDir") & "\..\..\3rd Party\IE6\ie6Setup.exe"
'	          	msgbox mystr		
				set oWSHShell = CreateObject("WScript.Shell")
'				nreturn = oWSHShell.Run (mystr, 1, true)
				nreturn = oWSHShell.Run ("notepad", 1, true)
'			    Set oExec = oWSHShell.Exec(mystr)
			    
'				Do While oExec.Status = 0
'					oWSHShell.Sleep 100
'				Loop
			    set oWSHShell = nothing
		    End If
        End If
    End If
    
    Set oMSI = nothing
    set fso = nothing
    
End Function









