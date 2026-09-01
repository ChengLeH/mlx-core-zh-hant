# MLX Core 繁體中文語言包

這是 [mlx-serve / MLX Core](https://github.com/ddalcu/mlx-serve) **v26.8.11** 的繁體中文（台灣）介面套件。它翻譯主視窗、設定頁、狀態列選單、代理、圖像／影片／語音／音樂生成、提示、確認視窗與常見錯誤訊息。產品名稱固定保留為 **MLX Core**，模型名稱、API、路徑與命令列參數亦保留原文，避免技術語意失真。

## 支援範圍

- MLX Core v26.8.11
- macOS 15 或更新版本
- 完整 Xcode；若專案含 Metal shader，另需安裝 Metal Toolchain
- 預設 App 路徑：`/Applications/MLX Core.app`

本倉庫不包含 MLX Core App 二進位檔、模型、API Key 或任何使用者設定；安裝器會從官方上游取得對應版本原始碼，並在本機完成補丁與建置。

## 安裝

在本專案根目錄執行：

```bash
./scripts/install-zh-Hant.sh
```

若 App 已更新，也可指定版本重新注入：

```bash
./scripts/install-zh-Hant.sh 26.8.12
```

腳本會先下載相同版本並執行補丁相容性檢查；新版 UI 若未改動相關區域就會正常重編，若上游新增或調整選單而造成衝突，腳本會在覆蓋 App 前安全停止，保留原 App 與備份。

安裝程式會：

1. 核對 MLX Core 版本。
2. 下載完全相同的上游 `v26.8.11` 原始碼。
3. 套用繁中 patch 並重編前端 App。
4. 先把原始執行檔與語言資源備份到 `~/Library/Application Support/MLXCore-zh-Hant/backups/`。
5. 安裝、重新簽署並啟動 MLX Core。

模型、聊天、設定與 `~/.mlx-serve` 不會被刪除。

## 還原

```bash
./scripts/restore-original.sh
```

還原腳本會使用最近一份備份復原官方執行檔與原始語言資源。

## 手動驗收

- 主視窗導覽、設定頁左側分類及所有設定說明顯示繁體中文。
- 點擊狀態列 MLX Core 圖示，伺服器、記憶體、媒體生成、任務和日誌控制均顯示繁體中文。
- 舊資料庫內標題為 `New Chat` 的對話顯示為「新增對話」，但不改寫資料庫值。
- 啟動既有模型後，`GET /health` 回傳 `{"status":"ok"}`，既有模型參數不被安裝器更動。

## 設計與限制

- 補丁以 v26.8.11 為基準；更新後會先做相容性檢查，絕不把不相容的 UI patch 強行套用。
- App 更新後通常需要重新安裝本語言包。
- 本套件使用 ad-hoc code signing；若你的組織要求特定簽章，請在安裝後用自己的憑證重新簽署。
- 此專案不是 MLX Core 官方翻譯，問題請在本專案回報。

## 目錄

- `locales/zh-Hant/Localizable.strings`：繁中語言包。
- `patches/v26.8.11-zh-Hant.patch`：動態 UI 與相容性修正。
- `scripts/install-zh-Hant.sh`：備份、建置與安裝。
- `scripts/restore-original.sh`：一鍵回復。

## 授權與來源

原始 MLX Core 程式碼依其上游授權條款使用。本專案新增的翻譯、腳本與 patch 採 MIT License。
