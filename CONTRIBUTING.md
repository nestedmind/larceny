# Contributing

This repo is a work in progress, tested on one machine, and it has gaps. If you want to join the team and help fill them, start with [docs/limitations.md](docs/limitations.md), which lists the known ones.

## Pick a ticket

Open issues are the work list. Choose one that no one has taken, and comment that you want it so two people do not start the same job. If you have an idea that has no ticket, open an issue first and wait for a maintainer to agree before you build it.

## Branch and pull request

1. Branch from the latest `origin/main`. Name the branch for the ticket, for example `docs/20-limitations`.
2. Keep one ticket to one pull request.
3. Do not push to `main`.
4. Open the pull request with a description that says what changed and why, and put `Closes #<number>` in it.
5. Rebase before you open it if `README.md` may have changed, because several branches edit it.

## Review

A reviewer reads each pull request against its ticket and either approves or requests changes. Merge only after an approval on the current head commit.

The repo dismisses an approval on every push, so ask for review again after each push. If the reviewer and you disagree after two rounds, stop and take the open findings to the maintainer. Do not merge past a disagreement. `skills/coordinator/SKILL.md` describes the full protocol.

## Plain writing

Docs, skills and pull request text follow [skills/plain-writing/SKILL.md](skills/plain-writing/SKILL.md). Cut words that do no work, use the active voice, and name the thing, the number and the ticket. State only what you checked.

Do not put names of people or private accounts, tokens or home directory paths in any file or pull request text.

## Report a bug on an untested setup

The tested setup is one Linux machine with Claude Code. If something fails on another setup, open an issue with:

- your operating system and whether you ran in a virtual machine, container or remote session
- the harness and version, Claude Code or Codex
- the steps you took, the result you expected and the result you got
- the error text, with any token or path that names you removed

An issue that reports success on an untested setup helps as well.

## Add a skill

1. Create `skills/<name>/SKILL.md`. The directory name matches the `name` in the frontmatter.
2. Write a `description` that begins with "Use when" and says when the skill applies.
3. Follow `skills/writing-skills/SKILL.md`, and test the skill against a real task before you open the pull request.
4. If the skill comes from another project, credit it in `THIRD_PARTY.md` and in the skill body.

## Add a persona

A persona is a role with a skill that defines it, and the name lives in that skill. Follow the steps for adding a skill, and describe the role and when it is used. Add an agent definition at `agents/<name>.md`, with the persona's founding prompt and a `skills:` list, and run `scripts/check-agents.sh` to check it. Add a `commands/spawn-<role>.md` command, named after the role rather than the shipped persona's name (see `commands/spawn-reviewer.md` for the pattern, added in #105), that starts the persona as an agent. If the role needs its own GitHub account, see [docs/identity-wiring.md](docs/identity-wiring.md). Then decide whether it runs persistent or as a fresh dispatch using [docs/agent-lifecycle.md](docs/agent-lifecycle.md). Add a row to the team table in `skills/coordinator/SKILL.md` if the persona joins that team.

## Releasing

The plugin version lives in one place: `version` in `.claude-plugin/plugin.json`. Do not add it to the plugin entry in `.claude-plugin/marketplace.json`. Claude Code reads the `plugin.json` value and ignores the other one.

Because the version is set, users who already installed the plugin get an update only when that string changes. Bump it in any pull request that users should receive. Skip the bump for pull requests that change only docs.

A check enforces this. `scripts/check-version-bump.sh` compares your branch with `origin/main`. If it changes anything under `agents/`, `skills/`, `commands/`, `.claude-plugin/` or `.codex-plugin/`, then `version` in `.claude-plugin/plugin.json` must differ from `main`, or the check fails. Adding, editing, moving or deleting a file there all count, so moving a skill out of `skills/` needs a bump too. Changes to docs, `examples/`, `scripts/` and `.github/` need no bump. Run it locally before you push.

If a change touches those folders but users need not receive it, such as a typo fix, a maintainer can add the `no-bump` label to the pull request, and the check passes. Locally, set `NO_BUMP=1`. State the reason in the pull request. The workflow in `.github/workflows/checks.yml` runs this check and `scripts/check-agents.sh` on every pull request.

Maintainers only. A contributor bumps the version in their own pull request, as above, and does not tag or publish. After a maintainer merges a version bump, the maintainer releases it:

1. Merge the pull request that bumps `version` in `.claude-plugin/plugin.json`.
2. From the merge commit, run `claude plugin tag --push` (add `-m "<message>"` for an annotation). It creates a `{name}--v{version}` tag (for example `larceny--v0.1.1`), validates that `plugin.json` and the marketplace entry agree on the version, and pushes it with `--push`. Use this instead of typing a bare `vX.Y.Z` tag by hand — a hand-typed tag skips that validation.
3. Publish a GitHub Release from the tag. The release notes are that version's entry in `CHANGELOG.md`, not GitHub's generated notes.

The repo keeps a `CHANGELOG.md`, newest release first. A release PR adds that version's entry.

## License

By contributing you agree that your work is released under the MIT license in `LICENSE`.
