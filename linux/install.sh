#!/bin/bash
# IAST Keyboard Layout Installer für Linux (X11 und Wayland)
set -e

XKB_SYMBOLS="/usr/share/X11/xkb/symbols"
XKB_RULES="/usr/share/X11/xkb/rules"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Mapping-Tabelle ────────────────────────────────────────────────────────────
echo ""
echo "IAST Keyboard Layout – Installer"
echo "================================="
echo ""
echo "IAST-Zeichen via AltGr (beide Layouts gleich):"
echo ""
echo "  Taste  AltGr    Shift+AltGr    Taste  AltGr    Shift+AltGr"
echo "  ─────────────────────────────────────────────────────────────"
echo "  a      ā        Ā              s      ṣ        Ṣ"
echo "  i      ī        Ī              d      ḍ        Ḍ"
echo "  u      ū        Ū              n      ṇ        Ṇ"
echo "  r      ṛ        Ṛ              h      ḥ        Ḥ"
echo "  l      ḷ        Ḷ              m      ṃ        Ṃ"
echo "  t      ṭ        Ṭ              g      ṅ        Ṅ"
echo "  x      ś        Ś              j      ñ        Ñ"
echo ""
echo "  Erhalten: AltGr+q = @  (DE)   AltGr+2 = @  (CH)"
echo "            AltGr+e = €  (beide)"
echo ""

# ── Root-Check ────────────────────────────────────────────────────────────────
if [ "$EUID" -ne 0 ]; then
    echo "Fehler: Root-Rechte erforderlich."
    echo "Ausführen mit: sudo bash install.sh"
    exit 1
fi

# ── Symboldateien kopieren ────────────────────────────────────────────────────
echo "Kopiere Symboldateien nach $XKB_SYMBOLS ..."
cp "$SCRIPT_DIR/symbols/iast_de"     "$XKB_SYMBOLS/iast_de"
cp "$SCRIPT_DIR/symbols/iast_ch"     "$XKB_SYMBOLS/iast_ch"
cp "$SCRIPT_DIR/symbols/iast_de_mac" "$XKB_SYMBOLS/iast_de_mac"
cp "$SCRIPT_DIR/symbols/iast_ch_mac" "$XKB_SYMBOLS/iast_ch_mac"
chmod 644 "$XKB_SYMBOLS/iast_de" "$XKB_SYMBOLS/iast_ch" \
          "$XKB_SYMBOLS/iast_de_mac" "$XKB_SYMBOLS/iast_ch_mac"

# ── evdev.xml patchen (für GNOME, KDE, systemd-localed) ──────────────────────
patch_xml() {
    local XML="$XKB_RULES/evdev.xml"
    if [ ! -f "$XML" ]; then
        echo "  Warnung: $XML nicht gefunden, übersprungen."
        return
    fi

    # Nur einfügen wenn noch nicht vorhanden
    if grep -q "iast_de" "$XML"; then
        echo "  evdev.xml: IAST-Layouts bereits registriert."
        return
    fi

    cp "$XML" "${XML}.bak"
    python3 - "$XML" << 'PYEOF'
import sys, re

path = sys.argv[1]
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

new_layouts = """
  <layout>
    <configItem>
      <name>iast_de</name>
      <shortDescription>IAST</shortDescription>
      <description>German (IAST)</description>
      <languageList><iso639Id>deu</iso639Id></languageList>
    </configItem>
    <variantList/>
  </layout>

  <layout>
    <configItem>
      <name>iast_ch</name>
      <shortDescription>IAST</shortDescription>
      <description>Swiss German (IAST)</description>
      <languageList><iso639Id>deu</iso639Id></languageList>
    </configItem>
    <variantList/>
  </layout>

  <layout>
    <configItem>
      <name>iast_de_mac</name>
      <shortDescription>IAST</shortDescription>
      <description>German (IAST, Mac keyboard)</description>
      <languageList><iso639Id>deu</iso639Id></languageList>
    </configItem>
    <variantList/>
  </layout>

  <layout>
    <configItem>
      <name>iast_ch_mac</name>
      <shortDescription>IAST</shortDescription>
      <description>Swiss German (IAST, Mac keyboard)</description>
      <languageList><iso639Id>deu</iso639Id></languageList>
    </configItem>
    <variantList/>
  </layout>
"""

# Vor </layoutList> einfügen
content = content.replace('</layoutList>', new_layouts + '</layoutList>', 1)
with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
print("  evdev.xml: IAST-Layouts eingetragen.")
PYEOF
}

patch_xml

# ── evdev.lst patchen (für setxkbmap und ältere Tools) ───────────────────────
patch_lst() {
    local LST="$XKB_RULES/evdev.lst"
    if [ ! -f "$LST" ]; then
        echo "  Warnung: $LST nicht gefunden, übersprungen."
        return
    fi

    if grep -q "iast_de" "$LST"; then
        echo "  evdev.lst: IAST-Layouts bereits registriert."
        return
    fi

    cp "$LST" "${LST}.bak"
    sed -i '/^  de /a\  iast_de         German (IAST)\n  iast_ch         Swiss German (IAST)' "$LST"
    echo "  evdev.lst: IAST-Layouts eingetragen."
}

patch_lst

# ── XKB-Cache leeren ─────────────────────────────────────────────────────────
if command -v dpkg-reconfigure &>/dev/null; then
    dpkg-reconfigure xkb-data 2>/dev/null || true
fi

echo ""
echo "Installation abgeschlossen."
echo ""
echo "Aktivierung:"
echo ""
echo "  PC-Tastatur (AltGr-Taste):"
echo "    setxkbmap iast_de          # Deutsch IAST"
echo "    setxkbmap iast_ch          # Schweizer Deutsch IAST"
echo ""
echo "  Apple-Tastatur (rechte ⌥-Taste als AltGr):"
echo "    setxkbmap iast_de_mac      # Deutsch IAST"
echo "    setxkbmap iast_ch_mac      # Schweizer Deutsch IAST"
echo ""
echo "  Permanent via localectl:"
echo "    sudo localectl set-x11-keymap iast_de_mac   # Apple DE"
echo "    sudo localectl set-x11-keymap iast_ch_mac   # Apple CH"
echo ""
echo "  GNOME: Einstellungen → Tastatur → Eingabequellen → + → 'IAST'"
echo "  KDE:   Systemeinstellungen → Eingabegeräte → Tastatur → Layouts"
echo ""
echo "  Apple-Tastatur: Falls Tasten (< > |) falsch belegt sind:"
echo "    setxkbmap iast_de_mac -option apple:badmap"
echo ""
echo "Deinstallation:"
echo "  sudo rm /usr/share/X11/xkb/symbols/iast_de iast_ch"
echo "  evdev.xml.bak und evdev.lst.bak zum Wiederherstellen verwenden."
