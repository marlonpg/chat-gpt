# Ralph Loop Workflow

A continuous delivery loop where specialized agents collaborate through explicit handoffs.

## Loop Stages
1. **Intake (Orchestrator + Product Owner)**
   - Capture task, intent, constraints.
2. **Clarification (Product Owner)**
   - Finalize acceptance criteria.
3. **Solutioning (Architect + UX Designer)**
   - Define technical approach and user flow.
4. **Implementation (Backend + Frontend Developers)**
   - Build in parallel or sequence as needed.
5. **Validation (UX + Orchestrator)**
   - Verify behavior and usability.
6. **Git Completion (All delivery roles)**
   - Commit, push, and prepare PR notes.
7. **Close/Next (Orchestrator)**
   - Mark done and pick next queued task.

## Handoff Contract
Each handoff must include:
- What was completed
- Evidence/checks
- Open risks/questions
- Required next action

## Blocking Rules
- No stage transition without handoff note.
- No closure without acceptance criteria mapping.
- No "done" status until commit and push are confirmed.
