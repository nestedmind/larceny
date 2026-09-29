# Changelog

## Unreleased

- The coordinator resolves its name quietly and goes straight to the status report. It only says how it resolved the name when you need to act. The old `scofield` skill name is removed: override files must say "follow the `coordinator` skill" (#140).

## 0.1.3

- The reviewer is now Amy (she/her) and the advisor is now Yoda (he/him). Tbag and Linc are removed, with no aliases (#133, #135, #136).
- The reviewer, advisor and teacher each have a named agent file (`amy`, `yoda`, `sara`) and a role alias (`reviewer`, `advisor`, `teacher`) (#133, #134).
- `larceny:reviewer` is new, and the coordinator now dispatches it instead of a named reviewer (#134, #135).
- Renaming the reviewer, advisor or teacher now swaps only the opening line of the prompt, which is copied from the spawn command (#135, #136).
- The uninstall steps now list the leftover persona agent files in each project's `.claude/agents/` folder and the global crew file (#139).

## 0.1.2

- Onboarding records the project board IDs, the coordinator checks them before it dispatches a ticket, and a coder always moves its card to In review (#117).
- The crew can be saved once per machine, so a new project skips the crew questions during onboarding (#118).
- The reviewer's approval counts only when it is a formal review from the reviewer's own account on the current head. A helper script posts the review and reads it back (#121).
- You can talk to the teacher and the advisor directly, and bring a persona into the conversation by naming it (#122).

## 0.1.1

- The version is set to 0.1.1 for the first real rollout (#107).
- The reviewer, advisor and teacher can be renamed the way the coordinator and coders can. The spawn commands are now `/larceny:spawn-reviewer`, `/larceny:spawn-advisor` and `/larceny:spawn-teacher`, and the coordinator skill is named `coordinator` (#108).
- The reviewer's instructions now say where to find its GitHub token, so its reviews post under its own account (#111).
- The README and onboarding say that the agents are AI and can make mistakes (#112).

## 0.1.0

- The plugin and its manifests, licensed MIT (#14, #41).
- Workflow skills for test-driven development, debugging, code review and adversarial review (#30, #32, #24, #36).
- The coordinator, reviewer and coder personas, with an onboarding command and model choices (#33, #47, #90).
- The coordinator and coders can be renamed (#78, #98).
- Personas can use their own GitHub accounts, and the reviewer posts real inline review comments (#17, #97).
