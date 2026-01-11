# US-01.02 Dataset Discovery Implementation Plan

## Overview

Implement dataset discovery and creation flows so users can detect an existing ExpenseTracker dataset in Google Drive (simulated locally for now), review a summary, or create a new dataset with the expected folder/spreadsheet structure and seeded defaults.

## Current State Analysis

The onboarding flow currently stops at a placeholder `DatasetDiscoveryView` that only shows static text and does not perform detection or creation logic. There is no persistence for dataset metadata or UI for selecting/creating datasets. (`ExpenseTrackingApp/Onboarding/DatasetDiscoveryView.swift`)

## Desired End State

After OAuth, users see a dataset discovery screen that automatically looks for an existing dataset (based on locally persisted metadata), displays a summary if found, or guides users to create a new dataset. Creating a dataset simulates Drive structure setup and default seeding, then allows users to continue onboarding.

### Key Discoveries:
- The onboarding flow switches between `WelcomeView` and `DatasetDiscoveryView` based on `AppState.onboardingStep`. (`ExpenseTrackingApp/Onboarding/OnboardingFlowView.swift`)
- Dataset discovery is a placeholder screen with no state handling. (`ExpenseTrackingApp/Onboarding/DatasetDiscoveryView.swift`)
- The app already uses a simple `AppState` observable object to track onboarding progress. (`ExpenseTrackingApp/AppState.swift`)

## What We're NOT Doing

- Real Google Drive/Sheets API calls or OAuth token exchange.
- Syncing or persisting any actual sheet data beyond mock dataset metadata.
- Implementing recovery or relink flows (US-01.03).

## Implementation Approach

Use a lightweight local persistence layer (UserDefaults + Codable) to simulate dataset discovery. Build a view model-style service for discovery/creation and update the dataset discovery UI to show the two-path flow (use existing vs create new). Provide a creation progress checklist that mirrors the folder/tabs/settings setup and seeding steps from the Drive architecture doc.

## Phase 1: Add dataset discovery models and persistence

### Overview
Create data models and a lightweight store/service to load or create dataset metadata.

### Changes Required:

#### 1. Onboarding models + store
**File**: `ExpenseTrackingApp/Onboarding/DatasetDiscoveryService.swift` (new)
**Changes**: Add `DatasetSummary`, `DatasetDiscoveryService`, and `DatasetStore` for loading/creating dataset metadata.

```swift
struct DatasetSummary: Codable, Identifiable {
    let id: UUID
    let name: String
    let rootFolder: String
    let spreadsheetName: String
    let lastModified: Date
}
```

### Success Criteria:

#### Automated Verification:
- [ ] Project builds (Xcode build or `xcodebuild`).

#### Manual Verification:
- [ ] Existing dataset metadata is loaded on app relaunch.

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that the manual testing was successful before proceeding to the next phase.

---

## Phase 2: Update dataset discovery UI and flow

### Overview
Implement the dataset discovery UI with auto-detect state handling, dataset summary display, and a creation flow with progress steps.

### Changes Required:

#### 1. Dataset discovery view
**File**: `ExpenseTrackingApp/Onboarding/DatasetDiscoveryView.swift`
**Changes**: Replace the placeholder UI with a two-path flow (use existing vs create new), showing auto-detect results and creation progress, and wiring up buttons to advance onboarding.

#### 2. App state
**File**: `ExpenseTrackingApp/AppState.swift`
**Changes**: Store the selected dataset summary for later use in the app.

### Success Criteria:

#### Automated Verification:
- [ ] Project builds (Xcode build or `xcodebuild`).

#### Manual Verification:
- [ ] Dataset discovery displays a summary when metadata exists.
- [ ] Creating a dataset shows progress steps and lands on “Start Using App”.
- [ ] “Use This Dataset” continues onboarding into the main app.

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that the manual testing was successful before proceeding to the next phase.

---

## Testing Strategy

### Unit Tests:
- None planned (UI-first changes).

### Integration Tests:
- None planned.

### Manual Testing Steps:
1. Launch app after OAuth and confirm dataset discovery runs.
2. Verify existing dataset summary shows if metadata was saved previously.
3. Use “Create New Dataset” and ensure progress steps complete and app advances.
4. Use “Use This Dataset” to enter main app screen.

## Performance Considerations

No heavy computation expected; creation progress uses lightweight simulated delays.

## Migration Notes

No migrations required; dataset metadata is stored in UserDefaults.

## References

- Backlog item: `.ai/notes/backlog.md` (US-01.02)
- UI flow spec: `.ai/notes/ui-flow-spec.md` (sections 1.2–1.3)
- Drive architecture: `.ai/notes/google-drive-folder-architecture.md`
