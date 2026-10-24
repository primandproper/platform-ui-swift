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

## Customizing

One library, apps that look nothing alike. There are two layers, and every component honors both.

**Tokens.** `DSTheme` holds the colors, spacing, radii, typography, shadows, motion and icon and
avatar sizes every component draws from. Set it once near the root; anything you don't change
keeps the default look.

```swift
var theme = DSTheme.default
theme.colors.primary = .indigo
theme.radius.md = 0
theme.typography.button = .system(.body, design: .rounded).weight(.bold)

RootView()
  .dsTheme(theme)
```

An app's own views read the same theme with `@Environment(\.dsTheme) private var theme`. The
static spellings (`DSTheme.Colors.primary`) still compile, deprecated: they always return the
default theme, so a view using them won't follow an app's theme.

**Styles.** For a look tokens can't express, replace a component's style, the way SwiftUI's
`.buttonStyle(_:)` works. The component keeps its state, actions and accessibility, and hands
the style a `Configuration` (what to draw, plus the current theme); the style decides how.

```swift
struct PillButtonStyle: DSButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    Text(configuration.title ?? "")
      .padding(.horizontal, 24)
      .padding(.vertical, 10)
      .background(Capsule().fill(configuration.theme.colors.primary))
      .opacity(configuration.isPressed ? 0.6 : 1)
  }
}

RootView()
  .dsButtonStyle(PillButtonStyle())
```

The innermost style wins, and `.dsButtonStyle(.default)` restores the library's. Every style
protocol, its default, and the components it covers:

| Protocol | Modifier | Components |
| --- | --- | --- |
| `DSAvatarStyle` | `.dsAvatarStyle(_:)` | `DSAvatar`, `DSAvatarView`, the avatars in `DSAvatarGroup` |
| `DSButtonStyle` | `.dsButtonStyle(_:)` | `DSButton`, `DSButtonLink`, `DSIconButton` |
| `DSCardStyle` | `.dsCardStyle(_:)` | `DSCard`, `.dsCard()` |
| `DSDividerStyle` | `.dsDividerStyle(_:)` | `DSDivider`, `DSSoftDivider`, `DSListDivider` |
| `DSEmptyStateStyle` | `.dsEmptyStateStyle(_:)` | `DSEmptyState` |
| `DSErrorStyle` | `.dsErrorStyle(_:)` | `DSErrorView`, `DSContentState`'s error |
| `DSFieldGroupStyle` | `.dsFieldGroupStyle(_:)` | `DSFieldGroup` |
| `DSInfoRowStyle` | `.dsInfoRowStyle(_:)` | `DSInfoRow` |
| `DSListRowStyle` | `.dsListRowStyle(_:)` | `DSListRow`, `DSListRowLink` |
| `DSLoadingStyle` | `.dsLoadingStyle(_:)` | `DSLoadingView`, `DSInitializingView`, `DSContentState`'s loading |
| `DSRuleFlankedHeaderStyle` | `.dsRuleFlankedHeaderStyle(_:)` | `DSRuleFlankedHeader` |
| `DSSectionEmptyContentStyle` | `.dsSectionEmptyContentStyle(_:)` | `DSSectionEmptyContent` |
| `DSSectionHeaderStyle` | `.dsSectionHeaderStyle(_:)` | `DSSectionHeader`, the header inside `DSSection` |
| `DSSectionStyle` | `.dsSectionStyle(_:)` | `DSSection` |
| `DSStatusBadgeStyle` | `.dsStatusBadgeStyle(_:)` | `DSStatusBadge`, `DSStatusDot` |
| `DSStepperStyle` | `.dsStepperStyle(_:)` | `DSStepperButtons` |
| `DSTextFieldStyle` | `.dsTextFieldStyle(_:)` | `DSTextField` |

A component's `style:` argument picks one of its variants (`DSButtonVariant.destructive`,
`DSCardVariant.elevated`, …), which the style receives as `configuration.variant`.

## Platforms

iOS 18 and up, iOS only. The components use UIKit-backed colors and iOS-only modifiers, so
`swift build` and `swift test` (which target the host Mac) cannot build the package; the make
targets run `xcodebuild` against the newest installed iPhone simulator instead.

## Development

```sh
make format lint test
make build
```
