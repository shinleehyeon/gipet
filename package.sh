#!/bin/bash
# Package Gipet as a proper .app bundle so the gipet:// URL scheme registers
# with macOS (required for the GitHub OAuth callback to reach the app).
#
# Usage:  ./package.sh            # build (release) + bundle + register
#         ./package.sh --run      # ...and launch it
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
APP="$ROOT/깃독.app"
CONTENTS="$APP/Contents"
MACOS="$CONTENTS/MacOS"
RES="$CONTENTS/Resources"
EXE_NAME="Gipet"
BUNDLE_ID="com.gipet.app"

echo "▸ Building (release)…"
swift build -c release

BIN="$(swift build -c release --show-bin-path)/DesktopDog"
[ -f "$BIN" ] || { echo "✗ binary not found at $BIN"; exit 1; }

echo "▸ Assembling $APP …"
rm -rf "$APP"
mkdir -p "$MACOS" "$RES"
cp "$BIN" "$MACOS/$EXE_NAME"
cp "$ROOT/Sources/DesktopDog/Resources/AppIcon.icns" "$RES/AppIcon.icns"
chmod +x "$MACOS/$EXE_NAME"

cat > "$CONTENTS/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>            <string>깃독</string>
    <key>CFBundleDisplayName</key>     <string>깃독</string>
    <key>CFBundleExecutable</key>      <string>$EXE_NAME</string>
    <key>CFBundleIdentifier</key>      <string>$BUNDLE_ID</string>
    <key>CFBundleVersion</key>         <string>1</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>CFBundlePackageType</key>     <string>APPL</string>
    <key>LSMinimumSystemVersion</key>  <string>13.0</string>
    <!-- Menu-bar accessory: no Dock icon. -->
    <key>CFBundleIconFile</key>        <string>AppIcon</string>
    <key>LSUIElement</key>             <true/>
    <!-- Register the gipet:// scheme for the GitHub OAuth callback. -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLName</key>     <string>$BUNDLE_ID</string>
            <key>CFBundleURLSchemes</key>
            <array><string>gipet</string></array>
        </dict>
    </array>
</dict>
</plist>
PLIST

BUILD_DIR="$ROOT/.build/arm64-apple-macosx/release"

# Bundle Lottie.framework (and any other SPM frameworks)
FRAMEWORKS="$CONTENTS/Frameworks"
mkdir -p "$FRAMEWORKS"
for fw in "$BUILD_DIR"/*.framework; do
    [ -d "$fw" ] && cp -R "$fw" "$FRAMEWORKS/"
done
install_name_tool -add_rpath "@loader_path/../Frameworks" "$MACOS/$EXE_NAME" 2>/dev/null || true

# Copy SPM resource bundles (dog_animation.json, Memes, Notes, etc.)
for bundle in "$BUILD_DIR"/*.bundle; do
    [ -d "$bundle" ] && cp -R "$bundle" "$RES/"
done

echo "▸ Ad-hoc code signing…"
codesign --force --deep --sign - "$APP" 2>/dev/null || echo "  (codesign skipped)"

echo "▸ Registering URL scheme with LaunchServices…"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
    -f "$APP" 2>/dev/null || true

echo "✓ Built $APP"
echo "  gipet:// is now registered. Move Gipet.app to /Applications if you like."

if [ "${1:-}" = "--run" ]; then
    echo "▸ Restarting Gipet…"
    # If an existing Gipet process is alive, "open" only activates it and
    # code changes won't load. Kill first, then force a new app instance.
    pkill -9 -f "$APP/Contents/MacOS/$EXE_NAME" 2>/dev/null || true
    sleep 1.0
    open "$APP"
fi
