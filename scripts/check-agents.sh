#!/usr/bin/env bash
# Static checks for the plugin's agent definitions. Run from anywhere.
# Exits non-zero and prints each problem when a check fails.
set -u
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail=0
bad() { echo "FAIL: $1"; fail=1; }

expected="scofield amy yoda sara sucre mahone sheba whip"
for name in $expected; do
  [ -f "$root/agents/$name.md" ] || bad "agents/$name.md is missing"
done

for f in "$root"/agents/*.md; do
  base="$(basename "$f" .md)"
  # Frontmatter: first block between the two --- lines.
  fm="$(awk 'NR==1&&$0!="---"{exit} NR>1&&$0=="---"{exit} NR>1{print}' "$f")"
  [ -n "$fm" ] || { bad "$base: no frontmatter"; continue; }
  n="$(printf '%s\n' "$fm" | sed -n 's/^name: *//p')"
  [ "$n" = "$base" ] || bad "$base: name '$n' does not match the file name"
  printf '%s\n' "$fm" | grep -q '^description: .\+' || bad "$base: no description"
  # model: must be present and one of the harness's known model names, so a
  # typo does not silently fall back to whatever the harness defaults to.
  m="$(printf '%s\n' "$fm" | sed -n 's/^model: *//p')"
  if [ -z "$m" ]; then
    bad "$base: no model"
  else
    case "$m" in
      sonnet|opus|haiku|fable) ;;
      *) bad "$base: model '$m' is not one of sonnet, opus, haiku, fable" ;;
    esac
  fi
  # Every preloaded skill must exist under skills/.
  for s in $(printf '%s\n' "$fm" | sed -n 's/^  - //p'); do
    [ -f "$root/skills/$s/SKILL.md" ] || bad "$base: skill '$s' has no skills/$s/SKILL.md"
  done
  # Public repo: no home paths, account names or fixed token paths.
  if grep -nE '/home/|/Users/|-ns\b|gh-[a-z]+-token' "$f" | grep -v 'gh-'"$base"'-token' >/dev/null; then
    bad "$base: contains a home path, an account name or another persona's token path"
  fi
done

# Coders share one behaviour source: the `coder` skill. Each thin agent
# file points at it instead of duplicating its rules.
for name in sucre mahone sheba whip; do
  grep -q '^  - coder$' "$root/agents/$name.md" 2>/dev/null || bad "$name: does not preload the coder skill"
  grep -qF 'the `coder` skill' "$root/agents/$name.md" 2>/dev/null || bad "$name: body does not say to follow the coder skill"
done

# The rules coders share must actually live in that one skill.
for phrase in 'exactly one ticket per dispatch' 'No approval, no merge' 'stop and report the block' 'git branch -D' 'main checkout'; do
  grep -q "$phrase" "$root/skills/coder/SKILL.md" 2>/dev/null || bad "skills/coder/SKILL.md: missing rule '$phrase'"
done

# The security skill is wired into every coder and the reviewer.
for name in sucre mahone sheba whip amy reviewer; do
  grep -q '^  - secure-coding$' "$root/agents/$name.md" 2>/dev/null || bad "$name: does not preload secure-coding"
done

# Direct teacher/advisor entry and the one shared bring-in-by-name skill.
for name in teacher advisor coordinator; do
  grep -q '^  - bring-in-personas$' "$root/agents/$name.md" 2>/dev/null || bad "$name: does not preload bring-in-personas"
  # The behavior lives only in the skill: no copy of its rules in an agent file.
  if grep -qiE 'verbatim|auto-spawn' "$root/agents/$name.md" 2>/dev/null; then bad "$name: duplicates bring-in-personas rules"; fi
done
grep -q 'verbatim' "$root/skills/bring-in-personas/SKILL.md" 2>/dev/null || bad "skills/bring-in-personas/SKILL.md: missing the verbatim rule"
# Each founding prompt exists in three copies: the spawn command (inside a
# ~~~ block), the named agent file and the generic alias (body or ~~~ block).
# Compare the whole prompt, from the "You are <name>," line up to the first
# line that is not part of it, and name every file that differs. That line is
# "Project for this conversation:" (spawn command), the closing ~~~ (spawn
# command and alias) or "When you run as the main session," (named agent file's
# footer, which is not part of the prompt). Blank lines at either end do not
# count. No copy is allowed to differ on purpose.
prompt_of() { # file persona-name
  awk -v who="$2" '
    !on && index($0, "You are " who ",") == 1 { on = 1 }
    on && (index($0, "Project for this conversation:") == 1 || $0 == "~~~" || index($0, "When you run as the main session,") == 1) { exit }
    on { print }
  ' "$1" | sed -e :a -e '/^[[:space:]]*$/{$d;N;ba' -e '}'
}
for set in teacher:sara:Sara advisor:yoda:Yoda; do
  role="${set%%:*}"; rest="${set#*:}"; file="${rest%%:*}"; who="${rest##*:}"
  ref="$(prompt_of "$root/commands/spawn-$role.md" "$who")"
  [ -n "$ref" ] || { bad "commands/spawn-$role.md: no founding prompt found"; continue; }
  for copy in "agents/$file.md" "agents/$role.md"; do
    [ "$(prompt_of "$root/$copy" "$who")" = "$ref" ] || bad "$copy: founding prompt differs from commands/spawn-$role.md"
  done
done
# The reviewer alias copies Amy's opening line.
ln="$(grep -m1 '^You are Amy,' "$root/agents/amy.md")"
[ -n "$ln" ] && grep -qF "$ln" "$root/agents/reviewer.md" 2>/dev/null || bad "agents/reviewer.md: shipped prompt differs from agents/amy.md"

# The crew-resolution rule and every reader of it.
"$root/scripts/check-crew-resolution.sh" || fail=1

[ "$fail" = 0 ] && echo "ok: agent definitions pass"
exit "$fail"
