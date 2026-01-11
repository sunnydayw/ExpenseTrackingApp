# US-01.01 Google OAuth Onboarding Implementation Plan

## Overview

Implement the Welcome screen onboarding step that initiates Google OAuth with Drive/Sheets scopes, surfaces success/failure feedback, and transitions users to the next onboarding step on success.

## Current State Analysis

The app is currently the SwiftUI/SwiftData template with a simple `ContentView` list and no onboarding flow or authentication logic. There is no Google OAuth integration or onboarding state management in place.

### Key Discoveries:
- The app entry point renders `ContentView()` directly in `ExpenseTrackingAppApp.swift` without onboarding state or routing.【F:ExpenseTrackingApp/ExpenseTrackingAppApp.swift†L9-L32】
- The current UI is a basic list of `Item` records in `ContentView.swift`, with no authentication or onboarding views.【F:ExpenseTrackingApp/ContentView.swift†L1-L60】
- The onboarding UX spec defines a Welcome screen with a `Connect Google` CTA and a transition to dataset discovery upon successful OAuth.【F:.ai/notes/ui-flow-spec.md†L20-L38】

## Desired End State

- The app displays a Welcome screen with a `Connect Google` button and privacy footer.
- Tapping `Connect Google` launches Google OAuth with Drive/Sheets scopes and handles success/cancellation/errors.
- On success, the onboarding flow advances to the dataset discovery step (placeholder for US-01.02).
- Failures are surfaced clearly with an error message and a retry path.

### Key Discoveries:
- Follow the onboarding flow and transitions laid out in the UI flow spec for US-01.01.【F:.ai/notes/ui-flow-spec.md†L20-L38】

## What We're NOT Doing

- Implementing dataset discovery or creation flows (US-01.02).
- Persisting OAuth tokens or completing the token exchange with Google.
- Implementing Sync/Recovery or any Drive/Sheets API calls.

## Implementation Approach

Add an onboarding flow controller and a Welcome view that uses `ASWebAuthenticationSession` to perform the OAuth authorization code flow. Store onboarding state in a shared `AppState` environment object to switch between the Welcome screen and a dataset discovery placeholder view.

## Phase 1: Add Onboarding State + Flow Shell

### Overview
Create app-wide onboarding state and a root view that switches between onboarding steps.

### Changes Required:

#### 1. App State & Root Routing
**File**: `ExpenseTrackingApp/AppState.swift`
**Changes**: Add `OnboardingStep` enum and `AppState` observable object to store the current onboarding step.

```swift
enum OnboardingStep {
    case welcome
    case datasetDiscovery
    case completed
}

final class AppState: ObservableObject {
    @Published var onboardingStep: OnboardingStep = .welcome
}
```

#### 2. Root View
**File**: `ExpenseTrackingApp/RootView.swift`
**Changes**: Render the onboarding flow until onboarding is complete.

```swift
struct RootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        if appState.onboardingStep == .completed {
            ContentView()
        } else {
            OnboardingFlowView()
        }
    }
}
```

#### 3. App Entry Point
**File**: `ExpenseTrackingApp/ExpenseTrackingAppApp.swift`
**Changes**: Inject `AppState` and render `RootView()`.

```swift
@StateObject private var appState = AppState()

var body: some Scene {
    WindowGroup {
        RootView()
            .environmentObject(appState)
    }
    .modelContainer(sharedModelContainer)
}
```

### Success Criteria:

#### Automated Verification:
- [x] `ExpenseTrackingAppApp.swift` uses `RootView` with an environment `AppState`.
- [x] `AppState.swift` and `RootView.swift` compile without errors.

#### Manual Verification:
- [ ] App launches into a Welcome onboarding screen instead of the item list.

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that the manual testing was successful before proceeding to the next phase.

---

## Phase 2: Implement Welcome Screen + OAuth Flow

### Overview
Build the Welcome screen UI and the OAuth service that launches Google OAuth with required scopes.

### Changes Required:

#### 1. Google OAuth Service
**File**: `ExpenseTrackingApp/Onboarding/GoogleOAuthService.swift`
**Changes**: Add a service wrapping `ASWebAuthenticationSession` to launch OAuth and return the authorization code.

```swift
final class GoogleOAuthService: NSObject {
    struct Configuration { ... }
    func signIn(completion: @escaping (Result<String, Error>) -> Void) { ... }
}
```

#### 2. Welcome View
**File**: `ExpenseTrackingApp/Onboarding/WelcomeView.swift`
**Changes**: Render the Welcome UI with a `Connect Google` button, error messaging, and progress state.

```swift
Button("Connect Google") {
    connectGoogle()
}
```

#### 3. Dataset Discovery Placeholder View
**File**: `ExpenseTrackingApp/Onboarding/DatasetDiscoveryView.swift`
**Changes**: Add a placeholder screen that indicates the next onboarding step.

### Success Criteria:

#### Automated Verification:
- [x] OAuth flow constructs Google auth URL with Drive/Sheets scopes.
- [x] Welcome screen shows an error message on OAuth failure.
- [x] On success, onboarding state transitions to dataset discovery.

#### Manual Verification:
- [ ] Tapping `Connect Google` launches the Google OAuth sheet.
- [ ] Cancelling OAuth shows a user-visible error and allows retry.
- [ ] Successful OAuth transitions to the dataset discovery screen.

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that the manual testing was successful before proceeding to the next phase.

---

## Testing Strategy

### Unit Tests:
- None for this phase (UI flow + platform OAuth surface).

### Integration Tests:
- N/A.

### Manual Testing Steps:
1. Launch the app and confirm the Welcome screen appears.
2. Tap `Connect Google` and confirm the OAuth sheet opens.
3. Cancel the OAuth flow and confirm an error message is displayed.
4. Complete the OAuth flow and verify transition to dataset discovery.

## Performance Considerations

OAuth runs in a browser session and should not block the main thread; ensure UI feedback is immediate.

## Migration Notes

No migration required.

## References

- US-01.01 in `.ai/notes/backlog.md`
- Onboarding flow specification in `.ai/notes/ui-flow-spec.md`
- Current app entry point: `ExpenseTrackingApp/ExpenseTrackingAppApp.swift`
```
