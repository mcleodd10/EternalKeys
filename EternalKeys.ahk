; EternalKeys v1.1 - double-tap to dash, and grenade shortcuts, by evilmanimani

; Hit WinKey+F2 to reload script mid-game (if changing theme, etc)
;//////////// User Config ////////////
doubleTaptoDash  := true
, keyUpDelay     := 200 ; dash command will only fire if the first tap of the forward key is held for less than this amount of time (milliseconds)
, keyDownDelay   := 200 ; number of milliseconds you have to hit the move forward key a second time 
, holdToDash     := true ; whether holding the forward key will continue to dash repeatedly until released
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
keyDownDelay := keyDownDelay / 1000
keyUpDelay := keyUpDelay / 1000
inputHook := InputHook("V")
FileRead, doomCFG, % "C:\Users\" A_UserName "\Saved Games\id Software\DOOMEternal\base\DOOMEternalConfig.cfg"
keyList := ["attack1","changeweapon","crucible","moveforward","moveback","moveleft","moveright","dash"]
if (enableShortcut = true) {
    keyList.Push("quickUse","quick1")
    func := Func("focusCheck")
    SetTimer, %func% , %detectSpeed%
    inputHook.KeyOpt("{" iceNadeKey "}", "E")
}
for idx, key in keyList {
    RegExMatch(doomCFG, "i)(?<=bind\s"").*(?=""\s""_" key """)" , %key%)
    %key% := Format("{:L}",%key%)
    if (idx > 2)
        inputHook.KeyOpt("{" %key% "}", "E")
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
Return

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
                Sleep 10
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
