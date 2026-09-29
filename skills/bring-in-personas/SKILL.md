---
name: bring-in-personas
description: Use when you run as the main session (coordinator, teacher or advisor) and the owner names another of the three ("ask the advisor", "Sara, what do you think?", "all three of you"). Brings that persona into the same conversation and shows its reply verbatim.
---

# Bringing personas into the conversation

The coordinator, teacher and advisor can each run as the main session (`claude --agent larceny:coordinator`, `larceny:teacher`, `larceny:advisor`). Whichever one you are, the owner may name another of the three at any time and expect it to join the same conversation. This skill is the only place that behavior is written down.

## Who counts

Resolve each name by `docs/crew-resolution.md`: `coders:` (first name) for the coordinator, `teacher:`, `advisor:`, with the persona's file looked up in the project's `.claude/agents/` and then `~/.claude/agents/`. Match the owner's words against the resolved names and against the role words ("the teacher", "the advisor", "the coordinator"). Do not bring in the reviewer or a coder unless the owner asks for them by name; that is the ordinary "Addressing a persona" relay.

## Steps

1. Address the persona by plain name, as `docs/agent-lifecycle.md` "Addressing a persona" says: `SendMessage({to: "<name>", ...})`. Do not use an `@name` prefix.
2. If `ListAgents` shows no live agent by that name, auto-spawn it first as "Auto-spawn on first mention" in the same doc says, then send the message. Say once that you started it. You never spawn yourself: if the owner names the persona you are, answer as yourself.
3. Send the owner's message as written, plus a short neutral note of the conversation so far, written by you and free of your own opinion. If the owner says to leave the context out ("without the background", "cold"), send only their message. The persona's own context rules still apply: it names no project the owner has not named and reads nothing in a repository until told.
4. Show the reply to the owner verbatim, under a label with the persona's name, for example `Sara:` on its own line, then the reply unedited. Never paraphrase, condense, merge or reorder it.
5. You may add your own view after the reply, under your own label, kept clearly apart. Do not replace or trim theirs.
6. When the owner names several at once ("all three of you", "ask Sara and Yoda"), send each its message, then show every reply in full under its own label. The one you are answers directly, under your own label, and does not paraphrase the others.
7. Persona-to-persona chatter needs an owner message driving it. Do not have brought-in personas talk to each other on their own.

## Single-channel setups (Discord and similar)

When one session owns the channel, that session is the router: the owner's messages reach only it, and it relays to the others. Steps 3 to 6 apply unchanged, so replies still appear verbatim and labeled. A separate channel per persona is not something this plugin controls, and you do not try to create one.
