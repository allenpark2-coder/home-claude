將使用者提供的內容整理成筆記，儲存到 Obsidian vault。

## Vault 路徑
`/home/allen/SharedFolder/Obsidian_Knowledge`

## 執行步驟

### Step 1 — 搜尋既有相關筆記
在決定分類/檔名之前，先搜尋 vault 是否已有主題重疊的筆記：

- 用內容的關鍵字（中英文都試）搜尋 vault（`grep -ri` 或翻對應分類資料夾的
  `Index.md`），特別留意 `03-Resources/Tools/Index.md`——這個清單已經很長，
  最容易出現重複主題。
- 找到主題明顯重疊的既有筆記時，**不要直接新增一篇平行的筆記**，依重疊程度
  二選一：
  - **大幅重疊**：更新既有筆記內容（補充新資訊、修正過時內容），不建立新檔。
    在 Step 11 回報時說明「更新了 XXX，而非新增」。
  - **部分重疊（不同角度/不同案例）**：仍建立新筆記，但在新筆記的「相關連結」
    中明確連結到這些既有筆記，並執行 Step 8 的雙向連結。
- 完全沒有相關筆記時，正常繼續到 Step 2。

### Step 2 — 判斷分類
根據內容判斷最適合的位置：

- **01-Projects/**：針對特定進行中專案的筆記（WallE-S88、Cooper-2.5、WebRTC-Streamer-aarch64 等）
- **02-Areas/**：跨專案的技術知識（BSP-Kernel、Build-System、Cross-Compile、DRAM-Memory、WebRTC、ISP-Camera）
- **03-Resources/**：純參考資料、工具指令、規格摘要（Chips、Tools、Standards）
- **05-Inbox/**：無法判斷分類時，一律放此處

### Step 3 — 決定檔名
- 使用英文、kebab-case
- 簡短但能描述內容
- 例如：`lpddr5-shmoo-analysis.md`、`cmake-cross-compile-tips.md`

### Step 4 — 計算日期與週次
使用當天日期（`currentDate`）：
- `date`：格式 `YYYY-MM-DD`
- `week`：ISO 8601 週次，格式 `YYYY-WNN`（例如 `2026-W12`）

### Step 5 — 根據分類套用對應模板

**若筆記內容來自閱讀原始碼**（例如本次對話中讀過 `.c`、`.h`、`.py`、`.go` 等原始檔），
在筆記的 `## 參考` 或 `## 相關連結` **之前**加入以下區塊，條列實際讀過的原始檔路徑：

```markdown
## 原始碼位置
- `相對於 repo 根目錄的路徑/檔案名稱.c`
- `相對於 repo 根目錄的路徑/檔案名稱.h`
```

路徑使用相對路徑（相對於目前對話所在專案的 repo 根目錄），並只列本次真正讀過、對理解有幫助的檔案。

---

所有模板都在最前面加上 frontmatter：
```yaml
---
date: YYYY-MM-DD
week: YYYY-WNN
tags: []
---
```

**`tags` 規則：**
- 1~4 個，英文 kebab-case
- 優先重用 Step 1 搜尋時看到的既有 tag（例如
  `grep -rh "^  - " 03-Resources/Tools/*.md` 抓現有 tag 清單），不要每篇都
  發明新詞，避免標籤本身也變得雜亂
- 至少包含一個「主題」tag（例如 `claude-code`、`codegraph`、`obsidian`）和
  一個「類型」tag（例如 `tool-comparison`、`workflow`、`troubleshooting`）

#### 模板 A：02-Areas（技術知識）
```markdown
---
date: YYYY-MM-DD
week: YYYY-WNN
tags: []
---

# 標題

## 概念
（這個技術是什麼？解決什麼問題？）

## 原理 / 細節
（核心機制、重要參數、運作方式）

## 範例
（指令、程式碼、設定範例，使用 code block）

## 常見問題
（踩過的坑、錯誤訊息與解法）

## 參考
（文件連結、規格名稱）

## 原始碼位置
（若來自原始碼閱讀，列出讀過的檔案路徑；否則省略此區塊）

## 相關連結
（用 [[]] 連結到 vault 內相關筆記）

---
← [[Index|回 Index]]
```

#### 模板 B：01-Projects（專案工作日誌）
```markdown
---
date: YYYY-MM-DD
week: YYYY-WNN
tags: []
---

# 標題

## 目標
（這次要做什麼）

## 進度
（做了什麼，目前到哪一步）

## 問題 / 待解
（卡住的地方、待確認的事項）

## 結論 / 下一步
（結果與後續行動）

## 相關連結
（用 [[]] 連結到 vault 內相關筆記）

---
← [[Index|回 Index]]
```

#### 模板 C：03-Resources（指令速查 / 參考資料）
```markdown
---
date: YYYY-MM-DD
week: YYYY-WNN
tags: []
---

# 標題

## 用途
（這份資料是用來做什麼的）

## 指令 / 內容
（條列或 code block 呈現，方便查詢）

## 注意事項
（使用限制、版本差異、常見錯誤）

## 相關連結
（用 [[]] 連結到 vault 內相關筆記）

---
← [[Index|回 Index]]
```

#### 模板 D：05-Inbox（無法分類）
```markdown
---
date: YYYY-MM-DD
week: YYYY-WNN
tags: []
---

# 標題

（直接整理內容，不強制套用結構）

---
待整理 → 移至正確位置後刪除此行
```

### Step 6 — 寫入筆記檔案
將格式化後的筆記寫入正確路徑（或依 Step 1 的判斷，更新既有筆記）。

### Step 7 — 更新 Index.md
在對應資料夾的 `Index.md` 的「筆記列表」區段，加入新筆記的 `[[連結]]`。
（若 Step 1 判定為更新既有筆記，此步驟跳過。）

### Step 8 — 雙向連結
若新筆記的「相關連結」中有連到既有筆記，逐一打開那些既有筆記，在其「相關連結」
區段補上一條指回新筆記的連結（若該既有筆記沒有「相關連結」區段，就在檔案最後、
`← [[Index|回 Index]]` 之前新增一個）。

（Step 1 判定為「更新既有筆記」的情況不適用本步驟，因為沒有新檔案。）

### Step 9 — 更新當週周報草稿

周報草稿路徑：`/home/allen/SharedFolder/Obsidian_Knowledge/06-Weekly/YYYY-WNN.md`

若檔案不存在，建立新檔，內容如下：
```markdown
# 週報 YYYY-WNN

## 本週紀錄

```

接著，不論檔案是否已存在，都在 `## 本週紀錄` 區段的底部 **追加** 一行：
```
- YYYY-MM-DD [[檔名（不含.md）]] — 一句話說明這篇筆記的重點
```

追加時注意：
- 若今天日期的條目已存在，直接在最後一條同日期條目下方插入，不重複寫日期標題
- 一句話摘要要具體，避免只寫「筆記內容」這種廢話

### Step 10 — Git commit

Vault 是 git repo，所有筆記/Index/週報變更最後都要 commit：

```bash
cd /home/allen/SharedFolder/Obsidian_Knowledge
git add -A
git commit -m "note: <筆記標題或更新摘要>"
```

若出現 `detected dubious ownership` 錯誤，先執行一次：
```bash
git config --global --add safe.directory /home/allen/SharedFolder/Obsidian_Knowledge
```
再重新 `git add -A && git commit`。

若 `git status` 顯示大量（數十~數百個）檔案被改，且 `git diff --raw` 顯示
都是 `:100644 100755`（純權限模式變化、無內容差異）——這是 vault 放在
VirtualBox 共用資料夾（vboxsf）上導致權限位元失真的已知問題，與本次筆記
無關。執行一次：
```bash
git config core.fileMode false
```
（此設定是 per-repo 永久設定，修過一次後不會再出現，可跳過此檢查。）

若這個 vault 有自動備份程式（例如 Obsidian Git plugin）在背景定期 commit，
`git add -A && git commit` 可能出現 "nothing to commit, working tree clean"
——代表今天的變更已被自動備份 commit 帶走，視為成功，不算失敗。

若 commit 因其他原因失敗，不要讓整個流程失敗——筆記檔案已寫入即視為完成，
在 Step 11 回報中註明「git commit 失敗：<原因>，需手動處理」。

### Step 11 — 回報結果
告訴使用者：
- 儲存路徑（或「更新了既有筆記 XXX」，依 Step 1 判斷）
- 分類理由（若使用者沒有指定）
- Step 1 搜尋結果：找到哪些重疊筆記、採取的處理方式（新增 / 更新 / 雙向連結）
- 套用的 tags
- 是否更新了 Index.md
- 雙向連結更新了哪些既有筆記
- 周報草稿路徑與追加的摘要行
- git commit 結果（commit hash 或失敗原因）
