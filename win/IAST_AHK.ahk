; IAST Keyboard Remapper – AutoHotkey v2
; ========================================
; Voraussetzung: AutoHotkey v2 von https://www.autohotkey.com
; Starten: Doppelklick auf diese Datei.
; Automatischer Start: Verknüpfung in den Autostart-Ordner legen.
;   (%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup)
;
; IAST-Zeichen via AltGr (rechte Alt-Taste):
;
;   Taste  AltGr    Shift+AltGr    Taste  AltGr    Shift+AltGr
;   ──────────────────────────────────────────────────────────
;   a      ā        Ā              s      ṣ        Ṣ
;   i      ī        Ī              d      ḍ        Ḍ
;   u      ū        Ū              n      ṇ        Ṇ
;   r      ṛ        Ṛ              h      ḥ        Ḥ
;   l      ḷ        Ḷ              m      ṃ        Ṃ
;   t      ṭ        Ṭ              g      ṅ        Ṅ
;   x      ś        Ś              j      ñ        Ñ
;
; Erhalten: AltGr+q = @, AltGr+e = €
; ========================================
;
; Hinweis: Dieses Skript überschreibt nur die IAST-relevanten AltGr-Belegungen.
; Alle anderen Tasten bleiben unverändert.

#Requires AutoHotkey v2.0

; AltGr = RAlt (rechte Alt-Taste) in AHK-Notation

; Lange Vokale (Makron)
RAlt & a:: {
    if GetKeyState("Shift", "P")
        Send "{U+0100}"  ; Ā
    else
        Send "{U+0101}"  ; ā
}
RAlt & i:: {
    if GetKeyState("Shift", "P")
        Send "{U+012A}"  ; Ī
    else
        Send "{U+012B}"  ; ī
}
RAlt & u:: {
    if GetKeyState("Shift", "P")
        Send "{U+016A}"  ; Ū
    else
        Send "{U+016B}"  ; ū
}

; Retroflex (Punkt unten)
RAlt & t:: {
    if GetKeyState("Shift", "P")
        Send "{U+1E6C}"  ; Ṭ
    else
        Send "{U+1E6D}"  ; ṭ
}
RAlt & d:: {
    if GetKeyState("Shift", "P")
        Send "{U+1E0C}"  ; Ḍ
    else
        Send "{U+1E0D}"  ; ḍ
}
RAlt & n:: {
    if GetKeyState("Shift", "P")
        Send "{U+1E46}"  ; Ṇ
    else
        Send "{U+1E47}"  ; ṇ
}
RAlt & r:: {
    if GetKeyState("Shift", "P")
        Send "{U+1E5A}"  ; Ṛ
    else
        Send "{U+1E5B}"  ; ṛ
}
RAlt & l:: {
    if GetKeyState("Shift", "P")
        Send "{U+1E36}"  ; Ḷ
    else
        Send "{U+1E37}"  ; ḷ
}

; Sibilanten
RAlt & s:: {
    if GetKeyState("Shift", "P")
        Send "{U+1E62}"  ; Ṣ
    else
        Send "{U+1E63}"  ; ṣ
}
RAlt & x:: {
    if GetKeyState("Shift", "P")
        Send "{U+015A}"  ; Ś
    else
        Send "{U+015B}"  ; ś
}

; Weitere IAST
RAlt & m:: {
    if GetKeyState("Shift", "P")
        Send "{U+1E42}"  ; Ṃ
    else
        Send "{U+1E43}"  ; ṃ
}
RAlt & h:: {
    if GetKeyState("Shift", "P")
        Send "{U+1E24}"  ; Ḥ
    else
        Send "{U+1E25}"  ; ḥ
}
RAlt & g:: {
    if GetKeyState("Shift", "P")
        Send "{U+1E44}"  ; Ṅ
    else
        Send "{U+1E45}"  ; ṅ
}
RAlt & j:: {
    if GetKeyState("Shift", "P")
        Send "{U+00D1}"  ; Ñ
    else
        Send "{U+00F1}"  ; ñ
}
