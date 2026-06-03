# IASTast

IAST-konforme Tastaturlayouts (International Alphabet of Sanskrit Transliteration) für macOS, Windows und Linux. IAST-Zeichen sind via **Option/AltGr-Taste** erreichbar und ergänzen bestehende Deutsche und Schweizer Layouts ohne deren wichtige Sonderbelegungen (@ , €) zu beeinträchtigen.

## Teststatus

| Plattform | Getestet auf |
|-----------|-------------|
| macOS | macOS 15 Sequoia |
| Linux | Debian 13, Fedora 44 (X11 und Wayland) |
| Windows | AutoHotkey-Variante (`.klc` ungetestet) |

## IAST-Belegung

Die geopferten Zeichen unterscheiden sich leicht zwischen CH- und DE-Layout.

| Taste | ⌥ / AltGr | ⇧⌥ | Ersetzt (CH) | Ersetzt (DE) |
|-------|-----------|-----|-------------|-------------|
| a | ā | Ā | å | å |
| i | ī | Ī | ¡ | ⁄ (U+2044) |
| u | ū | Ū | ° | ¨ (dead) |
| r | ṛ | Ṛ | ® | ® |
| l / f¹ | ḷ | Ḷ | ¬ | ƒ |
| t | ṭ | Ṭ | † | † |
| d | ḍ | Ḍ | ∂ | ∂ |
| n | ṇ | Ṇ | ~ (dead) | ~ (dead) |
| s | ṣ | Ṣ | ß | ‚ |
| x | ś | Ś | ≈ | ≈ |
| m | ṃ | Ṃ | µ | µ |
| h | ḥ | Ḥ | ª | ª |
| q / g² | ṅ | Ṅ | œ | © |
| j | ñ | Ñ | º | º |

¹ CH: ⌥l → ḷ — DE: ⌥f → ḷ (⌥l = @ auf DE, bleibt erhalten; ⌥v = √ wiederhergestellt)  
² CH: ⌥q → ṅ — DE: ⌥g → ṅ  
Erhalten auf allen Layouts: **@ , € , [ ] { } | \** und alle Umlaute

## Layouts

| Layout | Basis | Plattform |
|--------|-------|-----------|
| IAST CH | Swiss German | macOS, Linux, Windows |
| IAST DE | German | macOS, Linux, Windows |

## Installation

### macOS

Zwei Varianten aus [Releases](https://github.com/marcodem/IASTast/releases):

**Option A – .app-Installer (einfacher):**
1. `IAST_CH_Installer.zip` oder `IAST_DE_Installer.zip` herunterladen und entpacken
2. `IAST_CH_Installer.app` (oder `DE`) doppelklicken → zeigt Belegung und startet Installation per Klick
3. Systemeinstellungen → Tastatur → Eingabequellen → **+** → „IAST" suchen

> **Hinweis:** Die `.app`-Installer sind unsigniert. macOS blockiert sie beim Download via Browser/Mail — per AirDrop, USB oder SFTP funktionieren sie. Alternativ Option B verwenden.

**Option B – manuell via DMG:**
1. `IAST_CH_Installer.dmg` oder `IAST_DE_Installer.dmg` herunterladen
2. DMG öffnen
3. `IAST_CH.keylayout` (oder `IAST_DE.keylayout`) nach `~/Library/Keyboard Layouts/` kopieren  
   *(Finder: ⌘⇧G → `~/Library/Keyboard Layouts`)*
4. Ab- und wieder anmelden
5. Systemeinstellungen → Tastatur → Eingabequellen → **+** → „IAST" suchen

### Linux

```bash
sudo bash linux/install.sh
```

**Aktivierung – permanent (X11 und Wayland):**
```bash
sudo localectl set-x11-keymap iast_ch      # Swiss German, PC-Tastatur
sudo localectl set-x11-keymap iast_ch_mac  # Swiss German, Apple-Tastatur (rechte ⌥ = AltGr)
sudo localectl set-x11-keymap iast_de      # German, PC-Tastatur
sudo localectl set-x11-keymap iast_de_mac  # German, Apple-Tastatur
```

**Aktivierung – temporär (nur X11):**
```bash
setxkbmap iast_ch
```

Oder: GNOME Einstellungen → Tastatur → Eingabequellen → **+** → „IAST"

> `localectl` funktioniert auf X11 und Wayland. `setxkbmap` funktioniert nur unter X11.  
> Mac-Tastaturen (`_mac`-Varianten): nur die **rechte ⌥-Taste** löst IAST-Zeichen aus. Die linke ⌥-Taste bleibt normales Alt (für App-Shortcuts).

### Windows

**Option A – AutoHotkey (sofort, ohne Compilation):**  
[AutoHotkey v2](https://www.autohotkey.com) installieren, dann `win/IAST_AHK.ahk` starten.

**Option B – nativer Treiber (ungetestet):**  
`win/IAST_DE.klc` oder `win/IAST_CH.klc` mit [Microsoft Keyboard Layout Creator](https://www.microsoft.com/en-us/download/details.aspx?id=102134) kompilieren und Setup ausführen.

## Projektstruktur

```
mac/
  IAST_CH.keylayout       Swiss German IAST
  IAST_DE.keylayout       German IAST
  build_apps.sh           Baut lokalen .app-Installer
  src/                    Swift/AppKit Installer-Quellcode

linux/
  install.sh              Installer (benötigt sudo)
  symbols/
    iast_ch               XKB-Symboldatei, Basis: ch(de)
    iast_de               XKB-Symboldatei, Basis: de(basic)
    iast_ch_mac           Wie iast_ch + rechte ⌥-Taste = AltGr (linke ⌥ = Alt, unverändert)
    iast_de_mac           Wie iast_de + rechte ⌥-Taste = AltGr (linke ⌥ = Alt, unverändert)

win/
  IAST_CH.klc             MSKLC-Quelldatei Swiss German
  IAST_DE.klc             MSKLC-Quelldatei German
  IAST_AHK.ahk            AutoHotkey v2 Skript
  README.txt              Installationsanleitung Windows
```
