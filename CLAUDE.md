# graphify
- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else.

# home-claude config repo
`~/.claude` is a git repo (origin `git@github.com:allenpark2-coder/home-claude.git`, branch
`main`, SSH auth). Tracked paths: `commands/`, `skills/` (non-symlink entries), `CLAUDE.md`,
`settings.json`, `statusline.sh` (everything else is gitignored). Whenever any of these are
created or edited, offer to commit + push (with a commit message describing the change) —
do not auto-commit without asking.
