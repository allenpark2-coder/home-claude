處理 `opsis-knowledge-staleness-check.sh` 產生的 stale notes 清單，將
Opsis_Knowledge 中因 opsis-ws 程式碼變動而可能過時的筆記進行 review 與更新。

## 設定

讀取 `~/.claude/opsis-knowledge.config`，取得：
- `OK_WORKSPACE`：專案原始碼工作區
- `OK_PROJECT_VAULT`：專案知識 vault（以下簡稱 `$VAULT`）

## 前置

stale 清單位於 `$VAULT/05-Inbox/stale-notes.md`，由
`~/.claude/scripts/opsis-knowledge-staleness-check.sh` 產生。若該檔案不存在，
或內容只有「（目前沒有需要 review 的筆記）」，告知使用者目前沒有待處理項目並結束。

若使用者尚未執行過該腳本，先執行：
```bash
bash ~/.claude/scripts/opsis-knowledge-staleness-check.sh
```

## 執行步驟

### Step 1 — 讀取 stale 清單
讀取 `$VAULT/05-Inbox/stale-notes.md`，列出每個被標記的筆記
（`[[筆記路徑（不含 .md）]]`），以及每篇筆記下被標記的每一個 `source[]`
項目：對應的 `repo`、`commit`（即該項目的 `source_commit`）、被標記的方式
（符號層級 `符號 X (file:lines) — N 個新 commit` 或檔案層級
`檔案層級 — N 個新 commit，涉及路徑: ...`）及新 commit 列表。

一篇筆記的 frontmatter 可能有多個 `source[]` 項目（對應不同 repo 或
不同 paths/symbols），stale-notes.md 只會列出**有變動**的項目；同一篇筆記
未被列出的其他 `source[]` 項目不需處理。

### Step 2 — 逐篇 review

對清單中**每一篇**筆記重複以下子步驟：

1. 讀取該筆記目前內容與完整 frontmatter `source:` 列表。
2. 對該筆記在 Step 1 中**被標記**的每一個 `source[]` 項目，分別執行：
   - **符號層級標記**（`符號 X (file:lines) — N 個新 commit`）：
     ```bash
     git -C $OK_WORKSPACE/<repo> log -p <commit>..HEAD -L<lines>:<file>
     ```
     （`<lines>` 與 `<file>` 取自 stale-notes.md 中列出的 `file:lines`）
   - **檔案層級標記**（`檔案層級 — N 個新 commit，涉及路徑: ...`）：
     ```bash
     git -C $OK_WORKSPACE/<repo> log -p <commit>..HEAD -- <paths...>
     ```
   閱讀實際的程式碼變動內容。
3. 判斷筆記內容是否仍正確：
   - **無需修改**：變動與筆記描述的內容無關（例如只是格式調整、無關函式的修改）。
   - **需要更新**：變動影響筆記描述的行為、參數、流程等，依變動內容修改筆記
     對應段落（例如「原理 / 細節」「常見問題」），保持原有格式與章節結構。
4. 無論該 `source[]` 項目的內容是否修改，都將**該項目自己的** `commit` 欄位
   更新為目前 `$OK_WORKSPACE` 下 `<repo>` 的 HEAD commit hash（`git -C
   $OK_WORKSPACE/<repo> rev-parse HEAD`）。

   **只更新被標記的 `source[]` 項目**，同一篇筆記中其他未被標記的項目
   （不同 repo 或不同 paths/symbols）保持原樣，不要連動更新其 `commit`。
5. 若任一 `source[]` 項目的 review 導致筆記內容有實質修改，記錄一句話摘要
   （供 Step 4 週報使用；一篇筆記只需一行摘要，即使有多個項目被修改）。

### Step 3 — 套用 save-note 的後續步驟

對於**內容有實質修改**的筆記，沿用 `/save-note` 的相關步驟：

- **Index 更新**：若筆記標題改變或新增了重要主題，更新所在分類的 `Index.md`
  條目說明（一般不需要，僅標題/重點明顯變化時才更新）。
- **雙向連結**：若修改內容新增了對其他筆記的 `[[連結]]`，到那些筆記補上回連。

僅更新 `source[]` 項目的 `commit`、未修改內容的筆記，跳過 Index/雙向連結。

### Step 4 — 更新週報

對於**內容有實質修改**的筆記，在 `$VAULT/06-Weekly/YYYY-WNN.md`
（`YYYY-WNN` 為今天的 ISO 週次）的「本週紀錄」區段追加一行：

```
- YYYY-MM-DD [[筆記路徑（不含 .md）]] — 因應 opsis-ws 程式碼變動更新：<一句話摘要>
```

檔案不存在則先建立（格式同 `/save-note` Step 9）。

### Step 5 — 清空 stale 清單

所有項目處理完成後，將 `$VAULT/05-Inbox/stale-notes.md` 內容改為：

```markdown
# Stale Notes — 程式碼變動待 Review

（目前沒有需要 review 的筆記）
```

### Step 6 — Git commit

```bash
cd $VAULT
git add -A
git commit -m "sync: 因應 opsis-ws 程式碼變動更新筆記（<N> 篇）"
```

dubious ownership / vboxsf 權限問題的處理方式與 `/save-note` Step 10 相同。

### Step 7 — 回報結果

告訴使用者：
- 處理了幾篇 stale 筆記，各自是否有實質內容修改
- 內容修改的筆記列表與一句話摘要
- 僅更新 `source[]` 項目 `commit`（內容無需修改）的筆記列表
- 週報追加的摘要行
- git commit 結果（commit hash 或失敗原因）

## 排程建議

`opsis-knowledge-staleness-check.sh` 需要存取本機 git repo，建議用系統
crontab（而非雲端排程）每天執行一次，例如：

```cron
0 8 * * * /usr/bin/bash /home/allen/.claude/scripts/opsis-knowledge-staleness-check.sh >> /tmp/opsis-knowledge-staleness.log 2>&1
```

加入 crontab：`crontab -e`，貼上以上一行後存檔。腳本只會更新
`$VAULT/05-Inbox/stale-notes.md`，不會自動修改筆記內容——實際 review/更新
仍由使用者執行 `/sync-opsis-knowledge` 觸發。
