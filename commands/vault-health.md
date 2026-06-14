對 `Opsis_Knowledge` 與 `Obsidian_Knowledge` 兩個 vault 執行保管庫健康檢查，找出
孤立頁面（沒有任何 `[[連結]]` 指向的筆記）與斷鏈（`[[連結]]` 指向不存在的筆記），
並整理成摘要回報。純檢查，不會自動修改任何筆記。

## 執行步驟

### Step 1 — 執行健康檢查腳本

讀取 `~/.claude/opsis-knowledge.config`，取得 `OK_PROJECT_VAULT`、
`OK_GENERAL_VAULT`，對兩個 vault 各執行一次：

```bash
python3 ~/.claude/scripts/opsis-knowledge-vault-health-check.sh $OK_PROJECT_VAULT
python3 ~/.claude/scripts/opsis-knowledge-vault-health-check.sh $OK_GENERAL_VAULT
```

腳本會覆寫各自的 `05-Inbox/vault-health.md`。

### Step 2 — 讀取報告並整理摘要

讀取兩份 `05-Inbox/vault-health.md`，向使用者回報：

- 各 vault 的孤立頁面數量與清單（保留 `[[連結]]` 形式，方便在 Obsidian 中點擊）
- 各 vault 的斷鏈數量與清單（來源筆記 → 斷掉的連結文字）
- 若某 vault 兩者皆無，回報「<vault 名稱>：目前沒有發現孤立頁面或斷鏈」

### Step 3 — （視情況）後續動作

本指令只回報，不自動修改筆記。若使用者接著要求修正特定項目（例如把孤立頁面加進
對應 Index、或修正/移除斷鏈連結），再依使用者指示個別處理；不要主動大量修改筆記。
