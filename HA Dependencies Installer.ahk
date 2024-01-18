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
FileRead, HALocation, _HALocation.temp ; Get HA location

; Install Direct X Bundle
GuiControl,, InstallMessage, Installing DirectX Bundle...
SetWorkingDir %HALocation%\help_faqs\Technical\DirectX 9
RunWait, DXSETUP.exe /silent
GuiControl,, InstallProgress, 25

; Install Microsoft .NET Framework
GuiControl,, InstallMessage, Installing Microsoft .NET Framework...
SetWorkingDir %HALocation%\help_faqs\Technical\Microsoft .NET Framework 4
RunWait, dotNetFx40_Full_x86_x64.exe /passive /norestart
GuiControl,, InstallProgress, 50

; Install Visual C++ Runtimes
GuiControl,, InstallMessage, Installing Visual C++ Runtimes...
SetWorkingDir %HALocation%\help_faqs\Technical\Visual-C-Runtimes-All-in-One-Aug-2020
if A_Is64bitOS = 1 ; Check architecture
{
    RunWait, vcredist2005_x86.exe /q
    RunWait, vcredist2005_x64.exe /q
    RunWait, vcredist2008_x86.exe /qb
    RunWait, vcredist2008_x64.exe /qb
    RunWait, vcredist2010_x86.exe /passive /norestart
    RunWait, vcredist2010_x64.exe /passive /norestart
    RunWait, vcredist2012_x86.exe /passive /norestart
    RunWait, vcredist2012_x64.exe /passive /norestart
    RunWait, vcredist2013_x86.exe /passive /norestart
    RunWait, vcredist2013_x64.exe /passive /norestart
    RunWait, vcredist2015_2017_2019_x86.exe /passive /norestart
    RunWait, vcredist2015_2017_2019_x64.exe /passive /norestart
}
else
{
    RunWait, vcredist2005_x86.exe /q
    RunWait, vcredist2008_x86.exe /qb
    RunWait, vcredist2010_x86.exe /passive /norestart
    RunWait, vcredist2012_x86.exe /passive /norestart
    RunWait, vcredist2013_x86.exe /passive /norestart
    RunWait, vcredist2015_2017_2019_x86.exe /passive /norestart
}
GuiControl,, InstallProgress, 75

; Install Bebas Neue Font
GuiControl,, InstallMessage, Installing Bebas Neue Font...
BebasUrl = %HALocation%\RocketLauncher\Media\Fonts\BebasNeue.ttf
DllCall("GDI32.DLL\AddFontResource", str, BebasUrl)

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