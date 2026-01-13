# US-01.03 Dataset Recovery Implementation Plan

## Overview

Implement dataset recovery controls so users can sync cached data from the stored dataset, relink to a different dataset, and receive clear error guidance when recovery fails.

## Current State Analysis

The app stores dataset metadata locally in `DatasetStore` and uses `DatasetDiscoveryView` to select or create datasets during onboarding. There is no settings screen or recovery UI to trigger a reload or relink once onboarding is complete.

### Key Discoveries:
- `DatasetStore` persists dataset summary/settings in `UserDefaults` and is only used by `DatasetDiscoveryService`.【ExpenseTrackingApp/Onboarding/DatasetDiscoveryService.swift】
- `AppState` holds the active `datasetSummary` and the current onboarding step, but does not reload stored data on launch.【ExpenseTrackingApp/AppState.swift】
- The main app surface (`ContentView`) has no settings or recovery controls today.【ExpenseTrackingApp/ContentView.swift】

## Desired End State

Users can open a settings panel, trigger “Sync Now” to reload dataset metadata from local storage (simulating Drive/Sheet reload), relink to a different dataset by returning to dataset discovery, and see clear error guidance when recovery actions fail.

### Key Discoveries:
- Recovery can be simulated by reloading the stored `DatasetSummary` from `DatasetStore` until Drive integration is available.
- The existing onboarding flow already handles dataset selection and creation, so relink should reuse it.

## What We're NOT Doing

- Implementing real Google Drive/Sheets sync or network recovery.
- Adding conflict resolution or background sync scheduling (covered in E-07).
- Modifying transaction storage or receipts data.

## Implementation Approach

Add a small recovery service that reads/clears stored dataset metadata, expose recovery actions in a new Settings view, and wire the UI into `ContentView`. Extend `AppState` to load any stored dataset summary on launch so the app can skip onboarding when already linked.

## Phase 1: Add Dataset Recovery UI + Service

### Overview

Provide a Settings screen with “Sync Now” and “Relink Dataset” actions, wire them to a recovery service backed by `DatasetStore`, and surface errors with user guidance.

### Changes Required:

- [x] **Add recovery service and storage reset helpers**
  - **File**: `ExpenseTrackingApp/Onboarding/DatasetRecoveryService.swift` (new)
  - **File**: `ExpenseTrackingApp/Onboarding/DatasetDiscoveryService.swift`
  - **Changes**: Add a recovery service that reloads the stored summary and clears stored metadata for relinking.

- [x] **Load stored dataset on app launch**
  - **File**: `ExpenseTrackingApp/AppState.swift`
  - **Changes**: Initialize `AppState` with stored dataset summary and set onboarding to completed when one exists.

- [x] **Add Settings view with recovery controls**
  - **File**: `ExpenseTrackingApp/Settings/SettingsView.swift` (new)
  - **Changes**: Create a Settings UI with dataset details, sync progress, relink button, and error alerts.

- [x] **Expose Settings from the main app**
  - **File**: `ExpenseTrackingApp/ContentView.swift`
  - **Changes**: Add a toolbar button that opens Settings in a sheet.

### Success Criteria:

#### Automated Verification:
- [ ] App builds successfully.

#### Manual Verification:
- [ ] Settings shows dataset metadata when a dataset is linked.
- [ ] “Sync Now” shows progress and refreshes the dataset summary.
- [ ] “Relink Dataset” returns the user to dataset discovery.
- [ ] Recovery errors show a clear guidance message.

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that the manual testing was successful before proceeding to the next phase.

---

## Testing Strategy

### Unit Tests:
- N/A (UI-only change in this phase).

### Integration Tests:
- N/A.

### Manual Testing Steps:
1. Complete onboarding to select or create a dataset.
2. Open Settings, tap “Sync Now,” and confirm the dataset summary refreshes.
3. Tap “Relink Dataset” and confirm the app returns to dataset discovery.
4. Clear the stored dataset (delete the app or clear user defaults) and confirm “Sync Now” shows an error message.

## Performance Considerations

- Recovery operations are lightweight (local storage only) and should not impact UI responsiveness.

## Migration Notes

- No data migrations required.

## References

- Original backlog: `.ai/notes/backlog.md` (US-01.03)
- Related implementation: `ExpenseTrackingApp/Onboarding/DatasetDiscoveryService.swift`
