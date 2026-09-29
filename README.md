# larceny

A plugin of skills for agent personas: a team with a coordinator, a reviewer and coders, and the skills each one works from. Claude Code and Codex read the same `skills/` directory, so each skill exists once.

It has been tested only with Claude Code, and it is recommended for Claude Code users. Codex users are welcome to try it and send feedback. See [Codex](#codex-untested) below.

**The coordinator and every persona are AI agents. They make mistakes** — a wrong claim stated with confidence, a review that misses something real, an action taken on bad information. Review their work yourself, verify a claim against the actual code or GitHub state rather than a self-report, and check before anything irreversible: a merge, a tag, a release, a delete.

## Get started

Three steps. Steps 1 and 2 are typed inside Claude Code. Step 3 is typed in a terminal.

### 1. Install

Inside Claude Code:

```
/plugin marketplace add nestedmind/larceny
/plugin install larceny@larceny
```

Claude Code finds every skill under `skills/` and every command under `commands/` on its own.

### 2. Try it now: wake up Scofield

Scofield is the coordinator and holds the context for the team. In a project that has a git remote on GitHub and a `gh` login, type this inside Claude Code:

```
/larceny:wake-up
```

`commands/wake-up.md` tells the current session to act as Scofield, in the main session, so it can ask you questions. It follows `agents/scofield.md`: if the project has no `.larceny/config.md`, it follows the `onboarding` skill first. That skill checks your `gh` login, git repo and repo access, asks a few questions, and writes your answers to `.larceny/config.md`. If the file exists, Scofield reads it and the status file and reports where things stand. It confirms with you before it spawns any agent.

If you have renamed your coordinator (see "Rename a persona" below), the same command resolves to that name instead of Scofield, without you needing to know or type the old name.

This route is untested. Nobody has run `/larceny:wake-up` in a live session yet. It is on the owner's checklist in [docs/smoke-test.md](docs/smoke-test.md).

### 3. Coming back later, or in another terminal tab or window

In a terminal, start a session as Scofield:

```
claude --agent larceny:scofield
```

Or, without naming Scofield, use the generic alias:

```
claude --agent larceny:coordinator
```

Both resolve the same way: to Scofield, or to your renamed coordinator if you have one. This needs a new terminal session. It has not been run on a clean machine either.

### Optional: have the plugin explained first

Run `/larceny:spawn-teacher`. It starts Sara, a teacher, as a background agent named `sara`. Sara gauges what you already know, explains in steps, and checks your understanding. Her founding prompt tells her to ignore the project around her, and she reads nothing in a repository until you name it. To message her, ask the main session to relay: "Ask Sara: explain how git rebase works." Add a project name after the command to give her one project for the conversation. The command file calls no `gh` command, so starting Sara needs no `gh` login. That the agent itself needs none is untested.

## What you need

- Claude Code, with the plugin installed as above.
- For `/larceny:wake-up` and `claude --agent larceny:scofield` (or its alias `claude --agent larceny:coordinator`): a `gh` login, a git repository, and access to its GitHub repo, the same as onboarding.
- For starting the spawn commands (`/larceny:spawn-teacher`, `/larceny:spawn-advisor`, `/larceny:spawn-reviewer`): nothing beyond the plugin. The command files call no `gh` command. A spawned Amy reviews pull requests, so it needs a `gh` login to do that work.
- For `/larceny:onboard`: a `gh` login, a git repository, and access to its GitHub repo. Onboarding checks all three before it writes anything.
- For the full team on a project (coordinator, reviewer, coders): one ordinary GitHub login is enough, and the project must be a git repository with at least one commit, because each coder works in its own worktree. Persona accounts and tokens are optional. Without them the reviewer states its verdict in a comment, because GitHub does not let one login approve its own pull request.
- A project board: GitHub Projects is the tested board. Linear through its MCP server is untested; the spike in [#72](https://github.com/nestedmind/larceny/issues/72) will test it.
- Persona accounts, if you want each persona to show up under its own name: a person must create them, since GitHub requires email verification and a captcha. See [docs/identity-wiring.md](docs/identity-wiring.md).
- A budget you can watch. Each agent is its own model session, and a team runs several at once. See [docs/cost-and-safety.md](docs/cost-and-safety.md).
- Tested on one Linux machine only. macOS, Windows, containers and remote setups are untested, and so is `/plugin install` on a clean machine. See [docs/limitations.md](docs/limitations.md).

## The team

The plugin ships agent files in `agents/`. Each carries the skills it needs, and none needs a GitHub account of its own.

- `scofield` coordinates: it plans, dispatches coders and reports to you.
- `amy` is the adversarial reviewer. She reviews pull requests against their tickets.
- `yoda` is the senior advisor. He gives advice when you consult him.
- `sara` is the teacher. She explains in steps.
- `reviewer`, `advisor` and `teacher` are role aliases that resolve to Amy, Yoda and Sara, or to your renamed replacements.
- `sucre`, `mahone`, `sheba` and `whip` are coders. Each takes one ticket per dispatch, works in its own worktree, opens a pull request and merges it only after an approval.

Claude Code lists a plugin's agents under the plugin name, so dispatch them as `larceny:sucre` and so on. The coders read the project's test and lint commands from `.larceny/config.md`. That folder is gitignored, so a coder's fresh worktree does not hold it. The coder reads it in the main checkout, or takes the commands from the dispatch prompt.

## Uninstall

**Uninstalling has not been tested on this plugin.** The commands below come from the Claude Code plugin documentation ([Manage installed plugins](https://code.claude.com/docs/en/discover-plugins#manage-installed-plugins) and [Manage marketplaces](https://code.claude.com/docs/en/discover-plugins#manage-marketplaces)), and we checked each one against that page. Nobody has run them on this plugin yet. If one fails, please tell us on the [issues page](https://github.com/nestedmind/larceny/issues).

Remove the plugin, inside Claude Code:

```
/plugin uninstall larceny@larceny
```

This opens the plugin panel and leaves it open. Press Esc to close it. You can also run `/plugin`, open the Installed tab, select the plugin and choose uninstall. From a shell, `claude plugin uninstall larceny@larceny` does the same without the panel. If you installed it for a project, add `--scope project`.

To keep the plugin but turn it off, run `/plugin disable larceny@larceny`. Turn it back on with `/plugin enable larceny@larceny`.

Optionally, remove the marketplace too:

```
/plugin marketplace remove larceny
```

The docs warn that removing a marketplace uninstalls any plugins you installed from it.

Uninstalling does not touch what the plugin's work left behind. Clean these up by hand if they exist:

- Custom agent files in each project's `.claude/agents/` folder. If you renamed the coordinator, a coder, the reviewer, the advisor or the teacher during onboarding, onboarding wrote one `<name>.md` file per renamed persona into that folder. Uninstalling does not remove them, and once the plugin is gone they point at skills that no longer exist. Larceny's files are the ones whose names match the values of `coders:` (its first name is the coordinator), `reviewer:`, `advisor:` and `teacher:` in that project's `.larceny/config.md`. Do this before you delete `.larceny/`, because its config names the files. Delete only those files, because other agent files in the folder may not come from Larceny.
- The `.larceny/` folder in each project where you ran onboarding, and the `.gitignore` line that ignores it.
- An `"agent": "larceny:scofield"` line in `.claude/settings.json`, if you opted in to run Scofield as the main session.
- Coder worktrees and branches in your projects.
- Token files under `~/.config/larceny/`, if you set up persona accounts. Also delete those tokens on GitHub.
- The global crew file `~/.config/larceny/global-config.md`, if you saved your crew globally. It sits in the same folder as the token files. If you set `LARCENY_CONFIG_DIR`, look there.

## Run Scofield as the main session

Nothing makes Scofield the default. The plugin does not set `"agent"` in a `settings.json`, because that would change every session of everyone who installs it. To run as Scofield, pick one:

- Inside a session, run `/larceny:wake-up`. This route is untested.
- Start a session with `claude --agent larceny:scofield`, or its alias `claude --agent larceny:coordinator`.
- Or add `{"agent": "larceny:scofield"}` (or `{"agent": "larceny:coordinator"}`) to your project's `.claude/settings.json`, or to your user settings, to make it the default there.

A main-session agent does not preload the skills its file lists, so Scofield loads them with the Skill tool when it starts. The tests behind this are in [docs/smoke-test.md](docs/smoke-test.md).

## First run

Run `/larceny:onboard` in your project. Scofield checks that `gh` is logged in, asks who you are and how you want reports, shows you the recommended per-persona model split and lets you keep it, run every persona on the harness default, or customize it (see "Model assignments" below), reads your `CLAUDE.md` and build files to agree the test, lint and build commands, and writes your answers to `.larceny/config.md` in the project. It adds `.larceny/` to `.gitignore`. A project board, a branch ruleset and persona accounts are offered last, and each can be skipped. One ordinary GitHub login is enough, and skipping every optional step leaves a working team. Running it again shows your current answers and asks before changing any.

### Save your crew once, use it in every project

If you customize the crew (your own names, renamed reviewer, advisor or teacher, or a different model split) and no global file exists yet, onboarding asks once: save this as your default crew for every project on this machine, or keep it to this project. Saving writes `global-config.md` in `~/.config/larceny/` (or in `LARCENY_CONFIG_DIR`, the same directory as the persona tokens) and puts your renamed personas' files in `~/.claude/agents/`. The project records `crew: global`.

In a new project, onboarding finds that file and offers to use it (the default) or set up a different crew just for that project. Choosing the saved crew asks no person and no crew question: it goes straight to reading the project's test, lint and build commands and to the optional board, ruleset and identities steps.

- **Per machine, not synced.** The file lives on this machine only. Another machine needs its own.
- **The project wins.** For each key, a project's own `.larceny/config.md` beats the global file, and the global file beats the shipped default. A project follows the global file only if it says `crew: global`; a project onboarded before this existed, or one that chose its own crew (`crew: project`), is never changed by it.
- **Edits carry over.** A project that follows global picks up later edits to the global file on its next dispatch, with no re-onboarding. If the file is missing or unreadable, the project falls back to the shipped defaults and says so.
- **What can be global.** `person`, `role`, `reports`, `coders`, `models`, `reviewer`, `advisor`, `teacher`. The test, lint and build commands, rules, board, ruleset and identities describe one repo and always stay in the project.

The full rule, and the one place every reader of these keys follows it, is [docs/crew-resolution.md](docs/crew-resolution.md).

Without persona accounts the reviewer states its verdict in a comment, because GitHub does not let one login approve its own pull request. See the fallbacks in `skills/coordinator/SKILL.md`.

## Commands

- `/larceny:wake-up` makes the current session act as Scofield, the coordinator, or as your renamed coordinator if you have one (see "Rename a persona").
- `/larceny:onboard` runs the onboarding skill only.
- `/larceny:spawn-reviewer`, `/larceny:spawn-advisor` and `/larceny:spawn-teacher` start a persona as an agent. See below.

## Spawn commands

Three personas run as long-lived agents that you message across a session. A slash command starts each one, named after the role it fills rather than the shipped default's name, so the command keeps working whether the project runs the shipped default or a renamed replacement. See [Renaming the reviewer, advisor or teacher](#renaming-the-reviewer-advisor-or-teacher) below. Plugin commands carry the plugin name, so the forms are:

- `/larceny:spawn-reviewer` starts the adversarial code reviewer (Amy by default).
- `/larceny:spawn-advisor` starts the senior advisor (Yoda by default).
- `/larceny:spawn-teacher` starts the teacher (Sara by default).

Each command starts an agent with that persona's founding prompt and tells it to ignore the project around it. Add a project name after the command, such as `/larceny:spawn-advisor my-app`, to give the agent one project for the conversation. Without a name, the agent asks.

Each command gives the agent a name, such as `amy`, and the agent is reachable by that name for the rest of the session, no id needed.

To talk to the agent, ask the main session to relay: "Ask Amy: review PR 12" (using whichever name the agent actually resolved to). The main session calls `SendMessage` with the name. If the persona is not running yet, the session starts it first, using the same founding prompt as its role's spawn command, then delivers the message. See "Addressing a persona" and "Auto-spawn on first mention" in [docs/agent-lifecycle.md](docs/agent-lifecycle.md).

### Talking to the teacher and advisor directly

You can also start a session as the teacher or the advisor, with no coordinator in between:

- `claude --agent larceny:teacher` (Sara by default)
- `claude --agent larceny:advisor` (Yoda by default)
- `claude --agent larceny:coordinator` (Scofield by default)

Each resolves to your customized persona or the shipped default, by [docs/crew-resolution.md](docs/crew-resolution.md), and keeps the founding prompt's context rules (no project until you name one, nothing read in a repository until told).

From any of the three, name another to bring it into the same conversation: "ask the advisor", "Sara, what do you think?", "all three of you". The persona is started if it is not running. Its reply is shown to you verbatim and labeled with its name, and the session you are in may add its own view separately. By default the persona also gets a short neutral note of the conversation so far; say "without the background" to leave it out. The rule lives in one place, the `bring-in-personas` skill.

Limit: on Discord or any single-channel setup, one session owns the channel and relays to the others, so your messages still pass through it. It follows the same verbatim-and-labeled rule. A separate channel per persona is not something this plugin controls.

The coders are not spawned this way. The coordinator starts a fresh coder for each ticket.

The commands live in `commands/`, which Claude Code finds on its own. They are Claude Code only for now. Whether Codex has an equivalent custom-command mechanism is unverified, so Codex users start these personas by hand.

## Rename a persona

A persona's name lives in the skill that defines it. To rename one, change the `name` field in the skill's `SKILL.md` frontmatter, rename its directory under `skills/` to match, and update any text in the skill body that uses the old name. This applies to the coordinator, whose identity lives in the `coordinator` skill (renamed from `scofield` in #105 — see "The `scofield` skill moved" below). It does not apply to the reviewer, advisor or teacher: each is defined by an agent file, not a skill of its own, so see [Renaming the reviewer, advisor or teacher](#renaming-the-reviewer-advisor-or-teacher) below instead.

### The `scofield` skill moved

Before #105, the coordinator's skill was named `scofield`, the same as the shipped default coordinator persona. It is now named `coordinator` (`skills/coordinator/SKILL.md`), so that loading it reads `Skill(larceny:coordinator)` regardless of what a project has renamed its coordinator to, instead of always printing the shipped default's name. `skills/scofield/SKILL.md` still exists, as a one-line stub that says the skill moved and to follow `coordinator` instead — this protects a project-level override file written before this rename (a body saying "Follow the `scofield` skill") from silently stopping being recognized once the plugin updates. Write new override files against `coordinator`; both phrasings resolve.

### Renaming the coordinator without editing the plugin

For the coordinator specifically, there is a second way that does not touch any shipped file, confirmed in issue #70: add a project-level `.claude/agents/<name>.md` file whose body says something like "You are `<name>`, the coordinator. Follow the `coordinator` skill." Because it lives in your project, not the plugin, it survives plugin updates the way an edit to `agents/scofield.md` would not.

`/larceny:wake-up` looks for this file before it does anything else. It scans `.claude/agents/*.md` for one whose body names the coordinator role and points at the `scofield` skill or the `coordinator` skill (both phrasings count, since the skill was renamed); if it finds exactly one, it acts under that name for the session instead of Scofield. With no such file, or with the coordinator's name left at its default, nothing changes. `agents/coordinator.md`, the generic alias for `claude --agent`, resolves the same way. This resolution is coordinator-only. Rename a reviewer, advisor or teacher with the method in [Renaming the reviewer, advisor or teacher](#renaming-the-reviewer-advisor-or-teacher) below.

### Renaming a coder without editing the plugin

Coders work the same way, since #77 split each shipped coder (`agents/mahone.md`, `sheba.md`, `sucre.md`, `whip.md`) into a thin file that only sets a name, a GitHub account and token path, and "Follow the `coder` skill." A project-level `.claude/agents/<name>.md` file with the same shape — `name`, `isolation: worktree`, `skills: [coder, ...]`, a body reading "You are `<name>`, a coder. Follow the `coder` skill.", and a token file path if the project uses persona accounts — works exactly like a shipped coder, without editing any shipped file. Leaving out `isolation: worktree` is the one way to make this not work exactly like a shipped coder: without it a dispatch runs directly against the coordinator's own checkout instead of an isolated worktree. `larceny:onboard`'s roster gate writes this file for you when you choose to name your own crew; you can also write it by hand and record the new name in `.larceny/config.md`'s `coders:` line yourself.

Unlike the coordinator, a renamed coder is not resolved automatically at invocation time — a coder is a fresh subagent dispatch, not a session someone starts by name. Instead, the `coordinator` skill resolves `coders:` before every dispatch (the project's `.larceny/config.md`, else your global crew if the project follows it, see [docs/crew-resolution.md](docs/crew-resolution.md)) and uses the roster's names.

### Renaming the reviewer, advisor or teacher

The reviewer (Amy by default), the advisor (Yoda by default) and the teacher (Sara by default) each ship as two files in `agents/`:

- The named file: `agents/amy.md`, `agents/yoda.md` and `agents/sara.md`, dispatched as `larceny:amy`, `larceny:yoda` and `larceny:sara`. Each is that persona's agent definition. The founding prompt that a rename copies lives in the role's spawn command.
- The role alias: `agents/reviewer.md`, `agents/advisor.md` and `agents/teacher.md`, dispatched as `larceny:reviewer`, `larceny:advisor` and `larceny:teacher`. Each resolves the configured persona and acts as it, so `claude --agent larceny:reviewer` works whether the project runs Amy or a replacement.

The spawn commands `commands/spawn-reviewer.md`, `commands/spawn-advisor.md` and `commands/spawn-teacher.md` are named after the role for the same reason.

To rename one, write a project-level `.claude/agents/<name>.md` file with `name: <name>` in its frontmatter and, as its body, that persona's founding prompt (copy it from the fenced block under "Shipped founding prompt" in `commands/spawn-reviewer.md`, `commands/spawn-advisor.md` or `commands/spawn-teacher.md`). Replace the shipped name (Amy, Yoda or Sara) only in the opening `You are <name>, ...` line, not in every mention. For a renamed advisor, also delete the sentence that begins "At most one sentence per reply may use Yoda's inverted word order", because it describes Yoda's voice and not the advisor role, and keep "Speak plainly." Then record the new name in `.larceny/config.md`: `reviewer: <name>` for a renamed Amy, `advisor: <name>` for a renamed Yoda, or `teacher: <name>` for a renamed Sara. The role alias and the spawn command each resolve the matching config key the same way, and when that key names a persona, read its founding prompt from its `.claude/agents/<name>.md` file instead of using the shipped one. `default`, or the key missing, means the shipped default, unchanged. This mirrors the coder mechanism above. Unlike the coordinator, none of the three is resolved by scanning file contents for a role phrase, because the config key already says which role each line customizes.

### The hiding ceiling

None of this makes a shipped default agent disappear. #82 confirmed, on a real installed copy of the plugin, that `larceny:sheba`, `larceny:mahone`, `larceny:sucre`, `larceny:whip` and `larceny:scofield` stay listed and directly dispatchable through the Agent tool for as long as the plugin is installed, no matter what a project names its replacements. There is no file-naming or precedence trick that hides or removes a shipped agent type — only the coordinator's own automated dispatch is guaranteed to use a customized roster's names, because it reads them from config instead of guessing. A human picking an agent by name from the Agent-tool UI can still reach a shipped default directly.

The shipped named files (`larceny:amy`, `larceny:yoda` and `larceny:sara`) stay listed and reachable through the Agent tool in the same way, whatever a project names its replacements.

That leaves a collision-ambiguity risk, confirmed by direct test: a project's own bare name (say `arya`) and a hypothetical future plugin version shipping the same name namespaced (`larceny:arya`) coexist independently, with no overwrite and no error. This is not a functional break — the coordinator's own dispatch stays correct either way, because it reads the exact roster name from config — but it means a human could pick the wrong one from the Agent-tool UI by name alone. Avoid choosing a coder or coordinator name that could later read ambiguously against a namespaced plugin name, and prefer a name clearly distinct from the shipped cast (Scofield, Amy, Yoda, Sara, Sucre, Mahone, Sheba, Whip).

A different kind of collision, also confirmed by direct test: installing two marketplaces that both ship a plugin literally named `larceny` collides in the dispatch namespace too — only one set of `larceny:*` agent types is exposed, not two side by side. This needs two different marketplace sources both choosing the same plugin name, unlikely in ordinary use, but worth knowing if you ever add a second source.

One combination #82 did not directly test: a coordinator-override file and a customized coder roster active in the same project at once. Nothing in either mechanism's design suggests they would conflict — they read different keys — but it has not been confirmed together.

## Model assignments

Each persona's model is a cost decision as much as a technical one, so onboarding shows it and lets you change it. The shipped default:

| Persona | Role | Model |
|---|---|---|
| Mahone / Sheba / Sucre / Whip | Coder | Sonnet |
| Scofield | Coordinator | Opus |
| Amy | Adversarial reviewer | Opus |
| Sara | Teacher | Opus |
| Yoda | Senior advisor | Fable |

This is a recommendation, not a requirement. During onboarding you choose to keep it, run every persona on the harness's own default model, or override one or more personas individually; see step 8 in `skills/onboarding/SKILL.md`. The choice is recorded in the `models:` line of `.larceny/config.md` (or of your global crew file, see "Save your crew once, use it in every project"), separately from `coders:`, `reviewer:`, `advisor:` and `teacher:` (renaming a persona and picking its model are independent choices, which is why onboarding asks the naming questions first and the model question last — see the onboarding skill's "Config format" section for the exact syntax, including what to do if you rename a persona that already has a `models:` override). Every way a persona gets spawned reads `models:` and passes any override as an explicit `model` parameter, taking precedence over the shipped default: a coder dispatch, a persistent persona's own role-based spawn command, and the auto-spawn path all apply it the same way — see "Model overrides" in [docs/agent-lifecycle.md](docs/agent-lifecycle.md).

## Identity wiring

Each persona can run under its own GitHub account, so commits, pull requests and reviews show who did what. This is optional, and everything in the repo works with your own `gh` login and git identity. The setup steps, and which ones only a person can do, are in [docs/identity-wiring.md](docs/identity-wiring.md).

Without a token, two personas working in the same project cannot be told apart by GitHub account — a pull request from an untokened coder shows your own ambient login, the same as every other untokened persona's, confirmed by #82. This is the expected result of skipping identity wiring, not a bug: per-persona attribution only works once each persona has its own token.

## Agent lifecycle

When you stand up a team, each role runs either as a persistent, named agent or as a fresh dispatch per task. A standing reviewer or advisor fits the first, and a coder fits the second. The rule and the reasons are in [docs/agent-lifecycle.md](docs/agent-lifecycle.md).

## Limitations

**GitHub comments and @-mentions do not reach a session running on your machine.** Commenting on a persona's name in an issue or pull request does not wake it or send the comment into the session. The session does not listen for GitHub events, so a persona reads a comment only when it checks for one.

Workaround: tell the session about the comment, and the persona reads it then. Or have the session poll the persona account's GitHub notifications on an interval, for example with `/loop` or a cron job. A poll picks up a comment up to one interval late, and it runs only while the session is open. A comment does not start work on its own. The persona reports what the comment says, and starts only when the user tells it to.

A hosted route exists: the [Claude Code GitHub Action](https://github.com/anthropics/claude-code-action) responds to @claude mentions on issues and pull requests. This repo does not set it up or cover it. Automatic pickup of GitHub comments in a local session is out of scope for now.

## Codex (untested)

Clone the repo and load it as a Codex plugin. Its manifest is `.codex-plugin/plugin.json`, which reads skills from `./skills/`.

```
git clone https://github.com/nestedmind/larceny.git
```

Codex reads the skills only. The agents in `agents/` and the commands in `commands/` are Claude Code features, and nothing here maps them to Codex, so Codex users get the skills and run the personas by hand. The Codex install steps are unverified. Codex is not installed on the machine that wrote this, and Codex's plugin documentation could not be checked. The manifest follows the layout of other Codex plugins, but confirm the load step against Codex's current documentation. If you try it, please tell us what worked and what did not on the [issues page](https://github.com/nestedmind/larceny/issues).

## More

- [docs/smoke-test.md](docs/smoke-test.md): what was tested, and the checklist for a clean-machine install and a pilot in a second project. The owner's run is still open.
- [docs/limitations.md](docs/limitations.md): what is untested or does not work yet.
- [docs/cost-and-safety.md](docs/cost-and-safety.md): token cost, GitHub tokens and what agents can run.
- [CONTRIBUTING.md](CONTRIBUTING.md): how to pick a ticket, open a pull request and add a skill or persona.

## License

MIT. See `LICENSE`. Adapted skills are credited in `THIRD_PARTY.md`.
