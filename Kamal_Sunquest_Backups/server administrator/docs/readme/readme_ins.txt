######################################################################
DELL OPENMANAGE(TM) INSTALLATION AND SERVER MANAGEMENT README
######################################################################

Version 5.0
Release Date: June 2006

Dell OpenManage Subscription Service Kit consists of a suite of five
CDs to assist you in installing, configuring, and updating the
necessary programs and operating systems you need to get your
Dell(TM) PowerEdge(TM) system up and running.

######################################################################
CONTENTS
######################################################################

* Criticality
* Compatibility/Minimum Requirements
* Release Highlights - Features
* Release Highlights - Fixes
* Installation
* User Notes
* Known Issues
* History

######################################################################
CRITICALITY
######################################################################

2 = Recommended

######################################################################
COMPATIBILITY/MINIMUM REQUIREMENTS
######################################################################

The following Dell PowerEdge systems are supported for
"Dell PowerEdge Installation and Server Management" CD version 5.0:
600SC, 650, 700, 750, 800, 830, 850, 1600SC, 1650, 1655MC, 1750, 1800,
1850, 1855MC, 1950, 1955, 2600, 2650, 2800, 2850, 2900, 2950, 4600,
6600, 6650, 6800, and 6850.

######################################################################
RELEASE HIGHLIGHTS - FEATURES
######################################################################

* Added installation support for the following operating system:

  - SUSE(R) Linux Enterprise Server (Version 9) for Intel(R) Extended
  Memory 64 Technology (EM64T)

* Added installation support for the following systems:

   - PowerEdge 1950
   - PowerEdge 1955
   - PowerEdge 2900
   - PowerEdge 2950

* Added support for Dell Remote Access Controller 5 (DRAC 5)

* Windows Installer Patch (MSP) is not available for installation. You
  can upgrade from Dell OpenManage software version 4.3 to 5.0 through
  a full Microsoft Software Installer (MSI) install.

######################################################################
RELEASE HIGHLIGHTS - FIXES
######################################################################

N/A

######################################################################
INSTALLATION
######################################################################

* On Microsoft(R) Windows(R) operating systems, run "setup.exe" from
  the "srvadmin\windows" directory of the CD (not necessary if your
  CD runs automatically) or the software package.

* On Red Hat(R) Enterprise Linux and SUSE Linux Enterprise Server
  operating systems, to perform an "Express Install", execute the
  "srvadmin-install.sh" script from the
  "/srvadmin/linux/supportscripts" directory as follows:

  "sh srvadmin-install.sh -x"

* Detailed installation instructions, including silent install
  options, can be found in the "Dell OpenManage Installation and
  Security User's Guide" on the "Dell PowerEdge Documentation" CD.

######################################################################
USER NOTES
######################################################################

======================================================================
USER NOTES FOR ALL SUPPORTED OPERATING SYSTEMS
======================================================================

* If a reboot is required after installation of Dell OpenManage
  Server Administrator, the CD must be removed from the CD drive.

* Adaptec utilities are no longer available on the "Installation
  and Server Management" CD. They continue to be available for
  customer downloads from the Dell Support website at
  "support.dell.com."

* The "Dell OpenManage Software Quick Installation Guide" provides
  instructions on how to install the applications on the "Installation
  and Server Management" CD for all supported operating systems. See
  the "QUICK_INSTALL_GUIDE.htm" file in the
  "srvadmin\docs\en\OpenManage_QIG" directory on the "Installation
  and Server Management" CD.

* If you are running any application on the "Installation and Server
  Management" CD, close the application before installing Server
  Administrator applications.

* This version of Dell OpenManage Install only supports upgrades from
  Dell OpenManage systems management software version 4.3 or above.
  If you are using a version prior to 4.3, you must uninstall the
  previously installed version before installing this new version.
  You can also upgrade the previously installed version to version
  4.3 first (if your version is 3.0 or higher), and then upgrade to
  this version.

======================================================================
USER NOTES FOR SUPPORTED WINDOWS OPERATING SYSTEMS
======================================================================

* This version of Dell OpenManage systems management software requires
  an MSI version of 3.0 or later on your system. If the version is
  lower than 3.0, the Prerequisite Checker prompts you to upgrade to
  MSI version 3.1.

* Dell OpenManage Array Manager is no longer supported on Dell
  OpenManage systems management software version 5.0. Upgrading to
  Dell OpenManage systems management software version 5.0 will remove
  Array Manager from your system. Switch to using Storage Management
  Service instead. Do not upgrade to Dell OpenManage systems
  management software version 5.0 if you require Array Manager.

* Do not apply Windows Server(TM) 2003 Service Pack 1 (SP1)
  until you have upgraded your version of Dell OpenManage systems
  management software. If you want to retain your Server
  Administrator settings from an older version of Dell OpenManage
  systems management software, you should first upgrade to Dell
  OpenManage systems management software version 4.3, and then
  upgrade to Dell OpenManage systems management software version
  5.0. You must upgrade to Dell OpenManage systems management
  software version 5.0 prior to applying SP1.

* In the prerequisite checker screen, you may get the following
  message, "An error occurred while attempting to execute a Visual
  Basic Script. Please confirm that Visual Basic files are installed
  correctly." This error occurs when the Prerequisite Checker calls
  the Dell OpenManage "vbstest.vbs" (a Visual Basic [VB]) script to
  verify the installation environment and fails for some reason.

  The possible causes are:

  1. Incorrect Internet Explorer "Security" settings.

     Ensure that "Active Scripting" is enabled by clicking:

     "Tools" -> "Internet Options" -> "Security" -> "Custom Level"
        -> "Scripting" -> "Active Scripting" -> "Enable"

     Ensure that "Scripting of Java Applets" is enabled by
     clicking:

     "Tools" -> "Internet Options" -> "Security" -> "Custom Level"
        -> "Scripting" -> "Scripting of Java Applets" -> "Enable"

  2. Windows Scripting Host (WSH) has disabled the running of VB
     scripts.

     By default, WSH is installed during operating system
     installation. WSH can be configured to prevent scripts
     with a ".VBS" extension from being run. On the Desktop,
     right click "My Computer", then go to "Open" -> "Tools" ->
     "Folder Options" -> "File Types."  Look for the extension
     "VBS" and verify that "File Types" is set to "VBScript
     Script File". If not, click "Change" and choose "Microsoft
     Windows Based Script Host" as the application that runs
     the script.

  3. WSH is the wrong version, is corrupted, or is not installed.
p
     By default, WSH is installed during operating system
     installation. To download the current WSH version, go to:

     "http://msdn.microsoft.com/downloads/list/webdev.asp"

  4. The Scrrun.dll file may not be registered. Register it manually
     by running the following command:

     "regsvr32 Scrrun.dll"


* If you burn your own CD, be aware of the following requirement:
  MSI requires all installers to specify the "MEDIAPACKAGEPATH"
  property if the MSI file does not reside on the root of the CD.
  This property is set to "\srvadmin\windows\SystemsManagement" for
  the Server Administrator MSI package. You must ensure that the CD
  layout remains the same when burning your own CD. The
  "SysMgmt.msi" file must reside under the folder
  "\srvadmin\windows\SystemsManagement" on the CD.

  For detailed information, go to the Microsoft website:

  "http://msdn.microsoft.com/library/default.asp?url=/library/en-us/
  msi/setup/mediapackagepath.asp"

* MSI reference counting takes effect if you install the Intel
  SNMP agent using the MSI provided by Intel, and then install the
  Intel SNMP agent again using Dell OpenManage Install. The Intel
  SNMP agent is not removed during installation of either MSI;
  you must remove both installers from the system to remove the
  agent.

* When launching the MSI installation packages from your Windows
  Explorer, all MSI output will be logged into the file,
  "SysMgmt.log." It is stored at "%TEMP%."

* During installation/removal, the Windows Installer Service
  may display the time remaining for the current task to complete.
  This is only an approximation by the Windows Installer Engine based
  on varying factors.

* A new console window must be opened and CLI commands executed from
  that window after an "Unattended Installation" has completed. It is
  not possible to execute CLI commands from the same console window on
  which Server Administrator was installed.

* If Server Administrator is being installed or uninstalled on a
  system where the Web download version of Dell PowerEdge
  Diagnostics (version 2.2) is running, the Windows Installer
  Service may display a message stating that specific files needed
  by Server Administrator are in use by Diagnostics. Select the
  "Ignore" option in the message box to continue.

* When installing Server Administrator on Windows 2000, you must
  select a disk drive that has disk space greater than the required
  space. This will ensure availability of additional disk space for
  the temporary installation (not reflected in the "space required"
  field) required by Windows Installer Service.

* When installing Server Administrator on Windows 2000 systems,
  additional "Custom Install" components selected during an "Express
  Install" are retained upon returning to the "Express Install"
  option. To remove these components, you must deselect them from
  the "Custom Install" dialog.

* Before installing Server Administrator on Windows 2000 systems,
  verify that the "Unsigned non-driver installation behavior"
  policy is set to "Silently succeed." Otherwise, the Dell OpenManage
  Installer cannot install the Server Administrator applications
  properly.

  This policy can be found in "Start" -> "Programs" ->
  "Administrative Tools" -> "Local Security Policy." Expand "Security
  Settings" -> "Local Policies" -> "Security Options." After changing
  the policy, execute "secedit /refreshpolicy MACHINE_POLICY" from the
  command shell to immediately invoke the security policy change.
  After Server Administrator installation is completed, this policy
  can be set to its original value.

* During installation of Server Administrator on Windows 2000,
  if an "Out of Memory" error message displays, you must exit
  the installation and free up memory. Close other applications
  or perform any other task that will free up memory, before
  re-attempting Server Administrator installation.

* Server Administrator may conflict with the Intel IMB driver.
  You may receive an informational message recommending that you
  uninstall the Intel IMB driver before installing Server
  Administrator. You can do so through the "Device Manager."
  Perform the following steps:

  1. Open the "Device Manager"
  2. Expand the "System devices" list
  3. Right-click the device with a name of the form "IMB Driver *"
     and select "Uninstall"
  4. Select "OK" to uninstall

  If you choose to install Server Administrator while the Intel
  IMB driver is being installed, you may have problems running
  Server Administrator. Server Administrator services may fail
  to start or Server Administrator may have problems accessing
  sensor data.

* If you upgrade the Microsoft Installer Engine to version 3.1 on
  your system using Dell OpenManage Install, you may have to reboot
  your system in order to install other software applications such
  as the Microsoft SQL Server.

  Note: Dell OpenManage software does not require a reboot - the
  software will install and operate without a reboot.

======================================================================
USER NOTES FOR SUPPORTED RED HAT ENTERPRISE LINUX AND
SUSE LINUX ENTERPRISE SERVER OPERATING SYSTEMS
======================================================================

* If your system comes with a factory installed Red Hat Enterprise
  Linux (version 3) operating system for Intel EM64T, then prior to
  installing Server Administrator, you will need to install a set of
  Server Administrator-dependent RPM files. For convenience, these
  32-bit versions of the RPM files are provided on the CD or package.
  Navigate to the subfolder "/srvadmin/linux/RPMS/RH3_x86_64" and run
  "rpm -Uvh *" to install these RPM files before installing Server
  Administrator. If the 64-bit version of the dependent RPMs are
  already installed, a warning message may display. Install the
  32-bit versions using "rpm -Uvh * -- force" to bypass the warning.

* To avoid warnings concerning the RPM package key during
  installation, mount the CD or package, and import the key using the
  command:

  "rpm --import /mnt/cdrom/srvadmin/linux/RPM-GPG-KEY"

* If you have performed a default manual install of your Linux
  operating system without using Dell OpenManage Server Assistant, you
  will need a set of Server Administrator dependent RPM files
  installed prior to installing Server Administrator. These RPM files
  can be found on the Red Hat operating system media. You can locate
  them under the "/srvadmin/linux/RPMS" folder on the CD or software
  package. Under this folder, there are subfolders "RH3_i386,"
  "RH3_x86_64," "RH4_i386," and "RH4_x86_64." Navigate to the
  subfolder that matches your Linux operating system and run
  "rpm -Uvh *" to install these RPM files prior to installing
  Server Administrator.

* If you have performed a non-default install of your Linux
  operating system using your Linux operating system media, you may
  see missing RPM file dependencies while installing Server
  Administrator. Server Administrator is a 32-bit
  application. When installed on a system running a 64-bit version of
  Red Hat Enterprise Linux operating system, the Server Administrator
  remains 32-bit, while the device drivers installed by Server
  Administrator are 64-bit. If you attempt to install Server
  Administrator on a system running Red Hat Enterprise Linux (versions
  3 and 4) for Intel EM64T, be sure to install the applicable 32-bit
  versions of the missing RPM file dependencies. The 32-bit RPM
  versions always have "i386" in the file name extension. You may also
  experience failed shared object file (files with "so" in the file
  name extension) dependencies. In this case, you can determine which
  RPM is needed to install the shared object, by using the RPM
  "--whatprovides" switch. For example,
  "rpm -q --whatprovides libpam.so.0".

  An RPM name such as "pam-0.75-64" could be returned, so obtain and
  install the "pam-0.75-64.i386.rpm". When Server Administrator is
  installed on a system running a 64-bit version of a Linux operating
  system, ensure that the "compat-libstdc++-<version>.i386.rpm" RPM
  package is installed. You will need to resolve the dependencies
  manually by installing the missing RPM files from your Linux
  operating system media.

* Source packages for RPMs are available on a CD image that is
  available from the Dell Support website at "support.dell.com."

* The OpenIPMI device driver used by Server Administrator will
  conflict with the Intel IMB device driver. Dell requires that you
  unload the IMB driver before installing Server Administrator.

* Non-factory Installation Methods:

  You can install managed systems software using one of two methods.
  The "Installation and Server Management" CD provides installation
  scripts and RPM packages to install, upgrade, and uninstall Server
  Administrator and other managed system software components on your
  managed system. Additionally, you can install Server Administrator
  on multiple systems through an unattended installation across a
  network.

   - First install method - Use the provided custom install
   script "srvadmin-install.sh." This script allows unattended express
   installation and custom, unattended or interactive installation. By
   including the "srvadmin-install.sh" script in your Linux scripts
   you may install Server Administrator on single or multiple systems,
   in attended or unattended modes and locally or across a network.

   - Second install method - Use the Server Administrator RPM
   packages provided in the custom directories and the Linux "rpm"
   command. This allows custom interactive installation. You may write
   Linux scripts that install Server Administrator on a single or
   multiple systems through an unattended installation locally or
   across a network.

  Using a combination of the two install methods is not recommended.
  It may be required that you manually install required Server
  Administrator RPM packages provided in the custom directories,
  using the Linux "rpm" command.

* Notes for Upgrade:

  There are a few additional components that can be installed on a
  machine that already has Server Administrator installed. For
  example, you can install Dell PowerEdge Diagnostics on a machine
  that has previously been installed with managed systems software.
  On such a machine, while uninstalling Server Administrator, only
  those RPM packages which are not required by any of the newly
  installed components are uninstalled. In the above example, Dell
  PowerEdge Diagnostics requires packages such as
  "srvadmin-omilcore-X.Y.Z-N" and "srvadmin-hapi-X.Y.Z-N." These
  packages will not get uninstalled during an uninstallation of Server
  Administrator.

  In this situation, if you try to install Server Administrator later
  by running the "sh srvadmin-install.sh" command, you
  will get the following message:

  "Server Administrator version X.Y.Z is currently installed.
   Installed Components are:
      - srvadmin-omilcore-X.Y.Z-N
      - srvadmin-hapi-X.Y.Z-N
   Do you want to upgrade Server Administrator to X.Y.Z ?
   Press ('y' for yes | 'Enter' to exit): "

  On pressing 'y', only those Server Administrator packages (in the
  above example, "srvadmin-omilcore-X.Y.Z-N" and
  "srvadmin-hapi-X.Y.Z-N") that are residing on the machine are
  upgraded.

  If you have to install other Dell OpenManage components as well, you
  will have to run the following command once again:

  "sh srvadmin-install.sh"

* While OM 4.5 is upgraded to OM 5.0 in ESX, the following error message
  may be displayed:

    error: Failed dependencies:
    openipmi >= 35.12 is needed by srvdmin-ipmi-5.0.0-NNN.rhel3

  Upon facing this issue, the relevant openipmi package applicable to
  the operating system (in this case, openipmi-35.12.RHEL3-3dkms.noarch.rpm)
  and dkms-2.0.10-1.noarch.rpm (if necessary) should be installed
  manually with 'rpm' command and then proceed with upgrading other
  OpenManage components using srvadmin-install.sh script. These openipmi
  packages can be located under srvadmin/linux/RPMS directory on the CD or
  software package.

  You may also face this issue while upgrading from ESX 2.x to ESX 3.0.
  Then the issue can be avoided by uninstalling OM 4.5 first and then upgrading
  to ESX 3.0. You can later install OM 5.0 on ESX 3.0 (67844)

* Installation of some packages like Dell PowerEdge Diagnostics
  Diagnostics require that you have some Server Administrator components
  (like "srvadmin-omilcore-X.Y.Z-N" and "srvadmin-hapi-X.Y.Z-N") available
  on your machine. Thus, during the installation of PowerEdge
  Diagnostics, you are installing these dependent packages as well.

  Later, if you try to install Server Administrator by running the
  command, "sh srvadmin-install.sh" you will get a message stating the
  following:

  "Server Administrator version X.Y.Z is currently installed.
   Installed Components are:
     - srvadmin-omilcore-X.Y.Z-N
     - srvadmin-hapi-X.Y.Z-N
  Do you want to upgrade Server Administrator to X.Y.Z ?
  Press ('y' for yes | 'Enter' to exit): "

  On pressing 'y', only those Server Administrator packages (in the
  above example, "srvadmin-omilcore-X.Y.Z-N" and
  "srvadmin-hapi-X.Y.Z-N") that are residing on the machine are
  upgraded.

  If you want to install other components of Server Administrator,
  you will have to execute the following install command again:

  "sh srvadmin-install.sh"

* While upgrading, all installed Server Administrator components,
  including ones that are not needed but were previously installed,
  will also be upgraded. The upgrade will not attempt to detect and
  remove unwanted components.

* Under some conditions with DKMS versions prior to version 2.0.9,
  device driver building may fail. This could prevent Server
  Administrator from installing. You may see the following
  error message:

  "Building module:
  cleaning build area....(bad exit status: 2)
  make KERNELRELEASE=2.6.5-7.232-smp -C src KSP=/lib/modules/      \
    2.6.5-7.232-smp/build MANDIR=%{_mandir}....(bad exit status: 2)

  Error! Bad return status for module build on kernel:             \
  2.6.5-7.232-smp (x86_64)
  Consult the make.log in the build directory
  /var/lib/dkms/e1000/6.2.11/build/ for more information."

  To resolve the device driver build problems:

  1. Update the DKMS version to 2.0.9 or later.
  2. Uninstall the kernel source on your system.
  3. Reinstall the kernel source on you system.
  4. Build and install the device driver that was failing to
     build.
  5. If Server Administrator has failed to install, either

     Install Server Administrator using the following script,
     "./srvadmin-install.sh"

     OR

     Install the desired Server Administrator RPMs.
  (31564) (31829) (42077)


######################################################################
KNOWN ISSUES
######################################################################

======================================================================
ISSUES FOR ALL SUPPORTED OPERATING SYSTEMS
======================================================================

* If you already have Adaptec Fast Console installed on your
  system, you must uninstall this application before installing
  the Server Administrator Storage Management Service.

======================================================================
ISSUES FOR SUPPORTED WINDOWS OPERATING SYSTEMS
======================================================================

* Dell OpenManage Install does not support Windows "Advertised"
  installation - the process of automatically distributing a program
  to client computers for installation via Windows group policies.
  (144364)

* If you upgrade from version "X" to version "Y" using MSP
  and then try to use the version "Y" CD (full install), the
  Prerequisite Checker on the version "Y" CD will inform you that the
  current version is already installed. If you proceed, the
  installation will not run in "Maintenance" mode and you will
  not get the option to "Modify," "Repair," or "Uninstall."
  Proceeding with the installation will remove the MSP and create
  a cache of the MSI file present in the version "Y" package. When
  you run it a second time, the installer will run in "Maintenance"
  mode.
  (154376)

* If you choose to remove Dell OpenManage systems management software
  using the CD or Web package, it could take a few minutes before
  the system responds after you select "Remove," to continue. This may
  give you an impression that the system has stopped responding. Dell
  recommends that you remove Dell OpenManage systems management
  software using "Add or Remove Programs."
  (144970)

* When launching the Dell OpenManage Installer, an error message may
  display, stating a failure to load a specific library, a
  denial of access, or an initialization error. An example of
  installation failure during Dell OpenManage Install is "failed to
  load OMIL32.DLL." This is most likely due to insufficient
  COM permissions on the system. See the following article to remedy
  this situation:

  "http://support.installshield.com/kb/view.asp?articleid=Q104986"

  The Dell OpenManage Install may also fail if a previous installation
  of Dell OpenManage systems management software or some other
  software product was unsuccessful. A temporary Windows Installer
  registry can be deleted, which may remedy the Dell OpenManage Install
  failure. Delete the following key, if present:

  "HKLM\Software\Microsoft\Windows\CurrentVersion\Installer
  \InProgress"
  (144114, 124944)

* If both Server Administrator and Management Station are to be
  installed on a system, and the Remote Access Controller (RAC)
  feature is required install the Server Administrator Remote
  Access Service. The Server Administrator Remote Access Service
  includes the functionality supplied by the Management Station
  Remote Access Console.
  (139224)

* In the "Custom Setup" screen, you must click on an active feature
  to view your disk space availability or to change the installation
  directory. For example, if Feature A is selected for installation
  (active) and Feature B is not active, the "Change" and "Space"
  buttons will be disabled if you click Feature B. You must click on
  Feature A to view your space availability, or to change the
  installation directory.
  (139020)

* When adding a feature, if you do not have sufficient disk space on
  the drive where Server Administrator or Management Station is
  installed, you will get an out-of-disk-space message suggesting
  that you select a different destination drive. This message is
  incorrect. To correct the problem, you must free up space on the
  drive where Server Administrator or Management Station is
  installed.
  (139143)

* Dell OpenManage systems management software versions 1.x through
  4.2 must be removed to successfully install Dell OpenManage
  systems management software version 4.3 or later. Use
  "srvadmin\support\OMClean\OMClean.exe" found on your "Installation
  and Server Management" CD to remove the old version of Dell
  OpenManage systems management software.
  (138227)


* If you see the following error when trying to launch Dell OpenManage
  Install, it is recommended that you run the "OMClean.exe" program,
  under the "srvadmin\support\OMClean" directory, to remove an old
  version of Server Administrator on your system.

  "An older version of Server Administrator software is detected on
   this system.  You must uninstall all previous versions of Server
   Administrator applications before installing this version."
  (149522)

* When launching the "Quick Installation Guide" or "User's Guide"
  from the Prerequisite Checker, a Windows message will appear
  indicating that the page is blocked due to enhanced security
  configuration. You must add this site to the "Trusted Sites"
  list for the pages to display or lower your security
  settings.
  (134991)

* Uninstall previous versions of Server Administrator before
  installing Citrix Metaframe (all versions). As errors may exist
  in the registry after the Citrix Metaframe installation, you
  will need to reinstall Server Administrator.
  (67690)

* If you have low disk space in your Windows system drive, you
  may encounter misleading warning or error messages when you
  run Dell OpenManage Install. In addition to having sufficient
  space on the drive you intend to install Server Administrator,
  ensure you have sufficient disk space (10 MB or more) on your
  system drive prior to running Dell OpenManage Install.
  (145218)

* On Windows 2000 with MSI engine "2.0.2600.1183," installing
  Server Administrator using deployment tools that employ user
  impersonation will install the Server Administrator device
  drivers. Upgrade the Windows installer engine to version
  3.0 (available via Microsoft website) and install using
  deployment tools.
  (134411)

* On Windows 2000 operating systems, a roll-back to the original
  install configuration occurs if you cancel the removal of
  Server Administrator. The roll-back may not succeed for systems
  with Windows Installer Service 2.x failing to re-register
  dependent services. To resolve the issue, uninstall the failing
  component and reinstall it. This issue has been fixed for
  Windows Installer Service 3.x and higher.
  (138608)

* When you run Dell OpenManage Install in English, German, French,
  or Spanish and get unreadable characters on the "Prerequisite
  Check Information" screen, ensure that your browser encoding has
  the default character set. Resetting your browser encoding to
  use the default character set will resolve the problem.
  (145698)

* If you have installed Server Administrator and Dell PowerEdge
  Diagnostics in the same folder, and then uninstall Server
  Administrator, you may lose all PowerEdge Diagnostics files. To
  avoid this problem, install Server Administrator and PowerEdge
  Diagnostics in different folders.

======================================================================
ISSUES FOR SUPPORTED RED HAT ENTERPRISE LINUX AND
SUSE LINUX ENTERPRISE SERVER OPERATING SYSTEMS
======================================================================

* Attempts to upgrade Server Administrator version 4.3 on a system
  running a Linux operating system may fail to update the Dell Remote
  Access Controller (DRAC) package "srvadmin-racsvc-4.3.0-785" when
  attempted from the RPM command-line. To overcome this issue, stop
  the service(s) first, and then retry the upgrade:

  "srvadmin-services.sh stop"

  "rpm -Uhv srvadmin-racsvc-*.rpm"
  (144524)

* If the default install location of Server Administrator has changed
  during installation, some of the directories in which Server
  Administrator is installed will not be deleted during its removal.
  This issue is related to the default behavior of the RPM engine.
  For example, if installed with the prefix
  "--prefix/opt/dell2/srvadmin2/abc/", the RPM will only delete the
  last directory ("abc") and the remaining directories
  ("/opt/dell2/srvadmin2") are left undeleted.

* When using the command "rpm -e 'rpm -qa | grep srvadmin'" to
  remove Dell OpenManage systems management software, some RPM
  utility versions appear not to perform a full dependency
  check before removal. This can result in some installed RPMs not
  being removed in the proper order. A message such as the following
  might display:

  "WARNING:  srvadmin-rac3-components configuration not performed;
             '/etc/omreg.cfg' is missing or damaged."

  The solution is to use the Dell OpenManage uninstall script,
  "srvadmin-uninstall.sh," that is provided.
  (153056)

* Dell OpenManage Server Assistant adds a script to the root user's
  ".bash_profile" file that prompts for the installation of Dell
  OpenManage systems management software. This script might interfere
  with remote client applications that authenticate using the root
  user account on the server, but do not have a means to handle user
  prompts. To remedy this limitation, edit the ".bash_profile" file
  and comment out the line: "[ ${SHLVL}...."
  (152668)

* There may be problems uninstalling Server Administrator after an
  unsuccessful upgrade during a manual RPM upgrade. You will
  see the following error message:

  "error: %preun(srvadmin-NAME-X.Y.Z-N.i386) scriptlet failed, exit
  status 1"

  Here, "NAME" is a feature name, for example "omacore". "X.Y.Z-N"
  is the version and build number of the feature.

  Some possible solutions to rectify this problem:

  1. Attempt to uninstall again. For example, use the following
     command:
     "rpm -e srvadmin-NAME-X.Y.Z-N.i386"

  2. Delete the line "upgrade.relocation=bad" if present in the
     "/etc/omreg.cfg" file and attempt to uninstall again.
  (20927 24290)


* Problems may arise while upgrading Server Administrator in
  some circumstances when the upgrade is attempted and not fully
  successful. This could happen, for instance, when a user is doing a
  manual RPM update on a system requiring an updated OpenIPMI driver
  and that driver is not installed. Some features depending on that
  driver will not install, which is correct. Unfortunately, older
  installed features that should have been uninstalled, may not be
  uninstalled. This leads to mixed versions of Server
  Administrator being installed on a system. This is not a viable
  installation. This is due to limitations in some versions of the RPM
  utility.

  During the upgrade, the following messages may be displayed:

  "srvadmin-omhip:
  The required dependency key, "hapi.omilcore.version", in the
  "/etc/omreg.cfg" file is not present."

  "Installation aborted."

  "error: %pre(srvadmin-omhip-5.0.0-200.i386) scriptlet failed, exit
         status 1"

  "error:  install: %pre scriptlet failed (2), skipping
         srvadmin-omhip-5.0.0-200"

  Using the command, "rpm -qa | grep srvadmin", displays the Server
  Administrator features that are installed. The following output may
  be displayed:

  srvadmin-deng-5.0.0-200
  srvadmin-omhip-4.4.0-339
  srvadmin-jre-5.0.0-200
  srvadmin-omacore-5.0.0-200
  srvadmin-cm-5.0.0-200
  srvadmin-omilcore-5.0.0-200
  srvadmin-odf-5.0.0-200

  To fix the problem, perform the following steps:

  1. Delete the older feature. For example, use the following command
     "rpm -e srvadmin-omhip-4.4.0-339"
  2. Resolve the dependency issue. In this case, install the proper
     set of OpenIPMI drivers. Go to the
     "supportscripts" directory on the "Installation and Server
     Management" CD and enter "./srvadmin-openipmi.sh install"
  3. Install the uninstalled RPMs from the "custom/srvadmin-base"
     directory on the "Installation and Server Management" CD. For
     example, use the following commands:
     "rpm -ihv srvadmin-hapi-5.0.0-200.i386.rpm"
     "rpm -ihv srvadmin-isvc-5.0.0-200.i386.rpm"
     "rpm -ihv srvadmin-omhip-5.0.0-200.i386.rpm"
  (21892)

* During uninstall, problems may occur that are caused by a previous
  attempt to upgrade Server Administrator that was not successful.
  After all Server Administrator RPMs have been uninstalled, some Server
  Administrator files may not have been deleted.  This is due to
  limitations in some versions of the RPM utility.

  To fix the problem:

  1. Log in as "root."
  2. Change directories to the directory Server Administrator was
     installed. For example, "cd /opt". The default directory is "/opt".
  3. Delete the Server Administrator directory by using the command:
     "rm -rf dell"
  (25247)

######################################################################
HISTORY:
######################################################################

Version 4.5.1 A00
Release Date: February 2006

######################################################################
RELEASE HIGHLIGHTS - FEATURES
######################################################################

* Limited installation support only for the following platforms on
  Windows and Linux operating systems:
  - PE6800
  - PE6850

* Updated Storage Management Service support to include SAS controllers

Note: This release supports only PE6800 and PE6850 systems.

######################################################################
RELEASE HIGHLIGHTS - FIXES
######################################################################

N/A

----------------------------------------------------------------------
Version 4.5 A00
Release Date: October 2005

######################################################################
Release Highlights - Features
######################################################################

* Added installation support for the following operating system:

   - VMWare ESX 2.5.1

* Added installation support for the following systems:

   - PowerEdge 830
   - PowerEdge 850

* From Dell OpenManage systems management software version 4.3
  onwards, added support for Windows upgrade using the Windows
  Installer Patch (MSP) file. MSP files are much smaller in size
  and are available on the Dell Support website at
  "support.dell.com."


######################################################################
Release Highlights - Fixes
######################################################################

N/A

----------------------------------------------------------------------
Version 4.4.1 A00
Release Date: July 2005

######################################################################
Release Highlights - Features
######################################################################

* Added installation support for the following new platforms:
  - PE830
  - PE850

Note: This release supports only these 2 new platforms.

######################################################################
Release Highlights - Fixes
######################################################################

N/A


----------------------------------------------------------------------
Version 4.4 A00
Release Date: May 2005

======================================================================
Release Highlights - Features
======================================================================


* Added installation support for the following operating systems:
   - Windows Server 2003 x64 (Standard and Enterprise editions)
   - Windows Server 2003 SP1
     NOTE: Dell OpenManage version 4.3 does not install on SP1
   - Red Hat Enterprise Linux (version 3) for Intel EM64T
   - Red Hat Enterprise Linux (version 4) for Intel x86
   - Red Hat Enterprise Linux (version 4) for Intel EM64T

* Added service pack file (MSP) support for Windows upgrade from
  version 4.3.  MSP files are much smaller in size and are available
  from the Dell Support website at "support.dell.com."

======================================================================
Release Highlights - Fixes
======================================================================

N/A

----------------------------------------------------------------------
Version 4.3 A00
Release Date: February 2005

======================================================================
Release Highlights - Features
======================================================================

* Added installation support for Dell OpenManage Server Administrator
  Storage Management Service under Microsoft Windows and Red
  Hat Enterprise Linux.

* Leveraged native install technologies for each operating system
  for Server Administrator installs.

* Added Server Update Utility (SUU) 1.0 to the "Dell PowerEdge
  Updates" CD. SUU is a CD-based application for identifying and
  applying updates on your PowerEdge server(s).

======================================================================
Release Highlights - Fixes
======================================================================

N/A

======================================================================

Information in this document is subject to change without notice.
(C) 2004-2006 Dell Inc. All rights reserved.

Reproduction in any manner whatsoever without the written
permission of Dell Inc. is strictly forbidden.

Trademarks used in this text: "Dell," "PowerEdge," and "Dell
OpenManage" are trademarks of Dell Inc.; "Windows Server" is a
trademark, and "Microsoft" and "Windows" are registered trademarks of
Microsoft Corporation; "Intel" is a registered trademark of
Intel Corporation; "Red Hat" is a registered trademark of Red Hat, Inc;
SUSE is a registered trademark of Novell, Inc. in the United States
and other countries.

Other trademarks and trade names may be used in this document to refer
to either the entities claiming the marks and names or their products.
Dell Inc. disclaims any proprietary interest in
trademarks and trade names other than its own.

Server Administrator uses the OverLIB JavaScript library. This
library can be obtained from "www.bosrup.com".

May 2006
