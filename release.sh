#!/bin/bash
# 发布脚本（本机跑）：下载 CI 编译的未签名二进制 → 本地 self-signed 签名打包 → 发 GitHub Release
# 用法：./release.sh <version>   例如 ./release.sh 1.1.0
set -euo pipefail
cd "$(dirname "$0")"

APP_NAME="VibeHub"
APP_BUNDLE="${APP_NAME}.app"

if [[ $# -ne 1 ]]; then
  echo "用法：$0 <version>   例如 $0 1.1.0" >&2
  exit 1
fi
VERSION="$1"
TAG="v${VERSION}"
ARTIFACT_DIR="/tmp/vibehub-artifact"
DMG_PATH="dist/${APP_NAME}-${VERSION}.dmg"

# 1. 校验 build.sh 里的 VERSION 与参数一致
BUILD_VERSION=$(grep -E '^VERSION=' build.sh | head -1 | sed -E 's/^VERSION="?([^"]*)"?/\1/')
if [[ "$BUILD_VERSION" != "$VERSION" ]]; then
  echo "❌ 版本不一致：build.sh VERSION=${BUILD_VERSION}，参数=${VERSION}。请先同步 build.sh / make-dmg.sh 的版本号。" >&2
  exit 1
fi
echo "→ 版本校验通过：$VERSION"

# 2. 找到对应 tag 的最新成功 run，下载 artifact
echo "→ 查找 tag $TAG 的成功构建…"
RUN_ID=$(gh run list --workflow=build.yml --branch "$TAG" --status success \
  --limit 1 --json databaseId --jq '.[0].databaseId')
if [[ -z "$RUN_ID" || "$RUN_ID" == "null" ]]; then
  echo "❌ 未找到 tag $TAG 的成功构建 run。确认已 push tag 且 CI 已跑成功。" >&2
  exit 1
fi
echo "→ 找到 run: ${RUN_ID}，下载产物…"
rm -rf "$ARTIFACT_DIR"
gh run download "$RUN_ID" -n VibeHub-binary -D "$ARTIFACT_DIR"
if [[ ! -f "$ARTIFACT_DIR/VibeHub" ]]; then
  echo "❌ 产物中未找到 $ARTIFACT_DIR/VibeHub" >&2
  exit 1
fi

# 3. 本地签名打包（复用 build.sh，跳过编译）
echo "→ 本地签名打包…"
PREBUILT_BINARY="$ARTIFACT_DIR/VibeHub" ./build.sh

# 4. 确认签名 identity 非 ad-hoc
echo "→ 检查签名…"
SIGN_INFO=$(codesign -dv "$APP_BUNDLE" 2>&1)
if echo "$SIGN_INFO" | grep -qi "Signature=adhoc"; then
  echo "⚠️  警告：$APP_BUNDLE 为 ad-hoc 签名，缺少 self-signed 证书。继续发布，但用户重编后 TCC 权限会丢失。" >&2
else
  echo "$SIGN_INFO" | grep -i "Authority" | sed 's/^/   /' || true
  echo "→ 签名检查通过（非 ad-hoc）"
fi

# 5. 生成 DMG
echo "→ 生成 DMG…"
./make-dmg.sh
if [[ ! -f "$DMG_PATH" ]]; then
  echo "❌ 未生成 $DMG_PATH" >&2
  exit 1
fi

# 6. 发布 Release（存在则覆盖上传资产）
NOTES="VibeHub v${VERSION}

由 GitHub Actions 编译未签名二进制，本机 self-signed 证书签名打包。
安装：双击 DMG，拖 VibeHub.app 到 Applications。"

echo "→ 发布 GitHub Release ${TAG}…"
if gh release view "$TAG" >/dev/null 2>&1; then
  echo "→ Release $TAG 已存在，覆盖上传 DMG…"
  gh release upload "$TAG" "$DMG_PATH" --clobber
else
  gh release create "$TAG" "$DMG_PATH" --title "VibeHub v${VERSION}" --notes "$NOTES"
fi

echo "✅ 发布完成：$TAG  ($DMG_PATH)"
