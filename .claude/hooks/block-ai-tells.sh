#!/usr/bin/env bash
# Apache License 2.0
#
# Copyright 2026 Shane
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# Claude Code PreToolUse hook (matcher: Bash).
# Blocks git commit / gh issue|pr create|comment commands whose message, title,
# or body contains an AI tell or emoji. Advisory layer; the git hooks enforce.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$DIR/lib.sh"

PY="$(command -v python3 || echo /usr/bin/python3)"
input="$(cat)"
cmd="$(printf '%s' "$input" | "$PY" -c 'import json,sys
try: print(json.load(sys.stdin).get("tool_input",{}).get("command",""))
except Exception: print("")')"

case "$cmd" in
  *"git commit"*|*"gh issue create"*|*"gh pr create"*|*"gh issue comment"*|*"gh pr comment"*) ;;
  *"gh api"*comment*) ;;
  *) exit 0 ;;
esac

tells="$(printf '%s' "$cmd" | gov_find_text_tells)"
if [ -n "$tells" ]; then
  reason="Blocked: AI-tell in a commit/issue/PR command. Remove attribution trailers (Co-Authored-By, Generated with) and session/AI references, then retry. Matched: ${tells}"
  "$PY" -c 'import json,sys
print(json.dumps({"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":sys.argv[1]}}))' "$reason"
fi
exit 0
