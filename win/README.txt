IAST Keyboard Layouts für Windows 11
=====================================

Zwei Varianten – Option A ist sofort nutzbar, Option B ist die saubere
Systemlösung (erfordert einmalige Compilation auf einem Windows-Rechner).


OPTION A – AutoHotkey (sofort, ohne Compilation)
-------------------------------------------------
1. AutoHotkey v2 herunterladen und installieren:
   https://www.autohotkey.com  (Version 2.x, nicht 1.x!)

2. IAST_AHK.ahk doppelklicken → startet den Remapper.
   AltGr+a tippt dann ā, AltGr+Shift+a tippt Ā, usw.

3. Automatisch beim Windows-Start:
   - Rechtsklick auf IAST_AHK.ahk → "Verknüpfung erstellen"
   - Verknüpfung verschieben nach:
     %APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup

Hinweis: Das AHK-Skript ist layout-unabhängig und funktioniert sowohl
mit DE als auch mit CH-Tastaturlayout.


OPTION B – Nativer Treiber via MSKLC (empfohlen für dauerhaften Betrieb)
------------------------------------------------------------------------
Auf einem Windows-Rechner:

1. Microsoft Keyboard Layout Creator (MSKLC) herunterladen:
   https://www.microsoft.com/en-us/download/details.aspx?id=102134

2. MSKLC öffnen → Datei → Laden → IAST_DE.klc (oder IAST_CH.klc)

3. Projekt → Setze als Standardlayout für aktuelle Eingabesprache

4. Projekt → DLL und Setuppaket erstellen...
   → MSKLC generiert einen Installer-Ordner mit setup.exe

5. setup.exe (als Administrator) ausführen

6. Einstellungen → Zeit & Sprache → Sprache & Region
   → Deutsch → Tastaturlayouts → IAST DE (oder IAST CH) hinzufügen

Nach der Installation erscheint "IAST DE" / "IAST CH" im Sprachleisten-
Schalter in der Taskleiste (Win+Leertaste zum Wechseln).


IAST-Belegung (beide Varianten identisch)
-----------------------------------------

  Taste  AltGr    Shift+AltGr
  ─────────────────────────────
  a      ā        Ā
  i      ī        Ī
  u      ū        Ū
  r      ṛ        Ṛ
  l      ḷ        Ḷ
  t      ṭ        Ṭ
  d      ḍ        Ḍ
  n      ṇ        Ṇ
  s      ṣ        Ṣ
  x      ś        Ś
  m      ṃ        Ṃ
  h      ḥ        Ḥ
  g      ṅ        Ṅ
  j      ñ        Ñ

  Erhalten: AltGr+q = @, AltGr+e = €, AltGr+7/8/9/0 = {[]}


WICHTIG – Bekannte Einschränkungen der .klc-Dateien
---------------------------------------------------
Da die .klc-Dateien nicht auf Windows getestet werden konnten, sollten
beim ersten Test in MSKLC folgende Dinge geprüft werden:

1. OEM-Tastencodes (OEM_1, OEM_3, OEM_4 etc.) – diese sind
   hardwareseitig vom Hersteller abhängig. Falls Umlaute (ä, ö, ü)
   oder Sonderzeichen falsch erscheinen, im MSKLC die entsprechenden
   Zeilen anpassen.

2. Scan Code 0d (Akzent-Taste ´/`) – bei manchen Tastaturen ist
   die Taste anders belegt.

3. Bei Problemen: Option A (AutoHotkey) verwenden – die funktioniert
   garantiert unabhängig von der Hardware.
