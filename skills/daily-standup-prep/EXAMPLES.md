# daily-standup-prep — Examples

Maps PowerShell invocations of `Get-Standup-Report.ps1` to skill invocations.

## Default — single team, 2-day window

```powershell
.\Get-Standup-Report.ps1
```

```text
/daily-standup-prep
```

Both produce a Pyrite standup with the last 2 days of Jira, Git, GitLab, Confluence activity, written to `<vault>\Scrum Teams\Pyrite\Scrum 📅\INC 25\Sprint 1\YYYY-MM-DD.md`.

## Single team, longer window

```powershell
.\Get-Standup-Report.ps1 -Teams "Onyx" -DaysToLookBack 3
```

```text
/daily-standup-prep Onyx --days 3
```

## Multi-team

```powershell
.\Get-Standup-Report.ps1 -Teams "Pyrite","Onyx" -DaysToLookBack 3
```

```text
/daily-standup-prep Pyrite,Onyx --days 3
```

Generates two files (one per team). Talking-order lines include ` (Onyx)` / ` (Pyrite)` suffixes after the wikilink.

## Specific increment / sprint

```powershell
.\Get-Standup-Report.ps1 -DaysToLookBack 1 -Teams "Onyx" -Inc 26 -Sprint 4
```

```text
/daily-standup-prep Onyx --days 1 --inc 26 --sprint 4
```

## Section toggles

```powershell
.\Get-Standup-Report.ps1 -IncludeJiraIssues:$false -IncludeGitCommits
```

```text
/daily-standup-prep --no-jira
```

```powershell
.\Get-Standup-Report.ps1 -Teams "Pyrite" -IncludeConfluenceActivity:$false -IncludeGitLabActivity:$false
```

```text
/daily-standup-prep Pyrite --no-confluence --no-gitlab
```

## Custom JQL

```powershell
.\Get-Standup-Report.ps1 -JQL "project = SC2 AND assignee = currentUser() AND updated >= -3d"
```

```text
/daily-standup-prep --jql "project = SC2 AND assignee = currentUser() AND updated >= -3d"
```

When `--jql` is provided, it overrides the auto-built JQL but `DaysToLookBack` still drives the Git, GitLab, and Confluence cutoffs.

## Custom Git repo

```powershell
.\Get-Standup-Report.ps1 -Teams "Pyrite" -GitRepoPath "D:\projects\my-repo"
```

```text
/daily-standup-prep Pyrite --git-repo "D:\projects\my-repo"
```

## First-run bootstrap

The first time you run the skill it will prompt for any missing memory values:

1. **GitLab base URL** — recommended `https://gdgitlab01.gd-ms.us` (the PS-script default). Saved to `reference_gitlab_config.md`.
2. **GitLab `bessemer` group key** — recommended `bessemer`. Saved as a row in the same memory.
3. **Roster CSVs** — for each team you ask for that has no roster at `{{vault_root}}\Scrum Teams\_rosters\<Team>.csv`, the skill offers to copy from `D:\powershell-scripting\src\bin\Teams\<Team>.csv`. Accept once, then maintain the CSV from the vault going forward.

After the first run, subsequent invocations skip every prompt and run silently.
