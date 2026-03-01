#!/usr/bin/env bash
set -euo pipefail

TASK_ID=""
FEATURE=""
GOAL=""
DEADLINE=""
CONSTRAINTS=""
USERS=""
NFRS=""
STACK=""
REPO_PATH="$(pwd)"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --task) TASK_ID="$2"; shift 2 ;;
    --feature) FEATURE="$2"; shift 2 ;;
    --goal) GOAL="$2"; shift 2 ;;
    --deadline) DEADLINE="$2"; shift 2 ;;
    --constraints) CONSTRAINTS="$2"; shift 2 ;;
    --users) USERS="$2"; shift 2 ;;
    --nfrs) NFRS="$2"; shift 2 ;;
    --stack) STACK="$2"; shift 2 ;;
    --repo) REPO_PATH="$2"; shift 2 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

if [[ -z "$TASK_ID" || -z "$FEATURE" ]]; then
  echo "Usage: $0 --task <TASK-ID> --feature <FEATURE_NAME> [--goal <BUSINESS_GOAL>] [--deadline <DATE>] [--constraints <TEXT>] [--users <TEXT>] [--nfrs <TEXT>] [--stack <TEXT>] [--repo <PATH>]"
  exit 1
fi

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
RUNTIME_DIR="$BASE_DIR/runtime/$TASK_ID"
mkdir -p "$RUNTIME_DIR"

TASK_INPUT_FILE="$RUNTIME_DIR/task-input.md"
MASTER_PROMPT_FILE="$RUNTIME_DIR/master-prompt.md"

cat > "$TASK_INPUT_FILE" <<TASK
# Task Input

- TASK_ID: $TASK_ID
- FEATURE_NAME: $FEATURE
- BUSINESS_GOAL: ${GOAL:-TBD}
- DEADLINE: ${DEADLINE:-TBD}
- CONSTRAINTS: ${CONSTRAINTS:-TBD}
- TARGET_USERS: ${USERS:-TBD}
- NON_FUNCTIONAL_REQUIREMENTS: ${NFRS:-TBD}
- EXISTING_TECH_STACK: ${STACK:-TBD}
- REPO_PATH: $REPO_PATH
TASK

cat > "$MASTER_PROMPT_FILE" <<PROMPT
# Ralph-Loop Autopilot Prompt — Veterinarian Ledger

You must execute this task as a **full multi-agent Ralph loop** in one continuous run.
Act as: Orchestrator -> Product Owner -> Architect -> UX Designer -> Backend Developer -> Frontend Developer -> Orchestrator Validation.
Do not ask to switch roles manually; do all handoffs yourself and continue automatically.

## Task Context
- TASK_ID: $TASK_ID
- FEATURE_NAME: $FEATURE
- BUSINESS_GOAL: ${GOAL:-TBD}
- DEADLINE: ${DEADLINE:-TBD}
- CONSTRAINTS: ${CONSTRAINTS:-TBD}
- TARGET_USERS: ${USERS:-TBD}
- NON_FUNCTIONAL_REQUIREMENTS: ${NFRS:-TBD}
- EXISTING_TECH_STACK: ${STACK:-TBD}
- REPO_PATH: $REPO_PATH

## Mandatory Execution Rules
1. Follow role-by-role sequence with explicit handoff sections.
2. Produce concrete artifacts for each role.
3. Backend and Frontend roles must include:
   - implementation plan
   - test/check plan
   - git commands (pull/rebase, add, commit, push)
   - PR-ready summary
4. End with an orchestrator validation table mapping every acceptance criterion to evidence.
5. If an input is TBD, define a safe assumption and mark it explicitly.

## Required Output Sections
1. Orchestrator Kickoff
2. Product Owner Brief
3. Architect Design
4. UX Specification
5. Backend Delivery Plan
6. Frontend Delivery Plan
7. Orchestrator Closure (GO/NO-GO)

## Templates To Respect
- projects/veterinarian-ledger/templates/task-input.md
- projects/veterinarian-ledger/templates/handoff-template.md
- projects/team-automation/templates/task-card.md
- projects/team-automation/templates/handoff-note.md
- projects/team-automation/templates/pr-message.md
PROMPT

if [[ -x "$REPO_PATH/projects/team-automation/scripts/run-loop.sh" ]]; then
  bash "$REPO_PATH/projects/team-automation/scripts/run-loop.sh" --task "$TASK_ID" --title "$FEATURE" --repo "$REPO_PATH" >/dev/null
fi

cat <<OUT
Ralph-loop trigger initialized.

Generated files:
- $TASK_INPUT_FILE
- $MASTER_PROMPT_FILE

Next step (single action for you):
Copy and run this generated prompt in Codex/ChatGPT:
$MASTER_PROMPT_FILE
OUT
