# Smoke test

This page checks that installing the plugin once gives a working team. Part 1 is automatic. Parts 2 to 4 need a person on a clean machine, and nothing in them is ticked until someone runs it. A box marked `[x]` was run and passed, and the note beside it says by whom and on what.

## Part 1: checks anyone can run

Run these from a clone of the repo. They passed on one Linux machine with Claude Code 2.1.278.

- [x] `scripts/check-agents.sh` prints `ok: agent definitions pass`. It checks that each of the eight named personas exists, that its name matches its file, that every skill in its `skills:` list exists under `skills/`, and that no agent file holds a home path, an account name or another persona's token path.
- [x] `claude plugin validate .` passes.
- [x] `claude -p --plugin-dir . "List the agent types whose name starts with larceny:"` lists `larceny:scofield`, `larceny:coordinator`, `larceny:amy`, `larceny:yoda`, `larceny:sara`, `larceny:reviewer`, `larceny:advisor`, `larceny:teacher`, `larceny:sucre`, `larceny:mahone`, `larceny:sheba` and `larceny:whip`.

## What was tested about the default agent and skill names

Tested with a throwaway plugin that used a unique agent name, so no user-level agent could hide the result. Version 2.1.278, headless (`claude -p`), from a directory outside the repo.

- A plugin `settings.json` containing `{"agent": "<name>"}` made the main thread run as that agent. It worked with the bare name.
- `claude --agent <name>` and `claude --agent larceny:<name>` both worked. The plugin's agents also appear as dispatch types under the `larceny:` prefix.
- `"agent": "larceny:<name>"` in a settings file passed with `--settings` worked.
- A subagent that lists `onboarding` in `skills:` received the skill body, and so did one that lists `larceny:onboarding`. The short names in the agent files resolve.
- A main-thread agent does not preload its `skills:` list. The skills appear in the session's skill list and load through the Skill tool, and the Skill tool accepted the short name `onboarding`. This is why `agents/scofield.md` tells Scofield to load its skills.

The coders set `isolation: worktree` in their frontmatter, and we did not dispatch one to see that the plugin honours it. Part 3 checks it. We also did not test a real install through `/plugin install`, a fresh terminal session, or any interactive UI. The plugin does not ship a `settings.json`, because making Scofield the default agent for everyone who installs is opt-in. See [the README](../README.md#run-scofield-as-the-main-session).

## Part 2: the clean machine (for the owner)

Use a machine, container or user account that has Claude Code and `gh` but no copy of this repo, no `~/.claude/agents/` files from this project, no `.larceny/` folder and no tokens.

- [ ] Add the marketplace and install: `/plugin marketplace add nestedmind/larceny`, then `/plugin install larceny@larceny`. Both succeed with no manual copying.
- [ ] Restart Claude Code and ask: "List the agent types you can dispatch whose names start with `larceny:`". The answer lists `larceny:scofield`, `larceny:coordinator`, `larceny:amy`, `larceny:yoda`, `larceny:sara`, `larceny:reviewer`, `larceny:advisor`, `larceny:teacher`, `larceny:sucre`, `larceny:mahone`, `larceny:sheba` and `larceny:whip`. (Not yet run in an interactive session. The `/agents` command no longer opens a list, so this prompt replaces it. Part 1 uses a similar prompt headless.)
- [ ] Type `/larceny:`. `onboard`, `wake-up`, `spawn-reviewer`, `spawn-advisor` and `spawn-teacher` are offered.
- [ ] Ask "which skills do you have from the larceny plugin?" The answer lists the skills under `skills/`.

## Part 3: fresh session and onboarding (for the owner)

- [ ] In a small project that has a GitHub remote and a `gh` login, start a plain `claude` session and run `/larceny:wake-up`. The main session says it is Scofield and offers onboarding, because the project has no `.larceny/config.md`, and it can ask you questions. If it dispatches a background agent instead, note what it did.
- [ ] In a small project that has a GitHub remote and a `gh` login, start `claude --agent larceny:scofield`. The session says it is Scofield and offers onboarding, because the project has no `.larceny/config.md`. If it does not, note what it did.
- [ ] Repeat the previous check with `claude --agent larceny:coordinator` instead. The session behaves the same way.
- [ ] Add `{"agent": "larceny:scofield"}` to the project's `.claude/settings.json` and start a plain `claude`. The main thread is Scofield. Remove the line again if you do not want it.
- [ ] Run `/larceny:onboard` with a real person answering. This is the clean-machine run that the onboarding work (#19) closed without. Check that `.larceny/config.md` and `.larceny/status.md` exist, that `.larceny/` is in `.gitignore`, that the persona-account steps can be skipped, and that a second run of the command shows the saved answers and asks before changing any.
- [ ] Run `/larceny:spawn-reviewer`. It confirms Amy is running (the shipped default, since no `reviewer:` override is configured). Ask the main session to relay a message ("Ask Amy: ...") and check that a reply comes back, with no id needed.
- [ ] Without running any spawn command, ask the main session to relay a message to a persona that is not running yet ("Ask Sara: ..."). Check that it spawns Sara first, using her founding prompt, then delivers the message, and that it says it did the extra step.
- [ ] Sign off one small ticket and ask Scofield to dispatch a coder. Check that the coder reads the ticket, works in a worktree, opens a pull request, messages the reviewer, and stops without merging until an approval arrives. Check that the coder finds the project's commands, though `.larceny/` is missing from its worktree.

## Part 4: pilot in a second project (for the owner)

- [ ] Repeat Parts 2 and 3 in a second real project that is not this one, on a project with different test and lint commands. Record which commands onboarding proposed and which you had to correct.
- [ ] Run one ticket through the whole loop there: dispatch, review, approval, merge, cleanup of the worktree and branches.
- [ ] Record anything that only worked because of setup on your own machine.

## Tear down (for the owner)

Run this last, on the clean machine from Part 2. The boxes are unticked because uninstall has not been run on this plugin. The commands come from the Claude Code plugin docs and are listed in [the README](../README.md#uninstall).

- [ ] Run `/plugin uninstall larceny@larceny`, then press Esc to close the panel. Type `/larceny:`. None of `onboard`, `wake-up`, `spawn-reviewer`, `spawn-advisor` or `spawn-teacher` is offered. If they still appear, run `/reload-plugins` and check again, and note that you had to.
- [ ] Ask "List the agent types you can dispatch whose names start with `larceny:`". None of the twelve `larceny:` agents is listed.
- [ ] Run `/plugin marketplace remove larceny`. Run `/plugin marketplace list`. The `larceny` marketplace is gone.
- [ ] In each project where you ran onboarding, check `.claude/agents/` for files named after the `coders:`, `reviewer:`, `advisor:` and `teacher:` values in `.larceny/config.md` (do this before you delete that file). Delete those files and leave any other agent files alone. Also delete `global-config.md` under `~/.config/larceny/` if you saved a crew globally.
- [ ] In each project where you ran onboarding, delete the `.larceny/` folder and the `.gitignore` line that ignores it. If you added `{"agent": "larceny:scofield"}` to `.claude/settings.json`, remove that line.
- [ ] Delete any worktrees and branches the test coder made, and any token files under `~/.config/larceny/` you created for the test. Delete those tokens on GitHub too.
- [ ] Delete the test user or container.

## Report the result

Comment on issue #18 with the date, the machine, the Claude Code version, and which boxes passed, failed or were skipped. Edit this file only to tick a box you ran.
