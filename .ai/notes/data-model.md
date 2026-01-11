# ExpenseTracker — iOS Data Model Specification (SwiftData / Local Store)

This specification defines the **local iOS data model** for the ExpenseTracker app.  
It is designed to map 1:1 to **google-drive-folder-architecture.md** and support a **user-editable sheet**.
---

## 1) Design Principles

1. **Sheet-first compatibility**
   - Local entities and fields must map cleanly to Google Sheet columns.
   - Category is stored by **name** (string), not by ID.

2. **User-editable robustness**
   - Expect categories/tags to be manually edited in the sheet.
   - Use tolerant parsing and validation rather than strict foreign keys.

3. **Receipts are 1-to-many**
   - A transaction can have multiple receipts.
   - Receipts are stored in a dedicated `Receipts` table (Option B).

4. **Sync-safe identity**
   - Use stable unique IDs for rows that require consistent identity across sync.
   - Prefer UUIDs for row identity.

---

## 2) Entity Overview

Entities in the local store:

1. **Transaction**
2. **Receipt**
3. **Category**
4. **RecurringRule**
5. **AppSettings** (single logical row)

Relationships:
- `Transaction 1 — N Receipt`
- No strict relationship between `Transaction.category` and `Category.name` (string reference only).
- `Transaction.recurringRuleId` references `RecurringRule.recurringRuleId` (optional link).

---

## 3) Field Types and Conventions

### 3.1 Common conventions
- **UUID fields**: stored as UUID locally; serialized as canonical UUID string in sheets.
- **Date fields**:
  - `date` (business date) maps to `YYYY-MM-DD` in the sheet.
  - `createdAt`, `lastModifiedAt` map to ISO8601 strings in the sheet.
- **Money**: store as `Decimal` (or equivalent high-precision numeric) locally.
- **CSV strings**: `tags` stored as comma-separated string (matches sheet).

### 3.2 Enumerations (string-based)
All enums are stored as strings to match the sheet:
- `Transaction.type`: `expense` | `income`
- `paidFlag`: `paid` | `unpaid` | empty
- `reimbursedFlag`: `reimbursed` | `unreimbursed` | empty
- `Category.type`: `expense` | `income` | `both`
- `RecurringRule.cadence`: `daily` | `weekly` | `monthly` | `yearly`

---

## 4) Entity Specifications

### 4.1 Transaction (maps to `Transactions` tab)

**Purpose**
- Represents a single ledger row (expense or income).
- The authoritative local record that syncs to the `Transactions` sheet.

**Identity**
- `transactionId` (UUID) — **primary key**, must be globally unique.

**Fields**
| Field | Type | Required | Sheet Column | Notes |
|---|---|---:|---|---|
| transactionId | UUID | Yes | transactionId | Primary key |
| type | enum(string) | Yes | type | `expense` / `income` |
| date | Date | Yes | date | Serialize to `YYYY-MM-DD` |
| year | Int | Yes | year | Derived from `date` if missing |
| month | Int | Yes | month | 1–12, derived from `date` if missing |
| amount | Decimal | Yes | amount | Positive number |
| category | String | Yes | category | Category **name** (user-editable) |
| tagsCSV | String | No | tags | Comma-separated string |
| note | String | No | note | Optional |
| paidFlag | enum(string) | No | paidFlag | `paid` / `unpaid` / empty |
| reimbursedFlag | enum(string) | No | reimbursedFlag | `reimbursed` / `unreimbursed` / empty |
| recurringRuleId | UUID | No | recurringRuleId | Optional link to rule |
| createdAt | DateTime | Yes | createdAt | ISO8601 |
| lastModifiedAt | DateTime | Yes | lastModifiedAt | ISO8601, sync watermark |

**Derived / integrity rules**
- `year` and `month` must match `date`. On edits to `date`, update both.
- `amount` is always positive; the meaning of inflow/outflow comes from `type`.
- `category` is treated as a free-text field but should be validated against `Categories` for UI dropdowns.

**Relationship**
- A transaction may have **0..N** receipts.

---

### 4.2 Receipt (maps to `Receipts` tab)

**Purpose**
- Represents one uploaded receipt image in Drive and links it to a transaction.

**Identity**
- `receiptId` (UUID) — **primary key**, globally unique.

**Fields**
| Field | Type | Required | Sheet Column | Notes |
|---|---|---:|---|---|
| receiptId | UUID | Yes | receiptId | Primary key |
| transactionId | UUID | Yes | transactionId | FK-like reference to Transaction |
| driveFileId | String | Yes | driveFileId | Google Drive file ID (stable handle) |
| fileName | String | Yes | fileName | Display name; should follow naming rule |
| createdAt | DateTime | Yes | createdAt | ISO8601 |
| lastModifiedAt | DateTime | Yes | lastModifiedAt | ISO8601 |

**Receipt naming rule (Drive)**
- Stored file name format:
  - `<YYYYMMDD>_<Category>_<TransactionId>_<n>.jpg`
- `driveFileId` is the reliable identifier; `fileName` is informational.

**Relationship**
- Each receipt belongs to exactly **one** transaction.
- A transaction may have multiple receipts.

---

### 4.3 Category (maps to `Categories` tab)

**Purpose**
- Defines UI categories and metadata used for pickers and analysis.
- `Transaction.category` references `Category.name` by string.

**Identity**
- `name` (String) — treated as a unique identifier.

**Fields**
| Field | Type | Required | Sheet Column | Notes |
|---|---|---:|---|---|
| name | String | Yes | name | Unique |
| type | enum(string) | Yes | type | `expense` / `income` / `both` |
| emoji | String | No | emoji | Optional |
| colorHex | String | No | colorHex | Optional |
| isActive | Bool | Yes | isActive | Hide in UI without breaking history |
| sortOrder | Int | No | sortOrder | Optional |
| createdAt | DateTime | Yes | createdAt | ISO8601 |
| lastModifiedAt | DateTime | Yes | lastModifiedAt | ISO8601 |

**Integrity rules**
- Names should be treated as case-consistent by the app UI (recommend normalizing display, but preserve as stored for sync).

---

### 4.4 RecurringRule (maps to `RecurringRules` tab)

**Purpose**
- Stores recurrence templates. Instances are materialized into `Transactions`.

**Identity**
- `recurringRuleId` (UUID) — primary key.

**Fields**
| Field | Type | Required | Sheet Column | Notes |
|---|---|---:|---|---|
| recurringRuleId | UUID | Yes | recurringRuleId | Primary key |
| isEnabled | Bool | Yes | isEnabled | |
| type | enum(string) | Yes | type | `expense` / `income` |
| amount | Decimal | Yes | amount | Positive |
| category | String | Yes | category | Category name |
| tagsCSV | String | No | tags | Comma-separated |
| note | String | No | note | Optional |
| startDate | Date | Yes | startDate | `YYYY-MM-DD` |
| cadence | enum(string) | Yes | cadence | daily/weekly/monthly/yearly |
| interval | Int | Yes | interval | >= 1 |
| endDate | Date | No | endDate | Optional |
| createdAt | DateTime | Yes | createdAt | ISO8601 |
| lastModifiedAt | DateTime | Yes | lastModifiedAt | ISO8601 |

**Operational rule**
- When generating instances, set `Transactions.recurringRuleId` to this rule’s ID.

---

### 4.5 AppSettings (maps to `Settings` tab)

**Purpose**
- Stores dataset identity and Drive/Sheet IDs needed for recovery and relinking.

**Identity**
- `datasetId` (UUID) — unique, single logical row.

**Fields**
| Field | Type | Required | Sheet Column | Notes |
|---|---|---:|---|---|
| datasetId | UUID | Yes | datasetId | Stable dataset identity |
| schemaVersion | Int | Yes | schemaVersion | Start at 1 |
| timezone | String | Yes | timezone | e.g., `America/New_York` |
| rootFolderId | String | Yes | rootFolderId | Drive folder ID of `ExpenseTracker/` |
| dataSpreadsheetId | String | Yes | dataSpreadsheetId | Sheet file ID |
| receiptsFolderId | String | Yes | receiptsFolderId | Drive folder ID of `Receipts/` |
| createdAt | DateTime | Yes | createdAt | ISO8601 |
| lastModifiedAt | DateTime | Yes | lastModifiedAt | ISO8601 |

---

## 5) Sync and Conflict Assumptions (Minimal)

These constraints keep the model consistent even with direct sheet edits:

1. **Row identity**
   - `transactionId`, `receiptId`, `recurringRuleId`, `datasetId` must be stable.
2. **Last write wins (baseline)**
   - `lastModifiedAt` is the tie-breaker for sync conflicts.
3. **Parsing**
   - If a category name in Transactions doesn’t exist in Categories, do not load the transaction with the non existing category name, prompt error message and let user fix it.
4. **Case sensitivity policy**
   - category name should be case sensitive
---
