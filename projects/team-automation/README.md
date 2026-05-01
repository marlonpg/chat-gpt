<<<<<<< ours
# Team Automation (Codex Agent Team)

This project bootstraps a **multi-agent ChatGPT/Codex team** that works in a continuous "Ralph loop" style process.

The team includes:
- Product Owner
- Architect
- Backend Developer
- Frontend Developer
- UX Designer
- Orchestrator (loop coordinator)

## Goals

- Define reusable agent specs in Markdown.
- Define skills required by each role.
- Provide scripts and templates for continuous orchestration.
- Standardize implementation flow with git discipline (branching, commits, pushes, PR-ready handoffs).

---

## Folder Structure

```text
projects/team-automation/
├── README.md
├── agents/
│   ├── orchestrator.md
│   ├── product-owner.md
│   ├── architect.md
│   ├── backend-developer.md
│   ├── frontend-developer.md
│   └── ux-designer.md
├── skills/
│   ├── common-workflow.md
│   ├── git-ops.md
│   ├── requirements-management.md
│   ├── architecture-design.md
│   ├── backend-delivery.md
│   ├── frontend-delivery.md
│   └── ux-research-design.md
├── workflows/
│   └── ralph-loop.md
├── templates/
│   ├── task-card.md
│   ├── handoff-note.md
│   └── pr-message.md
└── scripts/
    ├── run-loop.sh
    ├── handoff.sh
    └── status-report.sh
```

---

## How to Use

### 1) Create a work item
Use `templates/task-card.md` to describe the feature.

### 2) Start the team loop

```bash
bash projects/team-automation/scripts/run-loop.sh \
  --task TASK-001 \
  --title "Build user onboarding flow" \
  --repo /workspace/chat-gpt
```

This script logs orchestration steps into `projects/team-automation/logs/`.

### 3) Use the role specs
For each phase, run the corresponding role prompt from `agents/*.md`.

Example progression:
1. Product Owner creates acceptance criteria.
2. Architect proposes solution design.
3. UX Designer validates user flow.
4. Backend Developer implements APIs.
5. Frontend Developer implements UI.
6. Orchestrator verifies completion and requests commit/push/handoff.

### 4) Handoff notes between roles

```bash
bash projects/team-automation/scripts/handoff.sh \
  --task TASK-001 \
  --from "architect" \
  --to "backend-developer" \
  --summary "OpenAPI spec and data model approved"
```

### 5) Status report

```bash
bash projects/team-automation/scripts/status-report.sh --task TASK-001
```

---

## Commit & Push Policy for All Agents

Every delivery role must:
1. Pull latest branch state.
2. Implement scoped changes only.
3. Run role-relevant checks/tests.
4. Commit with meaningful message.
5. Push to remote branch.
6. Provide PR-ready summary in `templates/pr-message.md` structure.

Recommended commit format:
- `feat(team-automation): add backend endpoint for onboarding`
- `fix(team-automation): align UX copy with acceptance criteria`
- `docs(team-automation): update architecture decisions`

---

## Ralph Loop Operating Model

The loop is continuous and role-oriented:
- **Orchestrator** drives queue and role assignment.
- **Product Owner** clarifies "what" and "why".
- **Architect** defines "how".
- **UX Designer** optimizes interaction flow and usability.
- **Backend/Frontend Developers** deliver implementation.
- **Orchestrator** confirms DoD, coordinates git actions, and triggers next task.

Detailed flow is in `workflows/ralph-loop.md`.

---

## Extending the Team

You can add new roles by:
1. Creating a new file under `agents/`.
2. Defining role-specific skill references from `skills/`.
3. Updating `workflows/ralph-loop.md` to include new handoff stages.
4. Adding task templates for new responsibilities.

=======
=======
>>>>>>> theirs
# Team Automation Framework (Ralph Loop)

`team-automation` is the automation/framework layer.
Use it to run specialist agents in a loop against any project workspace.

## Separation of Concerns
- `projects/team-automation/` → framework assets only (agents, skills, scripts, logs, runtime).
- `projects/<your-project>/` → product assets only (PRD, tasks, source code, docs).

## Framework Structure
```text
projects/team-automation/
├── agents/
├── skills/
├── workflows/
├── templates/
├── frameworks/
│   └── veterinarian-ledger/
│       ├── prompts/
│       ├── task-input-template.md
│       └── handoff-template.md
├── scripts/
│   ├── ralph-loop-runner.sh
│   ├── generate-master-prompt.sh
│   ├── run-loop.sh
│   ├── handoff.sh
│   └── status-report.sh
├── logs/
└── runtime/
```

## First Command (True Iterative Ralph Loop)
From repo root:

```bash
bash projects/team-automation/scripts/ralph-loop-runner.sh \
  --task VET-001 \
  --repo /path/to/your/repo \
  --project-dir projects/veterinarian-ledger
```

This repeatedly calls your agent CLI per task iteration until all tasks are marked `DONE`/`SKIP`.

## Project Requirements
Your project directory (e.g. `projects/veterinarian-ledger`) should contain:
- `PRD.md`
- `tasks.txt` (one task per line)
- product code/docs only

## Optional: One-shot Prompt Generator

```bash
bash projects/team-automation/scripts/generate-master-prompt.sh \
  --task VET-001 \
  --feature "Intake + Billing MVP" \
  --project-dir projects/veterinarian-ledger \
  --repo /path/to/your/repo
```

## Agent CLI Override
Defaults: `codex exec --skip-git-repo-check`

```bash
bash projects/team-automation/scripts/ralph-loop-runner.sh \
  --task VET-001 \
  --repo /path/to/your/repo \
  --project-dir projects/veterinarian-ledger \
  --agent-cmd "claude" \
  --agent-args "--print"
```
<<<<<<< ours
>>>>>>> theirs
=======
>>>>>>> theirs
