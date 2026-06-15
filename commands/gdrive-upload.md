將指定的本機檔案上傳到使用者的 Google Drive。

## 輸入

使用者會在指令後面給：
- 一個本機檔案路徑（必填，可為相對或絕對路徑）
- 選填：目標資料夾名稱（例如「傳到 opisis」「上傳到 xxx 目錄」）。若未指定，預設使用 `opisis`。

## 已知資料夾 ID（快取，避免每次重新搜尋）

- `opisis` → `1mvSDLzDmHMnR7W01IVt3YhoT2eXmZwC6`

若使用者指定的資料夾名稱不在上面清單中，用
`mcp__claude_ai_Google_Drive__search_files` 搜尋：
```
title contains '<資料夾名稱>' and mimeType = 'application/vnd.google-apps.folder'
```
找到後，**將新發現的資料夾名稱與 ID 補進本檔案的「已知資料夾 ID」清單**（用 Edit
工具），下次就不用再搜尋。若搜到多個同名資料夾，列出選項請使用者選擇。

## 執行步驟

### Step 0 — 確認 Google Drive 已授權

若呼叫 `mcp__claude_ai_Google_Drive__*` 工具時提示尚未授權（要求 `/mcp` 登入），
告知使用者執行 `/mcp` 並選擇 "claude.ai Google Drive" 完成授權後再繼續。

### Step 1 — 讀取本機檔案

用 Read 工具讀取使用者指定的檔案。檔案不存在時，先用 `ls` 確認路徑（可能是相對
於目前工作目錄）。

### Step 2 — 判斷 MIME type 與轉換設定

依副檔名決定 `contentMimeType`：

| 副檔名 | contentMimeType | 是否設 `disableConversionToGoogleType: true` |
|---|---|---|
| `.html`, `.htm` | `text/html` | 是（保留原始 HTML，不轉成 Google Doc） |
| `.md`, `.txt` | `text/plain` | 是（保留純文字，不轉成 Google Doc） |
| `.csv` | `text/csv` | 是（保留 CSV，不轉成 Google Sheet） |
| `.json` | `application/json` | 是 |
| `.pdf` | `application/pdf` | 否（PDF 無 Google 對應類型，此欄位無影響） |
| `.png` | `image/png` | 否 |
| `.jpg`, `.jpeg` | `image/jpeg` | 否 |
| 其他 | 依實際內容判斷，預設 `text/plain` 並設 `disableConversionToGoogleType: true` | — |

> 若使用者在指令中明確要求「轉成 Google Doc/Sheet」，則該副檔名對應的
> `disableConversionToGoogleType` 改為 `false`（或省略），讓 Drive 自動轉換。

### Step 3 — 上傳

呼叫 `mcp__claude_ai_Google_Drive__create_file`：
- `title`：沿用原始檔名
- `parentId`：Step 0 解析出的資料夾 ID
- `textContent`：檔案內容（純文字類型）；二進位檔案（PDF/圖片）改用
  `base64Content` 並做 base64 編碼
- `contentMimeType`、`disableConversionToGoogleType`：依 Step 2 結果

### Step 4 — 回報結果

告訴使用者：
- 上傳到哪個資料夾（名稱）
- 檔名與檔案 ID
- 若是新發現的資料夾，提醒已將其 ID 記錄進本指令以便下次使用
