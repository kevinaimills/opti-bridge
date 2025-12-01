global gstring := ""
global Gestures := []
global JustGestured := false
Gestures[3412] := ["HardSleep"]
Gestures[1212] :=  ["HardSleep", true]
Gestures[13421] := ["1"]
Gestures[21342] := ["2"]
Gestures[34213] := ["3"]
Gestures[213] := ["3"]
Gestures[42134] := ["4"]
Gestures[124] := ["4"]
Gestures[31243] := ["5"]
Gestures[12431] := ["6"]
Gestures[24312] := ["6"]
Gestures[43124] := ["7"]

ResetGestureTimer(when := 1000) {
	when := -when
	SetTimer, greset, %when%
}

CheckGestures(varNumber) {

	if (varNumber < 5) {

		if (Toggles["Optikey"])
			Return
			
		ResetGestureTimer()

		if (SubStr(gstring, 0, 1) == varNumber)
			Return

		gstring .= varNumber

		for k, v in Gestures 
		{
			if (RegExMatch(gstring, k)) {
				
				; TrayTip, , %gstring%
				gstring := ""
				JustGestured := true
				;SetTimer, greset, -500

				args := v.Clone()
				toDo := args.RemoveAt(1)

				if (IsFunc(toDo))
				{
					toDo := Func(toDo)
					toDo.Call(args*)
				}
				else if (toDo > 0)
				{
					MainCaller(toDo, true)
				}
				else
					Send % v

			}
		}
	}
	
}

greset:
	gstring = ""
	JustGestured := false
Return
