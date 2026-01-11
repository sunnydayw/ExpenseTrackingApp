# Product Plan and Feature Breakdown (Updated)

## 1. Scope and Operating Assumptions
- **Primary cloud backend (MVP):** Google Drive + Google Sheets (user-owned dataset).
- **Local cache (MVP):** SwiftData for offline-first UX and fast queries.
- **Design constraint:** Keep workflows simple and predictable; minimize controls that require complex recurrence editing or conflict resolution UX.
- **Multi-user family sharing:** Achieved by sharing the underlying Google Sheet/Drive folder with family members.

---

## 2. Information Architecture (Tabs)

### Tab A — Add Expense (Capture)

#### A1. Transaction Entry (MVP)
**Required fields**
- **Type:** Expense / Income (**required**)
- **Amount:** required
- **Date:** required (default: today; remains until user changes it)

**Fields included**
- **Category:** required
- **Tags (store/vendor + custom):**
  - Primary use: merchant/store labels (e.g., Amazon, Costco), plus user-defined tags.
  - Input UX:
    - Free-entry tag input.
    - Show **top N most-used tags** as quick chips (computed from local history).
- **Note:** optional free text
- **Receipts:** optional; supports **multiple receipt photos** per transaction.

**“Status” handling (filterable, not toggles)**
- Replace toggles with **filterable flags presented as chips**:
  - Payment flag: `Paid` / `Unpaid` (optional)
  - Reimbursement flag: `Reimbursed` / `Unreimbursed` (optional)
- UI behavior: user taps chips to set/clear flags (chip-style selection, not toggle switches).
- Data behavior: flags are stored as structured fields (recommended) to keep filtering reliable.

**Quick-add behavior**
- After saving a transaction:
  - **Clear**: type, amount, category, tags, note, receipts.
  - **Keep**: date.
- Rationale: supports rapid entry of multiple historical items without “sticky” category/tag mistakes.

---

#### A2. Recurring Transactions (MVP+)
**Rule definition**
- Daily / Weekly / Monthly / Yearly
- Start date required; end date optional.

**Hybrid instance generation (recommended)**
- **Pre-generate all instances for the current year** at rule creation (or when rule is enabled).
- **Generate next year on demand**:
  - Trigger on first app open in a new year, or via a Settings action:
    - “Generate next year recurring transactions”

**Where rules live**
- A dedicated section in **Settings** that lists all recurring rules.

**Controls (simple)**
- Keep the app simple:
  - User can **delete the recurring rule** (and optionally choose whether to delete future generated instances).
  - No “edit this occurrence vs series” UX in MVP.

---

#### A3. Receipt Management (MVP)
- Sources:
  - Camera capture
  - Photo library import
- Editing:
  - Crop/rotate
- Compression:
  - **Hardcoded default** (experiment to find lowest usable resolution).
- Attachments:
  - Support **multiple receipts per transaction**.
- Storage:
  - Receipts uploaded to **Google Drive** under a predefined folder architecture.
  - Each receipt is linked to its transaction via Drive File ID.

---

### Tab B — Analysis (Review & Summaries)

#### B1. Transactions List + Edit (MVP)
- Primary browsing structure:
  - **Year selector** (e.g., 2024, 2025, 2026)
  - List grouped by **Month** (remove day grouping)
- Filters:
  - Category
  - Tags
  - Type (Expense/Income)
  - Flags: Paid/Unpaid, Reimbursed/Unreimbursed
  - Date range within a year (optional)
- Edit:
  - Update transaction fields
  - Add/remove receipts

---

#### B2. Dashboards (MVP+)
- Visuals:
  - **Bar charts only** (keep simple)
  - Spend by category (bar)
  - Monthly totals within selected year (bar)
- KPI summary:
  - Total Income, Total Expense, Net (for selected year or range)
  - **Expense per day** metric (see computation section below)

**Computation/performance decision**
- Do **not** recompute full-year totals on every screen transition from raw rows if the dataset grows large.
- Preferred approach:
  - Compute totals from **local SwiftData cache**.
  - Maintain a lightweight **aggregates cache** (by Year-Month and by Category) and update it incrementally when transactions change.
  - Only recompute from scratch on “Sync Now” full refresh or if cache is invalidated.

---

#### B3. Scope clarification
- No “business vs personal” split in this app (future separate business-focused app).
- Remove AI insights/anomaly detection for now.

---

### Tab C — Settings (Data, Sync, App)

#### C1. Data Provider
- MVP: **Google Drive + Google Sheets**
- Codebase should be structured to allow switching providers later (adapter/service layer pattern).

---

#### C2. Sync Controls and Recovery
- “Sync Now” use cases:
  - Normal refresh
  - **Phone switch / reinstall recovery**: pull all data + settings + folder IDs from Google Drive.
- Display:
  - Last sync time
  - Last sync status (success / failed + reason)

---

#### C3. Drive/Sheet Setup Management (mostly automatic)
- App uses a **predefined folder + sheet architecture** by default.
- Settings options:
  - “Repair dataset setup” (recreate missing tabs/folders if user moved/deleted items)
  - “Relink dataset” (select an existing dataset folder/spreadsheet)

No user-facing upload policy customization in MVP.

---

#### C4. Categories
- Categories use **emoji** as the icon.
- Categories source-of-truth:
  - Decision: store in **Google Sheet** (user-editable) and cache locally.

---

#### C5. Support and Safety
- Tip jar: “Buy me a coffee”
- Report a bug
- Give feedback
- Share app
- **Danger Zone**
  - “Erase local data”
  - “Erase cloud data (Drive/Sheet)” (explicit warnings + confirmations)

---

## 3. Milestone Plan (Re-scoped)
### Phase 1 — MVP (Ship)
- Add Expense: type/amount/date/category/tags/note + multi-receipt upload
- Analysis: year selector + month grouping + edit + basic bar charts + totals
- Settings: Google connect, dataset setup/repair, Sync Now, categories management
- SwiftData cache + basic full sync

### Phase 2 — Recurring (Practical)
- Rules management in Settings
- Pre-generate current year instances
- Generate next year on demand
- Simple delete rule behavior

### Phase 3 — Polish and Scale
- Aggregates cache for performance
- Improved sync efficiency
- Optional OCR (future)

---

