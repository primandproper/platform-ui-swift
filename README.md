# platform-ui-swift

Shared SwiftUI for apps built on [`platform-go`](https://github.com/primandproper/platform-go):
a design system today, platform screens (sign-in, MFA, settings) once the first one moves here.

It sits beside the other tiers. `primitives-*` is how to do a thing, `platform-go` is what a
product has, `platform-client-*` is how to talk to it with zero markup, and **this is what it
looks like**. The Svelte counterpart is
[`platform-ui-svelte`](https://github.com/primandproper/platform-ui-svelte).

## Products

- **`DesignSystem`**: theme tokens (`DSTheme`) and `DS*` components (buttons, cards, text
  fields, sections, list rows, avatars, status badges, loading, error and empty states). No
  dependencies, so an app that never talks to platform-go can use it.

Seeded from DDB's iOS design system; see the epic,
[#3](https://github.com/primandproper/platform-ui-swift/issues/3), for where it is headed.

## Platforms

iOS 18 and up, iOS only. The components use UIKit-backed colors and iOS-only modifiers, so
`swift build` and `swift test` (which target the host Mac) cannot build the package; the make
targets run `xcodebuild` against the newest installed iPhone simulator instead.

## Development

```sh
make format lint test
make build
```
