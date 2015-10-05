rem ***************************************************************************
rem Regcheck.vbs 
rem 
rem usageString = <successcode> <failurecode> <failureid> <rootkey> <regkey> 
rem [regvalue]
rem Checks a registry key, returning the specified error code if it is 
rem present.
rem
rem <successcode>	Value to return if the key is found or matched.  Will also
rem					be returned as 'Status=successcode'._
rem <failurecode>	Value to return if the key is not found.  Also returned as
rem 				'Status=failurecode
rem <failureid>		Message ID to return on failure. Format is 
rem 				'MessageID=failureid'
rem <rootkey>		Root Registry key.  Ex: HKEY_LOCAL_MACHINE_
rem <regkey>		Key to match.  Ex: Software\SoftwareCompany\Key
rem [regvalue]		Option string to match against the key value.  Ex: Value
rem
rem Copyright (c) 2004 Dell Incorporated
rem ***************************************************************************

rem ***************************************************************************
rem Returns the Key value if it's found or null on error or if the key isn't
rem found
rem regRoot - The root registry to search.  Can be abbr. Ex: HKLM, HKCU
rem regKey - The path to the key.  
rem 
rem For values: 
rem		Ex: "Software\SoftwareCompany\Key\Value"
rem For default values of a key:
rem		Ex: Software\SoftwareCompany\Key\
rem ***************************************************************************
Function GetRegistryKey(regRoot, regKey)
	
	Dim regPath, keyVal
	Dim oShell
	
	On Error Resume Next

	Set oShell = CreateObject("WScript.Shell")
	if Err Then
		GetRegistryKey = Null
	else 

		regPath = regRoot & "\" & regKey
	
		keyVal = oShell.RegRead(regPath)

		if Err Then
			rem If we don't find the key there will be an error
			Err.Clear
			GetRegistryKey = Null
		else
			GetRegistryKey = keyVal
		end if
	End if
End Function

rem ***************************************************************************
rem Returns true if key value matches regVal, false if it does not.
rem regRoot - The root registry to search.  Can be abbr. Ex: HKLM, HKCU
rem regVal - The path to the key value.  
rem 
rem For values: 
rem		Ex: "Software\SoftwareCompany\Key\Value"
rem For default values of a key:
rem		Ex: Software\SoftwareCompany\Key\
rem regData - The data to match with the key value data.
rem ***************************************************************************
Function CheckRegistryKey(regRoot, regVal, regData)

	Dim keyVal

	keyVal = GetRegistryKey(regRoot,regVal)

	if isNull(keyVal) Then
		rem If we don't find the key there will be an error
		Err.Clear
		CheckRegistryKey = false
	else
		if keyVal = regData Then
			CheckRegistryKey = true
		else
			CheckRegistryKey = false
		end if
	end if

End Function

rem ***************************************************************************
rem This is the main code.  It will exit the script
rem ***************************************************************************
Function Main
	Dim argList
	Dim returnCode

	set argList = WScript.Arguments

	if argList.length < 5 or argList.length > 6 Then
		rem Do Nothing, just exit
		returnCode = 1
	else	

		Dim success, failure, failureid, rootkey, regkey, regvalue

		success = argList(0)
		failure = argList(1)
		failureid = argList(2)
		rootkey = argList(3)
		regkey = argList(4)

		rem If they gave us a regvalue, try to match the key value.  
		rem Else just match the key
		if argList.length = 6 Then
			regvalue = argList(5)
			if not CheckRegistryKey(rootkey,regkey,regvalue) then
				WScript.Echo "Status=" & failure
				WScript.Echo "DescriptionID=" & failureid
				returnCode = 0
			else
				WScript.Echo "Status=" & success
				returnCode = 0
			end if		
		else
			Dim retVal
			retVal = GetRegistryKey(rootkey,regkey)
			If isNull(retVal) Then
				WScript.Echo "Status=" & failure
				WScript.Echo "DescriptionID=" & failureid
				returnCode = 0
			else 
				WScript.Echo "Status=" & success
				returnCode = 0
			End if
		end if
	end if

	WScript.Quit(returnCode)

End Function

Main()
