#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

APP_NAME="VibeHub"
APP_BUNDLE="${APP_NAME}.app"
BUNDLE_ID="com.xiabill.VibeHub"
VERSION="1.2.0"

# 1. 生成图标（不存在时）
if [[ ! -f AppIcon.icns ]]; then
  echo "→ 生成 icon…"
  swiftc -framework Cocoa make-icon.swift -o make-icon
  ./make-icon AppIcon.iconset
  iconutil -c icns AppIcon.iconset -o AppIcon.icns
  rm -rf AppIcon.iconset make-icon
fi

# 2. 清理上次构建
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# 3. 编译（arm64；本机 M 芯片用。需要 universal 时加 x86_64 lipo）
#    若设置 PREBUILT_BINARY 且文件存在，则跳过编译，直接用现成二进制（CI 产物本地签名用）
if [[ -n "${PREBUILT_BINARY:-}" && -f "$PREBUILT_BINARY" ]]; then
  echo "→ 使用现成二进制（跳过编译）: $PREBUILT_BINARY"
  cp "$PREBUILT_BINARY" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
  chmod +x "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
else
  echo "→ 编译 arm64…"
  swiftc -O -parse-as-library \
    -target arm64-apple-macos13.0 \
    -framework Cocoa -framework SwiftUI -framework CoreGraphics \
    -framework ServiceManagement -framework IOKit \
    VibeHub.swift \
    -o "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
fi

file "$APP_BUNDLE/Contents/MacOS/$APP_NAME" | sed 's/^/   /'

if [[ -f AppIcon.icns ]]; then
  cp AppIcon.icns "$APP_BUNDLE/Contents/Resources/AppIcon.icns"
fi

# 4. Info.plist
cat > "$APP_BUNDLE/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key><string>${APP_NAME}</string>
  <key>CFBundleIdentifier</key><string>${BUNDLE_ID}</string>
  <key>CFBundleName</key><string>${APP_NAME}</string>
  <key>CFBundleDisplayName</key><string>VibeHub</string>
  <key>CFBundleVersion</key><string>${VERSION}</string>
  <key>CFBundleShortVersionString</key><string>${VERSION}</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>LSUIElement</key><true/>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>NSHighResolutionCapable</key><true/>
  <key>NSHumanReadableCopyright</key><string>© 2026 xiabill</string>
</dict>
</plist>
EOF

# 5. 签名：依次尝试 SIGNING_IDENTITY → VibeHub Self-Signed → RemoteRemap Self-Signed → AirPodsRemap Self-Signed → ad-hoc
pick_signing_identity() {
    local candidate
    for candidate in "${SIGNING_IDENTITY:-}" \
                     "VibeHub Self-Signed" \
                     "RemoteRemap Self-Signed" \
                     "AirPodsRemap Self-Signed"; do
        [[ -z "$candidate" ]] && continue
        if security find-identity -v -p codesigning 2>/dev/null | grep -q "\"$candidate\""; then
            echo "$candidate"
            return 0
        fi
    done
    return 1
}

if IDENT=$(pick_signing_identity); then
    echo "→ 用 self-signed 证书签名（${IDENT}）…"
    codesign --force --deep --sign "$IDENT" "$APP_BUNDLE" >/dev/null
else
    echo "→ ad-hoc 签名（重编后 TCC 权限会丢失。建议跑 ./setup-codesign.sh 创建稳定证书）…"
    codesign --force --deep --sign - "$APP_BUNDLE" >/dev/null
fi

xattr -dr com.apple.quarantine "$APP_BUNDLE" 2>/dev/null || true
touch "$APP_BUNDLE"

echo "✅ 构建完成: $PWD/$APP_BUNDLE"
echo "   启动: open '$PWD/$APP_BUNDLE'"
