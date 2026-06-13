將 `~/.claude/plans/` 下的一份 plan mode 計畫檔，整理後存成 Opsis_Knowledge（或
Obsidian_Knowledge）`01-Projects` 下的工作日誌筆記，避免計畫內容散落、之後找不到。

本指令重用 `/save-note` 的多項步驟，差異僅在輸入來源與套用的模板。

## 輸入

一個 `~/.claude/plans/*.md` 的路徑。若使用者沒有指定，預設取本次對話中最近
讀寫過的 plan 檔（例如目前 plan mode 階段寫入/核准的計畫檔）。

若找不到任何 plan 檔，向使用者詢問路徑後再繼續。

## 執行步驟

### Step 0 — 判斷目標 vault（沿用 `/save-note` Step 0）

依計畫內容與工作目錄判斷 `$VAULT`：

- 計畫內容是關於 `/home/allen/newcompany/opsis-ws`（manifest/opsis/buildroot/
  .claude-config）的開發 → `$VAULT = /home/allen/SharedFolder/Opsis_Knowledge`，
  目標專案資料夾預設 `01-Projects/Opsis-Firmware/`
- 其他情況 → `$VAULT = /home/allen/SharedFolder/Obsidian_Knowledge`，目標專案
  資料夾依 `/save-note` Step 2 的分類邏輯判斷（或詢問使用者）
- 使用者可在指令中明確覆寫 vault 與目標專案資料夾

### Step 1 — 搜尋既有相關筆記（沿用 `/save-note` Step 1）

在 `$VAULT` 的目標專案資料夾內，搜尋是否已有同主題的工作日誌筆記
（例如同一個 feature/step 系列的前一篇）。

- **明顯是同一系列計畫的延續**（例如 `step3_xxx` 之後接 `step4_xxx`）：
  仍建立新筆記（每個 step 各自獨立），但在「相關連結」中連結前後 step 的筆記。
- **完全是同一份計畫的更新版**（同一檔案被多次寫入/修改）：更新既有筆記而非
  新增。

### Step 2 — 整理計畫內容為模板 B（01-Projects 工作日誌）

讀取整份 plan 檔內容，整理成以下結構（沿用 `/save-note` 模板 B 的章節）：

```markdown
---
date: YYYY-MM-DD
week: YYYY-WNN
tags: []
source_plan: ~/.claude/plans/<原始檔名>
---

# 標題

## 目標
（計畫要解決的問題、要做什麼 — 取自計畫的 Context/目標章節）

## 進度
（計畫的主要設計/實作內容摘要 — 取自計畫的 Phase/Section）

## 問題 / 待解
（計畫中標註的未決問題、待確認事項；若計畫已標示「design 完成」「待 review」
等狀態，在此說明）

## 結論 / 下一步
（計畫的結論、後續行動；若計畫尚未執行，註明「計畫已核准，待實作」或計畫本身
的狀態說明）

## 相關連結
（用 [[]] 連結到 vault 內相關筆記，包含 Step 1 找到的前後 step 筆記）

---
← [[Index|回 Index]]
```

- **標題**：取自計畫檔的第一個 `#` 標題；若計畫檔名本身較具體（例如
  `step3-1_face_detect_ultraface.md`），可在標題中保留 step 編號以利排序。
- **檔名**：英文 kebab-case，可保留原計畫檔名中有意義的部分（例如
  `step3-1-face-detect-ultraface.md`），不需沿用 plans/ 目錄下的隨機字尾。
- **`date`/`week`**：使用今天日期（`currentDate`），不是計畫檔的建立日期。
- **`tags`**：規則同 `/save-note`（1~4 個、kebab-case，優先重用 vault 內既有
  tag）。
- **`source_plan`**：填入原始計畫檔的完整路徑（例如
  `~/.claude/plans/step3-1_face_detect_ultraface.md`），保留可追溯性。
- 不要逐字複製整份計畫（計畫檔常含大量設計討論細節），而是**摘要整理**成上述
  四個章節；細節討論若有長期參考價值，可放進「進度」章節的條列或 code block。

### Step 3 — 寫入筆記檔案

寫入 `$VAULT/<目標專案資料夾>/<檔名>.md`（或依 Step 1 判斷更新既有筆記）。

### Step 4 — 更新 Index.md（沿用 `/save-note` Step 7）

在目標專案資料夾的 `Index.md`「筆記列表」加入新筆記的 `[[連結]]`。

### Step 5 — 雙向連結（沿用 `/save-note` Step 8）

若「相關連結」中有連到既有筆記（例如前後 step），到那些筆記補上回連。

### Step 6 — 更新當週週報（沿用 `/save-note` Step 9）

`$VAULT/06-Weekly/YYYY-WNN.md` 追加：
```
- YYYY-MM-DD [[檔名（不含 .md）]] — 一句話說明這份計畫的內容
```

### Step 7 — Git commit（沿用 `/save-note` Step 10）

```bash
cd $VAULT
git add -A
git commit -m "plan: <筆記標題>"
```

dubious ownership / vboxsf 權限問題的處理方式與 `/save-note` Step 10 相同。

### Step 8 — 回報結果

告訴使用者：
- 來源計畫檔路徑（`source_plan`）與存到哪個 vault/路徑
- Step 1 搜尋結果（新增 / 更新既有筆記 / 與哪些前後 step 筆記建立連結）
- 套用的 tags
- Index.md 與週報是否更新
- git commit 結果（commit hash 或失敗原因）

> 注意：本指令**不會刪除或修改** `~/.claude/plans/` 下的原始計畫檔，僅做摘要
> 整理後另存一份到 vault。原始計畫檔保留在原處供完整對照。
