---
Title: Create Backlog
Description: Create a product backlog for a greenfield project based on user-provided project documentation (vision, data model, architecture, UI flow spec, project plan, etc.), and write it to `backlog.md` at the user-provided path.
Output: backlog.md
---

# Create Backlog (AI Agent Instruction)

You are tasked with creating a high-quality product backlog for a greenfield project using the project’s documentation as the single source of truth. You must work **interactively and iteratively** with the user: produce a strong first draft, surface gaps/risks, ask targeted questions only when needed, and refine until the backlog is implementation-ready.

## Goals

1. **Read and understand** the project documentation end-to-end.
2. Produce a prioritized backlog of **Epics → User Stories → Tasks** with clear acceptance criteria.
3. Ensure backlog sequencing supports **buildability, testability, and risk reduction**.
4. Write the final backlog to **`backlog.md`** in the **exact file path provided by the user**.

## Operating Principles

- **Be skeptical and precise.** Do not invent requirements. If documentation is unclear, mark assumptions explicitly and ask focused questions.
- **Prefer small, testable increments.** Stories should be deliverable and verifiable.
- **Bias toward an MVP first**, then enhancements, then nice-to-haves—unless the docs explicitly require otherwise.
- **Traceability matters.** Every epic/story should reference the source document section it came from (short references, not long quotes).
- **Not too wordy.** Keep stories concise, tasks actionable, and criteria measurable.

---

## Required Inputs

### Must have
- A **path** to the project documentation directory (or list of file paths).
- The list of documentation files to use (or permission to enumerate the directory).

### If missing
- If **no documentation path** is provided, ask for it.
- If the user provides a path but no file list, enumerate the directory and confirm which files should be included (unless the environment already guarantees “all files under path”).

---

## Process

### 0) Setup a working checklist (internal)
Create a small checklist to track progress while you work:
- [ ] Locate and read all documentation
- [ ] Extract scope, users, workflows, constraints
- [ ] Draft epics
- [ ] Draft user stories + acceptance criteria
- [ ] Draft tasks per story (front-end / back-end / data / infra / QA)
- [ ] Prioritize & sequence (MVP → V1 → V2)
- [ ] Identify open questions / assumptions / risks
- [ ] Produce `backlog.md` at target path

### 1) Context Gathering & Document Reading (mandatory)
When given a path to project documentation:

1. **Read all mentioned files immediately and FULLY.**
   - **IMPORTANT:** Use the Read tool **without** limit/offset parameters.
   - **NEVER** read files partially—if a file is in scope, read it completely.
   - **CRITICAL:** Do **not** create backlog items before reading the documentation yourself in the main context.

2. Build a quick internal map:
   - Product goals / non-goals
   - User types / personas
   - Major workflows and screens (UI flow)
   - Data objects (data model)
   - System boundaries and integrations (architecture)
   - Constraints (security, privacy, performance, platforms)
   - Milestones (project plan)

3. Extract requirements into a structured list:
   - Functional requirements
   - Non-functional requirements
   - Known unknowns / TBDs / risks

### 2) Backlog Construction
Create a backlog with these levels:

#### Epics
High-level capability groups aligned to the documentation (e.g., “Expense Entry”, “Search & Filter”, “Recurring Transactions”, “Analytics”, “Sync/Storage”, “Auth & Settings”, etc.).

Each epic includes:
- Summary
- In-scope / out-of-scope notes (brief)
- Dependencies (if any)
- Source references

#### User Stories
User stories are short, user-centered descriptions of desired behavior.

Each story must include:
- **Story statement**: “As a <user>, I want <capability>, so that <benefit>.”
- **Acceptance Criteria** (clear, testable bullets; aim for 3–7)
- **Dependencies** (if relevant)
- **Notes / assumptions** (only when necessary)
- **Source reference**

**Story sizing guidance**
- Prefer stories that can be completed within a small iteration.
- Split stories by workflow step, platform layer, or risk area (e.g., UI capture vs persistence vs reporting).

#### Tasks
Tasks are implementation actions derived from stories. They should be concrete and unambiguous.

Tasks should be grouped when helpful:
- Frontend / UI
- Backend / API (if applicable)
- Data / persistence
- Infrastructure / DevOps
- QA / testing
- Documentation

Each task should include:
- Action-oriented title (verb-first)
- Short description of what “done” means
- Optional: estimate placeholder (leave blank if user doesn’t want estimates)

### 3) Prioritization & Sequencing (buildable + testable)
Order work to reduce risk and enable incremental delivery.

Use these sequencing rules unless documentation contradicts:
1. **Foundations first**: repo setup, CI, basic app shell, data persistence scaffolding.
2. **Core data model + storage** before features that depend on them.
3. **Critical flows** before secondary flows:
   - Example: auth/login and database setup before data insertion and downstream analytics.
4. **Vertical slices**: deliver end-to-end thin functionality early (UI → data → view).
5. **Observability and testing** built in early (logging, basic tests, error handling).
6. **Hard/unknown parts early**: integrations, permissions, performance hotspots.

### 4) Identify Gaps, Risks, and Questions
Create a short section listing:
- Open questions (only what blocks or materially changes scope)
- Assumptions made (explicit)
- Risks + mitigation ideas
- Suggested next documentation updates (if needed)

Keep this section crisp. The goal is to unblock backlog correctness.

### 5) Iterative Refinement Loop
After the first draft:
- Ask the user a **small set of targeted questions** (max ~5–10) that meaningfully impact backlog structure or priority.
- Revise backlog based on user responses.
- Repeat until the backlog meets “implementation-ready” quality.

---

## Output Requirements

### File output
- Write a Markdown file named **`backlog.md`** to the **exact directory path provided by the user**.
- If the path is invalid or not writable, report the problem clearly and ask for a corrected path.

### Backlog.md structure (required)
`backlog.md` must follow this structure:

1. **Overview**
   - Product summary (2–5 bullets)
   - Scope boundaries (in / out)
   - Key assumptions (if any)

2. **Backlog Summary**
   - A short list of epics in priority order

3. **Detailed Backlog**
   - Epic sections, each containing:
     - Epic summary
     - User stories (with acceptance criteria)
     - Tasks per story
     - Epic/story/task should have checkbox allow check off when completed.

4. **Dependencies & Milestones**
   - Notable cross-epic dependencies
   - Mapping to phases/milestones if project plan exists (MVP/V1/V2)

5. **Open Questions / Risks**
   - Questions
   - Risks
   - Mitigations
   - Documentation gaps

### Style rules
- Use concise, actionable language.
- Use consistent IDs:
  - Epics: `E-01`, `E-02`, …
  - Stories: `US-01.01` (epic.story)
  - Tasks: `T-01.01.01` (epic.story.task)
- Avoid long prose. Prefer bullet lists.
- Acceptance criteria must be testable and not vague (avoid “works well”, “fast”, “intuitive” without measurable criteria).

---

## Quality Bar (Definition of Done)

The backlog is considered complete when:
- All major requirements from documentation are represented as epics/stories/tasks.
- Stories have clear acceptance criteria and reasonable splits.
- Sequencing enables a safe MVP delivery path.
- Assumptions are explicit and questions are limited to true blockers.
- `backlog.md` is written to the provided path with the required structure.

--- 

## Failure Modes to Avoid

- Creating backlog items **before** reading the full documentation.
- Hallucinating features not supported by the docs.
- Writing “tasks” that are actually vague goals.
- Producing only a flat list without epics/stories/criteria.
- Overloading the backlog with premature optimizations or gold-plating.

