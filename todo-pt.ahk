/*
Name          : todo-pt - v0.2 - Universal TODO lists for Text Editors based on PlainTasks(1)
Source        : https://github.com/hi5/todo-pt
AHKScript     : http://ahkscript.org/boards/viewtopic.php?f=6&t=2366
Documentation : See readme.md at GH
License       : MIT see COPYING.txt
Note          : Some editors have plugins / addons which may proof more usable as they
                can work with the particular features of that editor, for example:
                (1) - Sublime Text (2 and 3) https://github.com/aziz/PlainTasks
                (2) - EverEdit (2 and 3) https://github.com/everedit/addons/tree/master/mode/todo

*/

;todo-pt-label:  ; uncomment if you wish to include todo-pt in your main script, 
                 ; also uncomment the Return below (after the Hotkey, IfWinActive line)
                 ; Add a Gosub, todo-pt-label in the auto-execute section of your main script

#SingleInstance, force
#NoEnv
SetKeyDelay, -1
SetBatchLines, -1
SendMode, Input
SetTitleMatchMode, 2

; setup objTodo to store all settings

objTodo := {filenames: {1: ".todo", 2: ".todolist", 3: ".tasks", 4: ".taskpaper"} ; extensions to create context sensitive hotkeys
		; The Unicode characters will only work properly if your TODO list is also in Unicode
		; Some examples are given below - You can find more characters at http://unicode-table.com/en/
		; If you want to use # ! ^ + wrapping these in {} is mandatory
	, mark_open: "❑" ; Alternatives: - [ ] ☐ – — › 
	, mark_done: "✔" ; Alternatives: * [x] ✔ ✓ ☑
	, mark_cancelled: "✘" ; Alternatives: x [-] ✘ ⛝
	, mark_project: "{#}" ; Alternatives: ➔ ➤ ■ 
	, mark_indent: "`t" ; `t = TAB
	, text_done: "@done" 
	, text_cancelled: "@cancelled"
	, text_today: "@today"
	, text_start: "@start"
	, text_time: "@time"
	, text_line: "--- ✄ ------------------------------"
	, text_archive: "_____________________________________`nArchive"
		; You can specify the date/time format as described here http://ahkscript.org/docs/commands/FormatTime.htm
		; Note that Date and Time Formats are case sensitive
	, date_format: " (dd/MM/yyyy - H:mm)"
		; Set date_options_us to 1 if the above date_format is in American date/time format
		; Only used for time calculation of time spent on task during @done when @start is present in task
	, date_options_us: 0 
		; To correctly calculate (working) time spent on a task you can define the following
		; settings - consult the time() function for a more detailed explantion:
		; - Units (output units) can be d=days, h=hours, m=minutes, s=seconds
		; - Params can be W,D,B,H,M,S
	, date_options_units: "m" ; The time in minutes spent on a task is converted into hours:minutes format so it is advised not to alter this
	, date_options_params: ""  
	, delay: 80 ; Delay in milliseconds after each clipboard action
	, hotkey_task_done: "^d"
	, hotkey_task_cancel: "^m"
	, hotkey_task_new: "^i"
	, hotkey_task_start: "!s"
	, hotkey_task_today: "!t"
	, hotkey_archive: "^+s"
	, hotkey_make_task: "^Enter"
	, hotkey_new_project: "^p"
	, hotkey_getline: "{home}{shift down}{end}{shift up}^x"  ; for some editors ^x will suffice
	, active_log : ""
	, archive_log: "" }

for k, v in ObjTodo.Filenames
	GroupAdd, ahkgroupTodo, %v%

Hotkey, IfWinActive, ahk_group ahkgroupTodo
Hotkey, % objTodo.hotkey_task_done  , todo_hotkey_task_done
Hotkey, % objTodo.hotkey_task_cancel, todo_hotkey_task_cancel
Hotkey, % objTodo.hotkey_task_new   , todo_hotkey_task_new
Hotkey, % objTodo.hotkey_task_start , todo_hotkey_task_start
Hotkey, % objTodo.hotkey_task_today , todo_hotkey_task_today
Hotkey, % objTodo.hotkey_make_task  , todo_hotkey_make_task
Hotkey, % objTodo.hotkey_new_project, todo_hotkey_new_project
Hotkey, % objTodo.hotkey_archive    , todo_hotkey_archive
Hotkey, IfWinActive

; Return ; Return from todo-pt-label - uncomment if you wish to include todo-pt in your main script

#IfWinActive ahk_group ahkgroupTodo
:*:--	::
	todo_ClipSave()
	todo_SendClip(objTodo.text_line)
	todo_ClipSave(1)
Return
#IfWinActive 

todo_hotkey_archive:
todo_ClipSave()
objTodo.active_log:="", objTodo.archive_log:=""
clipboard:=""
Send ^a
Sleep 20
Send ^x ; select all + cut
Sleep % objTodo.delay
Loop, parse, Clipboard, `n, `r
	{
	 If InStr(A_LoopField,todo_objGetValue("text_done",objTodo)) or InStr(A_LoopField,todo_objGetValue("text_cancelled",objTodo))
	 	{
	 	 objTodo.archive_log .= Trim(A_LoopField) "`n"
	 	 continue
	 	}
	 objTodo.active_log .= A_LoopField "`n"	
	}
If !InStr(clipboard,todo_objGetValue("text_archive",objTodo))
	objTodo.active_log .= "`n`n" objTodo.text_archive "`n"
todo_SendClip(objTodo.active_log objTodo.archive_log)
Sleep % objTodo.delay
objTodo.active_log:="", objTodo.archive_log:=""
todo_ClipSave(1)
Return

todo_hotkey_new_project:
	Send % "{enter}" objTodo.mark_project " Project:{enter}" objTodo.mark_indent objTodo.mark_open "{space}"
Return	

todo_hotkey_make_task:
	Send % "{home}" objTodo.mark_indent objTodo.mark_open "{space}"
Return	

todo_hotkey_task_new:
	Send % "{end}{enter}" objTodo.mark_open "{space}"
Return	

todo_hotkey_task_start:
	todo_Command(objTodo.text_start)
Return

todo_hotkey_task_done:
	todo_Command(objTodo.text_done)
Return

todo_hotkey_task_today:
	Send {end}{space}
	todo_SendClip(objTodo.text_today)
	Send {home}
Return

todo_hotkey_task_cancel:
	todo_Command(objTodo.text_cancelled)
Return	

todo_Command(CommandText) {
	global objTodo
	todo_GetLine()
	If InStr(Clipboard, CommandText)
		{
		 Clipboard:=RTrim(SubStr(Clipboard,1,InStr(Clipboard,CommandText))," @")
		 Sleep % objTodo.delay
		 StringReplace, Clipboard, Clipboard, % objTodo.mark_done, % objTodo.mark_open
		 StringReplace, Clipboard, Clipboard, % objTodo.mark_cancelled, % objTodo.mark_open
		 todo_SendClip(Clipboard)
		 Send {end}
		} 
	 Else
		{
		 if (CommandText = objTodo.text_done)
		 	mark:=objTodo.mark_done
		 else if (CommandText = objTodo.text_cancelled)
		 	mark:=objTodo.mark_cancelled
		 else if (CommandText = objTodo.text_start)
		 	mark:=objTodo.mark_open
		 StringReplace, Clipboard, Clipboard, % objTodo.mark_open, %mark%
		 Sleep % objTodo.delay
		 FormatTime, dtime, A_Now, % objTodo.date_format
		 if (InStr(Clipboard,todo_objGetValue("text_start",objTodo)) and (CommandText <> objTodo.text_cancelled))
			{
			 RegExMatch(Clipboard, "iU)" todo_objGetValue("text_start",objTodo) " \K\((.*)\)", StartTime)
			 ; calculate minutes from start to finish using todo_Time()
			 dtime:=todo_Time(SubStr(A_Now,1,12)
				 , todo_DateParse(Trim(StartTime,"()"),objTodo.date_options_us)
				 , objTodo.date_options_units
				 , objTodo.date_options_params)
			 ; convert minutes to hours:minutes, wrapped in ()
			 dtime:="(" (SubStr("0" Round(dtime) // 60,-1)) ":" (SubStr("0" Mod(Round(dtime), 60),-1)) " hh:mm)"
			 FormatTime, dtimenow, A_Now, % objTodo.date_format
			 CommandText:="@done" dtimenow " " objTodo.text_time " "
			}
		 todo_SendClip(RTrim(clipboard) " " CommandText dtime)
		}
	 todo_ClipSave(1)
	}

todo_GetLine() {
	 global objTodo
	 todo_ClipSave()
	 Send {home}{shift down}{end}{shift up}^x
	 Sleep % objTodo.delay
	}

todo_SendClip(text) {
	 global objTodo
	 Clipboard:=text
	 SendInput, ^v
	 Sleep % objTodo.delay
	}

todo_objGetValue(var,objTodo) {
	for k, v in objTodo
		if (k = var)
			Return v
	}

todo_ClipSave(action=0) {
	 static ClipSave
	 if (action = 0)      ; save Clipboard
		{
		 ClipSave:=ClipboardAll 
		}
	 else if (action = 1) ; restore Clipboard
		{
		 Clipboard:=ClipSave
		 ClipSave:=""
		}
	 else if (action = 2) ; clear ClipSave
		 ClipSave:=""
	}

; --- third party functions --- 

todo_DateParse(str, americanOrder=0) {
/*
	 Function: DateParse
		Converts almost any date format to a YYYYMMDDHH24MISS value.

	 Parameters:
		str - a date/time stamp as a string
		americanOrder - optional parameter to parse American day/months orders

	 Returns:
		A valid YYYYMMDDHH24MISS value which can be used by FormatTime, EnvAdd and other time commands.

	 Authors:
		polyethene https://github.com/polyethene/AutoHotkey-Scripts/
		this is a modified version by formivore http://www.autohotkey.com/board/topic/18760-date-parser-convert-any-date-format-to-yyyymmddhh24miss/page-5#entry561591
*/
	static monthNames := "(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\w*"
		, dayAndMonth := "(?:(\d{1,2}|" . monthNames . ")[\s\.\-\/,]+)?(\d{1,2}|" . monthNames . ")"
	If RegExMatch(str, "i)^\s*(?:(\d{4})([\s\-:\/])(\d{1,2})\2(\d{1,2}))?"
		. "(?:\s*[T\s](\d{1,2})([\s\-:\/])(\d{1,2})(?:\6(\d{1,2})\s*(?:(Z)|(\+|\-)?"
		. "(\d{1,2})\6(\d{1,2})(?:\6(\d{1,2}))?)?)?)?\s*$", i) ;ISO 8601 timestamps
		year := i1, month := i3, day := i4, t1 := i5, t2 := i7, t3 := i8
	Else If !RegExMatch(str, "^\W*(\d{1,2}+)(\d{2})\W*$", t){
		RegExMatch(str, "i)(\d{1,2})"				;hours
				. "\s*:\s*(\d{1,2})"				;minutes
				. "(?:\s*:\s*(\d{1,2}))?"			;seconds
				. "(?:\s*([ap]m))?", t)				;am/pm
		StringReplace, str, str, %t%
		If Regexmatch(str, "i)(\d{4})[\s\.\-\/,]+" . dayAndMonth, d) ;2004/22/03
			year := d1, month := d3, day := d2
		Else If Regexmatch(str, "i)" . dayAndMonth . "[\s\.\-\/,]+(\d{2,4})", d)  ;22/03/2004 or 22/03/04
			year := d3, month := d2, day := d1
		If (RegExMatch(day, monthNames) or americanOrder and !RegExMatch(month, monthNames)) ;try to infer day/month order
			tmp := month, month := day, day := tmp
	}
	f = %A_FormatFloat%
	SetFormat, Float, 02.0
	d := (StrLen(year) == 2 ? "20" . year : (year ? year : A_YYYY))
		. ((month := month + 0 ? month : InStr(monthNames, SubStr(month, 1, 3)) // 4 ) > 0 ? month + 0.0 : A_MM)
		. ((day += 0.0) ? day : A_DD) 
		. t1 + (t1 == 12 ? t4 = "am" ? -12.0 : 0.0 : t4 = "pm" ? 12.0 : 0.0)
		. t2 + 0.0 . t3 + 0.0
	SetFormat, Float, %f%
	return, d
}

todo_Time(to,from="",units="d",params=""){
/*
	time() by HotKeyIt, source and examples: 
	http://www.autohotkey.com/board/topic/42668-time-count-days-hours-minutes-seconds-between-dates/

	Parameters:
		to and from can be in following format (from will be A_Now if empty):
		- 20090101...
		- 20090101000000
		- Apr-04-2009 or Apr-04 for current year
		- 01-01-2009 or 01-01 for current year
		Units (output units) can be d=days, h=hours, m=minutes, s=seconds
		params can be W,D,B,H,M,S
		- W = WeeksDay to include, e.g. W2-6 (mon-fri) or W1.7 (exclude weekends)
		- D = Day of Month to include, e.g. e D1-5 (to exclude D1.2.3)
		- B = Bank holiday to exclude, e.g. B0101.3112
		- H = Hours to include, e.g. H8-17 (to exclude use H0.1.2...)
		- M = Minutes to include, e.g. M0-30 (to exclude use M0.1.2...)
		- S = Seconds to include, e.g. S0-30 (to exclude use S0.1.2...)
*/	
	static _:="0000000000",s:=1,m:=60,h:=3600,d:=86400
				,Jan:="01",Feb:="02",Mar:="03",Apr:="04",May:="05",Jun:="06",Jul:="07",Aug:="08",Sep:="09",Okt:=10,Nov:=11,Dec:=12
	r:=0
	units:=units ? %units% : 8640
	If (InStr(to,"/") or InStr(to,"-") or InStr(to,".")){
		Loop,Parse,to,/-.,%A_Space%
			_%A_Index%:=RegExMatch(A_LoopField,"\d+") ? A_LoopField : %A_LoopField%
			,_%A_Index%:=(StrLen(_%A_Index%)=1 ? "0" : "") . _%A_Index%
		to:=SubStr(A_Now,1,8-StrLen(_1 . _2 . _3)) . _3 . (RegExMatch(SubStr(to,1,1),"\d") ? (_2 . _1) : (_1 . _2))
		_1:="",_2:="",_3:=""
	}
	If (from and InStr(from,"/") or InStr(from,"-") or InStr(from,".")){
		Loop,Parse,from,/-.,%A_Space%
			_%A_Index%:=RegExMatch(A_LoopField,"\d+") ? A_LoopField : %A_LoopField%
			,_%A_Index%:=(StrLen(_%A_Index%)=1 ? "0" : "") . _%A_Index%
		from:=SubStr(A_Now,1,8-StrLen(_1 . _2 . _3)) . _3 . (RegExMatch(SubStr(from,1,1),"\d") ? (_2 . _1) : (_1 . _2))
	}
   count:=StrLen(to)<9 ? "days" : StrLen(to)<11 ? "hours" : StrLen(to)<13 ? "minutes" : "seconds"
	to.=SubStr(_,1,14-StrLen(to)),(from ? from.=SubStr(_,1,14-StrLen(from)))
	Loop,Parse,params,%A_Space%
		If (unit:=SubStr(A_LoopField,1,1))
			 %unit%1:=InStr(A_LoopField,"-") ? SubStr(A_LoopField,2,InStr(A_LoopField,"-")-2) : ""
			,%unit%2:=SubStr(A_LoopField,InStr(A_LoopField,"-") ? (InStr(A_LoopField,"-")+1) : 2)
	count:=!params ? count : "seconds"
	add:=!params ? 1 : (S2="" ? (M2="" ? (H2="" ? ((D2="" and B2="" and W="") ? d : h) : m) : s) : s)
	While % (from<to){
		FormatTime,year,%from%,YYYY
		FormatTime,month,%from%,MM
		FormatTime,day,%from%,dd
		FormatTime,hour,%from%,H
		FormatTime,minute,%from%,m
		FormatTime,second,%from%,s
		FormatTime,WDay,%from%,WDay
		EnvAdd,from,%add%,%count%
		If (W1 or W2){
			If (W1=""){
				If (W2=WDay or InStr(W2,"." . WDay) or InStr(W2,WDay . ".")){
					Continue=1
				}
			} else If WDay not Between %W1% and %W2%
				Continue=1
			;else if (Wday=W2)
			;	Continue=1
			If (Continue){
				tempvar:=SubStr(from,1,8)
				EnvAdd,tempvar,1,days
				EnvSub,tempvar,%from%,seconds
				EnvAdd,from,%tempvar% ,seconds
				Continue=
				continue
			}
		}
		If (D1 or D2 or B2){
			If (D1=""){
				If (D2=day or B2=(day . month) or InStr(B2,"." . day . month) or InStr(B2,day . month . ".") or InStr(D2,"." . day) or InStr(D2,day . ".")){
					Continue=1
				}
			} else If day not Between %D1% and %D2%
				Continue=1
			;else if (day=D2)
			;	Continue=1
			If (Continue){
				tempvar:=SubStr(from,1,8)
				EnvAdd,tempvar,1,days
				EnvSub,tempvar,%from%,seconds
				EnvAdd,from,%tempvar% ,seconds
				Continue=
				continue
			}
		}
		If (H1 or H2){
			If (H1=""){
				If (H2=hour or InStr(H2,hour . ".") or InStr(H2,"." hour)){
					Continue=1
				}
			} else If hour not Between %H1% and %H2%
				continue=1
			;else if (hour=H2)
			;	continue=1
			If (continue){
				tempvar:=SubStr(from,1,10)
				EnvAdd,tempvar,1,hours
				EnvSub,tempvar,%from%,seconds
				EnvAdd,from,%tempvar% ,seconds
				continue=
				continue
			}
		}
		If (M1 or M2){
			If (M1=""){
				If (M2=minute or InStr(M2,minute . ".") or InStr(M2,"." minute)){
					Continue=1
				}
			} else If minute not Between %M1% and %M2%
				continue=1
			;else if (minute=M2)
			;	continue=1
			If (continue){
				tempvar:=SubStr(from,1,12)
				EnvAdd,tempvar,1,minutes
				EnvSub,tempvar,%from%,seconds
				EnvAdd,from,%tempvar% ,seconds
				continue=
				continue
			}
		}
		If (S1 or S2){
			If (S1=""){
				If (S2=second or InStr(S2,second . ".") or InStr(S2,"." second)){
					Continue
				}
			} else if (second!=S2)
				If second not Between %S1% and %S2%
					continue
		}
		r+=add
	}
	tempvar:=SubStr(count,1,1)
	tempvar:=%tempvar%
	Return (r*tempvar)/units
}
