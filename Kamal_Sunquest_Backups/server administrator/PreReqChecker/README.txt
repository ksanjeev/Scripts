Prerequisite Checker
---------------------------------------------------------------------
The RunPreReqChecks utility will perform all prerequisite checking.

The prerequisite checker displays three types of messages. These are
informational, warning, and error messages.

Informational messages tell you of a condition of which you should be aware.
They do not prevent a feature from being installed.

Warning messages tell you about a condition that prevents a feature from
being installed during "Express" installation. It is best that you resolve
the condition causing the warning before proceeding with the installation
of that feature. If you decide to continue, you can select and install the
feature using the Custom installation.

Error messages tell you about a condition of which you should be aware
that prevents the feature from being installed. You must resolve the
condition causing the error before proceeding with the installation of
that feature. If not, the feature will not be installed.

To execute PreRequisite checking silently, run the utility
RunPreReqChecks.exe with the /s command line option. e.g.
"RunPreReqChecks.exe /s".

After running it, an htm file will be created in the %Temp% directory.
The file is named omprereq.htm, and will contain the results of the
prerequisite check. (The Temp directory is not usually X:\Temp, but
X:\Documents and Settings\username\Local Settings\Temp. To find %TEMP%,
go to a command line prompt and type "echo %TEMP%".)
The return code from RunPreReqChecks.exe will be the number associated
with the highest severity condition for all the features. The return
code values are as follows:

Return Code  Description
-----------  -------------------------------------------------------
     3       At least one feature has issued an error message.  The
             Prerequisite Checker has completed successfully.

     2       At least one feature has issued a warning message.
             The Prerequisite Checker has completed successfully.

     1       At least one feature has issued an informational message.
             The Prerequisite Checker has completed successfully.

     0       Prerequisite Checker completed successfully with no error,
             warning, or informational messages.

    -1       Windows Host Scripting Error (WSH).  The Prerequisite Checker
             did not run.

    -2       Operating system is not supported. The Prerequisite Checker
             did not run.

    -3       User does not have Administrator privileges. The Prerequisite
             Checker did not run.

    -4       Unused.

    -5       Failed to change working directory to %TEMP%.  The Prerequisite
             Checker did not run.

    -6       Destination directory does not exist.  The Prerequisite
             Checker did not run.

    -7       Internal Error.  The Prerequisite Checker did not run.

    -8       An instance is already running. The Prerequisite Checker
             did not run.

    -9       Windows Host Scripting Error (WSH) is wrong version, corrupted
             or not installed.  The Prerequisite Checker did not run.

   -10       Error with scripting environment.  The Prerequisite Checker
             did not run.


Additionally, The results of the Prerequisite Checker are written to the registry
under the main registry key for the Management Station:
HKEY_LOCAL_MACHINE\Software\Dell Computer Corporation\OpenManage\PreReqChecks\MS

and under the main registry key for the Managed System:
HKEY_LOCAL_MACHINE\Software\Dell Computer Corporation\OpenManage\PreReqChecks\MN

Each feature has an associated value set after running the prerequisite check,
they are the same values as those returned by RunPreReqChecks.exe.

Feature ID's for the Management Station
--------------------------------------------------------------------
AMCON          Array Manager Console
ITA            IT Assistant
RACMS          Remote Access Controller Management
ADS	       Active Directory Snap-In Utility
BMU	       Baseboard Management Controller Management Utility 	

Feature ID's for the Managed System:
--------------------------------------------------------------------
BRCM           Broadcom NIC agent
INTEL          Intel NIC agent
IWS            Server Administrator Web Server
OMSM           Storage Management
RAC3           Remote Access Controller (DRAC III)
RAC4           Remote Access Controller (DRAC IV)
SA             Server Administrator


Common Messages for the Management Station and the Managed System (SA)
----------------------------------------------------------------------

Status       Prerequisite Message                                                              Additional Information
---------    -----------------------------------------------------------------------------     -------------------------------------------------- 
Success      There are no prerequisite check conflicts for this system.                        There is nothing to prevent the express install of
                                                                                               the product.

Error        The current user does not have administrative privileges.                         The user needs to have administrator privileges
             Server Administrator software can only be installed as a user with                to install Server Administrator or Management Station.
             administrative privileges.
               
Error        The MSI package does not contain a valid signature.                               Either the MgmtSt.msi or SysMgmt.msi has been corrupted.
                                                                                               Obtain a replacement CD.
               
Error        An older version of Server Administrator software is detected on this system.     The user will need to uninstall the previous verison of
             You must uninstall all previous versions of Server Administrator applications     Server Administrator or Management Station before installing
             before installing this version.                                                   this verison.

(VARIES)     A description string not found in the prereqstrings.xml file.                     This message indicates that a message ID was produced for
                                                                                               a string that does not exist in the prereqstrings.xml file.
                                                                                               Severity level will depend on the check that failed.

Error        This prerequisite check failed to execute on this system.                         This message indicates that the prerequisite check did not
                                                                                               execute or the status of the check was not found.

Error        The prerequisite checks have failed to execute on this system.
             Consult your user guide for more information.

Error        The prerequisite checks did not execute on this system due to an inability to
             load the prereqreporttemplate.xml file.

Error        The prerequisite checks did not execute on this system due to an inability to
             load the omprereqcheck.xml file.

Error        The prerequisites did not execute on this system because the registry key
             HKEY_LOCAL_MACHINE\\SOFTWARE\\Dell Computer Corporation does not have
             appropriate permission settings.
             Consult your documentation for more information.

Error        The registry key for Windows Installer indicates that an install is currently
             running. Please wait for all installs to finish. If you are absolutely sure
             that no installs are currently running then you need to manually remove a
             registry key. Run regedit.exe and delete the registry key "InProgress" under
             registry tree
             "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\Windows\CurrentVersion\Installer\"

Error        You must reboot your system to remove any file rename operations that are pending.  
	      On reboot, the operating system will automatically remove the registry key 
	      HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\PendingFileRenameOperations.
	      This will ensure that the MSI upgrade is successful.

Messages for the Management Station
===================================

Common Messages for the Management Station
------------------------------------------
Status       Prerequisite Message                                                              Additional Information
---------    -----------------------------------------------------------------------------     --------------------------------------------------------
Information  An older version of Management Station or Server Administrator has been           This message is displayed when upgrading from versions of 
             detected on this system. Management Station install will first remove the         Server Administrator prior to 4.3.0.
             previous version of the systems management application and then install the
             Management Station applications you select.
             NOTE: If they have been previously installed, all Management Station
             applications and/or all Server Administrator applications will be removed.
             After installing Management Station, you can install Server Administrator
             applications using the latest version of Server Administrator Install.
               
Information  The current version of Management Station (some or all components) is
             already installed on this system. Management Station Install will allow
             you to modify, repair, or remove Management Station.

Error        The required SNMP service was not found on this host. You must install and
             activate SNMP in order for IT Assistant or other SNMP based management
             consoles to function properly.
             
Error        A newer version of Management Station (some or all components) is already
             installed on this system. You will not be allowed to install this version
             until the installed Management Station has been removed.

Error        The prerequisite checks did not execute on this system due to an inability to
             load the prereq_ms.xml file.

Error        Prereq checker has detected that you are running from a CD ROM but the cd
             layout does not match the layout of the official Management Station CD.
             The file MgmtSt.msi must appear under the folder \\windows\\ManagementStation
             otherwise install/upgrade may not work.

Information  An older version of Management Station is detected on this system.
             Continuing will upgrade Management Station. After performing the upgrade,
             you can add or remove features by using the Add/Remove programs.


Messages for the Management Station Feature: IT Assistant
---------------------------------------------------------
Status       Prerequisite Message                                                              Additional Information
---------    -----------------------------------------------------------------------------     -------------------------------------------------------
Error        A previous version of IT Assistant was detected on a system that has been
             upgraded to the Microsoft(R) Windows(R) Server 2003 operating system.
             See the "Installation" section in the "IT Assistant User's Guide";
             for important instructions required to properly upgrade IT Assistant.

Error        IT Assistant services cannot be installed on a system that has the Network
             Manager version 1.0.x-1.4.x application installed on it.

Error        IT Assistant version 6.2 or later is supported for upgrade in this version.
             Uninstall the existing IT Assistant version before continuing with the
             installation.

Error        If "Dell OpenManage Connection"; components, version 2.1 and earlier for
             HP OpenView, version 1.1 and earlier for Microsoft(R) Systems Management
             Server, or version 1.2 and earlier for CA Unicenter TNG are installed on this
             system, you cannot install IT Assistant.

Error        This system has a Microsoft(R) SQL Server version earlier than version 8.0.
             Install Microsoft SQL Server version 8.0 or later for the installation
             to continue.

Error        IT Assistant does not support a nondefault instance of
             Microsoft(R) SQL Server 2000. To continue with the installation,
             either install a default instance of Microsoft SQL Server 2000, or uninstall
             the nondefault instance of Microsoft SQL Server 2000.

Error        IT Assistant will not install on a system running the Microsoft(R) Windows(R)
             2000 operating system through a terminal session with Terminal Services in
             Application Mode enabled. Run the installation locally on the system.

Error        The Microsoft(R) SQL Client software is detected.
             Uninstall this software before continuing.
             
Error        Ensure that Microsoft(R) SQL Server or Microsoft Database Engine (MSDE)
             services are not corrupt and can start.
             
Error        Required TCP/IP protocol could not be found.
             
Error        IT Assistant cannot be installed on a Microsoft(R) Windows(R) Small
             Business Server.
             
Error        A newer version of IT Assistant is already installed on this system.
             
Error        Microsoft(R) Database Engine (MSDE) is not installed on this system.
             You must install the MSDE 2000 before installing the IT Assistant feature of
             the Management Station.  Click on the following link to install the MSDE:  
             
Error        IT Assistant cannot be installed on a system running a Microsoft(R)
             Windows(R) x64 operating system.


Messages for the Management Station Feature: Remote Access Controller Management Station
----------------------------------------------------------------------------------------
Status       Prerequisite Message                                                              Additional Information
---------    -----------------------------------------------------------------------------     -------------------------------------------------------
Error        The Server Administrator Remote Access Controller service is already
             installed. The Management Station Remote Access Console can not be
             installed and will be disabled.

Error        The Remote Access Controller Management Station cannot be installed on a
             system running a Microsoft(R) Windows(R) x64 operating system.


Messages for the Management Station Feature: Active Directory Services
----------------------------------------------------------------------
Status       Prerequisite Message                                                              Additional Information
---------    -----------------------------------------------------------------------------     --------------------------------------------------------
Information  The Management Station installer contains the 32-bit version of the Active
             Directory Snap-in Utility. You can install the 64-bit version of the
             Active Directory Snap-in Utility from the support directory on the "Consoles"
             CD or the Management Station Windows Web download package.


Messages for the Managed System (SA)
====================================

Common Messages for the Managed System (SA)
-------------------------------------------
Status       Prerequisite Message                                                              Additional Information
---------    -----------------------------------------------------------------------------     ---------------------------------------------------------
Error        Prereq checker has detected that you are running from a CD ROM but the cd
             layout does not match the layout of the official Server Administrator CD.
             The file SysMgmt.msi must appear under the folder
             \\srvadmin\\windows\\SystemsManagement otherwise install/upgrade may not work.
             
Information  The current version of Server Administrator (some or all components) is
             already installed on this system. Server Administrator Install will allow you
             to modify, repair, or remove Server Administrator.
             
Error        A newer version of Server Administrator (some or all components) is already
             installed on this system. You will not be allowed to install this version
             until the installed Server Administrator has been removed.

Error        The prerequisite checks did not execute on this system due to an inability to
             load the prereq_mn.xml file.


Messages for the Managed System (SA) Feature: Server Administrator
------------------------------------------------------------------
Status       Prerequisite Message                                                              Additional Information
---------    -----------------------------------------------------------------------------     ---------------------------------------------------------
Error        This is not a supported server. Server Administrator software can only be
             installed on supported servers.
             
Error        Server Administrator is no longer supported on this system.
             Please use Server Administrator CD version 3.3.0 to install
             Server Administrator software on this system.
             
Information  Operating system support for SNMP is not installed.  Server Administrator can
             be installed, but you will not be able to manage this system using SNMP.
             
Error        Server Administrator software cannot be installed on this system due to the
             operating system or service pack level. Server Administrator software can
             only be installed on Microsoft(R) Windows(R) 2000 with Service Pack 3 or
             above, or on Windows 2003.
             
Error        Server Administrator Instrumentation drivers cannot be installed on
             Microsoft(R) Windows(R) 2000 when the local or domain security policy does
             not allow unsigned non-driver installation. See the install readme file
             (readme_ins.txt under the readme directory) for further instructions to
             properly install Server Administrator.
             
Error        Required TCP/IP protocol could not be found.
             
Information  An older version of Management Station or Server Administrator has been
             detected on this system. Server Administrator install will first remove the
             previous version of the systems management application and then install the
             Server Administrator applications you select. NOTE: If they have been
             previously installed, all Management Station applications and/or all Server
             Administrator applications will be removed. After installing Server
             Administrator, you can reinstall Management Station applications using the
             latest version of Management Station Install.
            
Information  An older version of Server Administrator is detected on this system.
             Continuing will upgrade Server Administrator. After performing the upgrade,
             you can add or remove features by using the Add/Remove programs.

Error        Server Administrator does not support the running kernel.
             See Dynamic Kernel Support in the Server Administrator readme.txt file.

Information  The Intel(R) IMB device driver is currently installed. Server Administrator
             ("SA") installs an IPMI device driver that may conflict with the Intel IMB
             driver. SA can be installed, but it is recommended that you uninstall the
             Intel IMB driver before installing SA. See the install readme file
             (readme_ins.txt under the readme directory) for further information.


Messages for the Managed System (SA) Feature: Remote Access Controller
----------------------------------------------------------------------
Status       Prerequisite Message                                                              Additional Information
---------    -----------------------------------------------------------------------------     ---------------------------------------------------------
Warning      A Remote Access Controller III or IV was not detected on this server.
             This will disable the "Express" installation of the Remote Access Controller.
             Use the "Custom" installation setup type later during installation to select
             this feature if you have a Remote Access Controller III or IV installed.
             
Warning      Remote Access Controller cannot function fully until
             Remote Access Service (RAS) is installed.
             
Information  Remote Access Controller requires you to configure a PPP Dialup connection
             after the software installation.
             
Warning      Microsoft(R) Domain Name Services (DNS) or Windows(R) Internet Name Service
             (WINS) has been detected on this system. Please consult the
             ISSUES FOR REMOTE ACCESS section in the Server Administrator README for
             further information.
             
Error        The Management Station Remote Access Console is already installed.
             The Server Administrator Remote Access Controller service can not be
             installed and will be disabled.


 
 Messages for the Managed System (SA) Feature: Storage Management
-----------------------------------------------------------------
Status       Prerequisite Message                                                              Additional Information
---------    -----------------------------------------------------------------------------     --------------------------------------------------------
Error        Setup has detected Array Manager installed on your system.
             You will need to uninstall Array Manager before installing
             Storage Management.
             
Warning      Setup has detected the FAST package installed on your system.
             It is recommended that you uninstall the FAST package before installing
             Storage Management or Array Manager.
             
Warning      Setup has detected PERC Console installed on your system.  It is recommended
             that you uninstall PERC Console before installing Storage Management.
             
Warning      One or more of your storage controllers has an out-of-date driver.
             See the storage tab after installation for more information.
             
Warning      One or more of your storage controllers has out-of-date firmware.
             See the storage tab after installation for more information.
             
Information  If this is the first time Storage Management is being installed on this
             system, the installation may not be able to detect the firmware or device
             driver for any PERC2 or PERC 3/Di controller in your
             system.  See the storage tab after installation for more information.


Messages for the Managed System (SA) Feature: Intel SNMP Agent
--------------------------------------------------------------
Status       Prerequisite Message                                                              Additional Information
---------    -----------------------------------------------------------------------------     ---------------------------------------------------------
Warning      An Intel(R) NIC was not detected on this system.
             This will disable the "Express" installation of the Intel(R) SNMP Agent.
             Use the "Custom" installation setup type later during installation to select
             this feature if you have an Intel(R) NIC installed.
             
Information  An Intel(R) NIC was detected on this system. You should install the 64 bit
             version of Intel(R) SNMP agent from the support directory.


Messages for the Managed System (SA) Feature: Broadcom SNMP Agent
-----------------------------------------------------------------
Status       Prerequisite Message                                                              Additional Information
---------    -----------------------------------------------------------------------------     --------------------------------------------------------
Warning      A Broadcom(R) NIC was not detected on this system. This will disable the
             "Express" installation of the Broadcom(R) SNMP Agent. Use the "Custom"
             installation setup type later during installation to select this feature if
             you have a Broadcom(R) NIC installed.
             
Information  A Broadcom(R) NIC was detected on this system. You should install the 64 bit
             version of Broadcom(R) SNMP agent from the support directory.
             
             
             
             
             
             
		           
		           
               