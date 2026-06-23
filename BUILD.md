# Build, Sign, Notarize & Package

## Prerequisites

- macOS 13.0+
- Xcode 15+ with a valid Apple Developer account
- Developer ID Application signing certificate

## Build (debug)

```sh
open Caffeinate.xcodeproj
# Press ⌘R, or from the command line:
xcodebuild -project Caffeinate.xcodeproj -scheme Caffeinate -configuration Debug build
```

## Run unit tests

```sh
xcodebuild test -project Caffeinate.xcodeproj -scheme Caffeinate \
  -destination 'platform=macOS'
```

## Code coverage

Run the test suite with coverage and print a per-file summary for the app target:

```sh
./scripts/coverage.sh
```

The script enables coverage, writes `build/Coverage.xcresult`, and prints the
overall and per-file coverage via `xccov`. Coverage is also enabled in the shared
`Caffeinate` scheme, so the Xcode coverage report is populated when running tests
from the IDE.

## Distribution build

1. The project's bundle ID is `com.guilhermebueno.caffeinate`. If you maintain
   your own fork, replace it with your own identifier in the project's build settings.
2. Select the Caffeinate scheme → **Product → Archive**.
3. In the Organizer, choose **Distribute App → Developer ID → Export**.

## Notarize and staple

```sh
# Submit for notarization (replace placeholders)
xcrun notarytool submit Caffeinate.app.zip \
  --apple-id "your@email.com" \
  --password "@keychain:AC_PASSWORD" \
  --team-id "XXXXXXXXXX" \
  --wait

# Staple the ticket
xcrun stapler staple Caffeinate.app
```

## Package as .dmg

```sh
# Using create-dmg (brew install create-dmg), or Disk Utility
create-dmg \
  --volname "Caffeinate" \
  --window-pos 200 120 \
  --window-size 600 400 \
  --icon-size 100 \
  --app-drop-link 450 185 \
  "Caffeinate.dmg" \
  "Caffeinate.app"
```
