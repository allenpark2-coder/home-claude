# Pipeline Trace — Output Document Templates

Section structures derived from `oryx_v2/VIDEO_PIPELINE_SOP.md` and
`oryx_v2/VIDEO_PIPELINE_AGENT_MAP.md`. Adapt headings to the subsystem; keep
the overall shape.

---

## `<SUBSYSTEM>_PIPELINE_SOP.md` (human-facing)

Default language: match the user's conversation language.

```markdown
# <Subsystem> Pipeline SOP: <input boundary> -> <output boundary>

> 範圍 / Scope: ...
> 適用 SDK: ...
> agent 導覽版本: <SUBSYSTEM>_PIPELINE_AGENT_MAP.md
> (若有) 特殊限制筆記: NOTES_<topic>.md

## 1. 整體架構總覽
ASCII diagram of the full pipeline, stage by stage, annotated with the
copy/zero-copy semantics at each arrow.

## 2. 各階段說明與健康檢查
For each stage from Q1-Q10:
- 做什麼 (what it does, 1-3 sentences)
- 如何確認正常 (concrete checks: log strings, states, commands)
- 常見問題 (common failure modes seen for this stage)

## 3. 執行緒模型一覽
Table: 元件 | 執行緒/entry point | 數量

## 4. 常見故障排查 SOP
Symptom-based troubleshooting flows (A/B/C/...), each a numbered checklist
referencing the stages above.

## 5. 延伸閱讀
Cross-links to NOTES_*.md, AGENT_MAP, and any related *_PIPELINE_SOP.md.
```

---

## `<SUBSYSTEM>_PIPELINE_AGENT_MAP.md` (agent-facing)

Default language: English (technical/code-symbol heavy), terse, table-first.

```markdown
# <Subsystem> Pipeline Code Map (<input boundary> -> <output boundary>)

> Scope: ...
> Human/operator version: <SUBSYSTEM>_PIPELINE_SOP.md
> (if any) NOTES_<topic>.md
>
> This is a starting index. Re-verify file:line via codegraph_explore before
> relying on it for an edit — line numbers drift.

## Stage table
| # | Stage | Primary file(s) | Key symbols | Data structure | Copy semantics |
|---|---|---|---|---|---|
... one row per Q1-Q10 stage (and any sub-stages) ...

## End-to-end call chain
Pseudocode-style call chain, annotated with [stage N] markers, mirroring the
stage table order.

## Thread model
| Thread | Owner | Entry point |
|---|---|---|

## Key invariants / gotchas (check before editing)
Numbered list. Each item: the constraint, where it's enforced
(file:line/symbol), and what NOT to do without re-checking it.

## Task -> where to look
| If asked to... | Start here |
|---|---|
Forward-looking table of likely future tasks for this subsystem and their
entry points.
```

---

## `NOTES_<topic>.md` (optional, for major gotchas)

Only create when Step 1/2 surfaces something that:
- contradicts a reasonable prior assumption (e.g. "this struct field exists"
  when it doesn't on this SDK/platform combination), AND
- is likely to matter again in a *different* future task, not just this
  trace.

Structure (see `NOTES_iav_dma_buf_support.md` for a worked example):

```markdown
# <Topic> — <one-line conclusion>

## 結論 / Conclusion
The fact, with file:line evidence.

## 緣由 / Why this came up
What task surfaced this, and what assumption it broke.

## 之後若 ... / How to apply
Concrete guidance for future designs that touch this area.
```

If this also seems durable enough to matter in *future conversations* (not
just future edits to this codebase), consider saving it as a memory per the
project's CLAUDE.md memory instructions, in addition to the file.
