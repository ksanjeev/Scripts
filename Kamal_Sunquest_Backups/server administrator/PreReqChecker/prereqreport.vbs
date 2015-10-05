' **************************************************************************
' Prereqreport.vbs - Executes prerequisite checks for OpenManage install and
' generates an html report of the results.
'
' Usage 1: prereq_mn.xml|prereq_ms.xml <outputXMLFile>
' Processes the inputXMLfile and executes the Prerequisite checks for each
' feature.  Output xml is placed in the file outputXMLFile.
' prereq_mn.xml|prereq_ms.xml	Input XML file to process.  The name must be
'								one of these two, since that indicates whether
'								it is a management station or managed node
' <outputXMLFile>	Path and name of the output XML file.
'
' Usage 2: --generatereport <reportXMLFile> <stringsXMLFile>
' <templateXMLFile> <outputHTMLFile>
' Processes the reportXMLFile and outputs the results according to the
' template XML File.
' <reportXMLFile>   - The outputXMLFile from Usage 1.
' <stringsXMLFile>  - The strings file containing the message strings.
' <templateXMLFile> - The template file containing the html.
' <outputHTMLFile>  - The file that will contain the html.
'
' This script should return 1 on a usage error and 0 if the xml was
' processed.  If the xml input file could not be opened, a 1 will be
' returned.
'
' Copyright (c) 2004 Dell Incorporated
' **************************************************************************

Option Explicit

Dim gLogFile
Dim gStringFile
Const cLogFileName = "prereqreport.log"
' Messages when no translate file could be loaded
Const cstemplateDoc = "The prerequisite checks did not execute on this system due to an inability to load the prereqreporttemplate.xml file."
Const csreportDoc   = "The prerequisite checks did not execute on this system due to an inability to load the omprereqcheck.xml file."
Const csstringDoc   = "The prerequisite checks did not execute on this system due to an inability to load the prereqstrings.xml file."
Const csNoMNxmlFile = "The prerequisite checks did not execute on this system due to an inability to load the prereq_mn.xml file."
Const csNoMSxmlFile = "The prerequisite checks did not execute on this system due to an inability to load the prereq_ms.xml file."
Const csRegistry    = "The prerequisites did not execute on this system because the registry key HKEY_LOCAL_MACHINE\\SOFTWARE\\Dell Computer Corporation does not have appropriate permission settings. Please consult your documentation for more information."
Const cscStatusAttr = "The prerequisite checks have failed to execute on this system."
Const csAllFeatures = "All Selected Features"
Const csFeature     = "Feature"
Const csDescription = "Description"
' And their prereqstring message ID's
Const cstemplateDocID = "alf_tmpldoc"
Const csreportDocID   = "alf_reportdoc"
Const cscStatusAttrID = "alf_allfail"
Const csNoMNxmlFileID = "alf_nomn_file"
Const csNoMSxmlFileID = "alf_noms_file"
Const csRegistryID    = "alf_registry"
Const csAllFeaturesID = "cap_all"
Const csFeatureID     = "hfs_feature"
Const csDescriptionID = "hds_description"
' Additonal Messages
Const gMsgNotFoundID = "desc_notfound"
Const gMsgErrorID = "desc_error"

' Error Return Values
Const cInvalidParametersNoOutput = -2
Const cInvalidParameters = -3
Const cRunPreReqsFail = -4
Const cGenerateReportFailure = -5
Const cGetPreReqStatusFailure = -6

'
'XML Node and Elements
'
'Template File Heading Node Definitions
Const cHeadingTemplateNodeName = "HeadingTemplate"
Const cHeadingFeatureElement = "HeadingFeatureElement"
Const cHeadingDescriptionElement = "HeadingDescriptionElement"
'PreReq_mx File Heading Node Definitions
Const cHeadingListNodeName = "HeadingList"
Const cHeadingFeatureString = "HeadingFeatureString"
Const cHeadingDescriptionString = "HeadingDescriptionString"

'Template File All Pass Node Definitions
Const cAllPassTemplateNodeName = "AllPassTemplate"
Const cAllPassCaptionTemplateElement = "CaptionID"
Const cAllPassTemplateElement = "AllPassTemplateElement"
'PreReq_mx File All Pass Node Definitions
Const cAllPassListNodeName = "AllPassList"
Const cAllPassNodeName = "AllPassElement"
Const cCaptionNodeName = "CaptionID"

'Template File All Fail Node Definitions
Const cAllFailTemplateNodeName = "AllFailTemplate"
Const cAllFailCaptionTemplateElement = "CaptionID"
Const cAllFailTemplateElement = "AllFailTemplateElement"
'PreReq_mx File All Fail Node Definitions
Const cAllFailNodeName = "AllFailElement"
Const cAllFailListNodeName = "AllFailList"
'Const cCaptionNodeName = "CaptionID"  		' reused

'Template File Feature Node Definitions
Const cFeatureName     = "Feature"
Const cPRCheckIDNodeName = "PRCheckID"
Const cIconNodeName = "Icon"
'Const cCaptionNodeName = "CaptionID"  		' reused
Const cDescNodeName = "DescriptionID"
Const cURLNodeName = "URLID"
Const cLinkNodeName = "LinkID"
'PreReq_mx File Feature Node Definitions
Const cFeatureListNodeName = "FeatureList"
'Const cFeatureName     = "Feature"			' reused
Const cPRCheckNodeName = "PRCheck"
Const cPRCheckReportNodeName = "PRCheckReport"

'Template File PRCheckList Node Definitions
'PreReq_mx File PRCheckList Node Definitions
Const cPRCheckListNodeName = "PRCheckList"
'Const cPRCheckNodeName = "PRCheck"			' reused
Const cPRIDAttr = "pr_id"
Const cExecutedAttrName = "executed"
Const cExeNodeName = "Exename"
Const cParamNodeName = "Paramstring"
Const cStatusNodeName = "Status"
'Const cCaptionNodeName = "CaptionID"  		' reused
'Const cDescNodeName    = "DescriptionID"
'Const cURLNodeName     = "URLID" 			' reused
'Const cLinkNodeName    = "LinkID"			' reused
Const cParamVar1NodeName = "Param1"
Const cParamVar2NodeName = "Param2"
Const cParamVar3NodeName = "Param3"

'reReq_mx File PRCheckList Node Values
Const cExecutedAttrFalse = "false"
Const cExecutedAttrTrue = "true"

'reReq_mx File Feature Node Values
Const cValueAttr = "value"
Const cNameAttr = "name"

'reReq_mx File  Values
Const cStatusAttr = "status"
Const cStatusExecuted = "executed"

' Text Strings
Const cPRCheckFailLine = "<PRCheckReport status='failed'>"
Const cPRCheckFailLineEnd = "</PRCheckReport>"
Const cRegPathMS = "HKLM\Software\Dell Computer Corporation\OpenManage\PreReqChecks\MS\"
Const cRegPathMN = "HKLM\Software\Dell Computer Corporation\OpenManage\PreReqChecks\MN\"
Const cMSFile = "prereq_ms.xml"
Const cMNFile = "prereq_mn.xml"
Const cTrue  = "True"
Const cFalse = "False"

' Feature Strings
Const cAM = "AM"            ' Array Manager feature string
Const cOMSM = "OMSM"        ' OpenManage Storage Managment feature string
Const cOMSSAM = "OMSSAM"    ' Combines AM and OMSM feature string
Const cFeatureALL = "ALL"   ' All feature's string


' **************************************************************************
' Loads the xml document and returns the DOMDocument object.  Returns
' nothing if the document cannot be opened.
'
' xmlFile - The file name to open.
' **************************************************************************
Function LoadXMLDoc(xmlFile)
	Dim xmlDoc

	On Error Resume Next
	WriteLog("LoadXMLDoc - Entry. xmlfile= " & xmlFile)

	Set xmlDoc = CreateObject("Msxml.DOMDocument")

	If Err Then
		Err.Clear
		WriteLog("LoadXMLDoc - ERROR. Could not create MSXML object")
		Set LoadXMLDoc = Nothing
	Else

		xmlDoc.async = False
		xmlDoc.resolveExternals = False
		xmlDoc.validateOnParse = True
		xmlDoc.Load (xmlFile)

		If xmlDoc.parseError.errorCode <> 0 Then
			Set LoadXMLDoc = Nothing
			WriteLog("LoadXMLDoc - Parse ERROR: "  & xmlDoc.parseError.Reason)
		Else
			Set LoadXMLDoc = xmlDoc
		End If
	End If

	WriteLog("LoadXMLDoc - Exit.")

End Function

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
		WriteLog("HasWriteAccess - WARNING. Path " & path & " does not have write access")
	Else
		fileObject.Close
		FSO.DeleteFile(path & fileName)
		HasWriteAccess = True
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

	WriteLog("GetTempPath - Returning temporary path " & GetTempPath)

End Function

' *************************************************************************
' Executes the command identified by cmdString via the WScript.Shell.Run
' method.  This function will block while the command is being executed.
' Once it has completed, it will return the output of the command object.
'
' cmdString The command to execute
' *************************************************************************
Function ExecuteCmd(cmdString)
	Dim exeOutput
	Dim WshShell, FSO, tempFile, sCmd, OutF
	Dim timeOutCount

	rem On Error Resume Next

	Set FSO = createobject("Scripting.FileSystemObject")
	Set WshShell = CreateObject("WScript.Shell")

	If Err Then
		Err.Clear
		ExecuteCmd = Null
	Else
		tempFile = GetTempPath() & "\" & FSO.GetTempName

 		sCmd = "%COMSPEC% /D /c " & cmdString & " > """ & tempFile & """"

		WriteLog("ExecuteCmd - Executing command " & sCmd)

		exeOutput = WshShell.Run(sCmd, 0, True)

 		If FSO.FileExists(tempFile) and exeOutput = 0 Then
			If FSO.GetFile(tempFile).Size > 0 Then
				Set OutF = FSO.OpenTextFile(tempFile)
				ExecuteCmd = OutF.ReadAll
				WriteLog("ExecuteCmd - Result File:")
				WriteLog(ExecuteCmd)
  				OutF.Close
			End If
			FSO.DeleteFile(tempFile)
		Else
			If FSO.FileExists(tempFile) then
				WriteLog("ExecuteCmd - ERROR File exists but exe output was non-zero")
				Set OutF = FSO.OpenTextFile(tempFile)
				WriteLog("ExecuteCmd - Result File:")
				If OutF.AtEndOfStream = false then
					WriteLog(OutF.ReadAll)
				end if
				OutF.Close
				FSO.DeleteFile(tempFile)
			End if
			ExecuteCmd = NULL
		End If
	End If

End Function

' *************************************************************************
' Executes the PRCheck defined by the <PRCheck> element.  Returns a new
' DOMDocument object with the <PRCheck> element as the root and the
' <Status>, <CaptionID>, <DescID>, and <URLID> elements included with the
' original <Exestring> and <Paramstring> elements.
'
' prDoc - The xml document
' id - The id of the PRCheck to execute
' *************************************************************************
Function ExecutePRCheck(prDoc, id)
	Dim prCheckNode
	Dim statElement, capElement, descElement, urlElement, linkElement
	Dim cmdString
	Dim cmdOutput
	Dim exeNode, paramNode, node
	Dim param1Node, param2Node, param3Node

	Set prCheckNode = prDoc.nodeFromID(id)

	for each node in prCheckNode.childNodes
		if node.nodeName = cExeNodeName then
			Set exeNode = node
		elseif node.nodeName = cParamNodeName then
			Set paramNode = node
		elseif node.nodeName = cCaptionNodeName then
			Set capElement = node
			prCheckNode.removeChild(capElement)
		elseif node.nodeName = cDescNodeName then
			Set descElement = node
			prCheckNode.removeChild(descElement)
		elseif node.nodeName = cURLNodeName then
			Set urlElement = node
			prCheckNode.removeChild(urlElement)
		elseif node.nodeName = cLinkNodeName then
			Set linkElement = node
			prCheckNode.removeChild(linkElement)
		elseif node.nodeName = cParamVar1NodeName then
			Set param1Node = node
			prCheckNode.removeChild(param1Node)
		elseif node.nodeName = cParamVar2NodeName then
			Set param2Node = node
			prCheckNode.removeChild(param2Node)
		elseif node.nodeName = cParamVar3NodeName then
			Set param3Node = node
			prCheckNode.removeChild(param3Node)
		end if
	next

	cmdString = exeNode.text & " " & paramNode.text
	cmdOutput = ExecuteCmd(cmdString)

	If isNull(cmdOutput)Then
		prCheckNode.setAttribute cExecutedAttrName, cExecutedAttrFalse
		WriteLog("ExecutePRCheck - Command output is null")
	Else
		' If the command passes, break the string dump into lines
		Dim RegEx, Matches, Match
		Set RegEx = new RegExp
		RegEx.Global = True
		RegEx.Pattern = "\w+=\w+\S*"

		Set Matches = RegEx.Execute(cmdOutput)

		For Each Match in Matches
			Dim splitArray, name, value

			splitArray = split(Match.value,"=")
			name = splitArray(0)
			value = splitArray(1)

			' Now see what value it is and assign it to the appropriate
			' PRCheck element

			if name = cStatusNodeName Then
				Set statElement = prDoc.createElement(cStatusNodeName)
				statElement.text = value
				WriteLog("ExecutePRCheck - Status is " & value)
			elseif name = cCaptionNodeName Then
				Set capElement = prDoc.createElement(cCaptionNodeName)
				capElement.text = value
				WriteLog("ExecutePRCheck - Caption is " & value)
			elseif name = cDescNodeName Then
				Set descElement = prDoc.createElement(cDescNodeName)
				descElement.text = value
				WriteLog("ExecutePRCheck - Description is " & value)
			elseif name = cURLNodeName Then
				Set urlElement = prDoc.createElement(cURLNodeName)
				urlElement.text = value
				WriteLog("ExecutePRCheck - URL is " & value)
			elseif name = cLinkNodeName Then
				Set linkElement = prDoc.createElement(cLinkNodeName)
				linkElement.text = value
				WriteLog("ExecutePRCheck - Link is " & value)
			elseif name = cParamVar1NodeName Then
				Set param1Node = prDoc.createElement(cParamVar1NodeName)
				param1Node.text = value
				WriteLog("ExecutePRCheck - Param1 is " & value)
			elseif name = cParamVar2NodeName Then
				Set param2Node = prDoc.createElement(cParamVar2NodeName)
				param2Node.text = value
				WriteLog("ExecutePRCheck - Param2 is " & value)
			elseif name = cParamVar3NodeName Then
				Set param3Node = prDoc.createElement(cParamVar3NodeName)
				param3Node.text = value
				WriteLog("ExecutePRCheck - Param3 is " & value)
			end if
		Next

		prCheckNode.setAttribute cExecutedAttrName, cExecutedAttrTrue

	End If

	' Now append each child to the list
	if not isEmpty(statElement) then
		prCheckNode.appendChild(statElement)
	end if
	if not isEmpty(capElement) then
		prCheckNode.appendChild(capElement)
	end if
	if not isEmpty(descElement) then
		prCheckNode.appendChild(descElement)
	end if
	if not isEmpty(urlElement) then
		prCheckNode.appendChild(urlElement)
	end if
	if not isEmpty(linkElement) then
		prCheckNode.appendChild(linkElement)
	end if
	if not isEmpty(param1Node) then
		prCheckNode.appendChild(param1Node)
	end if
	if not isEmpty(param2Node) then
		prCheckNode.appendChild(param2Node)
	end if
	if not isEmpty(param3Node) then
		prCheckNode.appendChild(param3Node)
	end if


End Function

' *************************************************************************
' Loops through the FeatureList child nodes and builds a list of all the
' PRChecks that are required.  After removing any identical PRChecks the
' function calls the ExecutePRCheck function for each of <PRCheck> elements.
'
' prDoc - The DOMDocument of the PRCheckReport xml doc
' *************************************************************************
Function ProcessFeatureList(prDoc)

	Dim feature, id
	Dim newPRDoc, newPRCheckReport
	Dim featureList
	Dim oFeatureIDDict
	Dim aIDKeys
	Dim prCheckList
	Dim newPRCheckListDoc

	Set featureList = prDoc.getElementsByTagName(cFeatureListNodeName).item(0)
	Set prCheckList = prDoc.getElementsByTagName(cPRCheckListNodeName).item(0)

	' On Error Resume Next

	Set oFeatureIDDict = CreateObject("Scripting.Dictionary")

	If Err Then
		Err.Clear
	Else

		oFeatureIDDict.CompareMode = vbTextCompare

		' Loop through the child <Feature> nodes and get the ids into a dict
		For Each feature in featureList.childNodes
			Dim idElement

			' Any redundant ids will be overwritten in the dictionary.  We
			' don't want to call the same prcheck more than once
			For Each idElement in feature.childNodes
				Dim attrValue
				attrValue = idElement.getAttribute(cValueAttr)

				If oFeatureIDDict.Exists(attrValue) then
					oFeatureIDDict.Key(attrValue) = attrValue
				Else
					oFeatureIDDict.Add attrValue, attrValue
				End if
			Next
		Next

		' Execute the PRCheck indicated by the var id
		aIDKeys = oFeatureIDDict.keys
		For Each id in aIDKeys
			WriteLog("ProcessFeatureList - Executing PRCheck " & id)
			ExecutePRCheck prDoc, id
		Next
	End If
End Function

' ***************************************************************************
' Returns the status of the prerequisite with the id value of prID.  Returns
' 4 if the check node was not executed. ("executed" attr is "false")
' prReportDoc - The xml document
' prID - The id of the prereq
' ***************************************************************************
Function GetPreReqStatus(prReportDoc, prID, cPassedStatus)

	Dim prCheckNode, node

	' Get the pr check with the id of prID
	Set prCheckNode = prReportDoc.nodeFromID(prID)

	' Give it a bad status, so if the executed attribute is false it will
	' trigger an error
	GetPreReqStatus = cGetPreReqStatusFailure

	' Find out if it was executed.  If not we will return null
	if prCheckNode.getAttribute(cExecutedAttrName) = cExecutedAttrTrue then

		' Look for the status child node
		for each node in prCheckNode.childNodes
			if node.nodeName = cStatusNodeName then
                ' If the pr check results are greater than the passed in value
                ' return the pr check results. Otherwise returned the passed
                ' in status
				if CInt(node.text) >= CInt(cPassedStatus) then
				    GetPreReqStatus = node.text
                else
                    ' override the results with the passed in value
        			WriteLog("GetPreReqStatus - " & prID & " results    = " & node.text )
        			WriteLog("GetPreReqStatus - " & prID & " overriding = " & cPassedStatus )
				    node.text = cPassedStatus
				    GetPreReqStatus = cPassedStatus
                end if
			end if
		next

	end if

End Function

' ***************************************************************************
' This function checks a registry for write access.  Returns True if the
' registry location is writable, false if it is not.
'
' If the registry location is more than one level past an existing registry
' key, it will be left behind after this check.  For example, if you check
' HKLM\Software\Foo\Bar\Test, and current registry contains HKLM\Software\Foo,
' then the registry will contain HKLM\Software\Foo\Bar after the check.
' Conversely, if the registry contains HKLM\Software\Foo\Bar and you check
' HKLM\Software\Foo\Bar\Test, then the registry will be back to normal after
' this check.
' ***************************************************************************
Function CheckRegistryAccess(regPath)

	Dim oShell
	Dim sCRAreturncode

	On Error Resume Next

	sCRAreturncode = cFalse

	' Start by writing a dummy value to the registry
	Set oShell = CreateObject("WScript.Shell")
	If Err Then
		Err.Clear
	Else

		oShell.RegWrite regPath, 1, "REG_DWORD"
		if Err Then
			Err.Clear
		else
			sCRAreturncode = cTrue
			oShell.RegDelete regPath
			if Err Then
				Err.Clear
			end if
		end if

	End if

	CheckRegistryAccess = sCRAreturncode

	'On Error GoTo 0

End Function

' ***************************************************************************
' Writes the results of the prereq scan to the registry.  Each feature will
' be a registry value.  Its data will be the highest status of all its prereq
' checks.  This function will return the highest status returned by any feature.
'
' prReportDoc - The xml doc that contains the executed prerequisite checks.
' regPath - The registry path to write to.
' ***************************************************************************
Function WriteResultsToReg(prReportDoc, regPath)

	Dim featureList, feature, idElement
	Dim highestGlobalStatus
	Dim highestOMSSAMStatus
	Dim highestALLStatus

	' On Error Resume Next

	Set featureList = prReportDoc.getElementsByTagName(cFeatureListNodeName).item(0)
	highestALLStatus = 0

	' Loop through the feature list, look for ALL feature
	For each feature in featureList.childNodes
		Dim cALLhighestStatus
		cALLhighestStatus = 0

        ' Look for the "ALL" feature
        If cFeatureALL = feature.getAttribute(cNameAttr) then
    	    WriteLog("WriteResultsToReg - processing feature " & feature.getAttribute(cNameAttr))
			' Loop through the ALL's pr checks
			For each idElement in feature.childNodes
				if idElement.nodeName = cPRCheckIDNodeName then
					Dim cALLid, cALLstatus

					cALLid = idElement.getAttribute(cValueAttr)
					cALLstatus = GetPreReqStatus(prReportDoc, cALLid, CInt(0))

    				' Replace the highest status with this status if it's higher
					if not isNull(cALLstatus) then
						if CInt(cALLstatus) > CInt(cALLhighestStatus) then
							cALLhighestStatus = cALLstatus
							WriteLog("WriteResultsToReg - The ALL highest status is now " & cALLhighestStatus)
						end if

						'Also check if it is higher than the current highest ALL status
						if CInt(cALLstatus) > CInt(highestALLStatus) then
							highestALLStatus = cALLstatus
							WriteLog("WriteResultsToReg - The ALL highest ALL status is now " & highestALLStatus)
						end if
					end if

				end if
			Next 'End <PRCheckID> loop
        end if
	Next 'End <Feature> loop
	'highestALLStatus = "3" 'Test Case
	'highestALLStatus = "2" 'Test Case


	Set featureList = prReportDoc.getElementsByTagName(cFeatureListNodeName).item(0)
	highestOMSSAMStatus = 0

	' Loop through the feature list, look for OMSSAM feature
	For each feature in featureList.childNodes
		Dim chighestStatus
		chighestStatus = highestALLStatus

        ' Look for OMSSAM feature
        If cOMSSAM = feature.getAttribute(cNameAttr) then
    		WriteLog("WriteResultsToReg - processing feature " & feature.getAttribute(cNameAttr))
		    ' Loop through the OMSSAM's pr checks
		    For each idElement in feature.childNodes
		    	if idElement.nodeName = cPRCheckIDNodeName then
		    		Dim cid, cstatus

		    		cid = idElement.getAttribute(cValueAttr)
		    		cstatus = GetPreReqStatus(prReportDoc, cid, chighestStatus)

		    		' Replace the highest status with this status if it's higher
		    		if not isNull(cstatus) then
		    			if CInt(cstatus) > CInt(chighestStatus) then
		    				chighestStatus = cstatus
		    				WriteLog("WriteResultsToReg - The OMSSAM highest status is now " & chighestStatus)
		    			end if

		    			'Also check if it is higher than the current highest OMSSAM status
		    			if CInt(cstatus) > CInt(highestOMSSAMStatus) then
		    				highestOMSSAMStatus = cstatus
		    				WriteLog("WriteResultsToReg - The OMSSAM highest OMSSAM status is now " & highestOMSSAMStatus)
		    			end if
		    		end if

		    	end if

		    Next 'End <PRCheckID> loop
        end if
	Next 'End <Feature> loop
	'highestOMSSAMStatus = "2" 'Test Case

    ' Now after preprocessing, process all the features
	Set featureList = prReportDoc.getElementsByTagName(cFeatureListNodeName).item(0)
	highestGlobalStatus = 0

	' Loop through the feature list
	For each feature in featureList.childNodes
		Dim highestStatus, oShell, passedStatus
		highestStatus = 0
		passedStatus = highestALLStatus

		WriteLog("WriteResultsToReg - Writing results for " & feature.getAttribute(cNameAttr))

        ' Handle combined AM and OMSM results
        ' Look for AM feature
        If cAM = feature.getAttribute(cNameAttr) then
            If CInt(highestOMSSAMStatus) > CInt(passedStatus) then
                passedStatus = highestOMSSAMStatus
            end if
        end if

        ' Look for OMSM feature
        If cOMSM = feature.getAttribute(cNameAttr) then
            If CInt(highestOMSSAMStatus) > CInt(passedStatus) then
                passedStatus = highestOMSSAMStatus
            end if
        end if


		' Loop through each feature's pr checks
		For each idElement in feature.childNodes

			if idElement.nodeName = cPRCheckIDNodeName then
				Dim id, status

				id = idElement.getAttribute(cValueAttr)
				status = GetPreReqStatus(prReportDoc, id, passedStatus)

				' Replace the highest status with this status if it's higher
				if not isNull(status) then
					if CInt(status) > CInt(highestStatus) then
						highestStatus = status
						WriteLog("WriteResultsToReg - The highest status is now " & highestStatus)
					end if

					'Also check if it is higher than the global status
					if CInt(status) > CInt(highestGlobalStatus) then
						highestGlobalStatus = status
						WriteLog("WriteResultsToReg - The highest global status is now " & highestGlobalStatus)
					end if
				end if

			end if

		Next 'End <PRCheckID> loop

		' Now write the status to the registry
		Set oShell = CreateObject("WScript.Shell")

		If Err Then
			Err.Clear
		Else
			oShell.RegWrite regPath & feature.getAttribute(cNameAttr), _
			highestStatus, "REG_DWORD"
		End if

	Next 'End <Feature> loop

	WriteResultsToReg = highestGlobalStatus

End Function

' ***************************************************************************
' Checks the version of MSXML that is installed.  Checks for the reg keys
'
' HKEY_CLASSES_ROOT\MSXML.DOMDocument\CurVer\ - for MSXML 1
' HKEY_CLASSES_ROOT\Msxml2.DOMDocument\CurVer\ -or-
' HKEY_CLASSES_ROOT\Msxml2.DOMDocument.3.0\ - for MSXML 3
' HKEY_CLASSES_ROOT\Msxml2.DOMDocument.4.0\ - for MSXML 4
'
' Makes a judgement based on their presence.  Returns 0,1,3,4,5 based on the
' MSXML package that is installed (nothing, MSXML, MSXML3, MSXML4, or both
' 4 and other versions in side-by-side mode).
' ***************************************************************************
Function CheckMSXMLInstall

	const cMSXML = "HKEY_CLASSES_ROOT\MSXML.DOMDocument\CurVer\"
	const cMSXML2 = "HKEY_CLASSES_ROOT\Msxml2.DOMDocument\CurVer\"
	const cMSXML3 = "HKEY_CLASSES_ROOT\Msxml2.DOMDocument.3.0\"
	const cMSXML4 = "HKEY_CLASSES_ROOT\Msxml2.DOMDocument.4.0\"

	Dim oShell


	WScript.Echo "This function is not yet implemented!"
	WScript.Exit

	On Error Resume Next

	Set oShell = CreateObject("WScript.Shell")
	if Err Then
		CheckMSXMLInstall = Null
	else

		' If we don't find the key there will be an error
		msXML = oShell.RegRead(cMSXML)
		if Err Then
			Err.Clear
			msXML=0
		end if

		msXML2 = oShell.RegRead(cMSXML2)
		if Err Then
			Err.Clear
			msXML2=0
		end if

		msXML3 = oShell.RegRead(cMSXML3)
		if Err Then
			Err.Clear
			msXML3=0
		end if

		msXML4 = oShell.RegRead(cMSXML4)
		if Err Then
			Err.Clear
			msXML4=0
		end if

	End if

End Function

' ***************************************************************************
' Prints the usage of the function
' ***************************************************************************
' Function Usage
' 	WScript.Echo WScript.ScriptName & " <inputXMLFile> <outputXMLFile>" & vbNewLine & vbNewLine & "Processes the inputXMLfile and executes the Prerequisite checks for each" & vbNewLine & "feature.  Output xml is placed in the file outputXMLFile." & vbNewLine & vbNewLine & _
' "<inputXMLFile>" & vbTab & "Input XML file to process." & vbNewLine & _
' "<outputXMLFile>" & vbTab & "Path and name of the output XML file."
' End Function

' ***************************************************************************
' The main function of the program.  Returns the highest status returned by
' the prereqs or cRunPreReqsFail if error.
' ***************************************************************************
Function RunPreReqs( inputFile, outputFile )
	Dim prDoc
	Dim returnCode
	Dim regAccess
	Dim RegAccessPath
	Dim errorID

	returnCode = cRunPreReqsFail
	RegAccessPath = Null

	On Error Resume Next

	'Check that the input xml test file can be loaded
	Set prDoc = LoadXMLDoc(inputFile)

	'Check the registry for access.  We will fail immediately if we don't
	'have registry write access.
	regAccess = cFalse

	if InStr(inputFile, cMSFile) then
		regAccess = CheckRegistryAccess(cRegPathMS)
		RegAccessPath = cRegPathMS
		errorID = csNoMSxmlFileID
	elseif InStr(inputFile, cMNFile) then
		regAccess = CheckRegistryAccess(cRegPathMN)
		RegAccessPath = cRegPathMN
		errorID = csNoMNxmlFileID
	else
		WriteLog("RunPreReqs - The mn|ms parameter is malformed: " & inputFile)
	end if

	'Set prDoc = Nothing	' TESTCASE
	'regAccess = cFalse	' TESTCASE

	If prDoc is Nothing or regAccess = cFalse Then
		Dim genDoc, rootElement, FSO

		If prDoc is Nothing Then
			WriteLog("RunPreReqs - Initial Error, input file did not load: " & inputFile )
        End if
		If regAccess = cFalse Then
			WriteLog("RunPreReqs - Initial Error, registry access error: " & RegAccessPath)
        End if

		Set FSO = CreateObject("Scripting.FileSystemObject")
		If Err Then
			Err.Clear
		Else
			Set genDoc = FSO.CreateTextFile(outputFile, true)
			genDoc.WriteLine("<?xml version=""1.0"" encoding=""UTF-8""?>")
			genDoc.WriteLine(cPRCheckFailLine)
			genDoc.WriteLine("<HeadingList>")
			genDoc.WriteLine("<HeadingFeatureString>hfs_feature</HeadingFeatureString>")
			genDoc.WriteLine("<HeadingDescriptionString>hds_description</HeadingDescriptionString>")
			genDoc.WriteLine("</HeadingList>")
			genDoc.WriteLine("<AllFailList>")
			genDoc.WriteLine("<AllFailElement>")
			If prDoc is Nothing Then
				' can not load the input file
				genDoc.WriteLine(errorID)
        	Else
				' can not access the registry
				genDoc.WriteLine(csRegistryID)
        	End if
			genDoc.WriteLine("</AllFailElement>")
			genDoc.WriteLine("</AllFailList>")
			genDoc.WriteLine(cPRCheckFailLineEnd)
			genDoc.Close
		End if

	Else

		WriteLog("RunPreReqs - Processing Feature List")
		ProcessFeatureList(prDoc)
		prDoc.documentElement.setAttribute cStatusAttr, cStatusExecuted
		prDoc.save(outputFile)

		' Now write the results to the registry
		returnCode = WriteResultsToReg(prDoc, RegAccessPath)
		WriteLog("RunPreReqs - Return code from registy write is: " & returnCode)

	End if

	RunPreReqs = returnCode

End Function

' ***************************************************************************
' Returns a string from the strings xml file based on the id value
' stringFile - The xml file containing the strings
' idString - The id value of the string
' ***************************************************************************
Function GetStringByID(stringFile, idString)

	Dim stringDoc
	Dim stringNode

	Set stringNode = Nothing

	Set stringDoc = LoadXMLDoc(stringFile)

	If stringDoc is Nothing Then
		GetStringByID = Null
	Else
		Set stringNode = stringDoc.nodeFromID(idString)
		If Err or stringNode is Nothing Then
			WriteLog("GetStringByID - ERROR, string not found")
			GetStringByID = Null
		Else
			GetStringByID = stringNode.text
		End If
	End If

End Function

' ***************************************************************************
' Returns a new string with the %Param#% tags replaced (where # is a number).
' Any of the param parameters can be null.
' string - The string to be manipulated.
' paramArray(0) - The string to replace all occurances of %Param1% with.
' paramArray(1) - The string to replace all occurances of %Param2% with.
' paramArray(2) - The string to replace all occurances of %Param3% with.
' ***************************************************************************
Function ReplaceParamsInString(string, paramList)

	Dim tempString

	tempString = string

	WriteLog("ReplaceParamsInString - The params are")
	WriteLog("ReplaceParamsInString - " & paramList(0))
	WriteLog("ReplaceParamsInString - " & paramList(1))
	WriteLog("ReplaceParamsInString - " & paramList(2))

	If not isNull(paramList(0)) Then
		tempString = replace(tempString, "%Param1%", paramList(0))
	End If
	If not isNull(paramList(1)) Then
		tempString = replace(tempString, "%Param2%", paramList(1))
	End If
	If not isNull(paramList(2)) Then
		tempString = replace(tempString, "%Param3%", paramList(2))
	End If

	ReplaceParamsInString = tempString

End Function

' ***************************************************************************
' Adds the string as the text of the xml node.
'
' Node - The DOMNode to search.
' NodeName - The name of the node whose text will be changed.  All nodes with
' this name will have the string added as their text.
' string - The string to add as the text.
' ***************************************************************************
Function AddStringToNode(Node, NodeName, string)

	Dim tempNodeList, targetNode

	Set tempNodeList = Node.GetElementsByTagName(NodeName)

	for each targetNode in tempNodeList

		WriteLog("AddStringToNode - Adding " & string & " to the node " & NodeName)
		targetNode.text = string

	next

End Function

' ***************************************************************************
' This function formats an image element based on the icon template tag. The
' template can contain an icon tag like so:
' <icon error="file.gif" warning="file2.gif" information="file3.gif">
' <img ..."/>
' </icon>

' When this icon elemnt is found, the src attribute of the <img> element is set
' to the  error, warning, or information attribute of icon according to
' the status.  So after processing a PR Check that had a status of 3 (error),
' the Node should look like this:
' <icon error="file.gif" warning="file2.gif" information="file3.gif">
' <img ... src="file.gif"/>
' </icon>
' ***************************************************************************
Function AddIconToNode(Node, status)
	Dim iconNodeList, iconNode, templateDoc

	' Now find all the <icon> element in the template
	Set iconNodeList = Node.getElementsByTagName(cIconNodeName)

	for each iconNode in iconNodeList
		Dim imageNode, newSrcAttr

		WriteLog("AddIconToNode - Adding icon")

		Set	imageNode = iconNode.firstChild

		' Set the src attribute of the image tag according to the status
		if status = 1 then
			imageNode.setAttribute "src",iconNode.getAttribute("information")
		elseif status = 2 then
			imageNode.setAttribute "src",iconNode.getAttribute("warning")
		elseif status = 3 or status = 4 then
			imageNode.setAttribute "src",iconNode.getAttribute("error")
		End if

	next

End Function

' ***************************************************************************
' This function formats an html element based on the URL template tag. The
' template can contain an html tag like so:
' </URLID>
' <a href=""/>
' </URLID>

' When this html element is found, the href attribute of the <a> element is set
' to the passed in string.
' Node should look like this:
' </URLID>
' <a href="passed_in_string">"passed_in_string"</a>
' </URLID>
' ***************************************************************************
Function AddURLToNode(Node, URLsNode, URLstring, linkstring)
	Dim urlNode, urlNodeList
	Dim tempString

	tempString = URLstring

	WriteLog("AddURLToNode - Entry")
	WriteLog("AddURLToNode - URLstring:  " & tempString)
	WriteLog("AddURLToNode - linkstring: " & linkstring)

	' Now find the <URLID> element in the template
	Set urlNodeList = Node.getElementsByTagName(cURLNodeName)

	if isObject(urlNodeList) Then
		WriteLog("AddURLToNode - urlNodeList isObject")
		for each urlNode in urlNodeList
			Dim hrefNode
			Dim Attempt

			WriteLog("AddURLToNode - Adding URL")
 			Set	hrefNode = urlNode.firstChild
			WriteLog("AddURLToNode - Adding setAttribute onmousedown")
			' this generates the proper connections!!
			'var outURL  = '<URLID><a href="#" onmousedown="javascript:location.href=\'omsetup/en/Install_MSDE.htm\'">%LinkID%</a></URLID>';
   			hrefNode.setAttribute "onmousedown", "javascript:location.href" & chr(61) & "\'" & tempString & "\'"
			WriteLog("AddURLToNode - Added URL")

 			'onKeyPress="javascript: if (event.keyCode == 13) { location.href=\'omsetup/en/Install_MSDE.htm\';}"
 			WriteLog("AddURLToNode - Adding setAttribute onKeyPress")
   			hrefNode.setAttribute "onKeyPress", "javascript: if (event.keyCode == 13) { location.href" & chr(61) & "\'" & tempString & "\';}"
			WriteLog("AddURLToNode - Added URL for onKeyPress")

			WriteLog("AddURLToNode - Adding Link")
			WriteLog("AddURLToNode - hrefNode.text: " )
			WriteLog("AddURLToNode -   " & hrefNode.text)
			hrefNode.text = replace(hrefNode.text, "%LinkID%", linkstring)
			WriteLog("AddURLToNode - Added Link")
		next
	End if


	WriteLog("AddURLToNode - Exit")
End Function



' ***************************************************************************
' Takes the PRCheck element from the template output file as well as the
' PRCheck node from the prereq.xml output file and generates the
' corresponding html output.  Gets the strings from the strings xml file.
' Returns a text stream of the html output.
'
' templateNode - The <PRCheck> node from the template output file.
' prCheckNode - The <PRCheck> node from the output prereq file.
' status - The status of the prcheck.
' ***************************************************************************
Function GeneratePRCheckItem(templateNode, prCheckNode, status)

	Dim DescString, CapString, URLString, LinkString
	Dim DescNode, CapNode, URLNode, LinkNode
	Dim childNode
	Dim tempString
	Dim newTemplateNode, templateNodeParent

	WriteLog("GeneratePRCheckItem - Entry")
	WriteLog("GeneratePRCheckItem - gStringFile: " & gStringFile)

	' Make a copy of the template node.  What we want to do is add the
	' pr check information to the template node and then add it to the doc
	set newTemplateNode = templateNode.cloneNode(true)

	' new template is a copy of a section of prereqreporttemplate.xml
	if isObject(newTemplateNode) Then
		'if not isNULL (newTemplateNode.text) Then
		'	WriteLog("GeneratePRCheckItem - newTemplateNode.text: " )
		'	WriteLog("GeneratePRCheckItem -   " & newTemplateNode.text)
		'End if
	End if

	' Get the strings for the prCheckNode
	Set DescNode = prCheckNode.getElementsByTagName(cDescNodeName).item(0)
	Set CapNode  = prCheckNode.getElementsByTagName(cCaptionNodeName).item(0)
	Set URLNode  = prCheckNode.getElementsByTagName(cURLNodeName).item(0)
	Set LinkNode = prCheckNode.getElementsByTagName(cLinkNodeName).item(0)

	' The isObject function checks to make sure we found the element using the
	' methods above

	if isObject(DescNode) Then
		' If the executed attribute is false, use a general error message id
		' to notify the user that the prcheck wasn't executed
		if prCheckNode.getAttribute(cExecutedAttrName) = cExecutedAttrTrue then
			DescString = GetStringByID(gStringFile, DescNode.text )
		Else
			DescString = GetStringByID(gStringFile, gMsgErrorID )
		End if
		If isNull(DescString) then
			' If we didn't find the string in the strings xml file,
			' use the message not found string
			DescString = GetStringByID(gStringFile, gMsgNotFoundID )
		End if
	End if
	if isObject(CapNode) Then
		CapString = GetStringByID(gStringFile, CapNode.text)
		If isNull(CapString) then
			CapString = GetStringByID(gStringFile, gMsgNotFoundID)
		End if
	End If
	If not URLNode is Nothing Then
		URLString = GetStringByID(gStringFile, URLNode.text)
		If isNull(URLString) then
			URLString = GetStringByID(gStringFile, gMsgNotFoundID)
		End if
		WriteLog("GeneratePRCheckItem - URLString: " & URLString)
	End If
	If not LinkNode is Nothing Then
		LinkString = GetStringByID(gStringFile, LinkNode.text)
		If isNull(LinkString) then
			LinkString = GetStringByID(gStringFile, gMsgNotFoundID)
		End if
		WriteLog("GeneratePRCheckItem - LinkString: " & LinkString)
	End If

	' Now get the child xml (which is really html) and add the strings
	' to the appropriate tags in the template file
	if not isNull(DescString) then
		AddStringToNode newTemplateNode, cDescNodeName, DescString
	end if
	if not isNull(CapString) then
		AddStringToNode newTemplateNode, cCaptionNodeName, CapString
	end if
	if not isNull(URLString) then
		if not isNull(LinkString) then
			AddURLToNode    newTemplateNode, URLNode, URLString, LinkString
		end if
	end if

	' Now add the icon element to the template node
	AddIconToNode newTemplateNode, status

	' Now add the new template to the parent template doc.  We will have an
	' structure like this:
	' <PRCheck>
	' ...hollow template information...
	' </PRCheck>
	' <PRCheck>
	' ...node with information we just filled in above (like desc. strings)
	' <PRCheck>
	' The after the calling function is through adding pr checks to the
	' template he should remove the hollow PRCheck template node
	set templateNodeParent = templateNode.parentNode
	templateNodeParent.appendChild(newTemplateNode)

End Function

' ***************************************************************************
' Generates an html table based on the table template in the templateDoc.
' The table will only contain prereq results that are non-zero.
' featureTemplateNode - The DOM object of the feature element inside the
'						template.
' reportDoc - The doc containing the prereq report.
' feature - The DOM object of the feature in the prereq report.
' ***************************************************************************
Function GenerateTable(featureTemplateNode, reportDoc, feature)
	Dim newFeatureNode
	Dim prCheckTemplateNode
	Dim idElement
	Dim prCheckTemplateNodeParent, featureTemplateNodeParent
	Dim featureElementList


	' Make a copy of this node
	Set newFeatureNode = featureTemplateNode.cloneNode(true)

	' Find the <PRCheck> element within the template
	Set prCheckTemplateNode = newFeatureNode.getElementsByTagName("PRCheck").item(0)

	' Loop through each feature's pr checks.  They should look like this:
	' <Feature>
	' 	<PRCheckID value="pr009"/>
	'	<PRCheckID value="pr012"/>
	' </Feature>
	For each idElement in feature.childNodes

		' Make sure the node we're looking at is the right one
		' Check the executed attribute to make sure it was executed!
		' Check status to make sure it is there!
		if idElement.nodeName = cPRCheckIDNodeName then
			Dim id, status
			Dim prCheckNode

			id = idElement.getAttribute(cValueAttr)
			' Look up the status of the PRCheck with id
			status = GetPreReqStatus( reportDoc, id, CInt(0) )
			Set prCheckNode = reportDoc.nodeFromID(id)

			' if the status is non-zero
			if status <> 0 then
				WriteLog("GenerateTable - Status is non-zero for " & id)
				GeneratePRCheckItem prCheckTemplateNode, prCheckNode, status
			end if

		end if

	Next 'End <PRCheckID> loop

	AddStringToNode newFeatureNode, "FeatureName", feature.getAttribute(cNameAttr)

	set prCheckTemplateNodeParent = prCheckTemplateNode.parentNode
	set featureTemplateNodeParent = featureTemplateNode.parentNode

	' Append the new feature node to the parent of the feature template
	featureTemplateNodeParent.appendChild(newFeatureNode)

	' remove the template pr check from the templace pr check's parent,
	' since we don't want an empty pr check showing up.
	prCheckTemplateNodeParent.removeChild(prCheckTemplateNode)

End Function

' ***************************************************************************
' Generates a report based on the results of the prerequisite checks and the
' report template.
'
' reportFileName - The fully qualified path of the prereq xml file containing
' the result of the prerequisite checks.
' templateFileName - The fully qualified path of the template xml file
' containing the general framework for reporting the prereq results.
' ***************************************************************************
Function GenerateReport(reportFileName, templateFileName, outputFileName)

	On Error Resume Next

	Dim templateDoc, reportDoc, featureTemplateNode, featureTemplateNodeParent
	Dim allPassNode, allPassNodeParent, allFailNode, allFailNodeParent
	Dim FSO, outputFile, allPass, allFail
	Dim fatalfailString
	Dim fatalfailStringID
	Dim fsoFail
	Dim fsoFailFile
	Dim headerNode
	Dim iReturnCode
	Dim xmlPrereqstringFile
	Dim allRunPreReqsFail

	WriteLog("GenerateReport - reportDoc:      " & reportFileName)
	WriteLog("GenerateReport - templateDoc:    " & templateFileName)
	WriteLog("GenerateReport - outputFileName: " & outputFileName)
	WriteLog("GenerateReport - xlateFileName:  " & gStringFile)

	allFail = false
	allPass = false
	iReturnCode = cGenerateReportFailure

	' load prereqreporttemplate.xml
	Set templateDoc = LoadXMLDoc(templateFileName)
	' load Temp\omprereqcheck.xml
	Set reportDoc = LoadXMLDoc(reportFileName)

	Set xmlPrereqstringFile = Nothing
	If Not isNull(gStringFile) Then
		WriteLog("GenerateReport - gStringFile: " & gStringFile)
		Set xmlPrereqstringFile = LoadXMLDoc( gStringFile )
	Else
		WriteLog("GenerateReport - gStringFile: is Null")
	End If

	' First get the html that will be used for the feature
	if isObject(templateDoc) Then
		Set featureTemplateNode = templateDoc.getElementsByTagName(cFeatureName).item(0)
		if isNull(featureTemplateNode) then
			WriteLog("GenerateReport - ERROR: featureTemplateNode is nothing")
		end if
		Set allPassNode = templateDoc.getElementsByTagName(cAllPassTemplateNodeName).item(0)
		if isNull(allPassNode) then
			WriteLog("GenerateReport - ERROR: allPassNode is nothing")
		end if
		Set allFailNode = templateDoc.getElementsByTagName(cAllFailTemplateNodeName).item(0)
		if isNull(allFailNode) then
			WriteLog("GenerateReport - ERROR: allFailNode is nothing")
		end if
		Set headerNode = templateDoc.getElementsByTagName(cHeadingTemplateNodeName).item(0)
		if isNull(headerNode) then
			WriteLog("GenerateReport - ERROR: headerNode is nothing")
		end if
	end if

	'for testing:
	'reportDoc.documentElement.setAttribute(cStatusAttr) = "Halloween"

	WriteLog("GenerateReport - Testing for fatal errors")

	If not isObject(templateDoc) or not isObject(reportDoc) then
		' Set the all fail variable to true and all pass to false.  Further
		' on down we will remove the allpass message from the template
		WriteLog("GenerateReport - ERROR: a document Could not load")
		' try to determine what went wrong!
		if not isObject(templateDoc) then
			WriteLog("GenerateReport - ERROR: templateDoc is nothing")
			fatalfailString = cstemplateDoc
			fatalfailStringID = cstemplateDocID
 		end if
		if not isObject(reportDoc) then
			WriteLog("GenerateReport - ERROR: reportDoc is nothing")
			fatalfailString = csreportDoc
			fatalfailStringID = csreportDocID
		end if
		allFail = true
		allPass = false

	elseif reportDoc.documentElement.getAttribute(cStatusAttr) = "failed" Then
		Dim allRunPreReqsList, allfailElement
		WriteLog("GenerateReport - ERROR: reportDoc.documentElement.getAttribute(cStatusAttr) has failed")
		' need to read the passed in error message identifiers.
		Set allRunPreReqsList = reportDoc.getElementsByTagName(cAllFailListNodeName).item(0)
		' Loop through the allRunPreReqsList list
		For each allfailElement in allRunPreReqsList.childNodes
			WriteLog("GenerateReport - allfailElement loop, nodeName: " & allfailElement.nodeName)
			if allfailElement.nodeName = cAllFailNodeName then
				fatalfailStringID = allfailElement.text
			End if
		Next
		WriteLog("GenerateReport - allRunPreReqsList error id: " & fatalfailStringID)
		fatalfailString = Null
		allFail = true
		allPass = false

	elseif reportDoc.documentElement.getAttribute(cStatusAttr) <> "executed" Then
		WriteLog("GenerateReport - ERROR: reportDoc.documentElement.getAttribute(cStatusAttr) was not executed")
		fatalfailString = cscStatusAttr
		fatalfailStringID = cscStatusAttrID
		allFail = true
		allPass = false
	Else

		' The allpass variable will be marked false on the first prereq that
		' fails.  Otherwise if it is true we will print the "Allpass" section
		' of the template
		allPass = true
		allFail = false

		'process the header information
		If not isNull(headerNode) then
			Dim headerList
			Dim headingString
			Dim headerFeatureString
			Dim headerDescriptionString

			Set headerList = reportDoc.getElementsByTagName(cHeadingListNodeName).item(0)
			WriteLog("GenerateReport - headerList set")

			'Loop through the header list in
			For each headingString in headerList.childNodes  'cHeadingFeatureString, cHeadingDescriptionString
				if headingString.nodeName = cHeadingFeatureString then
					'WriteLog("GenerateReport - headingString.nodeName: " & cHeadingFeatureString )
					'WriteLog("GenerateReport - headingString.text:     " & headingString.text )
					headerFeatureString = GetStringByID(gStringFile, headingString.text )
					'WriteLog("GenerateReport - headerFeatureString: " & headerFeatureString )
				elseif headingString.nodeName = cHeadingDescriptionString then
					'WriteLog("GenerateReport - headingString.nodeName: " & cHeadingDescriptionString )
					headerDescriptionString = GetStringByID(gStringFile, headingString.text )
					'WriteLog("GenerateReport - headerDescriptionString: " & headerDescriptionString )
				else
					WriteLog("GenerateReport - Header Element ???? ")
				End if
			Next

			' replace the string text in the HeaderTemplate with the language specific string
			Dim ahNode
			For each ahNode in headerNode.childNodes
				WriteLog("GenerateReport - there is ahNode.text: " )
				WriteLog("GenerateReport -   " & ahNode.text )
				if not isNULL(headerFeatureString) then
					AddStringToNode ahNode, cHeadingFeatureElement, headerFeatureString
				End If
				if not isNULL(headerDescriptionString) then
					AddStringToNode ahNode, cHeadingDescriptionElement, headerDescriptionString
				End If
			Next

		End If

		Dim featureList, feature, idElement
		Set featureList = reportDoc.getElementsByTagName(cFeatureListNodeName).item(0)
		' Loop through the feature list
		For each feature in featureList.childNodes
			Dim highestStatus, oShell, isNonZero
			highestStatus = 0

			WriteLog("GenerateReport - Generating report for " & feature.getAttribute(cNameAttr))

			' First loop through each feature's pr checks and see if any
			' are non-zero.  If they are then we will create a table.
			For each idElement in feature.childNodes

				if idElement.nodeName = cPRCheckIDNodeName then
					Dim id, status
					id = idElement.getAttribute(cValueAttr)
					status = GetPreReqStatus( reportDoc, id, CInt(0) )
					If status <> 0 Then
						isNonZero = true
						allPass = false
					End If
				end if
			Next

			if isNonZero Then
				isNonZero = False
				' Generate a table for this feature
				WriteLog("GenerateReport - calling GenerateTable " )
				GenerateTable featureTemplateNode, reportDoc, feature
			End if
		Next 'End feature loop

		WriteLog("GenerateReport - remove the feature template ")
		' Finally, remove the feature template
		set featureTemplateNodeParent = featureTemplateNode.parentNode
		featureTemplateNodeParent.removeChild(featureTemplateNode)
	End If

	' Now we are left with an xhtml document that contains a bunch of prereq
	' items.  However we also have the AllPass item and the AllFail item, and
	' we don't want to print them if we have prereqs.  However if we don't
	' have prereqs (allPass = true), then we want to show the AllPass item to
	' the customer so we only remove the AllFail item.  The inverse is true
	' when the document failed to load or the prereqs didn't execute
	' (allFail = true)
	WriteLog("GenerateReport - Results ")
	WriteLog("GenerateReport - allPass: " & allPass)
	WriteLog("GenerateReport - allFail: " & allFail)
	if allPass <> true and allFail <> true then
		WriteLog("GenerateReport - There are prereqs required ")
		iReturnCode = 0
		Set allPassNodeParent = allPassNode.parentNode
		allPassNodeParent.removeChild(allPassNode)
		Set allFailNodeParent = allFailNode.parentNode
		allFailNodeParent.removeChild(allFailNode)

	elseif allPass = true and allFail <> true then
		WriteLog("GenerateReport - There are no prereqs required ")
		iReturnCode = 0
		Set allFailNodeParent = allFailNode.parentNode
		allFailNodeParent.removeChild(allFailNode)
		' fill in the allPass node, if no failures
		Dim allpassList, allpassElement

		WriteLog("GenerateReport - Generating report for allpass node")
		Set allpassList = reportDoc.getElementsByTagName(cAllPassListNodeName).item(0)
		Dim allpassString
		Dim allpasscaptionString

		' Loop through the allPass list
		For each allpassElement in allpassList.childNodes  'cAllPassNodeName, cCaptionNodeName
			if allpassElement.nodeName = cAllPassNodeName then
				'WriteLog("GenerateReport - Pass Element cAllPassNodeName ")
				' get the string name from the AllPassList AllPassElement in the Temp\omprereqcheck.xml
				'WriteLog("GenerateReport - allpassElement.text: " & allpassElement.text)
		    	' Need to attempt to write translated message
    			If xmlPrereqstringFile is Nothing Then
					allpassString = allpassElement.text
    			Else
					' get the language specific string from the xml\en\prereqstrings.xml file
					allpassString = GetStringByID(gStringFile, allpassElement.text )
					'WriteLog("GenerateReport - allpassString: " & allpassString)
				End If
			elseif allpassElement.nodeName = cCaptionNodeName then
				'WriteLog("GenerateReport - Pass Element cCaptionNodeName ")
    			If xmlPrereqstringFile is Nothing Then
					allpasscaptionString = allpassElement.text
    			Else
					'WriteLog("GenerateReport - allpassElement.text: " & allpassElement.text)
					allpasscaptionString = GetStringByID(gStringFile, allpassElement.text )
					'WriteLog("GenerateReport - allpasscaptionString: " & allpasscaptionString)
				End If
			else
				WriteLog("GenerateReport - Pass Element ???? ")
			End if
		Next
		' replace the string text in the allPassNode cAllPassTemplateElement with the language specific string
		Dim apNode
		For each apNode in allPassNode.childNodes
			WriteLog("GenerateReport - there is apNode.text: " )
			WriteLog("GenerateReport: " & apNode.text )
			if not isNULL(allpassString) then
				AddStringToNode apNode, cAllPassTemplateElement, allpassString
			End If
			if not isNULL(allpasscaptionString) then
				AddStringToNode apNode, cAllPassCaptionTemplateElement, allpasscaptionString
			End If
		Next

	elseif allPass <> true and allFail = true then
		WriteLog("GenerateReport - Everything failed")
		if isObject(allPassNode) Then
			WriteLog("GenerateReport - deleting allPassNode")
			Set allPassNodeParent = allPassNode.parentNode
			allPassNodeParent.removeChild(allPassNode)
		end if
		if isObject(featureTemplateNode) Then
			set featureTemplateNodeParent = featureTemplateNode.parentNode
			WriteLog("GenerateReport - deleting featureTemplateNode")
			featureTemplateNodeParent.removeChild(featureTemplateNode)
		end if

		if isObject(allFailNode) Then
			WriteLog("GenerateReport - Generating report for allfail node")


		    If not isObject(templateDoc) Then
		    	' Template file is also not present or invalid
				WriteLog("GenerateReport - No valid templateFileName: " & templateFileName)
		    	' Need to attempt to write translated message
    			if xmlPrereqstringFile is Nothing Then
		    		' Translate file is also not present or invalid
					WriteLog("GenerateReport - No valid gStringFile: " & gStringFile)
				Else
					' Translate file exists, get the translated message
                    WriteLog ("GenerateReport - Valid xmlPrereqreporttemplate: " & xmlPrereqstringFile)
					WriteLog("GenerateReport - Translating  xlateTextID: " & fatalfailStringID)
					fatalfailString = GetStringByID(gStringFile, fatalfailStringID )
				End if

				Set fsoFail = CreateObject("Scripting.FileSystemObject")
				'WriteLog("GenerateReport - Set fsoFail = CreateObject")
				Set fsoFailFile = fsoFail.OpenTextFile(outputFileName, 2, true)
				If not Err Then
					WriteLog("GenerateReport - to: " & outputFileName)
					fsoFailFile.Write("<?xml version=""1.0"" encoding=""UTF-8""?>")
					fsoFailFile.Write("<html>")
					fsoFailFile.Write("<body>")
					fsoFailFile.Write(fatalfailString)
					fsoFailFile.Write("</body>")
					fsoFailFile.Write("</html>")
					fsoFailFile.close()
				end if
				WriteLog(fatalfailString)
			Else
			Dim outputTextMessage, outputTextFeature, outputTextFeatures, outputTextDescription
    			' Template file is present, need to fill in the all failed node
				WriteLog("GenerateReport - Valid templateFileName: " & templateFileName)
				' Attempt to translate the message
    			if xmlPrereqstringFile is Nothing Then
   					' Translate file is also not present or invalid
					WriteLog("GenerateReport - No valid gStringFile: " & gStringFile)
					outputTextMessage = fatalfailString
					outputTextFeatures = csAllFeatures
					outputTextFeature = csFeature
					outputTextDescription = csDescription
				Else
					' Translate file exists, get the translated message
					WriteLog("GenerateReport - Valid xmlPrereqstringFile: " & gStringFile)
					WriteLog("GenerateReport - Translating  xlateTextID: " & fatalfailStringID)
					outputTextMessage = GetStringByID(gStringFile, fatalfailStringID )
					outputTextFeatures = GetStringByID(gStringFile, csAllFeaturesID )
					outputTextFeature = GetStringByID(gStringFile, csFeatureID )
					outputTextDescription = GetStringByID(gStringFile, csDescriptionID )
				End if

				Dim afHeaderNodeElement
				For each afHeaderNodeElement in headerNode.childNodes
					AddStringToNode afHeaderNodeElement, cHeadingFeatureElement, outputTextFeature
					AddStringToNode afHeaderNodeElement, cHeadingDescriptionElement, outputTextDescription
				Next

				Dim afNodeElement
				For each afNodeElement in allFailNode.childNodes
					AddStringToNode afNodeElement, cAllFailTemplateElement, outputTextMessage
					AddStringToNode afNodeElement, cAllFailCaptionTemplateElement, outputTextFeatures
				Next
                Set fsoFail = CreateObject("Scripting.FileSystemObject")
                'WriteLog("GenerateReport - Set fsoFail = CreateObject")
                Set fsoFailFile = fsoFail.OpenTextFile(outputFileName, 2, True)
                If Not Err Then
                   fsoFailFile.Write (templateDoc.xml)
                   fsoFailFile.Close()
                End If
			End If
		end if
	end if

	' was there a VERY fatal error?
	if not isObject(fsoFail) then
		' No fatal error
		Set FSO = CreateObject("Scripting.FileSystemObject")
		set outputFile = FSO.OpenTextFile(outputFileName, 2, true)
		If not Err Then
            WriteLog ("GenerateReport - Writing output file: " & outputFileName)
			outputFile.Write(templateDoc.xml)
			outputFile.close()
        Else
            WriteLog ("GenerateReport - Error creating output file: " & outputFileName)
            Err.Clear
		End if
    Else
        WriteLog ("GenerateReport - Very Fatal Error occured ")
	End if

	WriteLog("GenerateReport - Exit, return code: " & iReturnCode)
	GenerateReport = iReturnCode

End Function


' ***************************************************************************
' Output FATAL errors, this will handle the gross errors that
' were detected in main()
' ***************************************************************************
Function GenerateFailureReport(inputPreReqFile, translateStringFile, templateReportFile, outputFileName, englishText, xlateTextID )

	'Dim xmlOmprereqcheck
	Dim xmlPrereqstrings
	Dim xmlPrereqreporttemplate
	Dim fsoOmprereq, fsoOutputFile
	Dim outputTextMessage, outputTextFeature, outputTextFeatures, outputTextDescription
	Dim allFailNode, allfailList
	Dim featureTemplateNode, allPassNode, headerNode


	WriteLog("GenerateFailureReport - Entry")
	On Error Resume Next

	'Set xmlOmprereqcheck = Nothing
	'If Not isNull(inputPreReqFile) Then
	'	WriteLog("GenerateFailureReport - inputPreReqFile: " & inputPreReqFile)
	'	Set xmlOmprereqcheck = LoadXMLDoc( inputPreReqFile )
	'Else
	'	WriteLog("GenerateFailureReport - inputPreReqFile: is Null")
	'End If

	Set xmlPrereqstrings = Nothing
	If Not isNull(translateStringFile) Then
		WriteLog("GenerateFailureReport - translateStringFile: " & translateStringFile)
		Set xmlPrereqstrings = LoadXMLDoc( translateStringFile )
	Else
		WriteLog("GenerateFailureReport - translateStringFile: is Null")
	End If

	Set xmlPrereqreporttemplate = Nothing
	If Not isNull(templateReportFile) Then
		WriteLog("GenerateFailureReport - templateReportFile: " & templateReportFile)
		Set xmlPrereqreporttemplate = LoadXMLDoc( templateReportFile )
        If xmlPrereqreporttemplate Is Nothing Then
	        WriteLog ("GenerateFailureReport - ERROR: xmlPrereqreporttemplate is Nothing")
    	Else
			Set featureTemplateNode = Null
			Set featureTemplateNode = xmlPrereqreporttemplate.getElementsByTagName(cFeatureName).item(0)
			if not isObject(featureTemplateNode) then
				WriteLog("GenerateFailureReport - ERROR: featureTemplateNode is not an object")
			end if
			Set allPassNode = Null
			Set allPassNode = xmlPrereqreporttemplate.getElementsByTagName(cAllPassTemplateNodeName).item(0)
			if not isObject(allPassNode) then
				WriteLog("GenerateFailureReport - ERROR: allPassNode is not an object")
			end if
			Set allFailNode = Null
			Set allFailNode = xmlPrereqreporttemplate.getElementsByTagName(cAllFailTemplateNodeName).item(0)
			if not isObject(allFailNode) then
				WriteLog("GenerateFailureReport - ERROR: allFailNode is not an object")
			end if
			Set headerNode = Null
			Set headerNode = xmlPrereqreporttemplate.getElementsByTagName(cHeadingTemplateNodeName).item(0)
			if not isObject(headerNode) then
				WriteLog("GenerateFailureReport - ERROR: headerNode is not an object")
			else
	    		if xmlPrereqstrings is Nothing Then
    				' Translate file is also not present or invalid
					WriteLog("GenerateFailureReport - No valid xmlPrereqstrings: " & translateStringFile)
					outputTextFeature = csFeature
					outputTextDescription = csDescription
				Else
					' Translate file exists, get the translated message
					WriteLog("GenerateFailureReport - Valid xmlPrereqreporttemplate: " & templateReportFile)
					WriteLog("GenerateFailureReport - Translating  xlateTextID: " & xlateTextID)
					outputTextFeature = GetStringByID(translateStringFile, csFeatureID )
					outputTextDescription = GetStringByID(translateStringFile, csDescriptionID )
				End if

				Dim afHeaderNodeElement
				For each afHeaderNodeElement in headerNode.childNodes
					AddStringToNode afHeaderNodeElement, cHeadingFeatureElement, outputTextFeature
					AddStringToNode afHeaderNodeElement, cHeadingDescriptionElement, outputTextDescription
				Next
			end if

			' Remove unused nodes from template
			if isObject(allPassNode) Then
				Dim allPassNodeParent
				WriteLog("GenerateFailureReport - deleting allPassNode")
				Set allPassNodeParent = allPassNode.parentNode
				allPassNodeParent.removeChild(allPassNode)
			end if

			if isObject(featureTemplateNode) Then
				Dim featureTemplateNodeParent
				WriteLog("GenerateFailureReport - deleting featureTemplateNodeParent")
				set featureTemplateNodeParent = featureTemplateNode.parentNode
				featureTemplateNodeParent.removeChild(featureTemplateNode)
			end if

		end if
	Else
		WriteLog("GenerateFailureReport - templateReportFile: is Null")
	End If

	' Output file has been verified already
	WriteLog("GenerateFailureReport - outputFileName: " & outputFileName)
	Set fsoOmprereq = CreateObject("Scripting.FileSystemObject")
	set fsoOutputFile = fsoOmprereq.OpenTextFile( outputFileName, 2, true)

	WriteLog("GenerateFailureReport - englishText: " & englishText)
	WriteLog("GenerateFailureReport - xlateTextID: " & xlateTextID)

	' Attempt to output FATAL error messages
    If xmlPrereqreporttemplate is Nothing Then
    	' Template file is also not present or invalid
		WriteLog("GenerateFailureReport - No valid xmlPrereqreporttemplate: " & templateReportFile)
    	' Need to attempt to write translated message
    	if xmlPrereqstrings is Nothing Then
    		' Translate file is also not present or invalid
			WriteLog("GenerateFailureReport - No valid xmlPrereqstrings: " & translateStringFile)
			outputTextMessage = englishText
		Else
			' Translate file exists, get the translated message
			WriteLog("GenerateFailureReport - Valid xmlPrereqreporttemplate: " & templateReportFile)
			WriteLog("GenerateFailureReport - Translating  xlateTextID: " & xlateTextID)
			outputTextMessage = GetStringByID(translateStringFile, xlateTextID )
		End if
		fsoOutputFile.Write("<?xml version=""1.0"" encoding=""UTF-8""?>")
		fsoOutputFile.Write("<html>")
		fsoOutputFile.Write("<body>")
		fsoOutputFile.Write(outputTextMessage)
		fsoOutputFile.Write("</body>")
		fsoOutputFile.Write("</html>")
		fsoOutputFile.close()

	Else

    	' Template file is present, need to fill in the all failed node
		WriteLog("GenerateFailureReport - Valid xmlPrereqreporttemplate: " & templateReportFile)
		Set allFailNode = xmlPrereqreporttemplate.getElementsByTagName(cAllFailTemplateNodeName).item(0)
		If isNull(allFailNode) then
			WriteLog("GenerateFailureReport - ERROR: allFailNode is nothing")
		Else
			WriteLog("GenerateFailureReport - allFailNode is valid")
			' Attempt to translate the message
	    	if xmlPrereqstrings is Nothing Then
    			' Translate file is also not present or invalid
				WriteLog("GenerateFailureReport - No valid xmlPrereqstrings: " & translateStringFile)
				outputTextMessage = englishText
				outputTextFeatures = csAllFeatures
			Else
				' Translate file exists, get the translated message
				WriteLog("GenerateFailureReport - Valid xmlPrereqreporttemplate: " & templateReportFile)
				WriteLog("GenerateFailureReport - Translating  xlateTextID: " & xlateTextID)
				outputTextMessage = GetStringByID(translateStringFile, xlateTextID )
				outputTextFeatures = GetStringByID(translateStringFile, csAllFeaturesID )
			End if

			Dim afNodeElement
			For each afNodeElement in allFailNode.childNodes
				AddStringToNode afNodeElement, cAllFailTemplateElement, outputTextMessage
				AddStringToNode afNodeElement, cAllFailCaptionTemplateElement, outputTextFeatures
			Next
			fsoOutputFile.Write(xmlPrereqreporttemplate.xml)
			fsoOutputFile.close()

		end if

	End If

	GenerateFailureReport = 0
	WriteLog("GenerateFailureReport - Exit")
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

	if isObject(gLogFile) then
		gLogFile.WriteLine(myTime & ": " & logString)
	else
		' WScript.Echo myTime & ": " & logString
	end if

End Function

' ***************************************************************************
' Close the log file
' ***************************************************************************
Function CloseLog
	gLogFile.Close
End Function

' ***************************************************************************
' Initialize logs and call the main function
' ***************************************************************************
Function Main

	On Error Resume Next

	Dim rCode, argList
	Dim iCount

	InitLog()
	WriteLog(" ")
	WriteLog(" ")
	WriteLog("Main - Entry *********************************")

	' Default error value
	rCode = cInvalidParametersNoOutput

	set argList = WScript.Arguments

	WriteLog("Main - Parameters:")
	for  iCount = 0 to ( argList.length - 1 )
		WriteLog("Main - arg(" & iCount & ") = " & argList(iCount) )
	Next


	if argList(0) <> "--generatereport" then
		' Run the prerequiste checks
        ' arg(0) = prereq_ms.xml or prereq_mn.xml
        ' arg(1) = ...\Temp\omprereqcheck.xml
		If argList.length = 2 Then
			if isNull( argList(1) ) Then
				WriteLog("Main - argList(2) is Null" )
			Else
				WriteLog("Main - running RunPreReqs()")
				rCode = RunPreReqs( argList(0),argList(1) )
			End If
		Else
			' Do nothing, just exit
			WriteLog("Main: RunPreReqs path - Parameter count is not 2")
		End If

	else
		' Run generate report, prerequiste checks should have already run
        ' arg[0] = --generatereport
        ' arg[1] = ...\Temp\omprereqcheck.xml -- xml file generated from prereq call
        ' arg[2] = xml\XX\prereqstrings.xml   -- xml translate table
        ' arg[3] = prereqreporttemplate.xml   -- xml report template file
        ' arg[4] = ...\Temp\omprereq.htm      -- xml output of final results
		if argList.length = 5 then
			' Required parameters were passed in

			Dim xmlOmprereqcheck
			Dim xmlPrereqstrings
			Dim xmlPrereqreporttemplate
			Dim fsoOmprereq, fsoOutputFile

  			' Check for invalid output file name, arg(4)
			Set fsoOmprereq = CreateObject("Scripting.FileSystemObject")
			Set fsoOutputFile = fsoOmprereq.OpenTextFile( argList(4), 2, true)
			If Err Then
			'If not Err Then  'TESTCASE - comment out "Set fsoOutputFile = ..." line also
				WriteLog("Main - Could not open results file: " &  argList(4))
				WriteLog("Main - Caller will need to handle the error!")
				Err.Clear

			Else
				' Clean up, close and delete the file
				fsoOutputFile.Close()
				fsoOmprereq.DeleteFile argList(4),True
				Set fsoOutputFile = Nothing
				Set fsoOmprereq = Nothing

	  			' Attempt to open ...\Temp\omprereqcheck.xml, arg(1)
				Set xmlOmprereqcheck = LoadXMLDoc( argList(1) )
				'Set xmlOmprereqcheck = Nothing  ' TESTCASE
				if xmlOmprereqcheck is Nothing Then
					Err.Clear
					WriteLog("Main - argList(1) is Nothing" )
					rCode = GenerateFailureReport( Null, argList(2), argList(3), argList(4), csreportDoc, csreportDocID )
					rCode = cInvalidParameters

				Else
					xmlOmprereqcheck.close()
					Set xmlOmprereqcheck = Nothing

	  				' Attempt to open xml\XX\prereqstrings.xml, arg(2)
					Set xmlPrereqstrings = LoadXMLDoc( argList(2) )
					'Set xmlPrereqstrings = Nothing  ' TESTCASE
					if xmlPrereqstrings is Nothing Then
						Err.Clear
						WriteLog("Main - argList(2) is Nothing" )
						rCode = GenerateFailureReport(  argList(1), Null, argList(3), argList(4), csstringDoc, Null )
 						rCode = cInvalidParameters

					Else
						xmlPrereqstrings.close()
						Set xmlPrereqstrings = Nothing

			  			' Attempt to open prereqreporttemplate.xml, arg(3)
						Set xmlPrereqreporttemplate = LoadXMLDoc( argList(3) )
						'Set xmlPrereqreporttemplate = Nothing  ' TESTCASE
						if xmlPrereqreporttemplate is Nothing Then
							Err.Clear
							WriteLog("Main - argList(3) is Nothing" )
							rCode = GenerateFailureReport(  argList(1), argList(2), Null, argList(4), cstemplateDoc, cstemplateDocID )
							rCode = cInvalidParameters

						Else
							xmlPrereqreporttemplate.close()
							Set xmlPrereqreporttemplate = Nothing
							WriteLog("Main - gStringFile = " & argList(2) )
							gStringFile = argList(2)
							WriteLog("Main - running GenerateReport()")
							rCode = GenerateReport( argList(1), argList(3), argList(4) )
						End If
					End If
				End if
			End if
		End if
	End If

	WriteLog("Main - Return Code:" & rCode)
	WriteLog("Main - Exit  *********************************")
	CloseLog()
	WScript.Quit(rCode)
End Function

Main()