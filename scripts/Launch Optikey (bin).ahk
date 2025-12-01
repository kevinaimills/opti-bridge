#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

while ProcessExist("perl.exe")
	Process, Close, perl.exe

;Run %ComSpec% /c ""C:\My Utility.exe" "param 1" "second param" >"C:\My File.txt""
Run Make Keyboards.pl
Run Launch Optikey - Debug.pl
	
ProcessExist(Name){
	Process,Exist,%Name%
	return Errorlevel
}