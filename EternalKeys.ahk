; EternalKeys v1.1 - double-tap to dash, and grenade shortcuts, by evilmanimani

; Hit WinKey+F2 to reload script mid-game (if changing theme, etc)
;//////////// User Config ////////////
doubleTaptoDash  := true
, keyUpDelay     := 200 ; dash command will only fire if the first tap of the movement key is held for less than this amount of time (milliseconds)
, keyDownDelay   := 200 ; number of milliseconds you have to hit the move movement key a second time 
, holdToDash     := true ; whether holding the movement key will continue to dash repeatedly until released
; Nade shortcut Key config
, enableShortcut := true ; enable or disable the separate ice & frag grenade shortcuts, for best results, ensure the following keys aren't bound in-game
, iceNadeKey     := "H" ; keyboard shortcut for ice grenade. frag grenade is bound to default grenade key set in-game
, iceNadeMouse   := "XButton1" ; mouse button for ice grenade
, nadeMouse      := "MButton" ; mouse button for frag grenade
; Nade shortcut options, only adjust if you're having problems
, refPath        := "refimages/" ;path to images folder
, sensitivity    := 30 ; var for imagesearch function variation param
, detectSpeed    := 50 ; in milliseconds, how often to check for change to the nade icon
, diag           := false ; debug, shows tooltip indicating whether nade and/or icenade image is found
;/////////////////////////////////////

#Singleinstance, Force
#Persistent
#NoEnv
SetBatchLines, -1

iceNadeKey := Format("{:L}",iceNadeKey)
inputHook := InputHook("V")
FileRead, doomCFG, % "C:\Users\" A_UserName "\Saved Games\id Software\DOOMEternal\base\DOOMEternalConfig.cfg"
keyList := ["attack1","changeweapon","crucible","moveforward","moveback","moveleft","moveright","dash"]
if (enableShortcut = true) {
    keyList.Push("quickUse","quick1")
    func := Func("focusCheck")
    SetTimer, %func% , %detectSpeed%
    inputHook.KeyOpt("{" iceNadeKey "}", "E")
}
keyStr := "cfg keybinds:`r`n"
for idx, key in keyList {
    RegExMatch(doomCFG, "i)(?<=bind\s"").*(?=""\s""_" key """)" , %key%)
    %key% := Format("{:L}",%key%)
    if (idx > 2)
        inputHook.KeyOpt("{" %key% "}", "E")
    keyStr .= Format("{:-14}{}`r`n",key ":",%key%)
}
if (enableShortcut = true)
    inputHook.KeyOpt("{" quickUse "}", "S")
inputHook.KeyOpt("{F2}", "E")
inputHook.OnEnd := Func("EndFunc")
inputHook.NotifyNonText := true
inputHook.Start()
Hotkey, IfWinActive, DOOMEternal
If (iceNadeMouse <> "")
    Hotkey, %iceNadeMouse%, iceNadeMouse
If (nadeMouse <> "")
    Hotkey, %nadeMouse%, nadeMouse
Gui, Font,s10 Bold,Consolas
Gui, Add, Checkbox, Checked%doubleTaptoDash% vdoubleTaptoDash gSubmit, Double tap to dash
Gui, Font,Norm
Gui, Add, Checkbox, Checked%holdToDash% vholdToDash gSubmit, Hold to dash
Gui, Add, Edit, vkeyUpDelay Number gSubmit, % keyUpDelay
Gui, Add, Text, x+2 yp+2,Key up delay (ms)
Gui, Add, Edit, xm vkeyDownDelay Number gSubmit, % keyDownDelay
Gui, Add, Text, x+2 yp+2,Key Down delay (ms)
Gui, Add, Edit, xm w175 R5 +ReadOnly, % keyStr
Gui, Font,Bold
dashControls := ["holdToDash","keyUpDelay","keyDownDelay"]
Gui, Add, Checkbox, ym Checked%enableShortcut% venableShortcut gSubmit, Enable grenade keys
Gui, Font,Norm
Gui, Add, Hotkey, viceNadeKey gSubmit, % iceNadeKey
mouseDDL := "None|LButton|RButton|MButton|XButton1|XButton2"
Gui, Add, DDL, viceNadeMouse gSubmit, % mouseDDL
GuiControl, ChooseString, iceNadeMouse, % iceNadeMouse
Gui, Add, DDL, vnadeMouse gSubmit, % mouseDDL
GuiControl, ChooseString, nadeMouse, % nadeMouse
Gui, Add, Edit, Section vsensitivity Number gSubmit, % sensitivity
Gui, Add, Text, x+2 yp+2, Image search sensitivity
Gui, Add, Edit, xs vdetectSpeed Number gSubmit, % detectSpeed
Gui, Add, Text, x+2 yp+2, Detection frequency (ms)
nadeControls := ["iceNadeKey","iceNadeMouse","nadeMouse","sensitivity","detectSpeed"]
Gui, Add, Checkbox, xs Checked%diag% vdiag gSubmit, ImageSearch diag info
Gui, Show
keyDownDelay := keyDownDelay / 1000
keyUpDelay := keyUpDelay / 1000
Return

Submit:
If (iceNadeMouse <> "")
    Hotkey, %iceNadeMouse%, iceNadeMouse, Off
If (nadeMouse <> "")
    Hotkey, %nadeMouse%, nadeMouse, Off
if (enableShortcut = true) {
    inputHook.KeyOpt("{" iceNadeKey "}", "-E")
}
Gui, Submit, NoHide
iceNadeMouse := iceNadeMouse = "None" ? "" : iceNadeMouse
nadeMouse := nadeMouse = "None" ? "" : nadeMouse
keyDownDelay := keyDownDelay / 1000
keyUpDelay := keyUpDelay / 1000
If (iceNadeMouse <> "")
    Hotkey, %iceNadeMouse%, iceNadeMouse, On
If (nadeMouse <> "")
    Hotkey, %nadeMouse%, nadeMouse, On
if (enableShortcut = true) {
    inputHook.KeyOpt("{" iceNadeKey "}", "E")
}
for _, ctrl in dashControls
    GuiControl, Enable%doubleTaptoDash%, % ctrl
for _, ctrl in nadeControls
    GuiControl, Enable%enableShortcut%, % ctrl
Return

GuiClose:
ExitApp

nadeMouse:
Send, % "{" quickUse "}"
Return

iceNadeMouse:
Send, % "{" iceNadeKey "}"
Return

focusCheck() {
    global
    start := A_TickCount
    focused := WinActive("DOOMEternal")
    InputHook.KeyOpt("{" quickUse "}", focused ? "+S" : "+V")
    If focused {
        if (bottomRightCornerY = "" || bottomRightCornerY = "") {
            sleep 500
            WinGetPos, x, y, w, h, DOOMEternal
            bottomRightCornerY := (y + h) - (h // 4)
            bottomRightCornerX := (x + w) - (w // 4)
            resPath := w "x" h "/"
        }
        if (!icePath || !fragPath) {
            loop {
                loop, files, % refPath . resPath . "*.png" 
                {
                    ImageSearch, , , %bottomRightCornerX%, %bottomRightCornerY%, % x + w, % y + h, *%sensitivity% *TransBlack %A_LoopFilePath%
                    if !Errorlevel {
                        fragPath := RegExReplace(A_LoopFilePath, "(ice|frag)", "frag")
                        icePath := RegExReplace(A_LoopFilePath, "(ice|frag)", "ice")
                        break 2
                    }
                }
            }
        }
        ImageSearch, , , %bottomRightCornerX%, %bottomRightCornerY%, % x + w, % y + h, *%sensitivity% *TransBlack %fragPath%
        elvl1 := Errorlevel
        ImageSearch, , , %bottomRightCornerX%, %bottomRightCornerY%, % x + w, % y + h, *%sensitivity% *TransBlack %icePath%
        elvl2 := Errorlevel
        if diag
        Tooltip, % "Nade: "  . (elvl1 ? "Not Found" : "Found")
        . "`r`nIceNade: " . (elvl2 ? "Not Found" : "Found")
        . "`r`nTime: " . A_TickCount - start, 0, 0
    } else {
        bottomRightCornerY := bottomRightCornerX := ""
        tooltip
    }
}

EndFunc(ih) {
    global
    critical
    key := ih.EndKey
    key := StrReplace(key, "Control", "CTRL")
    If WinActive("DOOMEternal") {
        If (doubleTaptoDash 
        && ( InStr(key,moveforward)
        || InStr(key,moveback)
        || InStr(key,moveleft)
        || InStr(key,moveright) ) ) {
            KeyWait, % key, U T%keyUpDelay%
            If !Errorlevel
                KeyWait, % key, D T%keyDownDelay%
                    If !ErrorLevel
                        loop {
                            Send, % "{" dash "}"
                            Sleep 50
                        } Until (holdtoDash = false || !GetKeyState(ih.EndKey) )
        } else if (enableShortcut && key ~= "i)" iceNadeKey "|" quickUse) {
            if ((elvl1 && InStr(key,quickUse))
            || (elvl2 && InStr(key,iceNadeKey))
            || (elvl1 && elvl2)) {
                Send, % "{" quick1 "}"
                Sleep, 20
            }
            Send, % "{" quickUse "}{" quickuse " up}"
        } else if (key = "F2" && (GetKeyState("LWin") || GetKeyState("RWin"))) {
            Reload
        }
        ; } else if InStr(key,crucible) { ; doesn't work very reliably, still playing around with the timing
        ;     sleep 800
        ;     if InStr(attack1,"mouse")
        ;         Click
        ;     else
        ;         Send, % "{" attack1 "}"
        ;     sleep 800
        ;     Send, % "{" changeweapon "}"
        ; }
    }
    ih.Start()
}
