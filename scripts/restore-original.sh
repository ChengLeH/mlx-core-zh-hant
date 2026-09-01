#!/bin/zsh
set -euo pipefail

APP_PATH="${MLX_CORE_APP:-/Applications/MLX Core.app}"
STATE_DIR="$HOME/Library/Application Support/MLXCore-zh-Hant"
BACKUP_DIR="${1:-$(find "$STATE_DIR/backups" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort | tail -n 1)}"

[[ -n "$BACKUP_DIR" && -f "$BACKUP_DIR/MLXCore" ]] || {
  print -u2 "找不到可用備份。"; exit 1
}

pkill -x MLXCore 2>/dev/null || true
pkill -f "$APP_PATH/Contents/MacOS/mlx-serve" 2>/dev/null || true
cp "$BACKUP_DIR/MLXCore" "$APP_PATH/Contents/MacOS/MLXCore"
if [[ -d "$BACKUP_DIR/zh-Hant.lproj" ]]; then
  mkdir -p "$APP_PATH/Contents/Resources"
  ditto "$BACKUP_DIR/zh-Hant.lproj" "$APP_PATH/Contents/Resources/zh-Hant.lproj"
else
  rm -rf "$APP_PATH/Contents/Resources/zh-Hant.lproj"
fi
codesign --force --deep --sign - "$APP_PATH"
open -a "$APP_PATH"
print "已從 $BACKUP_DIR 還原。"
