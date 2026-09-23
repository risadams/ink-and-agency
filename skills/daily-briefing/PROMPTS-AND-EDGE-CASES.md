# Daily Briefing — Prompts and Edge Cases

Read the section you need when [SKILL.md](SKILL.md) points here: a carry-over item needs the user's
call, a dashboard base is missing, or the run hits an edge case.

## Phantom carry-over prompt

**Phantom prompt (raised by Phase C):** *"`{{title}}` has been carried as `- [ ]` for {{age}} consecutive daily notes and there's no fresh email/Jira/MR/calendar signal for it in the current briefing window. Most likely this is a phantom — already done, cancelled, or never actionable. Close it?"* Options: `Close as done (mark [x] in all prior carrying notes + suppress today + add to feedback memory)`, `Close as cancelled (same + add one-line reason)`, `Keep — I'm actively working it offline (render today, suppress phantom check for 3 days)`, `Defer to date (free text — suppress until then)`.

**Non-interactive fallback:** if `AskUserQuestion` is unavailable, default to `Close as cancelled` for `age ≥ 5 + no fresh signal` (the strongest phantom signal), and to `Keep` for `age 3-4 + no fresh signal` (weaker signal — favor false-positive carryover over silent suppression). Always surface the auto-decision in the executive summary so the user can reverse it.

**Memory write on close.** When the user picks `Close as done` or `Close as cancelled`, write a `feedback` memory in the format of `feedback_PRJ_12345_resolved.md` so the next briefing has a hard suppression backstop even if the original Outlook signal that spawned the item re-fires. Memory name pattern: `feedback_<kebab-case-normalized-signature>_resolved.md`.

## Stale carry-over prompt (age ≥ 3)

**Stale carryover rule (applies to `Carrying over (still open)`):** for each `- [ ]` item being carried over that **survived the phantom-carryover guard** (i.e., was not closed in Phase C), apply the age band logic below. Re-use the `age` value computed in Phase A — do not re-scan.

1. **Age 1–2** — render normally; let the existing overdue/badge logic apply.
2. **Age ≥ 3** — **prompt before rendering**. Raise an `AskUserQuestion` per stale item (batch into one multi-select question if 3+ items qualify): *"`{{normalized title}}` has been carried for {{age}} days. What now?"* Options: `Still doing it (keep)`, `Done — forgot to check (mark [x] in prior note + suppress today)`, `Cancel (mark [x] in prior note + suppress today + add a one-line note explaining why)`, `Defer to date (free text — render as deferred with new deadline, suppress until then)`.
3. **Apply the answer immediately**:
   - *Still doing it* — render today with no extra noise; **cap the visual escalation**: never render more than two warning emojis (e.g., `⚠️⚠️ OVERDUE (N+ days)`) regardless of age. The emoji-wall escalation pattern (`⚠⚠⚠⚠ ... 🚨🚨🚨`) is explicitly forbidden — it stops being signal and starts being noise after day 3.
   - *Done* — `Edit` **every** prior daily note within the 14-day age scan window where the item carried as `- [ ]`, flipping each occurrence to `- [x]`. The phantom guard's 7-day dedup scan reads multiple prior notes, so flipping only the most recent leaves the item visible in older notes and lets it re-spawn from there. Suppress in today's carryover. Print the count of files edited.
   - *Cancel* — same as Done but additionally append ` _(cancelled: {{reason}})_` to the now-checked line in the **most recent** prior note only (one annotation is enough — the others are silent flips).
   - *Defer* — replace the carry-over with a single `- [ ] {{title}} — **deferred to YYYY-MM-DD**` and suppress until that date arrives.
4. If `AskUserQuestion` is unavailable (e.g., non-interactive run), fall back to rendering with the two-emoji cap and surface a warning in the executive summary: *"{{N}} stale carry-over items skipped age-3 prompt — re-run interactively to triage."*

## Missing dashboard bases

**Detect missing bases on every run.** Before saving the daily report:

1. `Glob` for each of the three `.base` files at `📅/`. Build a list of which are missing.
2. If any are missing, prompt the user via `AskUserQuestion`: *"The following dashboard bases are missing from the vault: {{list}}. Create them now? They power the embedded views in the daily/weekly/monthly reports."* Options: `Create all (recommended)`, `Skip — leave broken-link placeholders`, `Choose individually`.
3. For each base the user approves, invoke the `obsidian-bases` skill via `Skill` with the target path, scope (which notes the base filters), and the named views above. `obsidian-bases` is the canonical reference for `.base` YAML grammar — defer schema decisions to it rather than authoring inline. Cross-check the generated YAML against `obsidian-bases`'s troubleshooting section (Duration math, formula quoting) before writing.
4. If the user declines, leave the embed in place — creating the missing file later will fix the rendering automatically.

This check is cheap (3 `Glob` calls) and after the first-run accept, becomes a no-op on subsequent days. `TODO.md` is Dataview-managed by the user and is *not* auto-created here — surface its absence as a warning only.

## Edge cases

- **No emails / empty calendar:** still render the report with "Nothing to triage" / "Open day" — useful signal.
- **All-day events:** treat as context, not as schedule blockers (unless `busy_status="out_of_office"`).
- **Recurring meeting series:** count as one item in the briefing, not N.
- **Cancelled meetings:** call out separately so the user knows freed-up time.
- **No prior daily note found:** first run ever, or `📅/` is empty — fall back to the standard 24h window and tell the user.
- **Last note > 14 days ago:** long vacation / extended absence — cap the window at 14 days, generate the briefing, and warn the user that older items aren't included. Suggest searching email manually for anything time-sensitive from the gap period.
- **Today's note already exists (re-run same day):** treat the *prior* day's note as `last_run_date` (not today's) so the window doesn't collapse to zero. The "overwrite/append/skip" prompt for today's note still applies at save time.
- **Backfill briefing:** the daily note still saves to today's path only — one consolidated catch-up note, not one note per missing day. The window label and executive-summary callout make the multi-day scope explicit.
