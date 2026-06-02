#!/bin/bash
set -e

BASE="$(cd "$(dirname "$0")" && pwd)"
SRC="$BASE/src"
OUT="$BASE"
SDK=$(xcrun --show-sdk-path)
ARCH=$(uname -m)   # arm64 oder x86_64

echo "SDK: $SDK"
echo "Arch: $ARCH"

# ── Icon neu generieren ────────────────────────────────────────────────────────
echo "Generiere IAST-Icon..."
python3 << 'PYEOF'
import os, AppKit
from AppKit import NSImage, NSFont, NSColor, NSAttributedString, NSMutableParagraphStyle, NSBitmapImageRep
from Foundation import NSMakeSize, NSMakeRect

SIZES = [16, 32, 64, 128, 256, 512, 1024]
ICONSET = "/tmp/iast_build.iconset"
os.makedirs(ICONSET, exist_ok=True)

def render(size):
    img = NSImage.alloc().initWithSize_(NSMakeSize(size, size))
    img.lockFocus()
    r = size * 0.18
    path = AppKit.NSBezierPath.bezierPathWithRoundedRect_xRadius_yRadius_(
        NSMakeRect(0, 0, size, size), r, r)
    NSColor.colorWithCalibratedRed_green_blue_alpha_(0.10, 0.20, 0.50, 1.0).setFill()
    path.fill()
    para = NSMutableParagraphStyle.alloc().init()
    para.setAlignment_(AppKit.NSTextAlignmentCenter)
    attrs = {
        AppKit.NSFontAttributeName: NSFont.boldSystemFontOfSize_(size * 0.36),
        AppKit.NSForegroundColorAttributeName: NSColor.whiteColor(),
        AppKit.NSParagraphStyleAttributeName: para,
    }
    ns = NSAttributedString.alloc().initWithString_attributes_("IAST", attrs)
    ts = ns.size()
    ns.drawAtPoint_(((size - ts.width) / 2, (size - ts.height) / 2))
    img.unlockFocus()
    return img

for size in SIZES:
    img = render(size)
    rep = NSBitmapImageRep.imageRepWithData_(img.TIFFRepresentation())
    png = rep.representationUsingType_properties_(AppKit.NSBitmapImageFileTypePNG, None)
    png.writeToFile_atomically_(f"{ICONSET}/icon_{size}x{size}.png", True)
    if size >= 32:
        png.writeToFile_atomically_(f"{ICONSET}/icon_{size//2}x{size//2}@2x.png", True)
PYEOF

iconutil -c icns /tmp/iast_build.iconset -o /tmp/IAST.icns
echo "Icon: /tmp/IAST.icns"

# ── App bauen ──────────────────────────────────────────────────────────────────
build_app() {
    local VARIANT=$1          # "ch" oder "de"
    local VUPPER
    VUPPER=$(echo "$VARIANT" | tr '[:lower:]' '[:upper:]')
    local APP_NAME="IAST_${VUPPER}_Installer"
    local APP="$OUT/${APP_NAME}.app"
    local BUNDLE="IAST_${VUPPER}.bundle"
    local BUNDLE_ID

    [ "$VARIANT" = "ch" ] && BUNDLE_ID="ch.iast.installer.CH" || BUNDLE_ID="de.iast.installer.DE"

    echo ""
    echo "Baue ${APP_NAME}.app ..."

    # Alte Version entfernen
    rm -rf "$APP"

    # Verzeichnisstruktur
    mkdir -p "$APP/Contents/MacOS"
    mkdir -p "$APP/Contents/Resources"

    # Kompilieren
    swiftc \
        "$SRC/config_${VARIANT}.swift" \
        "$SRC/InstallerBase.swift" \
        "$SRC/main.swift" \
        -o "$APP/Contents/MacOS/$APP_NAME" \
        -sdk "$SDK" \
        -target "${ARCH}-apple-macos12.0" \
        -framework AppKit \
        -framework Foundation

    # .keylayout direkt einbetten (kein Bundle – zuverlässiger für macOS-Erkennung)
    cp "$OUT/IAST_${VUPPER}.keylayout" "$APP/Contents/Resources/"

    # Icon
    cp /tmp/IAST.icns "$APP/Contents/Resources/IAST.icns"

    # Info.plist
    cat > "$APP/Contents/Info.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>     <string>${BUNDLE_ID}</string>
    <key>CFBundleName</key>           <string>${APP_NAME}</string>
    <key>CFBundleExecutable</key>     <string>${APP_NAME}</string>
    <key>CFBundleIconFile</key>       <string>IAST</string>
    <key>CFBundleVersion</key>        <string>1.0</string>
    <key>NSPrincipalClass</key>       <string>NSApplication</string>
    <key>NSHighResolutionCapable</key><true/>
    <key>LSMinimumSystemVersion</key> <string>12.0</string>
    <key>NSHumanReadableCopyright</key><string>IASTast 2026</string>
</dict>
</plist>
PLIST

    echo "  → $APP"
}

build_app ch
build_app de

echo ""
echo "Fertig."
echo "  $OUT/IAST_CH_Installer.app"
echo "  $OUT/IAST_DE_Installer.app"
