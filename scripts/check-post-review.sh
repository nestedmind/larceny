#!/usr/bin/env bash
# Tests skills/adversarial-review/post-review.sh against a fake `gh`.
# Run from anywhere. Exits non-zero and prints each problem when a check fails.
set -u
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
script="$root/skills/adversarial-review/post-review.sh"
fail=0
bad() { echo "FAIL: $1"; fail=1; }

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/cfg"
export LARCENY_CONFIG_DIR="$tmp/cfg"
export FAKE_LOG="$tmp/gh.log"
export FAKE_BODY="$tmp/posted-body"
export PATH="$tmp/bin:$PATH"

# Fake gh. It logs each call with the token it ran under, and answers from
# environment variables so each case can set the reviewer login it "sees".
cat > "$tmp/bin/gh" <<'EOF'
#!/usr/bin/env bash
echo "GH_TOKEN=${GH_TOKEN:-none} $*" >> "$FAKE_LOG"
case "$*" in
  "api user"*) echo "${FAKE_TOKEN_LOGIN:-amy-ns}" ;;
  "pr view"*) echo "abc1234def5678" ;;
  "api repo"*"/reviews"*"--input"*)
    cat > /dev/null 2>&1 || true
    echo "${FAKE_POST_RESPONSE:-{\"id\":77}}" ;;
  "api"*"/reviews"*) echo "${FAKE_READBACK:-77 amy-ns APPROVED abc1234def5678}" ;;
  "pr comment"*)
    while [ $# -gt 0 ]; do
      [ "$1" = "--body-file" ] && cp "$2" "$FAKE_BODY"
      shift
    done ;;
  *) echo "unexpected gh call: $*" >&2; exit 9 ;;
esac
EOF
chmod +x "$tmp/bin/gh"

printf 'APPROVED at abc1234. Looks right.\n' > "$tmp/body.txt"
printf 'sekrit-token-value\n' > "$tmp/cfg/gh-amy-token"
chmod 600 "$tmp/cfg/gh-amy-token"

run() { : > "$FAKE_LOG"; out="$("$script" "$@" 2>&1)"; rc=$?; }

# 1. Token present: posts a formal review under the token, reads the author back.
run amy 5 approve "$tmp/body.txt"
[ "$rc" -eq 0 ] || bad "token present: exit $rc, expected 0 ($out)"
grep -q 'GH_TOKEN=sekrit-token-value api repos/{owner}/{repo}/pulls/5/reviews' "$FAKE_LOG" \
  || bad "token present: review was not posted with the persona token"
echo "$out" | grep -q 'amy-ns' || bad "token present: output does not name the author"
echo "$out" | grep -q 'sekrit-token-value' && bad "token present: token printed"
grep -q 'pr comment' "$FAKE_LOG" && bad "token present: posted a plain comment"

# 2. Readback shows another login: the script must fail.
FAKE_READBACK='77 mattoranking COMMENTED abc1234def5678' run amy 5 approve "$tmp/body.txt"
[ "$rc" -ne 0 ] || bad "wrong author on readback: exit 0, expected failure"

# 3. Readback shows the right login on a stale commit: must fail.
FAKE_READBACK='77 amy-ns APPROVED 0000000000000' run amy 5 approve "$tmp/body.txt"
[ "$rc" -ne 0 ] || bad "stale commit on readback: exit 0, expected failure"

# 4. Token file exists but is unreadable: refuse, post nothing.
if [ "$(id -u)" -ne 0 ]; then
  chmod 000 "$tmp/cfg/gh-amy-token"
  run amy 5 approve "$tmp/body.txt"
  [ "$rc" -ne 0 ] || bad "unreadable token: exit 0, expected failure"
  [ -s "$FAKE_LOG" ] && bad "unreadable token: gh was called"
  chmod 600 "$tmp/cfg/gh-amy-token"
fi

# 5. No token file: comment via the ambient login, first line names the author.
rm "$tmp/cfg/gh-amy-token"
run amy 5 approve "$tmp/body.txt"
[ "$rc" -eq 0 ] || bad "no token: exit $rc, expected 0 ($out)"
grep -q 'GH_TOKEN=none pr comment 5' "$FAKE_LOG" || bad "no token: did not post a plain comment under the ambient login"
grep -q 'pulls/5/reviews' "$FAKE_LOG" && bad "no token: tried a formal review"
first="$(head -n 1 "$FAKE_BODY" 2>/dev/null)"
[ "$first" = "Amy (reviewer persona), posted via the owner's login because no persona account is configured." ] \
  || bad "no token: first line of the comment is '$first'"
grep -q '^APPROVED at abc1234' "$FAKE_BODY" 2>/dev/null || bad "no token: comment lost the verdict text"

# 6. Bad verdict word is rejected.
run amy 5 shrug "$tmp/body.txt"
[ "$rc" -ne 0 ] || bad "bad verdict: exit 0, expected failure"

exit "$fail"
