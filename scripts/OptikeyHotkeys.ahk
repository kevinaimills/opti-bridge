F13 Up::
	MainCaller(1)
Return

F14 Up::
	MainCaller(2)
Return

F15 Up::
	MainCaller(3)
Return

F16 Up::
	MainCaller(4)
Return

F17 Up::
	MainCaller(5)
Return

F18 Up::
	MainCaller(6)
Return

F19 Up::
	MainCaller(7)
Return

F20 Up::
	MainCaller(8)
Return

F21 Up::
	MainCaller(9)
Return

F22 Up::
	MainCaller(10)
Return

F23 Up::
	MainCaller(11)
Return

F24 Up::
	MainCaller(12)
Return

^!F24::
	MainCaller(13)
Return

*Numpad5::
	if (1==2)
		Send no
Return

^+F1::
	appName := getApp()
	MsgBox % appName
Return

^+F2::
	Scroll(3)
Return

^+F3::
	Scroll(-3)
Return

^+F4::
	Scroll(7)
Return

^+F5::
	Scroll(-7)
Return

^+F6::
	Toggles["Optikey"] := 0
Return

^+F7::
	if (!Disabled["Bottom"])
		Toggles["Optikey"] := 1
Return

^+F8::
	HardSleep()
Return

^+F9::
	WinMaximize, A 
Return

^+F10::
	Sleep % moment
	Send +{LButton}
Return

^+F11::
	if (Toggles["BottomLowered"])
		ReplaceKeyboard("Bottom", "Bottom")
	else
		ReplaceKeyboard("Bottom", "BottomSleep")
	ToggleVar("BottomLowered")
Return

^+F12::
	ArrowMode := 0
	Toggles["ShiftDown"] := 0
	Toggles["CtrlDown"] := 0
	If (Toggles["RButton"]) {
		Send {RButton up}
		ToggleVar("RButton")
	}
	MouseGetPos, xpos, ypos
	if (ypos < 400 || xpos < 150)
	{
		movex := xpos < 150 ? 150 - xpos : 0
		movey := ypos < 400 ? 400 - ypos : 0
		MouseMove, %movex%, %movey%, 0, R
	}
Return

^+F13::
	Sleep % moment
	Send {LButton}
Return

^+F14 up::
	WinRestore, A
Return

^+F15::
;	Sleep % moment
	Send !{tab}
Return

^+F16::
;	if (ToggleVar("SlowKeys"))
;	{
		Run perl "..\Make Keyboards.pl" "-d"
	ReloadIfChanged()
;	}
;	Else
;	{
;		Run perl "..\Make Keyboards.pl" "-ds1000"
;	}
Return

^+F17::
	SmartStartMenu()
Return

^+F18::
	Send {RCtrl down}
	Send {RShift down}
Return

^+F19::
	Send {RCtrl up}
	Send {RShift up}
Return

^+F20::
	Scroll(2)
Return

^+F21::
	Scroll(-2)
Return

^+F22::
	Sleep % moment
	Send ^{LButton}
Return

^+F23::
;	if (ToggleVar("SlowKeys"))
;	{
;		Run ..\Make Keyboards.pl -d
;	}
;	Else
;	{
;		Run ..\Make Keyboards.pl -m -d
;	}
	Run ..\Make Keyboards.pl -d
	ReloadIfChanged()
Return

^+F24::
	MMove(-100, 0, 0, R)
;	Sleep % moment
;	Send {LButton}
;
Return

^!F1::
	Sleep % moment
	Focus("winword")
Return

^!F2::|
	Sleep % moment
	Focus("devenv")
	Focus("LINQPad7")
	Focus("notepad++")
Return

^!F3::
	appName := getApp()
	if (appName = "WINWORD.EXE")
		WordFullScreen()
	else if (appName = "VLC.exe")
		Send {f}
	else
		Send {F11}
Return

^!F4::
	SmartClose()|
Return 

^!F5::
;	foo()
;	Send {LShift Up} ; weird autohotkey bug - this is required or shift gets stuck
;	Send {RShift Up}

;	appName := getApp()
;	if (appName = "WINWORD.EXE")
;		Send !{``}
;	else
		Send ^+{\}
;	Send, hello

Return

^!F6::
	Run perl "..\Make Keyboards.pl" "-d"
	ReloadIfChanged()
Return

^!F7::
	Run perl "..\Make Keyboards.pl" "-ds1000"
	ReloadIfChanged()
Return

^!F8::
	Run perl "..\Make Keyboards.pl" "-ds3000"
	ReloadIfChanged()
Return

^!F9::
	RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Tobii\EyeXConfig, CurrentUserProfile, high
;	MsgBox % A_LastError
Return

^!F10::
	RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Tobii\EyeXConfig, CurrentUserProfile, f4
;	MsgBox % A_LastError
Return

^!F11::
	RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Tobii\EyeXConfig, CurrentUserProfile, f1
Return

^!F12::
	RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Tobii\EyeXConfig, CurrentUserProfile, f5
	TrayTip, , Tracking: Mid Low
Return

^!F13::
	RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Tobii\EyeXConfig, CurrentUserProfile, f3
Return

^!F14::
	Sleep % moment
	Send !{escape}
;	MsgBox, foo
Return

^!F15::
	ArrowMode := 1
Return

^!F16::
	ArrowMode := 1
	ToggleVar("ShiftDown")
Return

^!F17::
	ArrowMode := 1
	ToggleVar("CtrlDown")
	ToggleVar("ShiftDown")
Return

^!F18::
	ArrowMode := 1
	ToggleVar("CtrlDown")
Return

^!F19::

;	MsgBox % A_LastError
Return


^+M Up::
	SetMute(1, "mic")
Return

^+U Up::
	SetMute(0, "mic")
Return

!Left::
	Sleep % moment
	appName := getApp()
	if (appName = "WINWORD.EXE")
		Send ^{Up}
	else
		Send !{Left}
Return

!Right::
	Sleep % moment
	appName := getApp()
	if (appName = "WINWORD.EXE")
		Send ^{Down}
	else
		Send !{Right}
Return
