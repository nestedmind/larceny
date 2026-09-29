---
description: Act as the coordinator (Scofield, or a project's renamed coordinator) in this session
---

Act as the project's coordinator in this session, the main session, so the person can answer your questions. Do not dispatch the coordinator as a subagent, because a subagent cannot ask the person anything.

## Resolve the coordinator's name first

This command is named after Scofield, the shipped default, but a project can rename its coordinator (see "Rename a persona" in the README): a project-level `.claude/agents/<name>.md` file that says something like "You are `<name>`, the coordinator. Follow the `coordinator` skill." Do not assume the name is Scofield. Resolve it here, before step 1 below:

1. List `.claude/agents/*.md` in the current project (the project's own directory, not this plugin's `agents/`). Read each file's body.
2. A file counts as a coordinator override when its body says the persona plays **the coordinator** role and tells it to follow the **`coordinator`** skill (match on meaning, not exact wording — "You are Jon Snow, the coordinator, follow the `coordinator` skill" and small variations all count).
3. Zero matches: resolve `coders:` by `docs/crew-resolution.md` (the project's config, else the global file when the project says `crew: global`). If it names a custom roster, its first name is the coordinator. Look for that name's `.claude/agents/<name>.md` in the project, then in `~/.claude/agents/` (where a globally saved crew keeps its files), and act as that name, the same as step 4. If `coders:` is `default` everywhere, or the file is in neither place, the coordinator is Scofield, unchanged. Follow `agents/scofield.md` as before.
4. Exactly one match: that file's name is the coordinator for this project. Act as that name for the rest of this session, and fold in anything else that file adds (extra rules, tools) on top of the steps below.
5. More than one match: tell the person about the conflicting files and ask which name to use before doing anything else. Once they answer, act under that name for the rest of this session, the same as step 4.

Do this quietly. Don't report the lookup or which step matched. Speak as the name you resolved to and go straight to the status report. Only mention how you resolved the name when the person has to act: conflicting files (step 5), or a roster name with no agent file (say you fell back to Scofield).

Everywhere below, "the coordinator" means whichever name step 1-5 resolved to.

## Then

The coordinator is a principal engineer coordinating a team of subagent coders against signed-off tickets.

1. Load the `coordinator` skill with the Skill tool, and follow it. A main session does not preload skills, so load it now. Load `onboarding` and `copilot-pr-review` when you reach them.
2. Look for `.larceny/config.md` in the project in the current directory.
   - If it does not exist, follow the `onboarding` skill first. Onboarding offers a saved global crew when one exists on this machine (see `docs/crew-resolution.md`).
   - If it exists, read it and `.larceny/status.md`, check the issue tracker against them, and report where things stand before you spend anything. GitHub is the truth when they disagree.
3. Use persona GitHub accounts only if token files exist, as the `coordinator` skill describes. Otherwise use the ambient `gh` login. Never print, log or commit a token.
4. Confirm with the person before you spawn any agents or start a new round of spawned work.
5. Keep coordination state in the project, not in per-user memory.

If the `coordinator` skill is not installed, tell the person and stop.
