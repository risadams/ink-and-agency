# Host portability

These skills are written to run on any agent host — Claude Code, OpenAI Codex, opencode. Instruction bodies use Claude Code's tool vocabulary; on other hosts, map by **intent**:

| In the skill text | Meaning on any host |
| :--- | :--- |
| `AskUserQuestion` | Ask the user interactively by whatever means the host provides. If the session is non-interactive, use the skill's documented fallback; if there is none, pick the safest/least-destructive option and say so in the output. |
| `Read` / `Write` / `Edit` / `Glob` / `Grep` | The host's file read/write/search capabilities. |
| `Skill` tool, `/skill-name` | Invoke the named skill. On Codex: `$skill-name`. |
| `disable-model-invocation: true` (frontmatter) | The skill is **user-invoked only** — the model must not reach for it autonomously; the human triggers it by name. On Codex this is carried by `policy.allow_implicit_invocation: false` in the skill's generated `agents/openai.yaml`. On a host with no such control, treat the skill as manual: don't auto-invoke it. |
| `Agent:` blocks, "invoke the `<name>` agent" | Spawn the named subagent if the host supports it (Codex: agents installed from `.codex/agents/`). If subagents are unavailable, adopt that agent's persona and instructions inline in the current session and continue — do not fail the skill. |
| Memory files (`~/.claude/projects/**/memory/*.md`) | The host's persistent-notes mechanism. If the host has none, ask the user for the value and suggest they record it in the project. |
| `/loop`, `loop-eligible`, `recurrence-hint` | Claude Code recurring-execution machinery. On other hosts, treat as documentation of how often the skill is typically run. |
| `${CLAUDE_PLUGIN_ROOT}` | The plugin's install root (avoid in new content — prefer paths relative to the skill folder). |

Frontmatter fields beyond `name` and `description` (`allowed-tools`, `related-skills`, `related-agents`, `loop-eligible`, `compatibility`, `codex-short-description`) are advisory metadata; hosts that don't understand them ignore them.

**Codex artifacts are generated, not hand-written.** Each skill's `agents/openai.yaml` (Codex picker metadata + invocation policy) is derived from its `SKILL.md` frontmatter by `scripts/convert-agents-to-codex.ps1`. Edit the frontmatter, never the yaml. See [AGENTS.md](../AGENTS.md#skill-invocation-across-hosts) for the full model.
