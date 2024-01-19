#SingleInstance, Force
#NoEnv
OnExit("cleanup")
#NoTrayIcon
SetWorkingDir %A_ScriptDir%

if not A_IsAdmin ; Ensure administrator privileges
{
	try Run *RunAs "%A_ScriptFullPath%" /restart
	ExitApp
}

if processExist("hyperspin attraction.exe") ; Check if HA is running
{
	MsgBox, 262160,, Please close HyperSpin Attraction before installing dependencies.
	ExitApp
}

MsgBox, 262212, Dependencies Installation,
(
The following will be installed on your system:

  - Direct X Bundle
  - Microsoft .NET Framework
  - Visual C++ Runtimes
  - Bebas Neue Font

Would you like to continue?
)
ifMsgBox, No
	ExitApp


; Build progress GUI
Gui, Add, Text, vInstallMessage w300, Beginning installation...
Gui, Add, Progress, vInstallProgress w300 h20 cGreen, 5
Gui -SysMenu
Gui, Show, y200, Installing Dependencies


; Start installation
; Clean up old dependencies folder
FileRemoveDir, %A_Temp%\ha_dependencies, 1

; Extract packages
FileCreateDir, %A_Temp%\ha_dependencies
FileInstall, dependencies.zip, %A_Temp%\ha_dependencies\dependencies.zip
DependLocation := A_Temp "\ha_dependencies"
DependZip := A_Temp "\ha_dependencies\dependencies.zip"
unz(DependZip, DependLocation)

; Install Direct X Bundle
SetWorkingDir %A_Temp%\ha_dependencies\directx_Jun2010_redist
GuiControl,, InstallMessage, Installing DirectX Bundle...
RunWait, DXSETUP.exe /silent
GuiControl,, InstallProgress, 25

; Install Microsoft .NET Framework
SetWorkingDir %A_Temp%\ha_dependencies
GuiControl,, InstallMessage, Installing Microsoft .NET Framework...
RunWait, dotNetFx40_Full_x86_x64.exe /passive /norestart
GuiControl,, InstallProgress, 50

; Install Visual C++ Runtimes
SetWorkingDir %A_Temp%\ha_dependencies
GuiControl,, InstallMessage, Installing Visual C++ Runtimes...
RunWait, VisualCppRedist_AIO_x86_x64.exe /y
GuiControl,, InstallProgress, 75

; Install Bebas Neue Font
SetWorkingDir %A_Temp%\ha_dependencies\fonts
GuiControl,, InstallMessage, Installing Bebas Neue Font...
RunWait, FontReg.exe /copy

GuiControl,, InstallProgress, 100
GuiControl,, InstallMessage, Done!
MsgBox, 262144, Installation Complete, Dependencies were installed successfully.
ExitApp


GuiClose:
MsgBox, 262196, Warning!, Installation still in progress. Quit anyway?
ifMsgBox, Yes
    ExitApp
else
    return


;;;; Functions ;;;;
cleanup() {
    SetWorkingDir %A_ScriptDir%
    FileRemoveDir, %A_Temp%\ha_dependencies, 1
}

processExist(exe) {
	Process, Exist, %exe%
	return ErrorLevel
}

Unz(sZip, sUnz) ; zip file, folder to unzip to
{
    FileCreateDir, %sUnz%
    psh := ComObjCreate("Shell.Application")
    psh.Namespace(sUnz).CopyHere(psh.Namespace(sZip).items, 4|16)
}