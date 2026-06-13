---
name: pipeline-trace
description: "Use when the user wants to systematically trace and document a hardware/data pipeline (video, audio, storage, network, or any other subsystem) inside an unfamiliar SDK/codebase, producing a human-readable SOP doc and an agent-oriented code map doc. Trigger phrases: \"trace一下這個SDK的XXX流程\", \"幫我整理XXX pipeline文檔\", \"用pipeline-trace分析...\", \"/pipeline-trace <subsystem>\"."
trigger: /pipeline-trace
---

# /pipeline-trace

Systematically trace a "data pipeline" subsystem (video, audio, storage,
network, sensor, etc.) end-to-end inside an SDK/codebase, and produce
durable documentation: a human SOP doc + an agent code-map doc (and an
optional NOTES_*.md for any major gotcha discovered).

This skill is the generalized form of a methodology developed while tracing
the video-to-network pipeline of an Ambarella SDK
(`oryx_v2/VIDEO_PIPELINE_SOP.md`, `VIDEO_PIPELINE_AGENT_MAP.md`,
`NOTES_iav_dma_buf_support.md`, `video流程trace.md`). Those files are good
worked examples if they exist in the current repo or a sibling project.

## Usage

```
/pipeline-trace <subsystem>            # e.g. /pipeline-trace audio
/pipeline-trace <subsystem> <path>     # target SDK dir, if not current dir
```

If `<subsystem>` is missing, ask the user what subsystem to trace (video /
audio / storage / network / other) and the input/output endpoints they care
about (e.g. "audio: from mic capture to RTSP" or "storage: from encoded
packet to MP4 file on SD card").

## Step 0 — Confirm scope

- Subsystem name and target codebase path.
- Input boundary and output boundary (where does this pipeline "start" and
  "end"?). Ask the user if unclear — don't guess for an unfamiliar SDK.
- Output filenames: default to `<SUBSYSTEM>_PIPELINE_SOP.md` and
  `<SUBSYSTEM>_PIPELINE_AGENT_MAP.md` in the project root, unless the repo
  already has a naming convention from a prior trace (match it, e.g.
  `VIDEO_PIPELINE_SOP.md` → `AUDIO_PIPELINE_SOP.md`).

## Step 1 — Q0: codegraph architecture scan

Use the `mcp__codegraph__*` tools (codegraph MCP server,
github.com/colbymchenry/codegraph) as the primary exploration tool:

1. `codegraph_status` — confirm the target codebase is indexed. If not,
   tell the user to run codegraph init on it first (don't do this silently
   for a path outside the current project without asking).
2. `codegraph_explore` with broad natural-language queries to map the
   subsystem, e.g.:
   - "{subsystem} pipeline architecture from {input boundary} to {output boundary}"
   - "{subsystem} buffer / memory / zero-copy mechanism"
   - "{subsystem} output protocol or storage format implementation"
3. From the scan, identify:
   - This SDK's naming conventions / module structure for this subsystem
     (so Q1-Q10 below can be asked with concrete names instead of generic
     terms).
   - Any subsystem-specific gotchas not covered by the generic questions
     (e.g. the dma_buf_fd platform-version limitation found for video) —
     these become extra questions on top of the standard 10.

## Step 2 — Ask the trace questions

Read `references/trace_questions.md` for the generalized 10-question
template (Q1-Q10) plus guidance on adapting each question's wording to the
subsystem and the concrete module names found in Step 1. Add any
SDK-specific questions discovered in Step 1.

Answer each question via `codegraph_explore` (and targeted `Read` only when
codegraph doesn't cover a needed line range). For each answer, capture:
- file:line references for key functions/structs
- data structures involved and their copy/zero-copy semantics
- thread ownership

## Step 3 — Produce the documents

Read `references/output_templates.md` for the SOP and agent-map document
structures (section layout derived from the video pipeline docs). Write:

1. `<SUBSYSTEM>_PIPELINE_SOP.md` — human-facing, default to the user's
   conversation language. Architecture diagram, per-stage description +
   health checks, thread table, troubleshooting-by-symptom section.
2. `<SUBSYSTEM>_PIPELINE_AGENT_MAP.md` — agent-facing, terse, table-heavy,
   English symbol/file names. Stage table, call chains, thread table, key
   invariants/gotchas, task→file index.
3. If Step 1/2 surfaced a major durable finding (a hard platform limitation,
   a wrong assumption likely to recur), write a focused
   `NOTES_<topic>.md` like `NOTES_iav_dma_buf_support.md`, and consider
   saving it as a memory too (see CLAUDE.md memory instructions) since it's
   a project-level fact that outlives this one trace.

Cross-link: each new doc should link to the others, and to any existing
`*_PIPELINE_SOP.md` / `*_PIPELINE_AGENT_MAP.md` / `NOTES_*.md` /
`video流程trace.md`-style trace files already in the repo.

## Step 4 — Retro: keep the template alive

After producing the docs, briefly note (to the user, not in the output
docs) whether any of the 10 questions in `references/trace_questions.md`
needed significant rewording for this subsystem, or whether a new
generally-useful question emerged. If the user agrees it's broadly useful
(not just specific to this one trace), update
`references/trace_questions.md` so the next `/pipeline-trace` run benefits.
Don't update it for one-off, subsystem-specific findings — those belong in
the per-trace NOTES file instead.
