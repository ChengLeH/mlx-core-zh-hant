#!/bin/zsh
set -euo pipefail

APP_PATH="${MLX_CORE_APP:-/Applications/MLX Core.app}"
PATCH_BASE_VERSION="26.8.11"
REPO_ROOT="${0:A:h:h}"
STATE_DIR="$HOME/Library/Application Support/MLXCore-zh-Hant"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$STATE_DIR/backups/$STAMP"
BUILD_DIR="$(mktemp -d /tmp/mlx-core-zh-hant.XXXXXX)"
trap 'rm -rf "$BUILD_DIR"' EXIT

[[ -d "$APP_PATH" ]] || { print -u2 "找不到 $APP_PATH"; exit 1; }
[[ -x /usr/bin/git ]] || { print -u2 "找不到 git"; exit 1; }
[[ -d /Applications/Xcode.app || -d /Applications/Xcode-beta.app ]] || {
  print -u2 "需要安裝完整 Xcode。"; exit 1
}

INSTALLED_VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP_PATH/Contents/Info.plist" 2>/dev/null || true)"
REQUESTED_VERSION="${1:-${MLX_CORE_VERSION:-$INSTALLED_VERSION}}"
[[ -n "$REQUESTED_VERSION" ]] || { print -u2 "無法判斷 MLX Core 版本，請以參數指定，例如：$0 26.8.11"; exit 1; }
TAG="v${REQUESTED_VERSION#v}"

mkdir -p "$BACKUP_DIR"
cp "$APP_PATH/Contents/MacOS/MLXCore" "$BACKUP_DIR/MLXCore"
if [[ -d "$APP_PATH/Contents/Resources/zh-Hant.lproj" ]]; then
  cp -R "$APP_PATH/Contents/Resources/zh-Hant.lproj" "$BACKUP_DIR/zh-Hant.lproj"
fi

git clone --depth 1 --branch "$TAG" https://github.com/ddalcu/mlx-serve.git "$BUILD_DIR/src"
if ! git -C "$BUILD_DIR/src" apply --check "$REPO_ROOT/patches/v26.8.11-zh-Hant.patch"; then
  print -u2 "繁中補丁以 v$PATCH_BASE_VERSION 為基準，無法安全套用至 $TAG。"
  print -u2 "App 尚未被修改，既有備份位於：$BACKUP_DIR"
  print -u2 "代表新版加入或調整了介面；請更新補丁後再執行，避免強行覆蓋。"
  exit 2
fi
git -C "$BUILD_DIR/src" apply "$REPO_ROOT/patches/v26.8.11-zh-Hant.patch"
mkdir -p "$BUILD_DIR/src/app/Sources/MLXServe/Resources/zh-Hant.lproj"
cp "$REPO_ROOT/locales/zh-Hant/Localizable.strings" "$BUILD_DIR/src/app/Sources/MLXServe/Resources/zh-Hant.lproj/Localizable.strings"

DEV_DIR="/Applications/Xcode.app/Contents/Developer"
[[ -d /Applications/Xcode-beta.app ]] && DEV_DIR="/Applications/Xcode-beta.app/Contents/Developer"
mkdir -p "$BUILD_DIR/cache" "$BUILD_DIR/tmp"
(
  cd "$BUILD_DIR/src/app"
  bash ../scripts/patch-swatex-font-lookup.sh .build/checkouts/SwaTex 2>/dev/null || true
  DEVELOPER_DIR="$DEV_DIR" CLANG_MODULE_CACHE_PATH="$BUILD_DIR/cache" \
    SWIFT_MODULECACHE_PATH="$BUILD_DIR/cache" TMPDIR="$BUILD_DIR/tmp" \
    xcrun swift build -c release
)

pkill -x MLXCore 2>/dev/null || true
pkill -f "$APP_PATH/Contents/MacOS/mlx-serve" 2>/dev/null || true
cp "$BUILD_DIR/src/app/.build/out/Products/Release/MLXCore" "$APP_PATH/Contents/MacOS/MLXCore"
mkdir -p "$APP_PATH/Contents/Resources/zh-Hant.lproj"
cp "$REPO_ROOT/locales/zh-Hant/Localizable.strings" "$APP_PATH/Contents/Resources/zh-Hant.lproj/Localizable.strings"
install_name_tool -add_rpath '@executable_path/../Frameworks' "$APP_PATH/Contents/MacOS/MLXCore" 2>/dev/null || true
codesign --force --deep --sign - "$APP_PATH"
open -a "$APP_PATH"
print "完成安裝 MLX Core $REQUESTED_VERSION 繁體中文介面。備份位於：$BACKUP_DIR"
