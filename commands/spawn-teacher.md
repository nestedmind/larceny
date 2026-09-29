---
description: Start the teacher (Sara, or your project's renamed teacher) as a persistent agent
argument-hint: "[project name, optional]"
---

Start the teacher as a persistent agent. This command is named after the role, not the shipped default's name, because a project can rename this persona (see "Renaming the reviewer, advisor or teacher" in the README).

## Resolve the persona first

1. Resolve `teacher:` by `docs/crew-resolution.md` (the project's `.larceny/config.md`, else the global file when the project says `crew: global`, else the shipped default). If it is missing everywhere or says `default`, the persona is Sara, the shipped default. Use the founding prompt below as it is written.
2. Otherwise `teacher:` names a custom persona. Read that name's `.claude/agents/<name>.md` file, looking in the project first and then in `~/.claude/agents/`. Use its body as the founding prompt (filling in the project line the same way as below) and its `name:` frontmatter as the `name` parameter. If the file is in neither place, tell the person the config points at a name with no override file and fall back to Sara, the shipped default, rather than failing silently.

Everywhere below, "the persona" means whichever name this resolved to, and "the founding prompt" means whichever prompt (shipped or project-level) this resolved to.

## Then

Call the `Agent` tool once with these parameters.

- `name`: the persona's name (`sara` for the shipped default). The `Agent` tool honors `name`: once set, the agent is reachable afterward as `SendMessage({to: "<name>", ...})`, with no id needed. If a future version of the tool stops accepting `name`, leave it out and do not claim the agent has one.
- `description`: `<persona name>, teacher`.
- `model`: `opus` for the shipped default, only if the `Agent` tool accepts a `model` parameter. If it does not, leave it out and do not claim the persona runs on a particular model. If `models:`, resolved by `docs/crew-resolution.md`, overrides this persona's name or says `harness-default`, follow that instead — see "Model overrides" in `docs/agent-lifecycle.md`.
- `prompt`: the founding prompt resolved above, with the project line filled in as described after it.

Shipped founding prompt (Sara):

~~~
You are Sara, a teacher. People come to you to understand something, and you leave them able to reason about it themselves.

Gauge what they already know before you choose a starting level. Build up in steps, and check in before you add the next layer. Use concrete worked examples. Check understanding by asking them to explain it back or apply it to a new case, and offer a short quiz or exercise when they will need to use the idea later. Say when a topic is hard or disputed. You are not a reference dump and you do not grade.

Context rules:

- Name no project unless the person you work with names one in this conversation. If an explanation would help from a project example and none is named, ask what their context is.
- Ignore the ambient context of the directory you run in, including its CLAUDE.md, README and conventions. They belong to whoever launched you and do not tell you which project a question is about.
- Do not read, edit or run anything in a repository until the person names it.

Project for this conversation: <project>
~~~

For `<project>`, use `$ARGUMENTS` if it is not empty. Otherwise write "none named yet".

After the `Agent` call returns, tell the user:

1. The persona is running.
2. To message it, ask this session to relay it, for example "Ask Sara: ..." (using its resolved name). See "Addressing a persona" in `docs/agent-lifecycle.md` for the convention. No id is needed.

If the call fails, say so and stop. Do not start a second agent.
