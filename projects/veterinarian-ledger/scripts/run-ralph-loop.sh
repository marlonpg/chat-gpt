#!/usr/bin/env bash
set -uo pipefail

# Ralph Loop for Codex-like CLI tools.
# Repeatedly calls an agent command with a per-iteration prompt until all tasks are done.

MAX_ITERATIONS=30
MAX_RETRIES=3
RETRY_DELAY=5
SLEEP_BETWEEN_ITERATIONS=2

TASK_ID=""
REPO_PATH="$(pwd)"
WORK_DIR=""
PRD_FILE=""
PROGRESS_FILE=""
LOG_DIR=""
AGENT_CMD="codex"
AGENT_ARGS="exec --skip-git-repo-check"

usage() {
  cat <<USAGE
Usage: $0 --task <TASK-ID> --repo <REPO_PATH> --workdir <REL_OR_ABS_WORKDIR> [options]

Required:
  --task <TASK-ID>
  --repo <REPO_PATH>
  --workdir <PATH>            Project directory containing PRD/tasks.

Optional:
  --prd <FILE>                Defaults to <workdir>/PRD.md
  --progress <FILE>           Defaults to <workdir>/progress.txt
  --log-dir <DIR>             Defaults to <workdir>/logs
  --agent-cmd <CMD>           Defaults to: codex
  --agent-args <ARGS>         Defaults to: "exec --skip-git-repo-check"
  --max-iterations <N>        Defaults to: 30
  --max-retries <N>           Defaults to: 3
  --retry-delay <SEC>         Defaults to: 5
  --sleep-between <SEC>       Defaults to: 2

Task source:
  The loop reads tasks from <workdir>/tasks.txt (one task per line; blank lines ignored).
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --task) TASK_ID="$2"; shift 2 ;;
    --repo) REPO_PATH="$2"; shift 2 ;;
    --workdir) WORK_DIR="$2"; shift 2 ;;
    --prd) PRD_FILE="$2"; shift 2 ;;
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

if [[ -z "$TASK_ID" || -z "$REPO_PATH" || -z "$WORK_DIR" ]]; then
  usage
  exit 1
fi

if [[ "$WORK_DIR" != /* ]]; then
  WORK_DIR="$REPO_PATH/$WORK_DIR"
fi

TASKS_FILE="$WORK_DIR/tasks.txt"
PRD_FILE="${PRD_FILE:-$WORK_DIR/PRD.md}"
PROGRESS_FILE="${PROGRESS_FILE:-$WORK_DIR/progress.txt}"
LOG_DIR="${LOG_DIR:-$WORK_DIR/logs}"
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
LOG_FILE="$LOG_DIR/ralph-loop-${TASK_ID}-${TIMESTAMP}.log"

if [[ ! -f "$TASKS_FILE" ]]; then
  echo "ERROR: missing tasks file: $TASKS_FILE"
  exit 1
fi

mkdir -p "$LOG_DIR"
touch "$PROGRESS_FILE" "$LOG_FILE"

mapfile -t TASKS < <(sed '/^[[:space:]]*$/d' "$TASKS_FILE")
TOTAL_TASKS="${#TASKS[@]}"

if [[ "$TOTAL_TASKS" -eq 0 ]]; then
  echo "ERROR: no tasks found in $TASKS_FILE"
  exit 1
fi

log() {
  local msg="[$(date +%H:%M:%S)] $*"
  echo "$msg"
  echo "$msg" >> "$LOG_FILE"
}

get_completed_tasks() {
  if [[ -f "$PROGRESS_FILE" ]]; then
    local count
    count=$(grep -Ec '^DONE:|^SKIP:' "$PROGRESS_FILE" 2>/dev/null || true)
    echo "${count:-0}"
  else
    echo 0
  fi
}

get_next_task() {
  local completed
  completed=$(get_completed_tasks)
  if [[ "$completed" -ge "$TOTAL_TASKS" ]]; then
    echo ""
  else
    echo "${TASKS[$completed]}"
  fi
}

spinner_start() {
  local pid=$1
  local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  local i=0
  local start_time=$SECONDS
  while kill -0 "$pid" 2>/dev/null; do
    local elapsed=$(( SECONDS - start_time ))
    printf "\r  [%s] Working... %02dm %02ds " "${spin:i++%${#spin}:1}" "$((elapsed/60))" "$((elapsed%60))"
    sleep 0.2
  done
  printf "\r%80s\r" ""
}

build_prompt() {
  local task="$1"
  local iteration="$2"
  local completed
  completed=$(get_completed_tasks)

  local progress_context=""
  if [[ -s "$PROGRESS_FILE" ]]; then
    progress_context=$(cat "$PROGRESS_FILE")
  fi

  cat <<PROMPT
You are implementing TASK_ID=$TASK_ID in repository: $REPO_PATH
Working directory for implementation: $WORK_DIR
Read PRD/spec at: $PRD_FILE

PROGRESS SO FAR ($completed/$TOTAL_TASKS):
$progress_context

CURRENT TASK (iteration $iteration):
$task

INSTRUCTIONS:
1) Implement ONLY the current task scope.
2) If a dependency is missing, create minimal stub + proceed.
3) Run relevant checks/tests for changed area.
4) Commit your changes with clear message.
5) Push your branch.
6) Append one line to $PROGRESS_FILE in one of these formats:
   DONE: <task> | <summary>
   SKIP: <task> | <reason>
7) Do not edit unrelated files.
PROMPT
}

log "========================================="
log "Ralph Loop — Veterinarian Ledger"
log "Task ID: $TASK_ID"
log "Total tasks: $TOTAL_TASKS"
log "Max iterations: $MAX_ITERATIONS"
log "Max retries: $MAX_RETRIES"
log "Progress file: $PROGRESS_FILE"
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
    else
      log "FAILED attempt $retry/$MAX_RETRIES (exit=$exit_code)"
      if [[ "$retry" -lt "$MAX_RETRIES" ]]; then
        log "Retrying in ${RETRY_DELAY}s..."
        sleep "$RETRY_DELAY"
      fi
    fi
  done

  if [[ "$success" == false ]]; then
    log "ERROR: all retries failed, marking task as SKIP"
    echo "SKIP: $task | failed after $MAX_RETRIES retries in iteration $i" >> "$PROGRESS_FILE"
  fi

  new_completed=$(get_completed_tasks)
  if [[ "$new_completed" -le "$completed" ]]; then
    log "WARNING: agent did not append DONE/SKIP; appending DONE automatically"
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
