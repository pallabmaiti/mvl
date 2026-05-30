# MVL iOS

Native iOS project built with SwiftUI, an app target (`MVL`), a shared design system, and two local Swift packages:

- `Core/MobileDesignSystem`
- `Libraries/Location`
- `Libraries/Networking`

## Requirements

- macOS
- Xcode with Swift 6.2 support
- iOS Simulator installed

## Project Structure

- `MVL.xcworkspace`: main workspace for the app, local packages, and design system
- `MVL/`: application target and app unit tests
- `Core/MobileDesignSystem/`: reusable UI components and tests
- `Libraries/Location/`: local Swift package for location-related functionality
- `Libraries/Networking/`: local Swift package for networking and mocks

## Setup

### 1. Clone the repository

```bash
git clone https://github.com/pallabmaiti/mvl.git
cd mvl
```

### 2. Create the local secrets file

The app expects two build settings to be available at runtime:

- `AQI_API_TOKEN`
- `RG_API_KEY`

Create `MVL/Config/Secrets.xcconfig` from the example file:

```bash
cp MVL/Config/Secrets.xcconfig.example MVL/Config/Secrets.xcconfig
```

Then replace the placeholder values with real credentials:

```xcconfig
AQI_API_TOKEN = "your-waqi-token"
RG_API_KEY = "your-reverse-geocode-key"
```

`MVL/Config/Secrets.xcconfig` is gitignored and should remain local.

### 3. Open the workspace

Open the workspace, not the standalone project file:

```bash
open MVL.xcworkspace
```

### 4. Resolve packages and run the app

In Xcode:

1. Select the `MVL` scheme.
2. Choose an iPhone simulator.
3. Build and run the app.

On first launch, Xcode may spend some time resolving the local and remote Swift package dependencies.

## Testing

This repository contains tests for:

- the main app target (`MVLTests`)
- the design system (`MobileDesignSystemTests`)
- the local packages (`LocationTests`, `NetworkingTests`)

### Run all tests from Xcode

1. Open `MVL.xcworkspace`.
2. Select the `MVL` scheme.
3. Run `Product > Test`.

The shared scheme is configured with the repository test plan, so running tests from the workspace executes the app tests plus the package and design-system test targets included in that plan.

### Run app workspace tests from the command line

```bash
xcodebuild test \
	-workspace MVL.xcworkspace \
	-scheme MVL \
	-testPlan MVLTesting \
	-destination 'platform=iOS Simulator,name=iPhone 17,OS=26.3.1'
```

If that exact simulator is unavailable locally, replace the destination with one installed on your machine.

Example:

```bash
xcodebuild test \
	-workspace MVL.xcworkspace \
	-scheme MVL \
	-testPlan MVLTesting \
	-destination 'platform=iOS Simulator,name=iPhone 16'
```

## Notes

- If the app crashes at launch, verify that `MVL/Config/Secrets.xcconfig` exists and contains non-empty values.
- If package resolution fails, reopen the workspace and let Xcode re-resolve dependencies.
- Prefer opening `MVL.xcworkspace` so the app target, local packages, and design system stay wired together correctly.
