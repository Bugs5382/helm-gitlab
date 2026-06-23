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
# On `git push`, gives fast feedback: blocks if there are uncommitted changes or
# if a quick test pass fails for the detected ecosystem. The git pre-push hook is
# the authoritative gate; this just shortens the feedback loop.
set -euo pipefail
PY="$(command -v python3 || echo /usr/bin/python3)"
input="$(cat)"
cmd="$(printf '%s' "$input" | "$PY" -c 'import json,sys
try: print(json.load(sys.stdin).get("tool_input",{}).get("command",""))
except Exception: print("")')"

case "$cmd" in *"git push"*) ;; *) exit 0 ;; esac

deny() {
  "$PY" -c 'import json,sys
print(json.dumps({"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":sys.argv[1]}}))' "$1"
  exit 0
}

if ! git diff --quiet --exit-code 2>/dev/null; then
  deny "Uncommitted changes present. Commit or stash before pushing."
fi
if [ -f go.mod ]; then
  if ! go test -short ./... >/dev/null 2>&1; then
    deny "Quick test pass failed (go test -short ./...). Fix before pushing."
  fi
fi
exit 0
