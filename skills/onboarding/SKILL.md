---
name: onboarding
description: Use when the person runs the plugin for the first time in a project, asks to set up or onboard the team, or asks to change their onboarding answers. Also use when the project has no .larceny/config.md.
---

# Onboarding

The coordinator (Scofield in the example team) meets the person and sets the team up for one project. It needs one ordinary GitHub login. Persona accounts and tokens are an optional upgrade at the end.

Project answers are stored in the project, in `.larceny/`. The one exception is a crew the person chooses to save for every project on this machine (step 9). Do not store answers in per-user memory, and do not edit the project's own `CLAUDE.md`. Reading it is enough.

## Files

- `.larceny/config.md`: the person's answers and the project's commands (format below).
- `global-config.md` in `~/.config/larceny/` (or `LARCENY_CONFIG_DIR`), optional and per machine: the person-level and crew-level keys saved as this machine's default crew. How the two files combine is `docs/crew-resolution.md`, which every reader of those keys follows.
- `.larceny/status.md`: the ledger described in `planning-and-reporting` and the status file in `coordinator`. Create it empty, with the line `# Ledger: <project>`.

## Run it

1. **Look first.** If `.larceny/config.md` exists, this is a re-run: read it, show the person what it holds, and go to "Re-running". Otherwise continue.
2. **Check prerequisites.** Run `gh auth status`, `git rev-parse --show-toplevel` and `gh repo view`. For each failure say what is missing and the one command that fixes it (`gh auth login`, `git init`, `gh repo create` or a remote to add). Stop until the required ones pass: a `gh` login, a git repo and access to its GitHub repo. Write nothing before this passes.
3. **Introduce yourself, once, before asking anything.** Use your own resolved name (the coordinator's name for this project, not a hardcoded default) and say, briefly: who you are, that this is a first-time setup for this project, what happens next (a few quick questions, then reading the repo's conventions, then optional skippable steps), and that skipping every optional step still leaves a working team. Include a disclaimer, in your own words, covering: you and your crew are AI agents and can make mistakes, so the person should review and verify your work, especially before merging, tagging or releasing anything — for example, "My crew and I are AI agents — we make mistakes. Please review our work and verify anything important before accepting it, especially before merging, tagging or releasing." Three or four sentences is enough — this is orientation, not a sales pitch. Do this only on a first run; a re-run goes straight to "Re-running".
4. **Offer the saved crew, only when a global file exists.** Run `cat "${LARCENY_CONFIG_DIR:-$HOME/.config/larceny}/global-config.md"` (a shell resolves the variable; do not guess the directory); see `docs/crew-resolution.md`. If it is there, say a crew saved on this machine was found, show its names and models in a few lines, and ask one question: use it for this project (default), or set up a different crew just for this project.
   - **Use it** (or no answer): record `crew: global` in this project's config, and skip steps 5, 6, 7, 8 and 9. Ask no person question and no crew question (roster, renames, models). Go to step 10, which is inherently per-repo, then 11, 12 and 13.
   - **Different crew for this project**: record `crew: project` and continue with step 5. Whatever is answered from here on belongs to this project only, and step 9 does not apply.
   - No global file: skip this step and continue with step 5. Record no `crew:` line yet.
5. **Ask about the person, one question at a time.** Name to use, role (for example CTO, CEO, lead), how often they want reports, how long, and where (chat, an issue comment, a file). Offer a default for each. Do not ask more than these.
6. **Ask about the roster, one yes/no question.** "Want to name your own crew (coordinator and coders), or keep the default cast (Scofield, Sheba, Mahone, Sucre, Whip)?" Default answer is keep-as-is.
   - **No** (or no answer): record `coders: default` and ask nothing further about names. This is the common case, and it stays a single question.
   - **Yes**: name each role in turn, coordinator first, then each coder. For the coordinator, write the project-level override file described in README's "Rename a persona" (`.claude/agents/<name>.md`, "You are `<name>`, the coordinator. Follow the `coordinator` skill.") — the #70/#78 mechanism, unchanged by this step except for the skill's new name. For each renamed coder, write a thin project-level wrapper file `.claude/agents/<name>.md`: frontmatter with `name: <name>`, `isolation: worktree` (every shipped coder carries this; without it a dispatch runs against the coordinator's own checkout instead of an isolated worktree) and `skills: [coder, ...]` (mirror the skill list of the shipped coder it replaces), and a body reading "You are `<name>`, a coder. Follow the `coder` skill." plus the token file path if the project uses persona accounts. Record the chosen names, in dispatch order, as `coders:` in `.larceny/config.md`.
   - Before writing a chosen name, check it against the shipped default names and their `larceny:` forms (`larceny:sheba`, `larceny:mahone`, `larceny:sucre`, `larceny:whip`, `larceny:scofield`, `larceny:amy`, `larceny:yoda`, `larceny:sara`, `larceny:reviewer`, `larceny:advisor`, `larceny:teacher`, `larceny:coordinator`). If the chosen bare name matches or nearly matches one of those (for example choosing `sheba`, or a name that differs only by the `larceny:` prefix), warn the person once that a human picking an agent by name in the Agent-tool UI could still pick the shipped default by mistake, and point at README's "Rename a persona" section for the full explanation. This is a warning, not a block — record whatever name they confirm.
   - This gate does not hide the shipped default agents. They stay listed and dispatchable in the raw Agent-tool listing no matter what is chosen here (confirmed by #82) — only the coordinator's own dispatch calls, which read `coders:` from config, are guaranteed to use the replacement.
7. **Ask about the reviewer, advisor and teacher, one yes/no question.** "Want to rename the reviewer, advisor or teacher persona, or keep the default cast (Amy, Yoda, Sara)?" Default answer is keep-as-is. This is independent of the roster question in step 6: it can be skipped even when the roster was customized, and vice versa. Ask it before the model question in step 8, so a model override recorded there uses each persona's final name, not a shipped default that gets renamed a step later.
   - **No** (or no answer): record nothing (`reviewer:`, `advisor:` and `teacher:` are left unset, which behaves exactly like `default`). This is the common case, and it stays a single question.
   - **Yes**: ask which of the three to rename (one, two or all three), then the new name for each. For each renamed persona, write a project-level `.claude/agents/<name>.md` file: frontmatter with `name: <name>`, and a body that copies that persona's shipped founding prompt from `commands/spawn-reviewer.md`, `commands/spawn-advisor.md` or `commands/spawn-teacher.md` with the shipped name (Amy, Yoda or Sara) replaced by `<name>` in the opening `You are <name>, ...` line only. For a renamed advisor, also delete the sentence that begins "At most one sentence per reply may use Yoda's inverted word order", because it describes Yoda's voice and not the advisor role, and keep "Speak plainly." Record the chosen name in `.larceny/config.md` as `reviewer: <name>` (for a renamed Amy), `advisor: <name>` (for a renamed Yoda) or `teacher: <name>` (for a renamed Sara). Leave the other two roles unset if only one or two are renamed.
   - Run the same collision check as step 6's roster question, against the same shipped names and their `larceny:` forms, before recording a chosen name.
   - Each role's spawn command (`/larceny:spawn-reviewer`, `/larceny:spawn-advisor`, `/larceny:spawn-teacher`) reads the matching config key at spawn time and uses the override automatically; nothing else needs to change for the rename to take effect.
8. **Show the model table, one yes/no/customize question.** Show the recommended split:

   | Persona | Role | Model |
   |---|---|---|
   | Mahone / Sheba / Sucre / Whip | Coder | Sonnet |
   | Scofield | Coordinator | Opus |
   | Amy | Adversarial reviewer | Opus |
   | Sara | Teacher | Opus |
   | Yoda | Senior advisor | Fable |

   Say plainly why it matters: model choice drives cost, and the split above is a recommendation the shipped agents already carry, not a requirement. Ask: keep the recommended split, run every persona on the harness default model, or customize one or more personas.
   - **Keep the recommended split** (or no answer): record `models: default`. The shipped `agents/*.md` frontmatter and each persona's role-based spawn command already carry these models, so nothing further is needed.
   - **Harness default for everything**: record `models: harness-default`.
   - **Customize**: ask which persona(s) to override and with which model, one at a time, offering the harness's known model names. Record each as `<persona>: <model>` on its own indented line under `models:` in config. A persona not listed keeps the shipped default.
   - This is independent of the roster question in step 6 and the rename question in step 7: renaming a persona and picking its model are separate choices, and this step's answer is recorded under a separate `models:` key, never inside `coders:`, `reviewer:`, `advisor:` or `teacher:`. Use the final names from step 6 and step 7 (if any were changed there) as the persona names here — never a shipped default that step 6 or step 7 already replaced. This step runs after both naming steps specifically so there is only ever one name to key a model override against.
   - This covers every persona, not only coders dispatched by the coordinator: Sara, Yoda and Amy are started from their own role-based spawn commands, and both a ticket dispatch and that spawn path read `models:` the same way — see "Model overrides" in `docs/agent-lifecycle.md`.
9. **Offer to save the crew globally, once.** Ask only when all of these hold: no global file exists yet, this run customized something (a custom `coders:` roster, a renamed reviewer, advisor or teacher, or a `models:` choice other than `default`), and step 4 did not apply. Ask: save this as your default crew for every project on this machine, or keep it to this project.
   - **Save globally**: write `global-config.md` in `~/.config/larceny/` (or `LARCENY_CONFIG_DIR`; create the directory if needed) with `person:`, `role:`, `reports:` and each of `coders:`, `models:`, `reviewer:`, `advisor:`, `teacher:` that was set, in the config format below. Move each `.claude/agents/<name>.md` file written in steps 6 and 7 to the user-level `~/.claude/agents/<name>.md` instead, so any project that follows global finds it. Record only `crew: global` in this project, with none of those keys. Say the file is per machine and not synced, and that editing it changes every project that follows it.
   - **Keep it to this project** (or no answer): record `crew: project` and the keys as answered. Do not ask again on later runs.
10. **Read the project.** Read `CLAUDE.md`, the contributing notes, and the build files (`Makefile`, `package.json`, `pyproject.toml` and the like). Propose the test, lint and build commands you found and any rules that bind every ticket (branch names, commit style). Ask the person to confirm or correct. Record only what they confirm. If you cannot ask, or they do not answer, write the value with `(unconfirmed)` after it and ask again next run. If you find no command, record it as unset and say so.
11. **Write the config.** Write `.larceny/config.md` (for a project that follows the global crew, that is `crew: global` plus the project-only keys, and none of the crew keys), and create `.larceny/status.md` if it does not exist (see Files). Add `.larceny/` to the project's `.gitignore` unless it is already there. Tell the person it is ignored, and that they can commit the folder if they want the team to share it. Say that a coder's fresh worktree will not contain the folder, so the coordinator puts the commands and rules in each dispatch and review request.
12. **Offer the optional steps, each skippable, one at a time.** Say plainly that skipping all of them leaves a working team.
    - A project board, so tickets show a status. When the board exists, look up and record its IDs (see "Board IDs" below), so the coordinator never has to find them again.
    - A branch ruleset that requires a review before merge.
    - Persona accounts, using `docs/identity-wiring.md`. A person does the account steps there, so link it and move on.
    Record each answer as `done`, `skipped` or `later`.
13. **Report.** Say in a few lines what was written and where, which optional steps were skipped, and the next step: sign off a ticket and dispatch a coder.

Without persona accounts, the team runs under the one login. GitHub blocks approving your own pull request, so the reviewer states its verdict in a comment starting APPROVED or CHANGES REQUESTED, as the fallbacks in `coordinator` describe. Say this once during the optional steps.

## Config format

```
# Larceny config
crew: global | project
person: <name>
role: <role>
reports: <frequency>, <length>, <channel>
coders: default | <coordinator name>, <coder name>, <coder name>, ...
reviewer: default | <name>
advisor: default | <name>
teacher: default | <name>
models: default | harness-default
  <persona name>: <model>
test: <command or unset>
lint: <command or unset>
build: <command or unset>
rules: <one line per rule that binds every ticket>
board: done | skipped | later
  owner: <org or user>
  project-number: <n>
  project-id: <PVT_... node id>
  status-field-id: <PVTSSF_... id>
  status-options: <Backlog>=<id>, <Ready>=<id>, <In progress>=<id>, <In review>=<id>, <Done>=<id>
ruleset: done | skipped | later
identities: done | skipped | later
```

`crew:` records whether the project follows the machine's global crew. `crew: global` means it does: the person-level and crew-level keys below are left out of this file (or overridden individually by writing one here) and resolve through `docs/crew-resolution.md`. `crew: project`, or no `crew:` line, means the project's own keys are the crew and the global file is not read. A project with `crew: global` and no other crew keys is different from a project with no `crew:` line and no keys: the first follows the global crew, the second runs the shipped defaults.

The global file has the same format, with only `person`, `role`, `reports`, `coders`, `models`, `reviewer`, `advisor` and `teacher`. The other keys (`test`, `lint`, `build`, `rules`, `board` and its IDs, `ruleset`, `identities`) describe one repo, so they live in the project file only.

`coders: default` means the shipped cast (Scofield, Sheba, Mahone, Sucre, Whip). A customized roster lists the coordinator's name first, then each coder's name, in the order the `coordinator` skill should dispatch them — not the shipped names they replace.

`reviewer:`, `advisor:` and `teacher:` each default to `default` (or the key missing), meaning the shipped persona (Amy, Yoda, Sara). A renamed persona's own name goes here instead — not the shipped name it replaces — and its founding prompt lives in a project-level `.claude/agents/<name>.md` file (see "Renaming the reviewer, advisor or teacher" in the README). These three keys are independent of `coders:` and of each other: renaming the reviewer does not require renaming the advisor or teacher.

`models: default` means the recommended split already baked into the shipped `agents/*.md` frontmatter and each persona's own role-based spawn command (coders on Sonnet, coordinator and reviewer on Opus, Sara on Opus, Yoda on Fable) — record nothing further. `models: harness-default` means every persona runs on whatever model the harness defaults to when none is specified; no explicit `model` is passed at spawn time for any persona, coder or otherwise. A customized choice keeps the `default` (or `harness-default`) line as the baseline and adds one indented `<persona name>: <model>` line per overridden persona, keyed by that persona's final name — the name in `coders:`, `reviewer:`, `advisor:` or `teacher:` if it was renamed, or the shipped default name otherwise. This is exactly why onboarding asks the roster and rename questions (steps 6 and 7) before this one: every persona already has its final name by the time a model override is recorded, so there is only ever one name to key it against. Every spawn path — a coder dispatch, a persistent persona's own spawn command, and the auto-spawn path in `docs/agent-lifecycle.md` — reads these and passes that persona's `model` as an explicit override at spawn time, taking precedence over the shipped default. A persona with no override line keeps the baseline for that mode. See "Model overrides" in `docs/agent-lifecycle.md` for the full mechanism.

If you rename a persona (`coders:`, `reviewer:`, `advisor:` or `teacher:`) after already recording a `models:` override for its old, shipped name, re-key that override line to the new name yourself — nothing does this automatically, since the two keys are independent and a re-run does not infer the connection between them.

### Board IDs

The indented `board:` keys are written only when `board: done`. Look them up with:

```
gh project list --owner <owner> --format json
gh project field-list <n> --owner <owner> --format json
gh project view <n> --owner <owner> --format json
```

`field-list` gives the Status field id and one option id per status; `view` gives the project node id. Record every option the board has, each as `<name as the board spells it>=<id>`, and at least In progress, In review and Done. The five names in the format above are only an example. If the board lacks a status (a board with no Backlog or Ready column, say), leave that name out of `status-options:`; do not write a placeholder or an empty id. If the board lacks In progress, In review or Done, say so, record what exists, and tell the person the coordinator cannot move cards to the missing status until they add it. The per-ticket item id is not recorded here; the coordinator finds it at dispatch (see `coordinator`).

## Re-running

- Never overwrite an answer without asking. Show the current value beside the new one and ask before each change.
- A partly finished run resumes at the first missing key. Do not ask again for keys that hold a value.
- Offer again every optional step recorded as `later`, one at a time, before you report. Keep `done` and `skipped` as they are. Record the new answer over `later`.
- A project with `board: done` and no `owner:`, `project-number:`, `project-id:`, `status-field-id:` or `status-options:` keys was onboarded before those keys existed. Offer to look them up and record them (see "Board IDs"), instead of leaving the gap.
- If `crew: global` and the global file is missing or unreadable, say so and say the shipped defaults apply until it returns. Do not treat that as a missing answer and do not re-ask the crew questions.
- Re-check prerequisites every time. They cost nothing.
- Change only the keys the person named. Leave the rest.
- A project with `crew: global` shows the resolved values and where each came from (project or global, per `docs/crew-resolution.md`). To change the crew, ask whether the change is for every project on this machine (edit `global-config.md`, and say every following project changes) or for this project only (write the keys here and set `crew: project` when all of them are overridden, or write only the one key to override it and keep `crew: global`).
- A project with no `crew:` line was onboarded before the global file existed. Leave it alone. Do not ask about global on its account unless the person asks to switch it to the global crew (write `crew: global` and remove the crew keys they agree to drop).

## Red flags

Stop and correct yourself if you catch these.

| Thought | Reality |
|---|---|
| "I'll save this to memory so it carries over." | Memory is per user and per machine. The project config travels with the project. |
| "The project's CLAUDE.md is the natural place." | It belongs to the project. Write `.larceny/` only. |
| "They said they are in a hurry, so I'll assume the commands." | Ask once, and record only what they confirm. |
| "They said the new role, so I'll just update it." | Show the old and new values and ask. |
| "I'll skip the gh check, it is probably fine." | A missing login fails later and worse. Check first. |
| "A global crew exists, so I'll copy its values into this project's config." | That freezes them. Record `crew: global` and no crew keys, so later edits to the global file reach the project. |
| "Personas need accounts and tokens." | They do not. Never make them a requirement. |
| "They didn't answer the roster question, so I'll ask again to be sure." | No answer means keep-as-is. Record `coders: default` and move on; do not turn one question into a naming interview. |
| "A custom coder name hides the shipped default." | It does not, and never will while the plugin is installed (#82). Only the coordinator's own dispatch is guaranteed to use the replacement. |
| "The roster question in step 6 already covers the reviewer, advisor and teacher." | It does not. That question renames the coordinator and coders only. Renaming the reviewer, advisor or teacher is a separate question, step 7. |
| "They're renaming a persona that already has a `models:` override, I'll leave the old override line as it is." | The override is keyed by name. Re-key it to the new name yourself, or the spawn command will silently fall back to the baseline model instead of the override the person chose. |
