# ExpenseTracker Product Backlog

## 1. Overview
- **Frictionless expense & receipt tracking for individuals/families** (see vision.md)
- **User-owned data**: Google Drive/Sheets as primary store; offline/SwiftData cache (product-plan.md)
- **Multi-receipt, recurring, rich metadata**: supports multiple receipts, rich tags, flexible recurrence (ui-flow-spec.md)
- **Collaborative, safe, and recoverable**: family sharing via sheet sharing, robust recovery (vision.md, product-plan.md)
- **MVP focus:** Buildable/testable verticals, no AI/"insight" features in MVP (product-plan.md)
**Scope boundaries:**
- **IN:** Expense/income tracking, multi-receipt, recurring, tags, categories, Google Drive/Sheet sync, local cache, family sharing, basic analytics
- **OUT:** Business features, advanced AI/insights, non-Google cloud provider, complex recurrence/series editing, fine-grained permissions

**Key assumptions:**
- User has a Google account
- User grants Drive/Sheets access
- Data model and UI flows as in ai/notes

## 2. Backlog Summary
- E-01: App Setup, Auth, Dataset Onboarding
- E-02: Expense/Income Entry & Management
- E-03: Receipt Management
- E-04: Recurring Transactions
- E-05: Analysis & Reporting
- E-06: Categories & Tags Management
- E-07: Sync, Recovery, & Cloud Integration
- E-08: Settings & Safety/Danger Zone

## 3. Detailed Backlog

### E-01: App Setup, Auth, Dataset Onboarding (vision.md, ui-flow-spec.md §1)
- [ ] **Epic summary:** End-to-end onboarding, Google auth, initial dataset discover/create, recovery.
  - **In-scope:** OAuth, folder/sheet setup, dataset pick/create, recovery/relink
  - **Dependencies:** Google APIs
- [ ] **US-01.01:** As a new user, I can sign in with Google and grant Drive/Sheets access.
    - **Acceptance Criteria:**
      - [ ] Google OAuth launches, requests correct scopes
      - [ ] Success/failure is shown, errors handled
      - [ ] Proceeds to next onboarding step on success
    - **Source:** ui-flow-spec.md 1.1, vision.md
    - **Tasks:**
      - [ ] T-01.01.01 Implement Google OAuth screen
      - [ ] T-01.01.02 Handle OAuth callback and error states
  
- [ ] **US-01.02:** As a user, I can select an existing dataset or create a new one on Drive
    - **Acceptance Criteria:**
      - [ ] App auto-detects eligible folders/files
      - [ ] User can view found dataset summary
      - [ ] User can trigger new dataset creation
      - [ ] Creation sets up correct Drive folders/sheet/tabs
    - **Source:** ui-flow-spec.md 1.2-1.3, google-drive-folder-architecture.md
    - **Tasks:**
      - [ ] T-01.02.01 Auto-detect dataset/folder
      - [ ] T-01.02.02 Show dataset summary/selection
      - [ ] T-01.02.03 Create new dataset structure (folders, sheet, tabs)
      - [ ] T-01.02.04 Seed default categories/settings

- [ ] **US-01.03:** As a user, I can recover or relink my dataset if needed
    - **Acceptance Criteria:**
      - [ ] "Sync now" reloads from Drive/Sheet to local cache
      - [ ] "Relink" lets user pick a different dataset
      - [ ] Error guidance is shown if recovery fails
    - **Source:** ui-flow-spec.md 1.4, product-plan.md
    - **Tasks:**
      - [ ] T-01.03.01 Implement "Sync Now" and progress
      - [ ] T-01.03.02 Implement "Relink Dataset"
      - [ ] T-01.03.03 Error UI for recovery failures

---

### E-02: Expense/Income Entry & Management (ui-flow-spec.md §2, data-model.md 4.1)
- [ ] **Epic summary:** Add and edit transactions, support all core fields, instant save/local cache, field reset, error handling.
  - **In-scope:** Type, Date, Amount, Category, Tags, Note, Flags, Receipts (link only)
  - **Source:** ui-flow-spec.md 2.1-2.4, data-model.md 4.1
- [ ] **US-02.01:** As a user, I can add a new expense/income with required and optional fields
    - **Acceptance Criteria:**
      - [ ] Type, Amount, Date, Category required; Tags/Note/Flags/Receipts optional
      - [ ] Save is instant, local-first; UI resets after save (keeps date)
      - [ ] Input validation and error UI for required fields
    - **Tasks:**
      - [ ] T-02.01.01 Implement Transaction entry UI
      - [ ] T-02.01.02 Instant local save/reset logic
      - [ ] T-02.01.03 Input validation/errors
      - [ ] T-02.01.04 Field normalization (category/tag casing)

- [ ] **US-02.02:** As a user, I can edit or delete a transaction
    - **Acceptance Criteria:**
      - [ ] Tap to open/edit all fields
      - [ ] Delete with confirmation
      - [ ] Syncs edits/deletes to cloud
    - **Tasks:**
      - [ ] T-02.02.01 Edit transaction UI
      - [ ] T-02.02.02 Delete logic + confirmation
      - [ ] T-02.02.03 Sync edited/deleted rows

- [ ] **US-02.03:** As a user, I can apply and filter by flags (Paid/Unpaid, Reimbursed/Unreimbursed)
    - **Acceptance Criteria:**
      - [ ] Flags show as chips; set/clear is one tap
      - [ ] Flags filterable in all lists/analytics
    - **Tasks:**
      - [ ] T-02.03.01 Implement flag chips UI
      - [ ] T-02.03.02 Filter logic for flags

---

### E-03: Receipt Management (ui-flow-spec.md 2.5, 3.4, data-model.md 4.2)
- [ ] **Epic summary:** Attach, view, delete multiple receipts per transaction; crop/edit; Drive upload; error handling.
  - **In-scope:** Camera/library attach, 1:N mapping, Google Drive sync, receipt viewer
- [ ] **US-03.01:** As a user, I can attach one or more photo receipts to a transaction
    - **Acceptance Criteria:**
      - [ ] Add receipt button starts camera or picker
      - [ ] Crop/rotate, confirm to attach
      - [ ] Receipts saved locally, linked to transaction
    - **Tasks:**
      - [ ] T-03.01.01 Receipt attach UI + flow
      - [ ] T-03.01.02 Image crop/rotate/editor
      - [ ] T-03.01.03 Local save + transaction link

- [ ] **US-03.02:** As a user, I can upload receipts to Google Drive and view them in-app
    - **Acceptance Criteria:**
      - [ ] Receipts upload to correct folder/year, with correct file naming
      - [ ] `driveFileId` stored in Receipts table
      - [ ] View receipts via Drive ID link
    - **Tasks:**
      - [ ] T-03.02.01 Drive upload logic for receipts
      - [ ] T-03.02.02 File naming/placement logic
      - [ ] T-03.02.03 Receipt viewer UI

- [ ] **US-03.03:** As a user, I can delete a receipt from a transaction
    - **Acceptance Criteria:**
      - [ ] Delete removes from UI and marks as deleted in sheet
      - [ ] Cloud delete triggers Drive file move to trash
    - **Tasks:**
      - [ ] T-03.03.01 Delete logic
      - [ ] T-03.03.02 UI sync/trash

---

### E-04: Recurring Transactions (ui-flow-spec.md 2.6, data-model.md 4.4)
- [ ] **Epic summary:** Define recurring rules, generate instances, manage rules, support delete and next-year generation.
- [ ] **US-04.01:** As a user, I can make a transaction recurring (daily/weekly/monthly/yearly, start/end, cadence)
    - **Acceptance Criteria:**
      - [ ] UI exposes recurrence setup modal
      - [ ] Saving applies recurrence rule and generates current year’s instances
    - **Tasks:**
      - [ ] T-04.01.01 Recurrence configuration UI
      - [ ] T-04.01.02 Rule creation/save logic
      - [ ] T-04.01.03 Instance generation for current year

- [ ] **US-04.02:** As a user, I can view/edit/delete recurring rules in Settings
    - **Acceptance Criteria:**
      - [ ] List rules; tap to view/edit
      - [ ] Delete rule supports "delete rule only" or "delete future transactions"
    - **Tasks:**
      - [ ] T-04.02.01 Rules list/detail UI
      - [ ] T-04.02.02 Edit/save recurring rule
      - [ ] T-04.02.03 Delete options

- [ ] **US-04.03:** As a user, I can generate next year’s recurring transactions on demand
    - **Acceptance Criteria:**
      - [ ] Settings action triggers generation for next year
      - [ ] No-duplicate check is enforced
    - **Tasks:**
      - [ ] T-04.03.01 Generate-next-year logic
      - [ ] T-04.03.02 UI for generation action

---

### E-05: Analysis & Reporting (ui-flow-spec.md 3, product-plan.md "Analysis")
- [ ] **Epic summary:** Charting, list views, filters, KPIs, swipe-to-delete, performance rules.
- [ ] **US-05.01:** As a user, I can view expenses/income over time with bar charts and breakdowns
    - **Acceptance Criteria:**
      - [ ] Chart updates by Type/Timeframe (year/month/week)
      - [ ] KPIs: totals, spend per day
      - [ ] Category breakdowns
    - **Tasks:**
      - [ ] T-05.01.01 Chart UI (bar, breakdowns)
      - [ ] T-05.01.02 KPI summary logic
      - [ ] T-05.01.03 Aggregates cache logic

- [ ] **US-05.02:** As a user, I can filter by type, category, tags, date, and flags everywhere
    - **Acceptance Criteria:**
      - [ ] Filter logic applies to all list/chart views
      - [ ] Multi-select, search, and clear for each filter
    - **Tasks:**
      - [ ] T-05.02.01 Filters UI
      - [ ] T-05.02.02 Filter engine logic

- [ ] **US-05.03:** As a user, I can edit or delete transactions from analysis lists
    - **Acceptance Criteria:**
      - [ ] Tap to edit; swipe to delete with confirm
    - **Tasks:**
      - [ ] T-05.03.01 Edit-in-list UI
      - [ ] T-05.03.02 Swipe-to-delete logic

---

### E-06: Categories & Tags Management (ui-flow-spec.md 4.2, data-model.md 4.3)
- [ ] **Epic summary:** Manage/edit categories, tag stats, normalization, disable/hide instead of delete.
- [ ] **US-06.01:** As a user, I can add/edit/delete categories (with emoji/color) in Settings
    - **Acceptance Criteria:**
      - [ ] Add/edit fields: emoji, name, color, active toggle
      - [ ] CategoryKeys are normalized for sync
      - [ ] Delete disables (marks inactive) instead of hard delete
    - **Tasks:**
      - [ ] T-06.01.01 Categories list/detail UI
      - [ ] T-06.01.02 Add/edit category
      - [ ] T-06.01.03 Disable instead of delete

- [ ] **US-06.02:** As a user, I can use and manage tags with normalization and suggestions
    - **Acceptance Criteria:**
      - [ ] Tags are normalized to lowercase
      - [ ] Suggestions from usage frequency (TagStat)
      - [ ] Chips/dropdowns for selection
    - **Tasks:**
      - [ ] T-06.02.01 Tag normalization logic
      - [ ] T-06.02.02 TagStat tracking and suggestions
      - [ ] T-06.02.03 Tag chips UI

---

### E-07: Sync, Recovery, & Cloud Integration (vision.md, product-plan.md, google-drive-folder-architecture.md)
- [ ] **Epic summary:** Full/partial sync, Drive/Sheet APIs, conflict and error handling, offline/online reconciliation.
- [ ] **US-07.01:** As a user, my data syncs between local and cloud (Drive/Sheet), supporting full recovery
    - **Acceptance Criteria:**
      - [ ] Full sync loads all data to local cache
      - [ ] Pushes local changes to Drive/Sheet
      - [ ] Conflict resolution by last write wins
      - [ ] Sync runs on demand or scheduled
    - **Tasks:**
      - [ ] T-07.01.01 Drive/Sheet sync engine
      - [ ] T-07.01.02 Conflict detection/resolution
      - [ ] T-07.01.03 Sync status/progress UI

- [ ] **US-07.02:** As a user, sync errors and recovery steps are clearly communicated
    - **Acceptance Criteria:**
      - [ ] Non-blocking sync errors shown
      - [ ] Recovery UI prompts and repair options
    - **Tasks:**
      - [ ] T-07.02.01 Sync error UI
      - [ ] T-07.02.02 Recovery/repair flows

---

### E-08: Settings & Safety/Danger Zone (ui-flow-spec.md 4, product-plan.md)
- [ ] **Epic summary:** Settings management, support links, user data safety, erase/reset flows.
- [ ] **US-08.01:** As a user, I can manage app/data settings and perform dangerous operations with confirmations
    - **Acceptance Criteria:**
      - [ ] Data & Sync: dataset status, sync now, relink dataset
      - [ ] Danger zone: erase local/cloud data with confirmations
    - **Tasks:**
      - [ ] T-08.01.01 Settings UI (data, categories, recurring)
      - [ ] T-08.01.02 Danger zone erase logic
      - [ ] T-08.01.03 Confirmations and warnings

---

## 4. Dependencies & Milestones
- E-01 → E-02 → E-03/E-06 → E-04/E-05 → E-07 → E-08 (MVP vertical slices prioritized)
- **Phase 1 (MVP):** E-01 to E-08, core data model, vertical slice flows
- **Phase 2 (Recurring):** Enhance recurring rules, next year generation, robust deletes
- **Phase 3 (Polish/Scale):** Performance tuning, sync/aggregates, optional OCR

## 5. Open Questions / Risks
- [ ] Google API quota/capacity for receipts at scale? (vision.md, google-drive-folder-architecture.md)
- [ ] Family sharing: any Drive permission caveats? (vision.md)
- [ ] Complex recurrence/series editing: defer beyond MVP (product-plan.md)
- [ ] Data model: future migration/CloudKit support? (data-model.md)
- [ ] Sync error edge cases—test user-edited sheet anomalies (data-model.md, google-drive-folder-architecture.md)
- [ ] Performance: will SwiftData+aggregates cache keep up at 5,000+ transactions? (product-plan.md)

---

**End of backlog. Every epic/story/task references its source in ai/notes/ for traceability.**


