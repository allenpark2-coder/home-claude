將目前對話的工作背景（目前進度／結論／下一步）整理成簡短摘要，存到目標 vault 的
`05-Inbox/recent-context.md`（每次覆寫），供下次開 session 時快速接續脈絡。

這是「暫存便利貼」，不是正式筆記；若是有長期保存價值的設計決策/計畫，請用
`/save-note` 或 `/save-plan`。

## 執行步驟

### Step 0 — 判斷目標 vault（沿用 `/save-note` Step 0）

讀取 `~/.claude/opsis-knowledge.config`，取得 `OK_WORKSPACE`、
`OK_PROJECT_VAULT`、`OK_GENERAL_VAULT`。

依目前工作目錄/對話內容判斷 `$VAULT`：

- 工作目錄在 `$OK_WORKSPACE` 之下，或對話內容是關於該工作區下子 repo
  （例如 `manifest/`、`opsis/`、`buildroot/`、`.claude-config/`）的程式碼/
  設計/進度 → `$VAULT = $OK_PROJECT_VAULT`
- 其他情況 → `$VAULT = $OK_GENERAL_VAULT`
- 使用者可在指令中明確覆寫

### Step 1 — 整理摘要

把目前對話狀態整理成以下格式：

```markdown
---
updated: YYYY-MM-DD HH:MM
---

## 目前進度
（這次 session 做到哪裡、做了什麼）

## 結論
（已經確定/完成的事項）

## 下一步
（接下來要做什麼、還沒解決的問題）
```

- `updated` 使用目前時間
- 內容力求簡短（幾句話到一個條列清單即可），重點是「下次接續時看得懂」，不是
  完整記錄

### Step 2 — 寫入檔案

覆寫 `$VAULT/05-Inbox/recent-context.md`（每次執行都是覆寫整份檔案，不是追加）。

### Step 3 — 回報結果

告訴使用者已存到 `$VAULT/05-Inbox/recent-context.md`，並簡單列出寫入的「下一步」
內容，方便確認摘要抓得對不對。
