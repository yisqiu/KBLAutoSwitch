/*AHK KBLAutoSwitch自动切换输入法精简代码，可用于整合到自己的ahk中
*/
DetectHiddenWindows on		;显示隐藏窗口



Label_DefVar: ; 初始化变量
	global CN_Code:=0x804,EN_Code:=0x409 ; KBL代码
Label_NecessaryVar:	; 定义必要变量
	global ImmGetDefaultIMEWnd := DllCall("GetProcAddress", "Ptr", DllCall("LoadLibrary", "Str", "imm32", "Ptr"), "AStr", "ImmGetDefaultIMEWnd", "Ptr")



;-----------------------------------【输入法切换功能】-----------------------------------------------
setKBLlLayout(KBL:=0,Source:=0) { ; 设置输入法键盘布局
	AutoSwitchFrequency += Source
	gl_Active_IMEwin_id := getIMEwinid()
	CapsLockState := LastCapsState
	If !WinActive("ahk_group Inner_AHKGroup_NoCapsLock") { ; 设置大小写
		Switch Reset_CapsLock_State
		{
			Case 1: SetCapsLockState, Off
			Case 2: SetCapsLockState, On
		}
		If (Reset_CapsLock_State>0)
			CapsLockState := Reset_CapsLock_State-1
	}
	LastKBLCode := getIMEKBL(gl_Active_IMEwin_id)
	If (KBL=0){ ; 切换中文输入法
		If (LastKBLCode=CN_Code){
			setIME(1,gl_Active_IMEwin_id)
		}Else{
			SendMessage, 0x50, , %CN_Code%, , ahk_id %gl_Active_IMEwin_id%,,,,1000
			Sleep,50
			setIME(1,gl_Active_IMEwin_id)
		}
	}Else If (KBL=1){ ; 切换英文(中文)输入法
		If (LastKBLCode=CN_Code){
			setIME(0,gl_Active_IMEwin_id)
		}Else{
			SendMessage, 0x50, , %CN_Code%, , ahk_id %gl_Active_IMEwin_id%,,,,1000
			Sleep,50
			setIME(0,gl_Active_IMEwin_id)
		}
	}Else If (KBL=2){ ; 切换英文输入法
		If (LastKBLCode!=EN_Code)
			PostMessage, 0x50, , %EN_Code%, , ahk_id %gl_Active_IMEwin_id%
	}
	; try showSwitch(KBL,CapsLockState,1)
	; SetTimer, Label_Change_TrayTip, -1000
}

setIME(setSts, win_id:="") { ; 设置输入法状态-获取状态-末位设置
	SendMessage 0x283, 0x001, 0, , ahk_id %win_id%,,,,1000
	CONVERSIONMODE := 2046&ErrorLevel, CONVERSIONMODE += setSts
    SendMessage 0x283, 0x002, CONVERSIONMODE, , ahk_id %win_id%,,,,1000
    SendMessage 0x283, 0x006, setSts, , ahk_id %win_id%,,,,1000
    Return ErrorLevel
}

getIMEwinid() { ; 获取激活窗口IME线程id
	If WinActive("ahk_class ConsoleWindowClass"){
		WinGet, win_id, , ahk_exe conhost.exe
	}Else If WinActive("ahk_group focus_control_ahk_group"){
		ControlGetFocus, CClassNN, A
		If (CClassNN = "")
			WinGet, win_id, , A
		Else
			ControlGet, win_id, Hwnd, , %CClassNN%
	}Else
		WinGet, win_id, , A
	IMEwin_id := DllCall(ImmGetDefaultIMEWnd, Uint, win_id, Uint)
	Return IMEwin_id
}

getIMEKBL(win_id:="") { ; 获取激活窗口键盘布局
	thread_id := DllCall("GetWindowThreadProcessId", "UInt", win_id, "UInt", 0)
	IME_State := DllCall("GetKeyboardLayout", "UInt", thread_id)
	Switch IME_State
	{
		Case 134481924:Return 2052
		Case 67699721:Return 1033
		Default:Return IME_State
	}
}

getIMECode(win_id:="") { ; 获取激活窗口键盘布局中英文状态
	SendMessage 0x283, 0x005, 0, , ahk_id %win_id%,,,,1000
	IME_Input_State := ErrorLevel
	If (IME_Input_State=1){		
		SendMessage 0x283, 0x001, 0, , ahk_id %win_id%,,,,1000
		IME_Input_State := 1&ErrorLevel
	}
	Return IME_Input_State
}






^`:: ; 按下 Ctrl+` 时执行以下代码
    Reload ; 重新加载当前脚本
return


#IfWinActive, ahk_exe code.exe ; 仅在 code.exe 激活时生效
; ::;::
; Send, `{;}
$+a:: 
ToolTip, 中文
setKBLlLayout(0,1) ;中
return

$+b:: 
ToolTip, 英文
setKBLlLayout(1,1) ;中
return


Return
