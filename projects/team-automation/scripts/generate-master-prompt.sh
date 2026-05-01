#!/usr/bin/env bash
set -euo pipefail

TASK_ID=""
FEATURE=""
REPO_PATH="$(pwd)"
PROJECT_DIR=""
FRAMEWORK_DIR="projects/team-automation"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --task) TASK_ID="$2"; shift 2 ;;
    --feature) FEATURE="$2"; shift 2 ;;
    --repo) REPO_PATH="$2"; shift 2 ;;
    --project-dir) PROJECT_DIR="$2"; shift 2 ;;
    --framework-dir) FRAMEWORK_DIR="$2"; shift 2 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

if [[ -z "$TASK_ID" || -z "$FEATURE" || -z "$PROJECT_DIR" ]]; then
  echo "Usage: $0 --task <TASK-ID> --feature <FEATURE> --project-dir <PATH> [--repo <PATH>] [--framework-dir <PATH>]"
  exit 1
fi

[[ "$PROJECT_DIR" == /* ]] || PROJECT_DIR="$REPO_PATH/$PROJECT_DIR"
[[ "$FRAMEWORK_DIR" == /* ]] || FRAMEWORK_DIR="$REPO_PATH/$FRAMEWORK_DIR"

RUNTIME_DIR="$FRAMEWORK_DIR/runtime/$TASK_ID"
mkdir -p "$RUNTIME_DIR"
MASTER_PROMPT_FILE="$RUNTIME_DIR/master-prompt.md"

cat > "$MASTER_PROMPT_FILE" <<PROMPT
# Team Automation Master Prompt

Execute one complete Ralph-loop cycle for:
- TASK_ID: $TASK_ID
- FEATURE: $FEATURE
- PROJECT_DIR: $PROJECT_DIR
- FRAMEWORK_DIR: $FRAMEWORK_DIR

Use these role specs:
- $FRAMEWORK_DIR/agents/product-owner.md
- $FRAMEWORK_DIR/agents/architect.md
- $FRAMEWORK_DIR/agents/ux-designer.md
- $FRAMEWORK_DIR/agents/backend-developer.md
- $FRAMEWORK_DIR/agents/frontend-developer.md
- $FRAMEWORK_DIR/agents/orchestrator.md

Rules:
- Product outputs stay in project directory.
- Framework artifacts stay in framework directory.
- Include commit/push steps for implementation roles.
- End with orchestrator validation and next queued task.
PROMPT

echo "Generated: $MASTER_PROMPT_FILE"
