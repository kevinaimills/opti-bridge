#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

while ProcessExist("OptikeyPro.exe")
	Process, Close, OptikeyPro.exe
	
ProcessExist(Name){
	Process,Exist,%Name%
	return Errorlevel
}