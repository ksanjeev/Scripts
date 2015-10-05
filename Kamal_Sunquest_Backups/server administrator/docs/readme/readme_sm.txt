#######################################################################

DELL OPENMANAGE(TM) Server Administrator Storage Management, VERSION 2.0
README

This is the readme file for the Dell OpenManage Server Administrator
Storage Management Service. For additional information, see the Server
Administrator readme file and the Server Administrator user's guide.

NOTE: The Storage Management Service is installed using the
      Server Administrator install process. See the Dell OpenManage
      Install readme (readme_ins.txt) on the "Systems Management" CD
      for the latest installation information.

Note: Installing Storage Management on a system that does not have a
      supported controller or that has a controller that is not attached
      to storage is an unsupported configuration. Attempts to install or
      run Storage Management using an unsupported configuration can
      result in unexpected and undesirable system behavior.


Always see the Dell support Website at support.dell.com for the most
current information.

#######################################################################

======================================================================
Criticality
======================================================================

2 - Recommended


Note: The Storage Management Service does not support Novell(R)
      NetWare(R) or fibre channel. Disk and volume management are also
      not provided by the Storage Management Service.

======================================================================
Title and Description
======================================================================

Dell OpenManage Server Administrator Storage Management is a storage
management application for PowerEdge(TM) servers that provides enhanced
features for configuring a system's locally-attached RAID and non-RAID
disk storage. Dell OpenManage Server Administrator Storage Management
enables you to perform controller and enclosure functions for all
supported RAID and non-RAID controllers and enclosures from a single
graphical or command-line interface without requiring the use of the
controller BIOS utilities. The graphical user interface (GUI) is
wizard-driven with features for novice and advanced users and detailed
online help. The command line interface is fully-featured and scriptable.

The Storage Management Service supports SCSI, SATA, ATA and SAS
technologies.

######################################################################
README TABLE OF CONTENTS
######################################################################

COMPATIBILITY/RECOMMENDED REQUIREMENTS
WARNINGS
WHAT IS NEW IN THIS RELEASE?
COMPARING THE STORAGE MANAGEMENT SERVICE AND ARRAY MANAGER
CONSIDERATIONS WHEN MIGRATING FROM ARRAY MANAGER
INSTALLING STORAGE MANAGEMENT, VERSION 2.0
KNOWN LIMITATIONS

######################################################################
COMPATIBILITY/RECOMMENDED REQUIREMENTS
######################################################################

The Storage Management Service is installed using the Server
Administrator install process. For Server Administrator installation
requirements, see the following documentation:

* The Dell OpenManage Install readme (readme_ins.txt) on the
  "Installation and Server Management" CD for the latest installation
  information.

* The "Installing Server Administrator" chapter in the Server
  Administrator User's Guide.


In addition to the Server Administrator installation requirements,
the following recommendations apply to Storage Management. Storage
Management may experience instability if these recommendations are
not met.

* On a Windows Server 2003 system, it is strongly recommended that you
  update to Service Pack 1 or later.  Service Pack 1 is required to
  fully support SAS technology.

* On a Windows 2000 system, it is strongly recommended that you update
  to Service Pack 4 or later.  Service Pack 4 is required to
  fully support SAS technology.

* On a Red Hat Enterprise Linux 3.x system, Update 3 or later is
  required for Storage Management and Update 6 or later is required to
  fully support SAS technology.  Dell strongly recommends that you use
  the Red Hat Network (RHN) service to update your system software with
  the latest update package before deploying your system. Go to
  www.redhat.com to access the RHN service and download updates.

======================================================================
COMPATIBILITY WITH ARRAY MANAGER
======================================================================

Installing the Storage Management Service replaces any previous
installation of the Array Manager managed system (server software) that
resides on the system. The Array Manager console (client software) is
not replaced.

======================================================================
COMPATIBILITY WITH OTHER RAID STORAGE MANAGEMENT UTILITIES
======================================================================

* PERC Console and FAST Compatibility Issues when Installing Storage
  Management

  Installing Storage Management on a system that has FAST or the PERC
  Console installed is an unsupported configuration. It is recommended
  that you uninstall FAST and the PERC Console before installing Storage
  Management. In particular, you may find that Storage Management or the
  FAST features are disabled at run time when using Storage Management
  on a system that also has FAST installed. Storage Management replaces
  all storage management features provided by FAST and the PERC Console.
  In addition, Storage Management has features not provided by FAST and
  the PERC Console.


* Compatibility with Linux Utilities

  Installing Storage Management on a Linux system that has other RAID
  storage management utilities provided by Dell or other vendors is an
  unsupported configuration. It is recommended that you uninstall these
  utilities before installing Storage Management. Storage Management
  replaces the storage management features provided by these utilities.
  Examples of the Dell or vendor-supplied Linux utilities include:

  - LinFlash
  - DellMgr
  - DellMON
  - LINLib
  - MegaMgr
  - MegaMON


Note: See the WARNINGS section of this readme for additional information.


======================================================================
FIRMWARE AND DRIVER REQUIREMENTS FOR THE PERC 3/SC, 3/DC, 3/DCL, 3/QC,
4/SC, 4/DC, 4e/DC, 4/Di, 4/IM, 4e/Si, 4e/Di, CERC ATA100/4ch, PERC 5/E,
PERC 5/i Integrated, Perc 5/i Adapter, SAS 5/iR Adapter, SAS 5/iR
Integrated, SAS 5/i Adatper, SAS 5/E Adapter, LSI 1020, and LSI 1030
CONTROLLERS
======================================================================

The firmware and drivers listed in the following table refer to the
minimum supported version. Later versions of the firmware and drivers
are also supported. Refer to http://support.dell.com for the most recent
driver and firmware requirements.


Controller	Firmware/ 	Windows 2000	Windows		Windows		Redhat		Redhat		SUSE
		BIOS		Driver		Server		Server		Linux		Linux		Linux
						2003 32-bit	2003 64-bit	Driver		Driver		9 64-bit
						Driver		Driver		3.0		4.0		Driver


PERC 3/SC	1.98X		5.48		6.46.2.32	6.46.3.64	2.10.10.1	2.20.4.4	Not
														Applicable

PERC 3/DC	1.98X		5.48		6.46.2.32	6.46.3.64	2.10.10.1	2.20.4.4	Not
														Applicable

PERC 3/DCL	1.98X		5.48		6.46.2.32	6.46.3.64	2.10.10.1	2.20.4.4	Not
														Applicable
PERC 3/QC	1.98X		5.48		6.46.2.32	6.46.3.64	2.10.10.1	2.20.4.4	Not
														Applicable

PERC 4/SC	3.51X		5.48		6.46.2.32	6.46.3.64	2.10.10.1	2.20.4.4	Not
														Applicable


PERC 4/DC	3.51X		5.48		6.46.2.32	6.46.3.64	2.10.10.1	2.20.4.4	Native
32-Bit														2.20.4.6


PERC 4/DC	3.51S		5.48		6.46.2.32	6.46.3.64	2.10.10.1	2.20.4.4	Native
64-Bit														2.20.4.6


PERC 4e/DC	5.12X		5.48		6.46.2.32	6.46.3.64	2.10.10.1	2.20.4.4	Native
														2.20.4.6


PERC 4e/Si	5.21X		5.48		6.46.2.32	6.46.3.64	2.10.10.1	2.20.4.4	Not
														Applicable


PERC 4e/Di	5.21X		5.48		6.46.2.32	6.46.3.64	2.10.10.1	2.20.4.4	Not
														Applicable


PERC 4/Di on a	2.51X		5.48		6.46.2.32	6.46.3.64	2.10.10.1	2.20.4.4	Not
PowerEdge 2600													Applicable


PERC 4/Di on a	4.21W		5.48		6.46.2.32	6.46.3.64	2.10.10.1	2.20.4.4	Not
PowerEdge 1750													Applicable


PERC 4/IM on a	1.00.12.00	1.08.06		1.08.06		1.08.06		Not		Not		Not
PowerEdge	(1.00.0C.00 Hex)						Applicable	Applicable	Applicable
1655MC


PERC 4/IM on a	1.03.23.90	1.09.11		1.09.11		Native (SP1)	2.05.16		Native		Not
PowerEdge 1855							1.09.11.53			3.01.16		Applicable


CERC		6.62		 5.46 		6.41.2.32	6.41.2.32	2.10.10.1 	2.20.4.4 	Not
ATA 100/4CH													Applicable


PERC 5/E	5.0.1-0026	1.18.00.32	1.18.00.32	1.18.00.64	00.00.02.03     00.00.02.03	00.00.02.05


PERC 5/i 	5.0.1-0030	1.18.00.32	1.18.00.32	1.18.00.64	00.00.02.03     00.00.02.03	00.00.02.05
Integrated


PERC 5/i	5.0.1-0030	1.18.00.32	1.18.00.32	1.18.00.64	00.00.02.03     00.00.02.03	00.00.02.05
Adapter

SAS 5/iR	00.06.50.00/	1.21.08.00	1.21.08.00	1.21.08.00	02.06.32	03.02.63	03.02.63
Integrated      06.06.00.02


SAS 5/iR	00.06.50.00/	1.21.08.00	1.21.08.00	1.21.08.00	02.06.32	03.02.63	03.02.63
Adapter		06.06.00.02


SAS 5/i		00.06.40.00/	1.21.08.00	1.21.08.00	1.21.08.00	2.06.32		3.02.63		3.02.63
Integrated	06.06.00.02


SAS 5/E		00.08.01.00/	1.21.08.00	1.21.08.00	1.21.08.00	2.06.32		3.02.63		3.02.63
Adapter		06.06.00.01


LSI 1020 on a	1.03.23		1.09.11		1.09.11		1.09.11		2.05.11.03	Native		Not
PowerEdge													Applicable
1600SC


LSI 1030 on a 	1.03.23		1.09.11		1.09.11		1.09.11		2.05.11.03	Native		Not
PowerEdge													Applicable
1750



======================================================================
FIRMWARE AND DRIVER REQUIREMENTS FOR THE PERC 3/Si, PERC 3/Di,
CERC SATA1.5/6ch, and CERC SATA1.5/2s CONTROLLERS
======================================================================

The firmware and drivers listed in the following table refer to the
minimum supported version. Later versions of the firmware and drivers
are also supported. Refer to http://support.dell.com for the most
recent driver and firmware requirements.

Note: Versions of these controllers (PERC 3/Si, PERC 3/Di,
      CERC SATA1.5/6ch, and CERC SATA1.5/2s) prior to 2.8
      are not supported.


Note: Storage Management requires that the system be rebooted before
      Storage Management can properly determine whether the system
      meets the firmware and driver requirements for the PERC 3/Si,
      and PERC 3/Di controllers. For this reason, it is possible to
      complete an initial installation of Storage Management without
      being notified whether your system meets the firmware and driver
      requirements. Refer to this readme and http://support.dell.com
      for the most recent driver and firmware requirements.





Controller	Firmware 	Windows 2000	Windows		Windows		Redhat		Redhat		SUSE
				Driver		Server		Server		Linux		Linux		Linux
						2003 32-bit	2003 64-bit	Driver		Driver		9 64-Bit
						Driver		Driver		3.0		4.0		Driver



PERC 3/Si	2.8.1.6098	2.8.0.6085*	2.8.0.6085*	2.8.0.6076	1.1.4**		Not		Not
												Applicable	Applicable


PERC 3/Di 	2.8.1.6098	2.8.0.6085*	2.8.0.6085*	2.8.0.6076	1.1.4**		1.1.5.2392	Not
														Applicable


CERC		4.1.0.7417	4.1.0.7010	4.1.0.7010	4.1.1.7038	1.1.5.2372	1.1.5.2392	Not
SATA1.5/6ch													Applicable


CERC		Not		6.0.0.50 	6.0.0.50	6.0.0.3635	1.1.5.2372	1.1.5.2392	Not
SATA1.5/2s	Applicable											Applicable


Note: * The 2.8.0.6085 driver install package for the PERC 3/Si,
        and 3/Di controllers contains the 2.8.0.6076 driver.
        For this driver, Storage Management displays 2.8.0.6076
        whereas Windows Device Manager displays 2.8.0.6085.

Note: ** The 1.1.4 Linux driver is included in RPM 2302 (Release Package
         Manager 2302).


======================================================================
ADAPTEC NON-RAID ULTRA SCSI CONTROLLER CARDS
======================================================================

The Ultra SCSI controller cards (non-RAID SCSI) include Ultra SCSI,
Ultra2 SCSI, Ultra160 SCSI, Ultra320 SCSI.

Support for the Ultra SCSI controller cards is provided in the BIOS.

======================================================================
PREREQUISITE DRIVERS AND FIRMWARE ON LINUX
======================================================================

On Linux, Storage Management installation is unable to detect whether
the drivers and firmware on the system are at the required level for
installing and using Storage Management. When installing on Linux, you
will be able to complete the installation regardless of whether the
driver and firmware version meets the required level. Even though you
have completed the installation, installing on a system that does not
meet the driver and firmware version requirements is an unsupported
configuration. In particular, you may find that controllers and their
features are not displayed by Storage Management on a system that does
not meet the driver and firmware requirements. At Storage Management
runtime, you can determine whether the system meets the firmware
requirements by checking your application log files for notifications
on outdated firmware. On SCSI controllers, Storage Management displays
the firmware version at runtime. On SAS controllers, Storage Management
displays both the firmware and the driver version at runtime.

######################################################################
WARNINGS
######################################################################

* As a general rule, you should use only one RAID utility to configure
  and manage storage. Installing the Storage Management Service on a
  system that has native RAID utilities or RAID utilities provided by
  Dell or other vendors is an unsupported configuration.

* The Storage Management Service enables you to perform storage tasks
  that are data-destructive. The Storage Management Service should be
  used by experienced storage administrators who are familiar with
  their storage environment.

######################################################################
WHAT IS NEW IN THIS RELEASE?
######################################################################

The following new features have been added in Storage Management 2.0:

* Support for SAS technology and support for the following controllers
  and adapters:

  -- PowerEdge RAID Controller (PERC) 5/E controller
  -- PERC 5/i Integrated and PERC 5/i Adapter
  -- SAS 5/iR Integrated and SAS 5/iR Adapter

######################################################################
COMPARING THE STORAGE MANAGEMENT SERVICE AND ARRAY MANAGER
######################################################################

The Storage Management Service provides the same storage management
and configuration functions as Array Manager. Unlike Array Manager,
however, the Storage Management Service features are accessible
from the Server Administrator graphical and command line interfaces.

The following summarizes notable differences in operating system and
feature support between Array Manager and the Storage Management Service:


* The Storage Management Service supports Linux. Array Manager does not.

* The Storage Management Service supports SAS technology. Array Manager
  does not.

* Array Manager supports disk and volume management on Windows 2000.
  Disk and volume management are not provided by the Storage Management
  Service. If you install Storage Management and need disk and volume
  management, you can use the native disk and volume management utilities
  provided by your operating system.

* Array Manager provides fibre channel support for the Dell PowerVault 660F
  storage system. The Storage Management Service does not.


* Array Manager provides NetWare support. The Storage Management Service
  does not.


######################################################################
CONSIDERATIONS WHEN MIGRATING FROM ARRAY MANAGER
######################################################################

If you replace an existing Array Manager installation with Storage
Management, the following migration considerations apply:


* Virtual Disk Preservation

  You can preserve the virtual disk names when migrating from Array
  Manager to Storage Management. To do so, however, you must not
  uninstall Array Manager prior to installing Storage Management.
  If Array Manager is uninstalled prior to installing Storage Management,
  then Storage Management will rename the virtual disks created with
  Array Manager. Whether or not Array Manager is uninstalled, Storage
  Management will be able to identify and manage the virtual disks
  created with Array Manager.

* SNMP Traps

  The architecture for handling the SNMP traps and the Management
  Information Base (MIB) is different in Storage Management than Array
  Manager. You may need to modify applications that have been customized
  to receive SNMP traps from Array Manager.

* Event Numbering

  The numbering scheme for Storage Management alerts or events is
  different than the numbers used for the corresponding Array Manager
  events. See the Alert Messages chapter in the Storage Management online
  help for more information.

######################################################################
INSTALLING STORAGE MANAGEMENT, VERSION 2.0
######################################################################

The Storage Management Service is installed using the Server
Administrator install process. For Server Administrator installation
requirements, see the following documentation:

* The Dell OpenManage Install readme (readme_ins.txt) on the
  "Systems Management" CD for the latest installation information.

* The "Installing Server Administrator" chapter in the Server
  Administrator User's Guide.


Note: You cannot reinstall Storage Management on a system that
      already has Storage Management installed. If you need to
      reinstall Storage Management, you must first uninstall the
      existing installation using the Server Administrator uninstall
      process.


Note: Installing Storage Management on a system that does not have a
      supported controller or that has a controller that is not attached
      to storage is an unsupported configuration. Attempts to install or
      run Storage Management using an unsupported configuration can
      result in unexpected and undesirable system behavior.


######################################################################
KNOWN LIMITATIONS
######################################################################

The following sections describe known problems associated with Storage
Management or the supported controllers. Dell is in the process of
resolving these problems.


* Storage Management responds slowly when using Internet Explorer 6.x
  on a system with mixed SAS and SATA physical disks. (60696)

  Problem:  When using the Create Virtual Disk wizard from the Storage
  Management graphical user interface (GUI), you may notice decreased
  performance when using Internet Explorer 6.x on a system with multiple
  Dell PowerVault MD1000 storage enclosures that are heavily populated
  with mixed SAS and SATA physical disks.

  Solution: Use a supported browser other than Internet Explorer 6.x or
  use the Storage Management command line interface (CLI) to
  create the virtual disk. See the Dell OpenManage Server Administrator
  readme for information on supported browsers. See the Storage Management
  online help or the "Dell OpenManage Server Administrator Command Line
  Interface User's Guide" for information on using the Storage Management
  CLI.

* The system may require an extended period of time to boot
  when a tape device without a driver is attached. (35823)

  Problem:  Storage Management performs a discovery process for all
  attached devices when the system boots. The discovery process
  may take an extended period of time if the system has a tape device
  with no driver or an unsupported driver attached. When this occurs,
  the system requires a period of time in excess of ten minutes to
  complete the boot process.

  Solution: Either detach the tape device from the system or install
  a supported version of the tape driver.

* Storage Management may not display controllers installed with the
  Dell OpenManage Service and Diagnostics utility. (152362)

  Problem: Storage Management may not recognize devices that are
  installed after Storage Management is already running.

  Solution: If Storage Management does not recognize a newly added
  device and this problem has not been corrected with a Global Rescan,
  then reboot the system.

* Storage Management SNMP traps are not filtered by Server Administrator
  (120475)

  Problem: Server Administrator allows you to filter SNMP traps that you
  do not wish to receive. To implement SNMP trap filtering, select the
  System tree object and then select the Alert Management tab and the
  SNMP Traps subtab. The SNMP Traps subtab has options for enabling or
  disabling SNMP traps based on severity or the component that generates
  the trap. Even when the SNMP traps are disabled, Storage Management
  will generate SNMP traps.

  Solution: SNMP trap filtering will be provided in a future release of
  Storage Management.


######################################################################

Information in this document is subject to change without notice.
(C) 2006 Dell Inc. All rights reserved.

Reproduction in any manner whatsoever without the written permission
of Dell Inc. is strictly forbidden.

Trademarks used in this text: "Dell", "PowerEdge", "PowerVault", and
"Dell OpenManage" are trademarks of Dell Inc.; "Microsoft", "Windows",
and "Windows NT" are registered trademarks of Microsoft Corporation;
"Novell" and "NetWare" are registered trademarks of Novell, Inc.;
"Red Hat" is a registered trademark of Red Hat, Inc. "EMC" and
"Navisphere" are registered trademarks of EMC Corporation; "VERITAS"
is a registered trademark and "Backup Exec" is a trademark of VERITAS
Software Corporation.

Other trademarks and trade names may be used in this document to refer
to either the entities claiming the marks and names or their products.
Dell Inc. disclaims any proprietary interest in trademarks and trade
names other than its own.

April, 2006

DELL OPENMANAGE(TM) Server Administrator Storage Management, VERSION 2.0
README

