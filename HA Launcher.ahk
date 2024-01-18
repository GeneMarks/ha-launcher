;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; HA LAUNCHER ;;;;;;;;;;;;;;;;;;;
;;; https://github.com/GeneMarks/ha-launcher ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#SingleInstance, Force
#NoEnv
OnExit("safeClose")
SetWorkingDir %A_ScriptDir%
Menu, Tray, NoStandard

;;;;;;;;;;;;;;;;;
Version = 1.2.2
;;;;;;;;;;;;;;;;;

; Config check
if !FileExist("config.ini")
{
	IniWrite, 0, config.ini, Options, AutoLaunchHA
	IniWrite, 0, config.ini, Options, RunWithWindows
	IniWrite, 1, config.ini, Options, DefaultHALocation
	IniWrite, %A_ScriptDir%\hyperspin attraction, config.ini, Options, HALocation
}

IniRead, AutoLaunchHA, config.ini, Options, AutoLaunchHA
IniRead, RunWithWindows, config.ini, Options, RunWithWindows
IniRead, DefaultHALocation, config.ini, Options, DefaultHALocation

if DefaultHALocation = 1 ; Ensure default location is up to date
	IniWrite, %A_ScriptDir%\hyperspin attraction, config.ini, Options, HALocation

IniRead, HALocation, config.ini, Options, HALocation


; Add menu items
Menu, Tray, Add, Start HA, Start
Menu, Tray, Add, Options, Options
Menu, Tray, Add, Exit, Exit
Menu, Tray, Default , Start HA


; Build Options GUI
GUI_Width = 360
GUI_Height = 240

Gui, Add, GroupBox, w340 h190, Options
Gui, Add, Picture, icon1 x20 y30, %A_ScriptDir%\HA Launcher.exe
Gui, Add, CheckBox, vGUI_AutoLaunchHA x90 y30 h20, Automatically launch HA
Gui, Add, CheckBox, vGUI_RunWithWindows h20, Run with Windows
Gui, Add, CheckBox, vGUI_DefaultHALocation gGUI_DefaultHALocation y+18 h20, Use default HA location
Gui, Add, Text, x24 y120, HA Location:
Gui, Add, Edit, vGUI_HALocation x90 y120 w200 h20, %HALocation%
Gui, Add, Button, vGUI_HALocation_Browse x295 y119 w30 h22, ...
Gui, Font, underline
Gui, Add, Button, x90 y+20, Install Dependencies
Gui, Font
Gui, Add, Text, x20 y205 ca6a6a6, v%Version%
Gui, Add, Button, Default x260 y205 w80 h24, OK

Gui -MinimizeBox ; Disable minimize button
OnMessage( 0x200, "WM_MOUSEMOVE" ) ; Window dragging

; Link GUI to config variables
GuiControl,, GUI_AutoLaunchHA, %AutoLaunchHA%
GuiControl,, GUI_RunWithWindows, %RunWithWindows%
GuiControl,, GUI_DefaultHALocation, %DefaultHALocation%

; Disable custom HA Location based on config
GuiControlGet, GUI_DefaultHALocation
if GUI_DefaultHALocation = 1
{
	GuiControl, Disable, GUI_HALocation
	GuiControl, Disable, GUI_HALocation_Browse
}


; Automatically start HA if enabled
if AutoLaunchHA = 1
	Goto, Start
return


; Start HA
Start:
IniRead, HALocation, config.ini, Options, HALocation
SetWorkingDir %HALocation%

; Check if HA exists and is not running
if !FileExist("hyperspin attraction.exe")
{
	MsgBox, 262160,, HyperSpin Attraction could not be found. Please change the HA folder location in Options.
	return
} 
else if processExist("hyperspin attraction.exe")
{
	MsgBox, 262160,, HyperSpin Attraction is already running on this machine. Please shut it down properly before launching again.
	return
}

Run, hyperspin attraction.exe
return


; Show Options GUI
Options:
SetWorkingDir %A_ScriptDir%
enableGUI("true")
return


; Disable/Enable custom HA location
GUI_DefaultHALocation:
GuiControlGet, CheckBoxState,, GUI_DefaultHALocation
if CheckBoxState = 1
{
	GuiControl, Disable, GUI_HALocation
	GuiControl, Disable, GUI_HALocation_Browse
	GuiControl,, GUI_HALocation, %A_ScriptDir%\hyperspin attraction
	return
}
else
{
	GuiControl, Enable, GUI_HALocation
	GuiControl, Enable, GUI_HALocation_Browse
	return
}


; Folder Browser
Button...:
FileSelectFolder, GUI_HALocation,, 0, Select your HyperSpin Attraction root folder
if ErrorLevel || GUI_HALocation = "" ; No change if dialogue cancelled or invalid location
	return
else
	GuiControl,, GUI_HALocation, %GUI_HALocation%
return


; Dependencies Installation
ButtonInstallDependencies:
SetWorkingDir %A_ScriptDir%

enableGUI("false") ; Disable GUI items
enableTray("false") ; Disable menu items

GuiControlGet, GUI_HALocation ; Get currently set location

; Checks
if !FileExist(GUI_HALocation . "\help_faqs\Technical\DirectX 9\DXSETUP.exe") || !FileExist(GUI_HALocation . "\help_faqs\Technical\Microsoft .NET Framework 4\dotNetFx40_Full_x86_x64.exe") || !FileExist(GUI_HALocation . "\help_faqs\Technical\Visual-C-Runtimes-All-in-One-Aug-2020\install_all.bat") ; Check for setup files
{
	MsgBox, 262160,, The setup files could not be found. Please ensure the HA folder location in Options is correct.

	enableGUI("true")
	enableTray("true")
	return
}
else if processExist("hyperspin attraction.exe") ; Check if HA is running
{
	MsgBox, 262160,, Please close HyperSpin Attraction before installing dependencies.

	enableGUI("true")
	enableTray("true")
	return
}
else
{
	MsgBox, 262212, Dependencies Installation,
	(
The following will be installed on your system:

  - Direct X Bundle
  - Microsoft .NET Framework
  - Visual C++ Runtimes
  - Bebas Neue Font

Would you like to continue?
	)
	ifMsgBox, Yes
	{
		; Clean up old temp files
		FileDelete, %A_Temp%\HA Dependencies Installer.exe

		; Extract installation script to temp dir
		FileInstall, HA Dependencies Installer.exe, %A_Temp%\HA Dependencies Installer.exe

		SetWorkingDir %A_Temp%
		RunWait *RunAs HA Dependencies Installer.exe
		
		enableGUI("true")
		enableTray("true")
		return
	}
	else
	{	
		enableGUI("true")
		enableTray("true")
		return
	}
}


; Save options to config upon GUI close
ButtonOK:
GuiClose:
SetWorkingDir %A_ScriptDir%
Gui, Submit

IniWrite, %GUI_AutoLaunchHA%, config.ini, Options, AutoLaunchHA
IniWrite, %GUI_RunWithWindows%, config.ini, Options, RunWithWindows
IniWrite, %GUI_DefaultHALocation%, config.ini, Options, DefaultHALocation
IniWrite, %GUI_HALocation%, config.ini, Options, HALocation

; Configure batch file for Windows startup
IniRead, RunWithWindows, config.ini, Options, RunWithWindows

if RunWithWindows = 1
{
	FileDelete, %A_AppData%\Microsoft\Windows\Start Menu\Programs\Startup\HA Launcher.bat
	FileAppend,
	(
start "" "%A_ScriptDir%\ha launcher.exe"
	), %A_AppData%\Microsoft\Windows\Start Menu\Programs\Startup\HA Launcher.bat
}
else
	FileDelete, %A_AppData%\Microsoft\Windows\Start Menu\Programs\Startup\HA Launcher.bat

; Clean any temp installer files
FileDelete, %A_Temp%\HA Dependencies Installer.exe
FileRemoveDir, %A_Temp%\ha_dependencies, 1
return


; Exit Launcher
Exit:
enableTray("false") ; Disable menu items
ExitApp


;;;; Functions ;;;;
safeClose() {
	Process, Close, hyperspin attraction.exe
	Process, WaitClose, hyperspin attraction.exe
}

processExist(exe) {
	Process, Exist, %exe%
	return ErrorLevel
}

enableGUI(enabled) {
	global GUI_Width
	global GUI_Height

	if enabled = true
	{
		Gui -Disabled
		Gui Show, w%GUI_Width% h%GUI_Height%, HA Launcher
	}
	else if enabled = false
		Gui +Disabled
}

enableTray(enabled) {
	if enabled = true
	{
		Menu, Tray, Enable, Start HA
		Menu, Tray, Enable, Options
		Menu, Tray, Enable, Exit
	}
	else if enabled = false
	{
		Menu, Tray, Disable, Start HA
		Menu, Tray, Disable, Options
		Menu, Tray, Disable, Exit
	}
}

WM_MOUSEMOVE(wparam, lparam, msg, hwnd) {
	if wparam = 1 ; LButton
		PostMessage, 0xA1, 2,,, A ; WM_NCLBUTTONDOWN
}