# Limitations

This page lists what is untested or does not work yet. Experimentation continues, and contributions are welcome. See [CONTRIBUTING.md](../CONTRIBUTING.md).

## Codex path is unverified

The repo ships a Codex manifest at `.codex-plugin/plugin.json`, and it points at the same `skills/` directory that Claude Code reads. Codex was not installed on the machine that wrote it, so the load step has never been run. The README says the same.

## Live agents end with the session

An agent you start inside a Claude Code session lives as long as that session. When the session closes, the agent is gone, along with anything it remembered. Work that has to outlast a session belongs in the repo, in an issue, or in a status file that a new session can read.

## GitHub comments do not reach a running session

An @-mention in an issue or pull request does not wake a session on your machine or send the comment into it. The session does not listen for GitHub events, so a persona reads a comment only when it checks for one.

Workaround: tell the session about the comment, and the persona reads it then. Or have the session poll the persona account's GitHub notifications on an interval, for example with `/loop` or a cron job. A poll picks up a comment up to one interval late, and it runs only while the session is open. A comment does not start work on its own. The persona reports what the comment says, and starts only when the user tells it to.

A hosted route exists: the [Claude Code GitHub Action](https://github.com/anthropics/claude-code-action) responds to @claude mentions on issues and pull requests. This repo does not set it up or cover it. Automatic pickup of GitHub comments in a local session is out of scope for now.

## Approvals go stale on every push

The repo's ruleset dismisses a pull request approval each time someone pushes to the branch. After every push, ask the reviewer to review again, and merge only on an approval for the current head.

## Merges can be blocked by a permission check

Claude Code can refuse a coder's `gh pr merge` even after the reviewer has approved. When that happens, the coder stops and reports the block to whoever coordinates the work, and that person merges or changes the permission. The coder does not retry the command or look for another way to merge.

## Spawn commands

`/larceny:spawn-reviewer`, `/larceny:spawn-advisor` and `/larceny:spawn-teacher` start a persona as a background agent (Amy, Yoda and Sara, or your project's renamed replacements; see "Renaming the reviewer, advisor or teacher" in [renaming.md](renaming.md)). See "Addressing a persona" and "Auto-spawn on first mention" in [agent-lifecycle.md](agent-lifecycle.md) for how to reach one afterward.

A spawn command's `description` frontmatter, the text shown in the `/` menu before you run it, is a static string shipped with the plugin. It cannot read a project's `.larceny/config.md` before you type the command, so it names the shipped default persona and role rather than a project's chosen replacement, even in a fully customized project. Once you run the command, what it tells you afterward (which agent it started, under which name) is accurate, because that step does read the config.

## Install and default agent are untested on a clean machine

The plugin loads and its agents resolve under `claude -p --plugin-dir`. Nobody has yet run `/plugin install` on a clean machine, checked a fresh interactive session, or piloted the team in a second project. Those runs are the checklist in [smoke-test.md](smoke-test.md). The plugin does not make Scofield the default agent. See "Coming back later" in the [README](../README.md#coming-back-later) for how to opt in.

## Agents and commands are Claude Code only

Codex reads `skills/`. It has no path here for the agents or the spawn commands.

## The full team needs a git repository

The project must be a git repository with at least one commit, because each coder works in its own worktree. Nobody has yet dispatched a coder in a folder that is not a repository or in a repository with no commits, so this page does not say what you would see.

## Only GitHub Projects boards are tested

Every board step in the plugin uses GitHub Projects. Linear through its MCP server is untested; the spike in [#72](https://github.com/nestedmind/larceny/issues/72) will test it.

## Onboarding

The onboarding skill has been pressure-tested with subagents that answer for the person, and it has not been run end to end on a clean machine with a real person. The steps for that run are in [smoke-test.md](smoke-test.md), Part 3. The onboarding skill writes a project-local file the agent definitions read on their own initiative. Nothing enforces that a coder reads it, so the coordinator puts the commands in each dispatch prompt.
