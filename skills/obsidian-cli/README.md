# Obsidian CLI

Drive a running Obsidian instance from the shell. Read, create, append, search, and manage notes; manipulate properties, tasks, tags, and backlinks; and use the dev subcommands for plugin and theme development (reload, errors, screenshots, DOM/CSS inspection, JavaScript eval). Requires Obsidian to be open.

## Why this exists

A lot of Obsidian work — appending a task to today's daily note, finding all notes with a specific tag, bulk-setting a property — is repetitive and faster from the shell than from the GUI. The CLI exposes Obsidian's internals as commands; the skill knows the parameter conventions, the file-targeting rules, and the develop-test loop for plugins so you don't have to reread `obsidian help` every session.

## Triggers

Invoke this skill by:

- Saying any of these in chat:
  - "use the obsidian CLI to..."
  - "from the shell, append a task to today"
  - "search the vault for {keyword} via CLI"
  - "reload my Obsidian plugin and check for errors"
- Whenever shell-driven Obsidian operations are the natural fit

## What it does

The skill issues `obsidian` CLI commands against a running instance. It targets vaults (defaults to most-recently-focused; override with `vault=`), files (by wikilink-style `file=` or exact `path=`), and supports both parameters (`name=value`, quoted if spaces) and flags (boolean switches without values). For plugin development it knows the develop/test cycle: `plugin:reload`, `dev:errors`, `dev:screenshot`, `dev:console`, `eval`, `dev:dom`, `dev:css`. It does **not** start Obsidian if it's not running.

### Inputs

- **Command + parameters/flags** — free-form, mapping to `obsidian help` commands.
- **Optional `vault=`** — target a specific vault.
- **Optional `file=` or `path=`** — target a specific note.

### Outputs

- Command output (read commands return the requested content; write commands return success/failure).
- *Optional*: clipboard content via `--copy` flag on any command.

### External systems used

- Local Obsidian app (must be running)
- Local filesystem (read by Obsidian's vault index)

## How to use it

A typical session looks like this:

```text
You: append "Follow up on Atlas design" to today's daily note

Skill: obsidian daily:append content="- [ ] Follow up on Atlas design"
       Done.

You: search the vault for "rate limit" — limit 5 results

Skill: obsidian search query="rate limit" limit=5

       Returns:
       1. Projects/Atlas.md — "rate limit on the search endpoint"
       2. Architecture/API gateway.md — "default rate limit is 100/min"
       3. 2026-04-22.md — "discussed rate limit changes with Alex"
       4. Reading/Distributed Systems.md — "global rate limit pattern"
       5. Templates/Postmortem.md — "did the rate limit alert fire?"
```

## Getting the most out of it

- **Use `silent` to prevent files from opening.** By default, many commands open the affected file in Obsidian. Add `silent` when you're scripting and don't want windows popping up.
- **Use `--copy` for one-shot extraction.** Append `--copy` to any command and the output goes to clipboard instead of stdout. Faster than piping through `pbcopy`/`clip.exe`.
- **Use `path=` for ambiguous filenames.** When two notes share a title (`Index.md` in two folders), `file=` resolves arbitrarily. `path=folder/note.md` is unambiguous.
- **Run `obsidian help` first when you forget syntax.** The CLI's own help is more current than any external doc — including this README.

## Anti-patterns

What this skill will NOT do, or what to avoid:

- ❌ **Start Obsidian if it's not running.** The CLI requires a running instance. Open Obsidian first.
- ❌ **Operate on closed vaults.** Only the open vault (or the one named via `vault=` if open) is reachable. Closed vaults are invisible to the CLI.
- ❌ **Replace bulk-edit tools for very large operations.** Bulk-renaming 5,000 files is faster with shell + sed than via the CLI's per-file commands. Use the CLI for hundreds, not tens of thousands.
- ❌ **Skip the `dev:errors` check during plugin development.** A plugin can reload successfully and still throw runtime errors. Always check `dev:errors` after `plugin:reload`.

## Examples

### Example: Daily-note workflow

```bash
# Read today's daily note
obsidian daily:read

# Append a task
obsidian daily:append content="- [ ] Review Atlas design doc"

# List all open tasks for today
obsidian tasks daily todo

# Set a frontmatter property
obsidian property:set name="mood" value="focused" file="2026-05-12"
```

These four commands cover the most common daily-note operations end-to-end.

### Example: Plugin develop/test cycle

```bash
# After making code changes:
obsidian plugin:reload id=my-plugin

# Check for errors
obsidian dev:errors

# Visually verify with a screenshot
obsidian dev:screenshot path=screenshot.png

# Check console output for warnings
obsidian dev:console level=error

# Inspect a specific DOM element
obsidian dev:dom selector=".workspace-leaf-content[data-type='my-plugin-view']" text

# Inspect computed CSS
obsidian dev:css selector=".my-plugin-button" prop=background-color

# Run arbitrary code in app context
obsidian eval code="app.vault.getFiles().length"
```

The reload → errors → visual cycle catches most regressions before manual testing.

### Example: Targeting a specific vault

```bash
obsidian vault="research-vault" search query="experiment design" limit=10
```

When multiple vaults are open, `vault=<name>` must be the first parameter.

## Internals

The skill maps user requests to `obsidian` CLI invocations using these conventions:

**Parameters** (key=value):

- File targeting: `file=<wikilink-style-name>` or `path=<exact/path/from/vault/root.md>`
- Vault targeting: `vault=<vault-name>` (must be first if used)
- Content: `content="..."` (use `\n` and `\t` for newlines and tabs)
- Most others: per command

**Flags** (no value):

- `silent` — don't open the file in Obsidian
- `overwrite` — replace existing content
- `total` — return a count (on list commands)
- `--copy` — output to clipboard instead of stdout

**Common commands**:

- `read`, `create`, `append`, `search`
- `daily:read`, `daily:append`
- `property:set`, `property:get`
- `tasks <scope> <state>` (e.g., `tasks daily todo`)
- `tags sort=count counts`
- `backlinks file="..."`
- `dev:errors`, `dev:screenshot`, `dev:console`, `dev:dom`, `dev:css`, `dev:mobile`, `eval`

Develop/test cycle for plugins:

1. `plugin:reload id=...`
2. `dev:errors` — if errors, fix and repeat from 1.
3. `dev:screenshot path=...` or `dev:dom selector=... text` — visual verify.
4. `dev:console level=error` — check console for warnings.

## FAQ

**Q: Where do I install the CLI?**
A: It's a separate Obsidian project — see [help.obsidian.md/cli](https://help.obsidian.md/cli) for installation. Once installed, the binary `obsidian` is on your PATH.

**Q: Does it work if Obsidian is closed?**
A: No. The CLI talks to a running Obsidian instance. Open it first.

**Q: Can I script daily operations?**
A: Yes — the CLI is designed for it. Common pattern: a shell script that runs at login, calling `daily:append` for recurring tasks and `daily:read --copy` to put today's note on the clipboard.

**Q: How do I see all available commands?**
A: `obsidian help`. That output is always current; this README is not.

**Q: Why does my command target the wrong vault?**
A: Without `vault=`, it targets the most recently focused vault. If that's not what you want, prepend `vault=<name>` to every invocation.

## Related skills

- **[obsidian-vault](../obsidian-vault/)** — for shell-side vault operations using `find` and `grep` directly (no Obsidian process required).
- **[obsidian-markdown](../obsidian-markdown/)** — for the markdown syntax of notes that the CLI creates and modifies.
- **[obsidian-bases](../obsidian-bases/)** — when bulk-modifying property values, generate the CLI command pattern from a base view's results.

## Files

- **[SKILL.md](SKILL.md)** — Skill entry point (parameter/flag conventions, develop/test cycle)
