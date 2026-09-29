# Agent lifecycle: persistent or fresh dispatch

When you stand up a team of agents, you decide for each role whether to start it once and keep it alive, or to start a new agent for every task. The choice follows how the role gets used. A role's importance does not enter into it.

This page gives the rule, the reasons behind it, and a worked example using the team from `skills/coordinator/SKILL.md`. If your team uses other names, map your roles onto the example by their usage.

## The rule

Ask how the role is called on.

- Other agents or people call on it repeatedly, at unpredictable times, and remembering earlier context helps. Make it a **persistent, named agent**.
- It does one bounded piece of work per dispatch and reports back. Make it a **fresh dispatch per task**, and put anything worth remembering in its skill file.

## Persistent, named agent

Start the agent once through your harness's persistent or named-agent mechanism. Address it by name from then on, and keep it alive for the life of the project.

This fits a role whose value builds up over many exchanges:

- A standing reviewer reviews pull request after pull request. It already knows what adversarial review means on this project, so each review starts from that shared understanding.
- An advisor or teacher is consulted directly by the human. The value is in the back-and-forth, and it depends on the agent remembering what it already explained or was already asked.

A standing reviewer's context grows as well, with every diff it reads. Keep its standards in its skill, not only in its memory, and restart it when its context gets long. The restarted agent reads the skill and loses nothing that mattered.

Both roles get pinged by several parties at times nobody can predict. A fresh agent would need the same background restated on every call, and a persistent one keeps it.

## Fresh dispatch per task

Start a new agent for each task, hand it the task, collect its report, and let it end. This fits implementers, whose work comes one ticket at a time. Four reasons favor it.

**It starts with no inherited history.** The coder reads the ticket itself, from the source, on every dispatch. A coordinator's summary of a ticket can be wrong, and a coder that carries no assumptions checks the summary against the ticket and the code. This is a safety property of the design. A fresh coder has caught a mistake in a coordinator's issue text and overridden it because the codebase said otherwise. A long-lived coder that had absorbed the coordinator's framing would be less likely to notice.

**Context stays bounded.** A single process that handles dozens of tasks accumulates history until the harness compacts it, and compaction loses detail. A coordinator that runs for a long time eventually hits this. Fresh dispatch spares every coder from it.

**Each task can be audited alone.** One dispatch yields one worktree, one pull request and one report. Nothing blends into a long running history that someone must untangle later.

**Replacement costs nothing.** If a coder fails, times out or gets swapped for another model, the next dispatch loses nothing, because the agent never held anything the repo did not.

### Where cross-task knowledge goes

Sometimes it would help if a coder learned a codebase's idioms over time. Write that knowledge into a skill or conventions file that every dispatch reads. A file is portable, reviewable in a pull request, and survives the loss of any one agent. This is also the premise of this whole repo: reusable knowledge lives in skills, and no single running agent holds it.

## Worked example

The example team maps onto the rule like this.

| Persona | Role | Lifecycle | Why |
|---|---|---|---|
| Amy | Standing reviewer | Persistent | Reviews every pull request and gains from keeping its standards and the project's history |
| Yoda | Advisor | Persistent | The human consults it repeatedly, and it remembers earlier advice |
| Sara | Teacher | Persistent | Its explanations build on what the learner already covered |
| Sucre, Mahone, Sheba, Whip | Coders | Fresh dispatch | One ticket each, read from source, isolated, reported once |
| Scofield | Coordinator | Your call | See below |

The coordinator sits between the two patterns. It lives across the whole project, so it usually runs as the main session, and it has to protect its context from filling up. `skills/coordinator/SKILL.md` covers this by keeping coordination state in a status file outside the session, so a compaction does not lose it.

To map your own team, sort each role by its usage. A role that several agents or people address over time, and that gains from memory, goes with Amy, Yoda and Sara. A role that takes one bounded task and reports goes with the coders.

## Roles that could go either way

A role can change pattern as its use changes. A reviewer that a project calls on twice a month gains little from staying alive, and a fresh dispatch that reads the review skill each time costs less. A coder that a human starts to consult daily about one codebase behaves like an advisor. When a role's usage changes, move it.

## Addressing a persona

Once a spawn command starts a persona with `name` set (`sara`, `yoda`, `amy`), message it by that name from then on: `SendMessage({to: "sara", ...})` resolves directly, and no id is needed. `SendMessage`'s own tool spec says it plainly: "the name IS the address; there is no separate address syntax." This was checked in practice, not just assumed from the spec: a session that spawned an agent named `sara` could still reach it by that bare name later in the same session, with its id never used.

The convention for how a person or another agent asks for this: name the persona in plain text, for example "Ask Sara: <question>" or "Tell Amy to review PR 12". Do not use an `@name` prefix. GitHub's own `@`-mentions on issues and pull requests do not reach a running session (see the Limitations section of the README), and giving `@name` a second, working meaning here would blur two different things that look the same. Plain-text naming is the one convention; use it everywhere a persona is addressed.

If a future Claude Code build stops honoring `name` on the `Agent` tool, a spawn command falls back to reporting the agent's id and the addressing above stops working until then; nothing else in this section changes.

## Spawn commands are named by role, not by persona

The three commands that start the reviewer, the advisor and the teacher are named after the role each fills, not the shipped default's name: `commands/spawn-reviewer.md`, `commands/spawn-advisor.md` and `commands/spawn-teacher.md`. This is so the command keeps working, under the same name, whether a project runs the shipped default persona or a renamed one, the same way `/larceny:wake-up` is named after the coordinator role rather than "Scofield". Each command resolves the shipped default (Amy, Yoda or Sara) or a project's configured replacement (the `reviewer:`, `advisor:` or `teacher:` key as [crew-resolution.md](crew-resolution.md) resolves it, with the founding prompt in a `.claude/agents/<name>.md` file, project-level or user-level) before it spawns anything. See "Renaming the reviewer, advisor or teacher" in the README for the full mechanism.

## Model overrides

Every way an agent gets spawned — a coder dispatch, a persistent persona started from its role's spawn command (`commands/spawn-reviewer.md`, `commands/spawn-advisor.md`, `commands/spawn-teacher.md`), or the auto-spawn path below — resolves `models:` by [crew-resolution.md](crew-resolution.md) (the project's `.larceny/config.md`, else the global file when the project says `crew: global`, else the shipped default) before picking a model, instead of using the shipped default unconditionally. See `skills/onboarding/SKILL.md`'s "Config format" for the exact syntax.

- `models: default`, or the key missing everywhere, or no `.larceny/config.md` at all: use the shipped default (the `model` in `agents/*.md` frontmatter for a coder or the coordinator, or the `model` bullet the persona's role resolves to in its spawn command).
- `models: harness-default`: pass no explicit `model` parameter to the `Agent` call for any persona, so the harness's own default applies instead of the shipped default.
- Either of the above can carry indented `<persona name>: <model>` override lines. When the persona being spawned has one, pass that model explicitly instead of the baseline for that mode. A persona with no override line keeps the baseline.

This applies by persona name, not by mechanism, so Amy, Yoda and Sara are covered exactly like a coder or the coordinator: the `model` bullet a spawn command resolves to (shipped default or project override) is the baseline this override replaces, never a value to pass unconditionally.

## Auto-spawn on first mention

A session does not need a separate, explicit spawn step before it can relay to a persona. When a request names a persona that is not currently running ("ask Sara ...", "tell Yoda ...") and `ListAgents` shows no live agent with that name:

1. Find that persona's founding prompt. For the reviewer, advisor or teacher role, it lives in that role's spawn command (`commands/spawn-reviewer.md`, `commands/spawn-advisor.md` or `commands/spawn-teacher.md`), which resolves the shipped default or a configured custom name itself (through [crew-resolution.md](crew-resolution.md)) — see "Spawn commands are named by role, not by persona" above. For a coder or the coordinator, it lives in the project's own definition of the persona if it has no spawn command.
2. Call `Agent` with the `name`, `description` and `prompt` the spawn command resolves to, filling in the project line the way the command describes. For `model`, apply "Model overrides" above instead of following the spawn command's `model` bullet unconditionally.
3. Once the call returns, send the original message to the new agent by name, as in "Addressing a persona" above.

Say once that this happened, for example "Sara wasn't running, so I started her first," rather than silently absorbing the step. If the spawn call fails, report the failure and do not drop the message.

This applies to any session asked to relay a message, not only the coordinator.

## Bringing personas into one conversation

The coordinator, teacher and advisor can each be the main session (`claude --agent larceny:coordinator`, `larceny:teacher`, `larceny:advisor`; the last two are `agents/teacher.md` and `agents/advisor.md`, which resolve the persona by [crew-resolution.md](crew-resolution.md), project `.claude/agents/` first and then `~/.claude/agents/`). In any of them, the owner can name another of the three and it joins the same conversation, using the plain-name addressing and auto-spawn described above. The `bring-in-personas` skill is the single place that says how: the persona's reply is shown verbatim under its name, the main session's own view is kept separate, several named at once each show a reply, and the persona gets the owner's message plus a short neutral note of the conversation so far unless the owner says to leave it out.

Single-channel setups: on Discord one session owns the channel, so it stays the router and relays. It follows the same verbatim, labeled and context rules. A truly separate channel per persona is not something this plugin controls.
