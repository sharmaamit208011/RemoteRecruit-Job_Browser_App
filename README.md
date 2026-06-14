# RemoteRecruit – JobOpening Browser iOS App

A production-quality iOS application for browsing, searching, and viewing opening listings. Built with SwiftUI, MVVM architecture, and a separate networking framework (`RRNetworking`).

---

## Setup Instructions

### Prerequisites
- Xcode 15.3 or later
- iOS 17.0+ simulator or device
- macOS Ventura 13+ recommended

### Steps

1. **Clone** the project and open root folder. You should have two sibling folders:
   ```
   RemoteRecruit/     ← main Xcode project
   RRNetworking/      ← local Swift Package (networking framework)
   ```

2. **Open Xcode project**
   ```bash
   open RemoteRecruit/RemoteRecruit.xcodeproj
   ```

3. **Resolve packages** — Xcode will automatically detect `../RRNetworking` as a local Swift Package. If it does not appear resolved, go to:
   - `File → Packages → Resolve Package Versions`

4. **Select a simulator** (iPhone 15 / iOS 17+) and press **⌘R** to build and run.

5. **Run tests**
   ```bash
   # App-level tests (ViewModels)
   xcodebuild test -project RemoteRecruit.xcodeproj -scheme RemoteRecruit -destination 'platform=iOS Simulator,name=iPhone 15'

   # Networking framework tests
   cd ../RRNetworking
   swift test
   ```

---

## Architecture

### Overview
```
RemoteRecruit (iOS App)
├── App/                        Entry point
├── Features/
│   ├── OpeningsList/
│   │   ├── OpeningsListScreen         SwiftUI screen
│   │   ├── OpeningCardView         Reusable card component
│   │   └── OpeningsListViewModel    @MainActor ObservableObject
│   └── OpeningDetail/
│       ├── OpeningDetailScreen       SwiftUI screen
│       └── OpeningDetailViewModel  @MainActor ObservableObject
├── Shared/
│   ├── Theme/AppTheme          Design tokens (colors, fonts, spacing)
│   └── Extensions/LoadableState    Generic state enum (idle/loading/loaded/empty/error)
└── Resources/
    ├── Info.plist              Explicit (not auto-generated)
    └── Assets.xcassets         Color palette with dark mode variants

RRNetworking (Swift Package)
├── Sources/RRNetworking/
│   ├── Core/
│   │   ├── HTTPClient          Protocol + Endpoint/HTTPMethod types
│   │   ├── URLSessionHTTPClient Concrete implementation with retry + re-auth
│   │   ├── NetworkConfiguration Timeout, retry, base URL settings
│   │   ├── NetworkError        Typed error enum (Equatable, LocalizedError)
│   │   └── RemoteJobOpeningProvider          Fetches from network, falls back to bundled JSON
│   ├── Models/
│   │   └── JobOpening                 Codable, Identifiable, Hashable model
│   ├── Resources/
│   │   └── jobData.json        Bundled fallback data
│   └── RRNetworking.swift      Factory entry point
└── Tests/RRNetworkingTests/
    ├── RemoteJobOpeningProviderTests
    ├── NetworkErrorTests
    └── JobOpeningModelTests
```

### Pattern: MVVM
- **Views** are pure SwiftUI — no business logic.
- **ViewModels** are `@MainActor ObservableObject` — hold state and call services.
- **Services** are injected via protocol — fully testable without network.

### Networking: Retry + Auto Re-auth
- Every request is wrapped with `performWithRetry(attempt:)`.
- On `timeout` or `noConnection` errors the request retries up to `retryCount` times with exponential-ish delay.
- On a `400` response (unauthorized) the client calls `refreshAuth()` then retries the original request exactly once.
- The app calls the live demo API by default.
- If the network fails entirely the `RemoteJobOpeningProvider` falls back to `jobData.json` bundled inside `RRNetworking`.

### State Handling
`LoadableState<T>` is a generic enum used across all screens:
```swift
enum LoadableState<T> {
    case idle
    case loading
    case loaded(T)
    case empty
    case error(String)
}
```

---

## Adding RRNetworking to Another Project

### Option A — Local Swift Package (recommended during dev)
1. In Xcode: `File → Add Package Dependencies…`
2. Click **Add Local…** and navigate to the `RRNetworking` folder.
3. Select the `RRNetworking` product and add it to your target.

### Option B — Git-hosted SPM
Push `RRNetworking` to a Git remote, then add in Xcode:
```
https://github.com/yourname/RRNetworking
```
Tag a version (`1.0.0`) and select **Up to Next Major**.

### Option C — Swift Package Manager CLI
Add to your `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/yourname/RRNetworking", from: "1.0.0")
],
targets: [
    .target(name: "YourTarget", dependencies: ["RRNetworking"])
]
```

### Usage in any project
```swift
import RRNetworking

// Default app data source: live demo API, with bundled JSON fallback
let service = RRNetworking.makeDefaultOpeningProvider()

// Explicit live demo API provider
let remoteService = RRNetworking.makeRemoteOpeningProvider()

// Bundled-only provider for offline demos
let localService = BundledJobOpeningProvider()

// Custom base URL
let service = RRNetworking.makeOpeningProvider(
    baseURL: URL(string: "https://api.yoursite.com")!,
    timeoutInterval: 20,
    retryCount: 2,
    authToken: "your-token"
)

// Fetch openings
let openings = try await service.fetchOpenings()
```

---

## Assumptions

- **Certificate errors**: The live API at `jsonfakery.com` may return SSL/certificate errors in some network environments. The app still attempts the request by default, then falls back to bundled `jobData.json` if the request fails. Certificate validation is not bypassed.
- **400 as Unauthorized**: Per the spec, a `400` response triggers auto re-authentication (token refresh) and one automatic retry.
- **Qualifications format**: The API returns qualifications as a JSON-encoded string (e.g. `"[\"Swift\",\"UIKit\"]"`). The `JobOpening` model parses this into a clean `[String]` array via `parsedQualifications`.
- **Apply Now**: The apply button is present with no navigation target — it would connect to an application flow in a full product.
- **No pagination**: The API returns all openings in a single call; the list view uses `LazyVStack` for performance.
- **iOS 17 minimum**: Uses `NavigationStack`, `UnevenRoundedRectangle`, and `@Observable`-ready patterns.
- **Dark mode**: All colors are defined as named assets with both light and dark variants.
