# Rename a persona

Onboarding can write your own names for any persona. This page explains how each rename works, if you want to do it by hand or understand what onboarding wrote.

A persona's name lives in the skill that defines it. To rename one, change the `name` field in the skill's `SKILL.md` frontmatter, rename its directory under `skills/` to match, and update any text in the skill body that uses the old name. This applies to the coordinator, whose identity lives in the `coordinator` skill. It does not apply to the reviewer, advisor or teacher: each is defined by an agent file, not a skill of its own, so see [Renaming the reviewer, advisor or teacher](#renaming-the-reviewer-advisor-or-teacher) below instead.

## Renaming the coordinator without editing the plugin

For the coordinator specifically, there is a second way that does not touch any shipped file, confirmed in issue #70: add a project-level `.claude/agents/<name>.md` file whose body says something like "You are `<name>`, the coordinator. Follow the `coordinator` skill." Because it lives in your project, not the plugin, it survives plugin updates the way an edit to `agents/scofield.md` would not.

`/larceny:wake-up` looks for this file before it does anything else. It scans `.claude/agents/*.md` for one whose body names the coordinator role and points at the `coordinator` skill; if it finds exactly one, it acts under that name for the session instead of Scofield. With no such file, or with the coordinator's name left at its default, nothing changes. `agents/coordinator.md`, the generic alias for `claude --agent`, resolves the same way. This resolution is coordinator-only. Rename a reviewer, advisor or teacher with the method in [Renaming the reviewer, advisor or teacher](#renaming-the-reviewer-advisor-or-teacher) below.

## Renaming a coder without editing the plugin

Coders work the same way, since #77 split each shipped coder (`agents/mahone.md`, `sheba.md`, `sucre.md`, `whip.md`) into a thin file that only sets a name, a GitHub account and token path, and "Follow the `coder` skill." A project-level `.claude/agents/<name>.md` file with the same shape — `name`, `isolation: worktree`, `skills: [coder, ...]`, a body reading "You are `<name>`, a coder. Follow the `coder` skill.", and a token file path if the project uses persona accounts — works exactly like a shipped coder, without editing any shipped file. Leaving out `isolation: worktree` is the one way to make this not work exactly like a shipped coder: without it a dispatch runs directly against the coordinator's own checkout instead of an isolated worktree. `larceny:onboard`'s roster gate writes this file for you when you choose to name your own crew; you can also write it by hand and record the new name in `.larceny/config.md`'s `coders:` line yourself.

Unlike the coordinator, a renamed coder is not resolved automatically at invocation time — a coder is a fresh subagent dispatch, not a session someone starts by name. Instead, the `coordinator` skill resolves `coders:` before every dispatch (the project's `.larceny/config.md`, else your global crew if the project follows it, see [docs/crew-resolution.md](crew-resolution.md)) and uses the roster's names.

## Renaming the reviewer, advisor or teacher

The reviewer (Amy by default), the advisor (Yoda by default) and the teacher (Sara by default) each ship as two files in `agents/`:

- The named file: `agents/amy.md`, `agents/yoda.md` and `agents/sara.md`, dispatched as `larceny:amy`, `larceny:yoda` and `larceny:sara`. Each is that persona's agent definition. The founding prompt that a rename copies lives in the role's spawn command.
- The role alias: `agents/reviewer.md`, `agents/advisor.md` and `agents/teacher.md`, dispatched as `larceny:reviewer`, `larceny:advisor` and `larceny:teacher`. Each resolves the configured persona and acts as it, so `claude --agent larceny:reviewer` works whether the project runs Amy or a replacement.

The spawn commands `commands/spawn-reviewer.md`, `commands/spawn-advisor.md` and `commands/spawn-teacher.md` are named after the role for the same reason.

To rename one, write a project-level `.claude/agents/<name>.md` file with `name: <name>` in its frontmatter and, as its body, that persona's founding prompt (copy it from the fenced block under "Shipped founding prompt" in `commands/spawn-reviewer.md`, `commands/spawn-advisor.md` or `commands/spawn-teacher.md`). Replace the shipped name (Amy, Yoda or Sara) only in the opening `You are <name>, ...` line, not in every mention. For a renamed advisor, also delete the sentence that begins "At most one sentence per reply may use Yoda's inverted word order", because it describes Yoda's voice and not the advisor role, and keep "Speak plainly." Then record the new name in `.larceny/config.md`: `reviewer: <name>` for a renamed Amy, `advisor: <name>` for a renamed Yoda, or `teacher: <name>` for a renamed Sara. The role alias and the spawn command each resolve the matching config key the same way, and when that key names a persona, read its founding prompt from its `.claude/agents/<name>.md` file instead of using the shipped one. `default`, or the key missing, means the shipped default, unchanged. This mirrors the coder mechanism above. Unlike the coordinator, none of the three is resolved by scanning file contents for a role phrase, because the config key already says which role each line customizes.

## The hiding ceiling

None of this makes a shipped default agent disappear. #82 confirmed, on a real installed copy of the plugin, that `larceny:sheba`, `larceny:mahone`, `larceny:sucre`, `larceny:whip` and `larceny:scofield` stay listed and directly dispatchable through the Agent tool for as long as the plugin is installed, no matter what a project names its replacements. There is no file-naming or precedence trick that hides or removes a shipped agent type — only the coordinator's own automated dispatch is guaranteed to use a customized roster's names, because it reads them from config instead of guessing. A human picking an agent by name from the Agent-tool UI can still reach a shipped default directly.

The shipped named files (`larceny:amy`, `larceny:yoda` and `larceny:sara`) stay listed and reachable through the Agent tool in the same way, whatever a project names its replacements.

That leaves a collision-ambiguity risk, confirmed by direct test: a project's own bare name (say `arya`) and a hypothetical future plugin version shipping the same name namespaced (`larceny:arya`) coexist independently, with no overwrite and no error. This is not a functional break — the coordinator's own dispatch stays correct either way, because it reads the exact roster name from config — but it means a human could pick the wrong one from the Agent-tool UI by name alone. Avoid choosing a coder or coordinator name that could later read ambiguously against a namespaced plugin name, and prefer a name clearly distinct from the shipped cast (Scofield, Amy, Yoda, Sara, Sucre, Mahone, Sheba, Whip).

A different kind of collision, also confirmed by direct test: installing two marketplaces that both ship a plugin literally named `larceny` collides in the dispatch namespace too — only one set of `larceny:*` agent types is exposed, not two side by side. This needs two different marketplace sources both choosing the same plugin name, unlikely in ordinary use, but worth knowing if you ever add a second source.

One combination #82 did not directly test: a coordinator-override file and a customized coder roster active in the same project at once. Nothing in either mechanism's design suggests they would conflict — they read different keys — but it has not been confirmed together.
