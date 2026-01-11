# UI Flow Specification (Expense Tracker App)

## 0. Global UX Rules (Apply Everywhere)
- **Save is instant (local-first):** user actions should never block on network calls.
- **Date persists:** date remains selected across multiple entries until the user changes it.
- **After Save resets:** clear type/amount/category/tags/note/receipts/flags/recurrence after save.
- **Receipts support multiple attachments** per transaction.
- **Filtering is consistent:** Type, Category, Tags, Flags, RecurringRule are filterable everywhere.
- **Minimal controls:** avoid complex recurrence series editing in MVP.
- **Text normalization for consistency:**
  - **Tags:** always stored as **lowercase** (e.g., user types `Amazon` → stored as `amazon`).
  - **Categories:** display name can keep user-friendly casing (e.g., `Groceries`), but store a normalized key (e.g., `groceries`) for stable matching/sync.

---

## 1. Onboarding + Dataset Setup Flow

### 1.1 First Launch (Welcome)
**Screen: Welcome**
- Primary CTA: `Connect Google`
- Secondary CTA: `Learn More` (optional)
- Footer: Privacy/data ownership short statement (“Your data stays in your Google Drive.”)

**Action: Connect Google**
- OAuth sign-in
- On success → proceed to dataset discovery

---

### 1.2 Dataset Discovery
**Screen: Find Your Dataset**
- Option A (default): `Use Existing Dataset` (auto-detect folder PersonalFinanceApps)
- Option B: `Create New Dataset`

**Auto-detect behavior**
- Search for a dataset root folder (e.g., `PersonalFinanceApps/`)
- Validate presence of:
  - `Data/` + spreadsheet
  - `Receipts/`
  - `Settings` tab in spreadsheet
> Note: In the current implementation, dataset discovery uses locally stored metadata to simulate this detection until Drive API integration is added.

**If found**
- Show dataset summary:
  - Dataset name
  - Last modified time
- CTA: `Use This Dataset`
- If the user chooses `Create New Dataset Instead`, confirm that the existing local selection will be replaced.

**If not found**
- Show guidance and default to `Create New Dataset`
- Indicate the issue (e.g., root folder not found, or required tabs missing)

---

### 1.3 Create New Dataset (Automatic Setup)
**Screen: Create Dataset**
- Show progress of each action

**Create action**
- Create Drive folder structure:
  - `ExpenseTracker/`
    - `Data/`
    - `Receipts/`
- Create spreadsheet in `Data/` with required tabs:
  - `Transactions`, `Receipts`, `Categories`, `RecurringRules`, `Settings`
- Write Settings keys:
  - datasetId, schemaVersion, spreadsheetId, rootFolderId, receiptsFolderId
- Seed default categories:
  - User can modify later
> Note: In the current implementation, dataset creation is simulated locally and does not create Drive folders/sheets until Drive/Sheets integration is implemented.

**Completion**
- CTA: `Start Using App`
- Next: go to Tab A (Add Expense)

---

### 1.4 Recovery Flow (Settings)
**Screen: Sync & Recovery**
- Button: `Sync Now`
- Button: `Relink Dataset`

**Sync Now behavior**
- Runs Full Sync to load the Google Drive data into cache
- Shows progress (non-blocking UI)
- On completion: show last sync timestamp and status

**Relink Dataset**
- Re-run auto-detect

---

## 2. Tab A — Add Expense Flow (Capture)

### 2.1 Add Expense (Default Screen)
**Screen: Add Expense**
- Header:
  - Type picker: `Expense` / `Income` (segmented control)
  - Date selector (shows current selected date; Today selected by default)
  - Optional overflow menu: `•••` (used for less-frequent options, e.g., recurrence configuration)
- Required:
  - Amount input (numeric keypad)
  - Category picker (emoji + name)
- Optional:
  - Tags input (with suggestions chips)
  - Note field
  - **Flags** (Payment/Reimbursement) — collapsed by default
  - **Recurrence summary** — hidden unless configured (see 2.6)
  - Receipts carousel (attachments)
- Primary CTA:
  - `Save`

**Field ordering (recommended)**
1) Type, Amount  
2) Category  
3) Tags  
4) Note  
5) Receipts  
6) Flags (collapsed)  

---

### 2.2 Category Picker Flow
**Screen: Choose Category**
- simple menu-style list
- Category list (emoji + name), show based on the type selected (Expense vs Income)
- CTA: `Manage Categories` (links to Settings > Categories)

**Select category**
- Returns to Add Expense with category applied

---

### 2.3 Tags + Note Input (Manual Entry + Keyboard Behavior)

#### 2.3.1 Tags (Manual Entry)
**Inline behavior**
- User types tags separated by commas or spaces (implementation choice; comma recommended).
- **Normalization:** on commit (comma, space, return, or losing focus), tag is trimmed and saved as lowercase.
  - Examples:
    - `Amazon` → `amazon`
    - `  Coffee Shop ` → `coffee shop` (keep internal spaces, trim edges)
- Autocomplete suggestions appear from:
  - Existing tags used before (local TagStat), shown as chips or a dropdown list.
- Tapping a suggestion inserts the tag in lowercase and completes it.

**Tag suggestions chips**
- Show top N tags as chips under the tag field:
  - Most-used tags (local TagStat)
  - Tapping chip toggles add/remove

#### 2.3.2 Note (Manual Entry)
- Free text, multiline
- No forced casing changes

#### 2.3.3 Keyboard Show/Hide Rules (Tags + Note)
- When Tags or Note is focused:
  - Keyboard slides up; view scrolls to keep the focused field visible.
  - The `Save` button remains reachable:
    - Option A: sticky `Save` bar above keyboard
    - Option B: keep `Save` in navigation bar
- Provide an explicit keyboard dismissal:
  - A `Done` button on a keyboard accessory toolbar **and**
  - Tap-outside-to-dismiss on the form background
- Focus transitions:
  - Return key on Tags → keyboard dismissal
  - Return key on Note → inserts newline (do not auto-save)

---

### 2.4 Flags (Payment/Reimbursement) — Collapsible
**Goal:** do not show all the time, but keep a clear indication that it exists and whether anything is set.

**On Add Expense screen**
- Show a single collapsed row:
  - Label: `Flags (optional)`
  - Right-side summary indicator (examples):
    - `None`
    - `Paid`
    - `Unpaid • Reimbursed`
  - Chevron to expand/collapse

**Expanded content**
- Chip group 1: `Paid`, `Unpaid` (single-select or none)
- Chip group 2: `Reimbursed`, `Unreimbursed` (single-select or none)
- Chips can be left unset

**Collapse behavior**
- After selecting, auto-collapse (optional) or keep open until user collapses manually.
- The collapsed row always reflects current selection.

---

### 2.5 Add Receipt Flow (Multiple Images, One-at-a-Time UX)
**On Add Expense screen**
- Section: `Receipts`
- Button: `Add Receipt`
- If attachments exist: show thumbnails with count

**Add Receipt action**
- Bottom sheet: `Add Receipt`
  - `Take Photo`
  - `Choose from Library`

**After selection**
- Screen: Receipt Edit
  - Crop/rotate
  - Confirm button: `Attach`

**Multiple receipts behavior**
- User can attach multiple images by repeating `Add Receipt`.
- UX is intentionally “one image per add” to keep the flow simple and predictable.
- Deleting a receipt is supported via:
  - Tap thumbnail → Receipt Viewer → `Delete`

**Attach action**
- Save receipt image locally (temporary)
- Create local Receipt record + OutboxChange entry
- UI returns to Add Expense showing thumbnail(s)

---

### 2.6 Recurring Transactions (Inline on Add Expense + Managed in Settings)

#### 2.6.1 Entry Point (Add Expense)
Recurring is **not** a separate main screen.

**Where it appears**
- Hidden by default. Visible only when enabled/configured.
- Provide access via one of these lightweight entry points:
  - Option A: header overflow menu `•••` → `Make Recurring`
  - Option B: inline row under Date: `Recurrence: None` (tappable)

**When configured**
- Add Expense shows a compact summary row:
  - `Recurrence: Monthly (1st) • Starts 2026-01-01`
- Tapping opens recurrence configuration (2.6.2)

#### 2.6.2 Configure Recurrence (Modal / Sheet)
**Sheet: Recurrence**
- Toggle: `Recurring` (off by default)
- When ON, show:
  - Cadence: Daily / Weekly / Monthly / Yearly
  - Interval (default 1)
  - Start date (default = transaction date)
  - End date (optional)
  - Optional: `Generate through year` (internal; default current year)
- CTA: `Done`

**Behavior**
- Turning recurrence ON does **not** block saving the transaction.
- On Save Transaction:
  - If recurrence is configured, the app creates/updates a RecurringRule and links the saved transaction to it (as the template).
  - Then generates instances (see 2.6.4).

#### 2.6.3 Rule Storage + Management (Settings)
Rules are saved and editable later.

**Settings > Recurring Rules**
- List of recurring rules (summary label)
  - Example: `🏠 rent • $2500 • monthly`
- Tap rule → Rule Detail
- CTA: `Add Rule` (optional; most users will create rules via Add Expense)

**Rule Detail**
- Editable fields:
  - Type, Amount, Category, Tags, Note
  - Cadence, Interval, Start/End
  - Enabled toggle
- Actions:
  - `Save Changes`
  - `Delete Rule` (see delete behavior below)

**Delete behavior**
- Confirmation dialog:
  - Option A: `Delete rule only` (keep already generated transactions)
  - Option B: `Delete rule and future transactions` (delete instances with date >= today)
- Default to Option A to avoid accidental data loss.

#### 2.6.4 Instance Generation (Current Year + Next Year Maintenance)
**Generation approach (MVP)**
- On rule create/update:
  - Pre-generate remaining instances for the **current year**
  - Generate instances on-demand for future years via maintenance action

**Generate Next Year**
- Location: Settings > Recurring Rules
- Button: `Generate Next Year`
- Behavior:
  - For each enabled rule:
    - Compute `nextYear = currentYear + 1`
    - **Check for duplicates:** if `generateThroughYear >= nextYear`, skip (no-op)
    - Otherwise generate instances for nextYear
    - Update `generateThroughYear = nextYear`

---

### 2.7 Save Transaction Flow
**User taps Save**
- App immediately:
  1. Creates/updates local Transaction + Receipts (+ optional RecurringRule updates) in SwiftData
  2. Adds OutboxChange entries
- UI:
  - Shows brief “Saved” confirmation (toast)
  - Resets fields:
    - Clear type/amount/category/tags/note/flags/receipts/recurrence
    - Keep date

**Background**
- Debounced push sync begins (non-blocking)
- Any failures update Settings > Sync status

---

## 3. Tab B — Analysis Flow (Timeframe Controls + Swipe-to-Delete)

### 3.1 Analysis (Default)
**Screen: Analysis**
- Top controls (single row, left-to-right):
  1) **Type selector:** `Expense` / `Income` (segmented control)
  2) **Timeframe selector:** `Year` / `Month` / `Week`
  3) **Left / Right arrows** to move the selected timeframe backward/forward
     - Example:
       - Year: 2026 ← → 2027
       - Month: Jan 2026 ← → Feb 2026
       - Week: Wk 03 (Jan 15–Jan 21) ← → Wk 04
  4) Optional: `Filter` button (opens Filters sheet)

**Chart area**
- Chart updates based on Type + Timeframe selection:
  - Year: monthly totals across the year
  - Month: weekly totals within the month
  - Week: daily totals within the week
- Secondary breakdown (optional, below primary chart):
  - Spend by category (Expense) or income by category/source (Income)

**List (directly below chart)**
- List content changes based on Type + Timeframe selection:
  - Year: grouped by Month
  - Month: grouped by Week (or by day; your choice)
  - Week: grouped by Day
- Each row shows:
  - Date
  - Emoji category + name
  - Amount
  - Tags preview (small)
  - Receipt indicator (paperclip + count)

**Row actions**
- Tap row → Transaction Detail
- **Swipe-to-delete (required)**
  - Swipe left → `Delete`
  - Confirm dialog (optional; recommended if receipts exist)
  - On confirm: enqueue outbox delete and remove locally

---

### 3.2 Filters
**Screen: Filters**
- Type: Expense/Income (mirrors main selector)
- Categories (multi-select)
- Tags (multi-select from known tags; optional search)
- Flags:
  - Paid/Unpaid
  - Reimbursed/Unreimbursed
- Date range override (optional; constrained to current timeframe)

Buttons:
- `Apply`
- `Clear`

---

### 3.3 Transaction Detail
**Screen: Transaction Detail**
- Editable fields:
  - Type, Amount, Date, Category, Tags, Note, Flags
- Recurrence:
  - If linked to a rule: show `Recurring` section with rule summary + `Edit Rule`
  - If not linked: allow `Make Recurring` (same sheet as 2.6.2)
- Receipts section:
  - Thumbnail grid
  - `Add Receipt`
  - Tap thumbnail to view full screen
- Actions:
  - `Save Changes`
  - `Delete`

**Delete behavior**
- Enqueue outbox delete (local + cloud) and update the Google Sheet row
- Return to Analysis list with toast “Deleted”

---

### 3.4 Receipt Viewer
**Screen: Receipt Viewer**
- Full-screen image
- Controls:
  - Close
  - Delete receipt
- If delete:
  - Update receipt row as deleted + enqueue outbox to trash Drive file

---

## 4. Tab C — Settings Flow

### 4.1 Settings Home
Sections:

**Data & Sync**
- Dataset status summary (connected account, dataset name)
- `Sync Now`
- `Relink Dataset`
- Last sync timestamp + status

**Categories**
- Manage Categories

**Recurring Rules**
- Manage rules + Generate Next Year

**Support**
- `Buy me a coffee`
- `Report a bug`
- `Give feedback`
- `Share app`

**Danger Zone**
- `Erase Local Data`
- `Erase Cloud Data` (strong warning)

---

### 4.2 Categories Management
**Screen: Categories**
- List of categories (emoji + name)
- CTA: `Add Category`

**Add/Edit Category**
- Fields:
  - Emoji picker (or text input)
  - Name (display casing preserved)
  - Active toggle
  - Optional color
- Save:
  - Write to local + enqueue outbox upsert
- Normalization:
  - Generate and store a stable `categoryKey` (lowercase) for matching/sync.

**Delete category**
- Prefer disable (`isActive=false`) instead of hard delete to avoid breaking historical transactions.

---

### 4.3 Recurring Rules Management
**Screen: Recurring Rules**
- List of rules with summary
- Button: `Generate Next Year`
  - Runs duplicate-safe generation (see 2.6.4)

---

### 4.4 Danger Zone
**Screen: Danger Zone**
- `Erase Local Data`
  - Confirmation: “This deletes app data on this phone. Cloud data stays.”
  - After action: app returns to onboarding with option to Sync Now

- `Erase Cloud Data`
  - Confirmation requires typing a phrase (e.g., `ERASE`)
  - Explains:
    - This will delete/clear the Google Sheet data tabs and receipts folder (implementation can be staged)
  - After action:
    - App resets to onboarding

---

## 5. Performance Rules for UI (Important)
- Analysis totals and charts are computed from:
  - SwiftData cached rows **plus** optional aggregates cache.
- When user changes Type/Timeframe/filters:
  - Update view from local cache immediately.
  - Trigger background refresh only if needed (e.g., missing period data locally).

---

## 6. Error Handling (User-visible)
- If sync fails:
  - Non-blocking banner/toast: “Sync paused — tap to view details”
  - Settings > Data & Sync shows:
    - Error reason
    - Retry button
- If Drive/Sheet structure missing:
  - Prompt: “Dataset needs repair” and show what is missing
