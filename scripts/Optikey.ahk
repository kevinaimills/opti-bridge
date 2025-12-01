#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#Persistent ;Keeps a script permanently running (that is, until the user closes it or ExitApp is encountered).
#UseHook ;Forces the use of the hook to implement all or some keyboard hotkeys.
#InstallMouseHook ;Forces the unconditional installation of the mouse hook.
#SingleInstance Force
FileGetTime ScriptStartOptikey, Optikey.ahk
FileGetTime ScriptStartOptikeyApps, OptikeyApps.ahk
FileGetTime ScriptStartOptikeyGestures, OptikeyGestures.ahk
FileGetTime ScriptStartOptikeyHotkeys, OptikeyHotkeys.ahk


global ScriptStartOptikey
global ScriptStartOptikeyApps
global ScriptStartOptikeyGestures
global ScriptStartOptikeyHotkeys
global moment := 100
global pids := []
global Suspended := []
global Disabled := []
global BackedUp := []
global Arrows := []
global UseAlt := []
global Toggles := []
	Toggles["Tobii"] := 1
	Toggles["Optikey"] := 1

global ConfirmClose := []
	ConfirmClose["OptikeyPro.exe"] := 1
	ConfirmClose["Firefox.exe"] := 1

global kstate := []
global ktimes := [300, 50]
global SlowKeys := 0
global ArrowMode := 0

#Include scripts\OptikeyApps.ahk
#Include scripts\OptikeyGestures.ahk
#Include scripts\OptikeyHotkeys.ahk

WordFullScreen() {
	Sleep % moment
;	if (ToggleVar("WinFullScreen")) {
;		Send {escape}
;	} else {
		Send !{v}
		Send {u}
;	}
}

SetMute(on, what := "mic") {
	if (on)
		on := 1
	else
		on := 0	
	SoundSet, %on%, MASTER, mute,20
}

Scroll(lines, hor := false) {
	Sleep % moment
	up := lines > 0 ? true : false
	lines := Abs(lines)
	if (up && !hor)
		Send {WheelUp %lines%}
	else if (!up && !hor)
		Send {WheelDown %lines%}
	else if (up && hor)
		Send {WheelLeft %lines%}
	else if (!up && hor)
		Send {WheelRight %lines%}
}

ShowMouseLoc() {
	MouseGetPos, xpos, ypos 
	TrayTip, , The cursor is at X%xpos% Y%ypos%.
}

getApp() {
	winHwnd := WinExist("A")
	WinGet, appName, ProcessName, ahk_id %winHwnd%
	Return appName
}

Focus(win) {
	WinActivate, ahk_exe %win%.exe
}

CycleActiveWindow() {
	WinGetClass, OldClass, A
	WinGet, ActiveProcessName, ProcessName, A
	WinGet, WinClassCount, Count, ahk_exe %ActiveProcessName%
	IF WinClassCount = 1
		Return
	loop, 2 {
	WinSet, Bottom,, A
	WinActivate, ahk_exe %ActiveProcessName%
	WinGetClass, NewClass, A
	if (OldClass <> "CabinetWClass" or NewClass = "CabinetWClass")
		break
	}
}

SmartClose(how := "F4") {
	Sleep % moment
	if (how = "w")
		Send ^{w}
	else
		Send !{F4}
}

SleepMoment(length := 1) {
	howLong := moment * length
	Sleep % howLong
}

OldSmartClose(how := "F4") {
	Sleep % moment
	SetTimer, closeReset, -5000
	appName := getApp()

	if (ConfirmClose[appName] == 1) {
		ConfirmClose[appName] := 2
	} else {
		if (how = "w")
			Send ^{w}
		else
			Send !{F4}
	}
}

closeReset:
	for k, v in ConfirmClose
	{
		ConfirmClose[k] := 1
	}
Return

ToggleVar(name, varType := "Toggles") {
	if (name = "appName")
		name := getApp()
	%varType%[name] := %varType%[name] ? false : true
	Return !%varType%[name]
}

ToggleKey(key) {
	Sleep % moment
	If (Toggles[key])
		Send {%key% up}
	Else
		Send {%key% down}
	ToggleVar(key)
}

HoldFor(key, dur) {
	Sleep % moment
	Send {%key% down}
	Sleep, %dur%
	Send {%key% up}
}

Delay(str) {
	howLong := moment * 3
	Sleep % howLong
	args := StrSplit(str, A_Space)
	toDo := args.Clone()
	toDo.RemoveAt(1)

	if (IsFunc(toDo))
	{
		toDo := Func(toDo)
		toDo.Call(args*)
	}
	else
	{
		for k, v in args
			Send % v
	}
}

SmartStartMenu() {
	Sleep % moment
	Send {LWin}
	Sleep % moment
	MouseClick, Left, 900, 300
}

foo(bar := "foo") {
	MsgBox % bar
} 

MainCaller(varNumber, force := false) {

;	ResetGestureTimer()

	if (varNumber < 8 && !force && Reject(varNumber))
		return false

	if (!force && varNumber > 4 && varNumber < 8) {
		kstate[varNumber] := -1
	}

	if ((Toggles["Optikey"] && !JustGestured) || force) {
		If (Toggles["ShiftDown"])
			Send {Shift down}
		If (Toggles["CtrlDown"])
			Send {Ctrl down}
		
		appName := getApp()
		
		if (ArrowMode && varNumber < 5)
		{
			switch varNumber
			{
				case 1:
					Send {up}
					Return
				case 2:
					Send {down}
					Return
				case 3:
					Send {left}
					Return
				case 4:
					Send {right}
					Return
			}
		}
		
	
		whichAlt := UseAlt[appName] ? UseAlt[appName] : 0

		if (UseAlt[appName] && AppAlt[appName][whichAlt][varNumber] && AppAlt[appName][whichAlt][varNumber] != "") {
			cmds := StrSplit(AppAlt[appName][whichAlt][varNumber], ", ")
		} else {
			cmds := StrSplit(AppList[appName][varNumber], ", ")
		}
		
		for k, v in cmds
		{
			args := StrSplit(v, A_Space)
			toDo := args.RemoveAt(1)

			if (IsFunc(toDo))
			{
				toDo := Func(toDo)
				toDo.Call(args*)
			}
			else
			{
				Send % v
				Sleep % moment
			}
		}		

		If (Toggles["ShiftDown"])
			Send {Shift up}
		If (Toggles["CtrlDown"])
			Send {Ctrl up}
	}
	
	CheckGestures(varNumber)
}

MMove(x, y, s, r) {
	MouseMove % x, y, s, r
}

MDrag(x, y, s, r, button := "LButton") {
	Sleep % moment
	Send {%button% down}
	MMove(x, y, s, r)
	Sleep % moment ;400
	Send {%button% up}
	Sleep % moment
	MMove(-x, -y, s, r)
}

SwitchToAlt(num) {
	appName := getApp()
	UseAlt[appName] := num
}

Reject(num) {
	timerTime := num > 4 ? -500 : -200

	SetTimer, freset%num%, %timerTime%
	if (!kstate[num])
		kstate[num] := 1

	if (kstate[num] < 0)
		return true
	
	if (kstate[num] > ktimes.Length())
		kstate[num] := ktimes.Length()
	
	if (num < 5) {
		ktime := -ktimes[kstate[num]]
		SetTimer, reset%num%, %ktime%
	}

	kstate[num] := -kstate[num]
	
	return false
}

resetKstate(num) {
	kstate[num] := -kstate[num]
	kstate[num]++
}

fresetKstate(num) {
	kstate[num] := 1
}
	
getPids(name := "all") {
	Loop, read, C:\Users\kevin\Optikey Scripts\pids.txt
	{
		Loop, parse, A_LoopReadLine, %A_Tab%
		{
			RegExMatch(A_LoopReadLine, "[A-Za-z]+", key)
			RegExMatch(A_LoopReadLine, "\d+", value)
			pids[key] := value
		}
	}

}

HardSleep(forceWake := false) {
	if (Disabled["Bottom"]) {
		SoundBeep
;		TrayTip, , Resuming
		FileCopy, C:\Users\kevin\AppData\Roaming\OptiKey\OptiKey\Keyboards\KevinBottom.dis, C:\Users\kevin\AppData\Roaming\OptiKey\OptiKey\Keyboards\KevinBottom.xml, 1
		Disabled["Bottom"] := false
		Toggles["Optikey"] := 1
		SetMute(0)
	} else if (!forceWake) {
;		TrayTip, , Pausing
		FileCopy, C:\Users\kevin\AppData\Roaming\OptiKey\OptiKey\Keyboards\KevinBottom.xml, C:\Users\kevin\AppData\Roaming\OptiKey\OptiKey\Keyboards\KevinBottom.dis, 1
		FileCopy, C:\Users\kevin\AppData\Roaming\OptiKey\OptiKey\Keyboards\KevinBottomDisabled.xml, C:\Users\kevin\AppData\Roaming\OptiKey\OptiKey\Keyboards\KevinBottom.xml, 1
		Disabled["Bottom"] := true
		Toggles["Optikey"] := 0
		SetMute(1)
	}
}

ReplaceKeyboard(one, two) {
	if (Disabled[one])
		Return false
	if (!BackedUp[one]) {
		FileCopy, C:\Users\kevin\AppData\Roaming\OptiKey\OptiKey\Keyboards\Kevin%one%.xml, C:\Users\kevin\AppData\Roaming\OptiKey\OptiKey\Keyboards\Kevin%one%.bak, 1
		BackedUp[one] := true
	}
	if (!BackedUp[two]) {
		FileCopy, C:\Users\kevin\AppData\Roaming\OptiKey\OptiKey\Keyboards\Kevin%two%.xml, C:\Users\kevin\AppData\Roaming\OptiKey\OptiKey\Keyboards\Kevin%two%.bak, 1
		BackedUp[two] := true
	}
;	FileCopy, C:\Users\kevin\AppData\Roaming\OptiKey\OptiKey\Keyboards\Kevin%one%.bak, C:\Users\kevin\AppData\Roaming\OptiKey\OptiKey\Keyboards\Kevin%two%.xml, 1
	FileCopy, C:\Users\kevin\AppData\Roaming\OptiKey\OptiKey\Keyboards\Kevin%two%.bak, C:\Users\kevin\AppData\Roaming\OptiKey\OptiKey\Keyboards\Kevin%one%.xml, 1
}

ToggleSuspended(name, forceEnable := false) {
	getPids()
	if (Suspended[name] || forceEnable) {
		TrayTip, , Resuming
		Process_Resume(pids[name])
		Suspended[name] := false
	} else {
		TrayTip, , Pausing
		Process_Suspend(pids[name])
		Suspended[name] := true
	}
}

Process_Suspend(PID_or_Name) {
   Return Process_Suspend_Resume(PID_or_Name, true)
}

Process_Resume(PID_or_Name) {
   Return Process_Suspend_Resume(PID_or_Name, false)
}

Process_Suspend_Resume(PID_or_Name, Suspend := true) {
   PIDs := SearchAllProcesses(PID_or_Name)
   if !PIDs[1]
      errors := "No process found"
   else {
      for k, PID in PIDs
         if error := SuspendResumeProcess(PID, Suspend)
            errors .= "PID: " . PID . " Error: " . error . "`n"
   }
   Return errors ? errors : 0
}

SearchAllProcesses(PID_or_Name) {
   if !(PID_or_Name + 0)
      Return EnumProcessesByName(PID_or_Name)
   else {
      Process, Exist, % PID_or_Name
      Return [ErrorLevel]
   }
}

EnumProcessesByName(searchName, regEx := false) {
   if !DllCall("Wtsapi32\WTSEnumerateProcesses", "Ptr", 0, "UInt", 0, "UInt", 1, "PtrP", pProcessInfo, "PtrP", count)
      throw Exception("WTSEnumerateProcesses failed. A_LastError: " . A_LastError)
   
   addr := pProcessInfo, PIDs := []
   Loop % count  {
      procName := StrGet( NumGet(addr + 8) )
      if ( regEx && RegExMatch(procName, searchName) ) || (procName = searchName)
         PID := NumGet(addr + 4, "UInt"), PIDs.Push(PID)
      addr += A_PtrSize = 4 ? 16 : 24
   }
   DllCall("Wtsapi32\WTSFreeMemory", "Ptr", pProcessInfo)
   Return PIDs
}

SuspendResumeProcess(PID, Suspend := true) {
   static PROCESS_SUSPEND_RESUME := 0x800
   error := false
   Loop 1 {
      if !hProcess := DllCall("OpenProcess", "UInt", PROCESS_SUSPEND_RESUME, "UInt", 0, "UInt", PID) {
         error := "OpenProcess failed. A_LastError: " . A_LastError
         break
      }
      res := DllCall(fn := "ntdll\Nt" . (Suspend ? "Suspend" : "Resume") . "Process", "Ptr", hProcess)
      (res != 0 && error := fn . " failed. Result: " res)
   }
   ( hProcess && DllCall("CloseHandle", "Ptr", hProcess) )
   Return error
}

PauseTobii() {
	if (Toggles["Tobii"])
		RunWait,sc stop "Tobii Service",,hide
	else
		RunWait,sc start "Tobii Service",,hide
	ToggleVar("Tobii")
}

ReloadIfChanged() {
	FileGetTime curStartOptikey, Optikey.ahk
	FileGetTime curStartOptikeyApps, OptikeyApps.ahk
	FileGetTime curStartOptikeyGestures, OptikeyGestures.ahk
	FileGetTime curStartOptikeyHotkeys, OptikeyHotkeys.ahk

    If (curStartOptikey != ScriptStartOptikey || curStartOptikeyApps != ScriptStartOptikeyApps || curStartOptikeyGestures != ScriptStartOptikeyGestures || curStartOptikeyHotkeys != ScriptStartOptikeyHotkeys)
        reload	
}

reset1:
	resetKstate(1)
Return

reset2:
	resetKstate(2)
Return

reset3:
	resetKstate(3)
Return

reset4:
	resetKstate(4)
Return

reset5:
	resetKstate(5)
Return

reset6:
	resetKstate(6)
Return

reset7:
	resetKstate(7)
Return

freset1:
	fresetKstate(1)
Return

freset2:
	fresetKstate(2)
Return

freset3:
	fresetKstate(3)
Return

freset4:
	fresetKstate(4)
Return

freset5:
	fresetKstate(5)
Return

freset6:
	fresetKstate(6)
Return

freset7:
	fresetKstate(7)
Return
