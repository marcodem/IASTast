# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Projektübersicht

IAST-konforme Tastaturlayouts (International Alphabet of Sanskrit Transliteration) für macOS, Windows und Linux. IAST-Zeichen sind via Option/AltGr-Taste erreichbar und ergänzen bestehende DE- und CH-Layouts ohne deren wichtige Sonderbelegungen (@ , €) zu zerstören.

**Unterstützte Layouts:**
- `IAST CH` — Swiss German Basis (`de(ch)`)
- `IAST DE` — Deutsches Basis (`de(basic)`) — Unterschied: ḷ liegt auf ⌥f statt ⌥l, weil ⌥l = @ auf DE

## Projektstruktur

```
mac/
  IAST_CH_Installer.dmg   ← Auslieferung Option B (keylayout + Anleitung.txt, funktioniert über jeden Übertragungsweg)
  IAST_DE_Installer.dmg   ← Auslieferung Option B
  IAST_CH_Installer.app   ← Auslieferung Option A (automatischer Installer, nur lokal/AirDrop/USB/SFTP)
  IAST_DE_Installer.app   ← Auslieferung Option A
  IAST_CH.keylayout       ← Quelle, Swiss German IAST
  IAST_DE.keylayout       ← Quelle, German IAST
  build_apps.sh           ← Baut .app-Installer aus Quellen neu
  src/                    ← Swift/AppKit Installer-App (Quellcode)

linux/
  IAST_Linux.zip          ← Auslieferung
  install.sh              ← Installer (benötigt sudo)
  symbols/
    iast_ch               ← XKB-Symboldatei, Basis: ch(de)
    iast_de               ← XKB-Symboldatei, Basis: de(basic)
    iast_ch_mac           ← Wie iast_ch + level3(ralt_switch) für Apple-Keyboards
    iast_de_mac           ← Wie iast_de + level3(ralt_switch) für Apple-Keyboards

win/
  IAST_Windows.zip        ← Auslieferung
  IAST_CH.klc             ← MSKLC-Quelldatei, Swiss German IAST
  IAST_DE.klc             ← MSKLC-Quelldatei, German IAST
  IAST_AHK.ahk            ← AutoHotkey v2 Skript (sofort nutzbar, ohne Compilation)
  README.txt
```

## macOS – Build

```bash
# .app-Installer neu bauen (nach Änderungen an keylayout oder src/):
cd mac && bash build_apps.sh

# DMGs neu verpacken (nach Änderungen an keylayout oder Anleitung.txt):
# hdiutil create -volname "IAST DE" -srcfolder /tmp/iast_de_new -ov -format UDZO mac/IAST_DE_Installer.dmg
```

**Voraussetzungen:** Xcode Command Line Tools, PyObjC (`pip3 install pyobjc-framework-Cocoa --break-system-packages`)

## macOS – Verteilung

Zwei Auslieferungsformate in den GitHub Releases:

**Option A – `.app`-Installer** (`IAST_CH_Installer.zip` / `IAST_DE_Installer.zip`):
- Installiert das keylayout automatisch per Doppelklick
- Nur via AirDrop, USB oder SFTP nutzbar — macOS 15 Sequoia blockiert unsignierte Apps aus dem Internet vollständig (kein „Dennoch öffnen"-Button mehr)

**Option B – DMG** (`IAST_CH_Installer.dmg` / `IAST_DE_Installer.dmg`):
- Enthält ausschliesslich `.keylayout` + `Anleitung.txt`
- `.keylayout` ist reines XML, kein Executable — Gatekeeper ignoriert es
- Funktioniert über jeden Übertragungsweg (Browser, E-Mail, WhatsApp etc.)

Für vollständig signierte/notarisierte Apps wäre ein Apple Developer Account ($99/Jahr) nötig.

## macOS – Kritische keylayout-Eigenschaft

Die `<layouts>`-Sektion **muss** Hardware-Typen 0–17 (und JIS) abdecken, sonst erscheint das Layout nicht in den Systemeinstellungen:

```xml
<layouts>
    <layout first="0" last="17" modifiers="..." mapSet="..." />
    <layout first="18" last="18" modifiers="..." mapSet="..." />
    <layout first="21" last="23" modifiers="..." mapSet="..." />
    <layout first="30" last="30" modifiers="..." mapSet="..." />
</layouts>
```

`first="0" last="0"` (was kluchrtoxml standardmässig erzeugt) deckt nur ANSI-Keyboards ab — ISO/deutsche Keyboards (Typ 1–4) werden nicht erkannt.

## Linux – Installation

```bash
sudo bash linux/install.sh

# Permanent (X11 und Wayland):
sudo localectl set-x11-keymap iast_ch      # Swiss German, PC
sudo localectl set-x11-keymap iast_ch_mac  # Swiss German, Apple-Tastatur

# Temporär (nur X11):
setxkbmap iast_ch

# Fedora: Cache-Reload nach Installation
sudo dnf reinstall -y xkeyboard-config
```

`setxkbmap` funktioniert **nur unter X11**, nicht unter Wayland. `localectl` ist die universelle Lösung für beide.

## Windows – Installation

**Option A (sofort):** `IAST_AHK.ahk` per AutoHotkey v2 starten.  
**Option B (permanent):** `IAST_DE.klc` oder `IAST_CH.klc` mit MSKLC kompilieren und Setup ausführen.

## IAST-Belegung (Option/AltGr + Taste)

| Taste | Klein | Gross | Taste | Klein | Gross |
|-------|-------|-------|-------|-------|-------|
| a | ā | Ā | s | ṣ | Ṣ |
| i | ī | Ī | d | ḍ | Ḍ |
| u | ū | Ū | n | ṇ | Ṇ |
| r | ṛ | Ṛ | h | ḥ | Ḥ |
| l/f¹ | ḷ | Ḷ | m | ṃ | Ṃ |
| t | ṭ | Ṭ | g/q² | ṅ | Ṅ |
| x | ś | Ś | j | ñ | Ñ |

¹ CH: ⌥l → ḷ — DE: ⌥f → ḷ (⌥l = @; ⌥v = √ wiederhergestellt)  
² CH: ⌥q → ṅ — DE (Linux/Win): ⌥g → ṅ
