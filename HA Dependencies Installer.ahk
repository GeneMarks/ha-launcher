#SingleInstance, Force
#NoEnv
#NoTrayIcon
SetWorkingDir %A_ScriptDir%

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

SetWorkingDir %A_Temp%\ha_dependencies

; Install Direct X Bundle
GuiControl,, InstallMessage, Installing DirectX Bundle...
RunWait, directx_Jun2010_redist\DXSETUP.exe /silent
GuiControl,, InstallProgress, 25

; Install Microsoft .NET Framework
GuiControl,, InstallMessage, Installing Microsoft .NET Framework...
RunWait, dotNetFx40_Full_x86_x64.exe /passive /norestart
GuiControl,, InstallProgress, 50

; Install Visual C++ Runtimes
GuiControl,, InstallMessage, Installing Visual C++ Runtimes...
RunWait, VisualCppRedist_AIO_x86_x64.exe /y
GuiControl,, InstallProgress, 75

; Install Bebas Neue Font
GuiControl,, InstallMessage, Installing Bebas Neue Font...
DllCall("GDI32.DLL\AddFontResource", str, BebasNeue.ttf)

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
Unz(sZip, sUnz) ; zip file, folder to unzip to
{
    FileCreateDir, %sUnz%
    psh := ComObjCreate("Shell.Application")
    psh.Namespace(sUnz).CopyHere(psh.Namespace(sZip).items, 4|16)
}