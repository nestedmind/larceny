# Changelog

## 0.1.3

- The reviewer is now Amy (she/her) and the advisor is now Yoda (he/him). Tbag and Linc are removed, with no aliases (#133, #135, #136).
- The reviewer, advisor and teacher each have a named agent file (`amy`, `yoda`, `sara`) and a role alias (`reviewer`, `advisor`, `teacher`) (#133, #134).
- `larceny:reviewer` is new, and the coordinator now dispatches it instead of a named reviewer (#134, #135).
- Renaming the reviewer, advisor or teacher now swaps only the opening line of the prompt, which is copied from the spawn command (#135, #136).

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

- The plugin scaffold, MIT licence and manifests, with the installed name and owner set to Nestedmind (#14, #41, #42, #43, #51).
- The workflow skills: code review, receiving review, review-comment triage, changelog and post-PR, test-driven development, systematic debugging, verification, worktrees, plain writing, planning, PR conventions, secure coding and adversarial review (#22, #23, #24, #25, #27, #30, #31, #32, #34, #35, #38, #46, #69).
- The personas and agents: the coordinator, the reviewer, the bundled coders, and the spawn commands for the reviewer, advisor and teacher (#33, #36, #39, #49, #90).
- The `/onboard` command and skill, with a first-run introduction, model choices, and a shared coder skill. Commands and skills follow a renamed coordinator, coders and personas, and the repo is renamed from inmates to larceny (#47, #59, #75, #78, #79, #85, #87, #98, #99, #102).
- The reviewer posts real inline review comments, and a chat message to the coder does not count as a review (#97, #100).
- Guardrails and docs: a check that fails a PR that changes shipped files without a version bump, commit identity set per command, one `<repo>-wt/` worktree container, and the README, limitations, smoke test, uninstall and identity-wiring docs (#17, #28, #21, #37, #40, #54, #58, #60, #62, #65, #67, #73, #92, #104).
