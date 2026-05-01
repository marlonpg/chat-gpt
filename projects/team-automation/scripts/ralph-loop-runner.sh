#!/usr/bin/env bash
set -uo pipefail

# Team Automation Framework — Ralph Loop Runner
# Repeatedly calls an agent CLI command per task until project tasks are done.

MAX_ITERATIONS=30
MAX_RETRIES=3
RETRY_DELAY=5
SLEEP_BETWEEN_ITERATIONS=2

TASK_ID=""
REPO_PATH="$(pwd)"
PROJECT_DIR=""
FRAMEWORK_DIR="projects/team-automation"
PRD_FILE=""
TASKS_FILE=""
PROGRESS_FILE=""
LOG_DIR=""
AGENT_CMD="codex"
AGENT_ARGS="exec --skip-git-repo-check"

usage() {
  cat <<USAGE
Usage: $0 --task <TASK-ID> --repo <REPO_PATH> --project-dir <PATH> [options]

Required:
  --task <TASK-ID>
  --repo <REPO_PATH>
  --project-dir <PATH>        Project workspace (e.g. projects/veterinarian-ledger)

Optional:
  --framework-dir <PATH>      Defaults to: projects/team-automation
  --prd <FILE>                Defaults to: <project-dir>/PRD.md
  --tasks <FILE>              Defaults to: <project-dir>/tasks.txt
  --progress <FILE>           Defaults to: <project-dir>/progress.txt
  --log-dir <DIR>             Defaults to: <framework-dir>/logs
  --agent-cmd <CMD>           Defaults to: codex
  --agent-args <ARGS>         Defaults to: "exec --skip-git-repo-check"
  --max-iterations <N>        Defaults to: 30
  --max-retries <N>           Defaults to: 3
  --retry-delay <SEC>         Defaults to: 5
  --sleep-between <SEC>       Defaults to: 2
USAGE
}

abs_path() {
  local base="$1"
  local p="$2"
  if [[ "$p" == /* ]]; then echo "$p"; else echo "$base/$p"; fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --task) TASK_ID="$2"; shift 2 ;;
    --repo) REPO_PATH="$2"; shift 2 ;;
    --project-dir) PROJECT_DIR="$2"; shift 2 ;;
    --framework-dir) FRAMEWORK_DIR="$2"; shift 2 ;;
    --prd) PRD_FILE="$2"; shift 2 ;;
    --tasks) TASKS_FILE="$2"; shift 2 ;;
    --progress) PROGRESS_FILE="$2"; shift 2 ;;
    --log-dir) LOG_DIR="$2"; shift 2 ;;
    --agent-cmd) AGENT_CMD="$2"; shift 2 ;;
    --agent-args) AGENT_ARGS="$2"; shift 2 ;;
    --max-iterations) MAX_ITERATIONS="$2"; shift 2 ;;
    --max-retries) MAX_RETRIES="$2"; shift 2 ;;
    --retry-delay) RETRY_DELAY="$2"; shift 2 ;;
    --sleep-between) SLEEP_BETWEEN_ITERATIONS="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1"; usage; exit 1 ;;
  esac
done

if [[ -z "$TASK_ID" || -z "$REPO_PATH" || -z "$PROJECT_DIR" ]]; then
  usage
  exit 1
fi

PROJECT_DIR=$(abs_path "$REPO_PATH" "$PROJECT_DIR")
FRAMEWORK_DIR=$(abs_path "$REPO_PATH" "$FRAMEWORK_DIR")
PRD_FILE="$(abs_path "$REPO_PATH" "${PRD_FILE:-$PROJECT_DIR/PRD.md}")"
TASKS_FILE="$(abs_path "$REPO_PATH" "${TASKS_FILE:-$PROJECT_DIR/tasks.txt}")"
PROGRESS_FILE="$(abs_path "$REPO_PATH" "${PROGRESS_FILE:-$PROJECT_DIR/progress.txt}")"
LOG_DIR="$(abs_path "$REPO_PATH" "${LOG_DIR:-$FRAMEWORK_DIR/logs}")"

TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
LOG_FILE="$LOG_DIR/ralph-loop-${TASK_ID}-${TIMESTAMP}.log"

for required in "$PROJECT_DIR" "$FRAMEWORK_DIR"; do
  [[ -d "$required" ]] || { echo "ERROR: missing directory: $required"; exit 1; }
done
[[ -f "$TASKS_FILE" ]] || { echo "ERROR: missing tasks file: $TASKS_FILE"; exit 1; }

mkdir -p "$LOG_DIR"
touch "$PROGRESS_FILE" "$LOG_FILE"

mapfile -t TASKS < <(sed '/^[[:space:]]*$/d' "$TASKS_FILE")
TOTAL_TASKS="${#TASKS[@]}"
[[ "$TOTAL_TASKS" -gt 0 ]] || { echo "ERROR: no tasks found in $TASKS_FILE"; exit 1; }

log() {
  local msg="[$(date +%H:%M:%S)] $*"
  echo "$msg"
  echo "$msg" >> "$LOG_FILE"
}

get_completed_tasks() {
  grep -Ec '^DONE:|^SKIP:' "$PROGRESS_FILE" 2>/dev/null || true
}

get_next_task() {
  local completed
  completed=$(get_completed_tasks)
  if [[ "$completed" -ge "$TOTAL_TASKS" ]]; then echo ""; else echo "${TASKS[$completed]}"; fi
}

spinner_start() {
  local pid=$1 spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏' i=0 start_time=$SECONDS
  while kill -0 "$pid" 2>/dev/null; do
    local elapsed=$(( SECONDS - start_time ))
    printf "\r  [%s] Working... %02dm %02ds " "${spin:i++%${#spin}:1}" "$((elapsed/60))" "$((elapsed%60))"
    sleep 0.2
  done
  printf "\r%80s\r" ""
}

build_prompt() {
  local task="$1" iteration="$2" completed progress_context framework_pack
  completed=$(get_completed_tasks)
  progress_context=""
  [[ -s "$PROGRESS_FILE" ]] && progress_context=$(cat "$PROGRESS_FILE")

  framework_pack="$FRAMEWORK_DIR/frameworks/$(basename "$PROJECT_DIR")"

  cat <<PROMPT
You are operating the Team Automation framework Ralph loop.
Repository: $REPO_PATH
Project workspace: $PROJECT_DIR
Framework workspace: $FRAMEWORK_DIR
PRD: $PRD_FILE
Task file: $TASKS_FILE

Use specialist agents in this order for EACH iteration:
1) Product Owner
2) Architect
3) UX Designer
4) Backend Developer
5) Frontend Developer
6) Orchestrator validation

Agent definitions:
- $FRAMEWORK_DIR/agents/product-owner.md
- $FRAMEWORK_DIR/agents/architect.md
- $FRAMEWORK_DIR/agents/ux-designer.md
- $FRAMEWORK_DIR/agents/backend-developer.md
- $FRAMEWORK_DIR/agents/frontend-developer.md
- $FRAMEWORK_DIR/agents/orchestrator.md

If framework pack exists, apply its prompts/templates too:
- $framework_pack

PROGRESS SO FAR ($completed/$TOTAL_TASKS):
$progress_context

CURRENT TASK (iteration $iteration):
$task

Execution rules:
- Implement only current task scope.
- Keep all product code/artifacts inside $PROJECT_DIR.
- Keep framework/automation artifacts inside $FRAMEWORK_DIR.
- Run checks/tests relevant to changed code.
- Commit and push changes.
- Append one line to $PROGRESS_FILE:
  DONE: <task> | <summary>
  or
  SKIP: <task> | <reason>
PROMPT
}

log "========================================="
log "Team Automation Ralph Loop"
log "Task ID: $TASK_ID"
log "Project: $PROJECT_DIR"
log "Framework: $FRAMEWORK_DIR"
log "Total tasks: $TOTAL_TASKS"
log "Log file: $LOG_FILE"
log "Agent command: $AGENT_CMD $AGENT_ARGS"
log "========================================="

for ((i=1; i<=MAX_ITERATIONS; i++)); do
  task=$(get_next_task)
  if [[ -z "$task" ]]; then
    log "ALL TASKS COMPLETE ($i iterations used)."
    cat "$PROGRESS_FILE"
    exit 0
  fi

  completed=$(get_completed_tasks)
  log "-----------------------------------------"
  log "Iteration $i | Task $((completed+1))/$TOTAL_TASKS"
  log "$task"
  log "-----------------------------------------"

  prompt=$(build_prompt "$task" "$i")
  task_start=$SECONDS
  success=false

  for ((retry=1; retry<=MAX_RETRIES; retry++)); do
    log "Attempt $retry/$MAX_RETRIES..."
    (
      cd "$REPO_PATH" || exit 1
      # shellcheck disable=SC2086
      $AGENT_CMD $AGENT_ARGS "$prompt"
    ) 2>&1 | tee -a "$LOG_FILE" &
    agent_pid=$!

    spinner_start "$agent_pid"
    wait "$agent_pid"
    exit_code=$?
    elapsed=$(( SECONDS - task_start ))

    if [[ "$exit_code" -eq 0 ]]; then
      success=true
      log "Completed in $((elapsed/60))m $((elapsed%60))s"
      break
    fi

    log "FAILED attempt $retry/$MAX_RETRIES (exit=$exit_code)"
    if [[ "$retry" -lt "$MAX_RETRIES" ]]; then
      log "Retrying in ${RETRY_DELAY}s..."
      sleep "$RETRY_DELAY"
    fi
  done

  if [[ "$success" == false ]]; then
    log "ERROR: all retries failed, marking task as SKIP"
    echo "SKIP: $task | failed after $MAX_RETRIES retries in iteration $i" >> "$PROGRESS_FILE"
  fi

  new_completed=$(get_completed_tasks)
  if [[ "$new_completed" -le "$completed" ]]; then
    log "WARNING: agent did not append DONE/SKIP; auto-marking DONE"
    echo "DONE: $task | auto-marked done in iteration $i" >> "$PROGRESS_FILE"
  fi

  sleep "$SLEEP_BETWEEN_ITERATIONS"
done

log "MAX ITERATIONS REACHED ($MAX_ITERATIONS)."
log "Completed: $(get_completed_tasks)/$TOTAL_TASKS"
skipped=$(grep -c '^SKIP:' "$PROGRESS_FILE" 2>/dev/null || true)
log "Skipped: ${skipped:-0}"
cat "$PROGRESS_FILE"
exit 1
