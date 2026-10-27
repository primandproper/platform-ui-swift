//
//  AppTheme.swift
//  DesignSystem
//
//  Design System Theme - Central configuration for colors, spacing, typography, and radii
//

import SwiftUI

// MARK: - Design System Theme

/// The tokens every component draws from: colors, spacing, radii, typography, shadows, motion,
/// and icon and avatar sizes.
///
/// Components read the theme from the environment, so an app restyles all of them at once:
/// ```swift
/// var theme = DSTheme.default
/// theme.colors.primary = .indigo
/// theme.radius.md = 0
///
/// RootView()
///   .dsTheme(theme)
/// ```
///
/// An app's own views read the same theme with `@Environment(\.dsTheme) private var theme`.
/// For a look tokens can't express, replace a component's style instead (`.dsButtonStyle(_:)`
/// and its siblings).
public struct DSTheme: Sendable {
  public var colors: Colors
  public var spacing: Spacing
  public var radius: Radius
  public var typography: Typography
  public var shadows: Shadows
  public var animation: Animation
  public var iconSize: IconSize
  public var avatarSize: AvatarSize

  public init(
    colors: Colors = Colors(),
    spacing: Spacing = Spacing(),
    radius: Radius = Radius(),
    typography: Typography = Typography(),
    shadows: Shadows = Shadows(),
    animation: Animation = Animation(),
    iconSize: IconSize = IconSize(),
    avatarSize: AvatarSize = AvatarSize()
  ) {
    self.colors = colors
    self.spacing = spacing
    self.radius = radius
    self.typography = typography
    self.shadows = shadows
    self.animation = animation
    self.iconSize = iconSize
    self.avatarSize = avatarSize
  }

  /// Today's look: the values every component used before themes existed.
  public static let `default` = DSTheme()

  // MARK: - Colors

  public struct Colors: Sendable {
    // Brand colors
    public var primary: Color
    public var secondary: Color
    public var tertiary: Color

    // Semantic colors
    public var success: Color
    public var warning: Color
    public var error: Color
    public var info: Color

    // Background colors
    public var background: Color
    public var cardBackground: Color
    public var cardBackgroundSelected: Color
    public var cardBackgroundElevated: Color

    // Text colors
    public var textPrimary: Color
    public var textSecondary: Color
    public var textTertiary: Color
    public var textOnPrimary: Color

    // Border colors
    public var border: Color
    public var borderSelected: Color
    public var borderSubtle: Color

    // Status colors (for badges, indicators)
    public var statusPending: Color
    public var statusAccepted: Color
    public var statusRejected: Color
    public var statusCancelled: Color
    public var statusUnknown: Color

    public init(
      primary: Color = Color.blue,
      secondary: Color = Color.purple,
      tertiary: Color = Color.orange,
      success: Color = Color.green,
      warning: Color = Color.orange,
      error: Color = Color.red,
      info: Color = Color.blue,
      background: Color = Color(.systemBackground),
      cardBackground: Color = Color(.systemGray6),
      cardBackgroundSelected: Color = Color.blue.opacity(0.1),
      cardBackgroundElevated: Color = Color(.systemGray5),
      textPrimary: Color = Color.primary,
      textSecondary: Color = Color.secondary,
      textTertiary: Color = Color(.tertiaryLabel),
      textOnPrimary: Color = Color.white,
      border: Color = Color(.separator),
      borderSelected: Color = Color.blue,
      borderSubtle: Color = Color(.systemGray4),
      statusPending: Color = Color.orange,
      statusAccepted: Color = Color.green,
      statusRejected: Color = Color.red,
      statusCancelled: Color = Color.gray,
      statusUnknown: Color = Color.secondary
    ) {
      self.primary = primary
      self.secondary = secondary
      self.tertiary = tertiary
      self.success = success
      self.warning = warning
      self.error = error
      self.info = info
      self.background = background
      self.cardBackground = cardBackground
      self.cardBackgroundSelected = cardBackgroundSelected
      self.cardBackgroundElevated = cardBackgroundElevated
      self.textPrimary = textPrimary
      self.textSecondary = textSecondary
      self.textTertiary = textTertiary
      self.textOnPrimary = textOnPrimary
      self.border = border
      self.borderSelected = borderSelected
      self.borderSubtle = borderSubtle
      self.statusPending = statusPending
      self.statusAccepted = statusAccepted
      self.statusRejected = statusRejected
      self.statusCancelled = statusCancelled
      self.statusUnknown = statusUnknown
    }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).colors.primary so the value follows the app's theme"
    )
    public static var primary: Color { DSTheme.default.colors.primary }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).colors.secondary so the value follows the app's theme"
    )
    public static var secondary: Color { DSTheme.default.colors.secondary }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).colors.tertiary so the value follows the app's theme"
    )
    public static var tertiary: Color { DSTheme.default.colors.tertiary }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).colors.success so the value follows the app's theme"
    )
    public static var success: Color { DSTheme.default.colors.success }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).colors.warning so the value follows the app's theme"
    )
    public static var warning: Color { DSTheme.default.colors.warning }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).colors.error so the value follows the app's theme"
    )
    public static var error: Color { DSTheme.default.colors.error }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).colors.info so the value follows the app's theme"
    )
    public static var info: Color { DSTheme.default.colors.info }

    @available(
      *, deprecated,
      message:
        "Read @Environment(\\.dsTheme).colors.background so the value follows the app's theme"
    )
    public static var background: Color { DSTheme.default.colors.background }

    @available(
      *, deprecated,
      message:
        "Read @Environment(\\.dsTheme).colors.cardBackground so the value follows the app's theme"
    )
    public static var cardBackground: Color { DSTheme.default.colors.cardBackground }

    @available(
      *, deprecated,
      message:
        "Read @Environment(\\.dsTheme).colors.cardBackgroundSelected so the value follows the app's theme"
    )
    public static var cardBackgroundSelected: Color {
      DSTheme.default.colors.cardBackgroundSelected
    }

    @available(
      *, deprecated,
      message:
        "Read @Environment(\\.dsTheme).colors.cardBackgroundElevated so the value follows the app's theme"
    )
    public static var cardBackgroundElevated: Color {
      DSTheme.default.colors.cardBackgroundElevated
    }

    @available(
      *, deprecated,
      message:
        "Read @Environment(\\.dsTheme).colors.textPrimary so the value follows the app's theme"
    )
    public static var textPrimary: Color { DSTheme.default.colors.textPrimary }

    @available(
      *, deprecated,
      message:
        "Read @Environment(\\.dsTheme).colors.textSecondary so the value follows the app's theme"
    )
    public static var textSecondary: Color { DSTheme.default.colors.textSecondary }

    @available(
      *, deprecated,
      message:
        "Read @Environment(\\.dsTheme).colors.textTertiary so the value follows the app's theme"
    )
    public static var textTertiary: Color { DSTheme.default.colors.textTertiary }

    @available(
      *, deprecated,
      message:
        "Read @Environment(\\.dsTheme).colors.textOnPrimary so the value follows the app's theme"
    )
    public static var textOnPrimary: Color { DSTheme.default.colors.textOnPrimary }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).colors.border so the value follows the app's theme"
    )
    public static var border: Color { DSTheme.default.colors.border }

    @available(
      *, deprecated,
      message:
        "Read @Environment(\\.dsTheme).colors.borderSelected so the value follows the app's theme"
    )
    public static var borderSelected: Color { DSTheme.default.colors.borderSelected }

    @available(
      *, deprecated,
      message:
        "Read @Environment(\\.dsTheme).colors.borderSubtle so the value follows the app's theme"
    )
    public static var borderSubtle: Color { DSTheme.default.colors.borderSubtle }

    @available(
      *, deprecated,
      message:
        "Read @Environment(\\.dsTheme).colors.statusPending so the value follows the app's theme"
    )
    public static var statusPending: Color { DSTheme.default.colors.statusPending }

    @available(
      *, deprecated,
      message:
        "Read @Environment(\\.dsTheme).colors.statusAccepted so the value follows the app's theme"
    )
    public static var statusAccepted: Color { DSTheme.default.colors.statusAccepted }

    @available(
      *, deprecated,
      message:
        "Read @Environment(\\.dsTheme).colors.statusRejected so the value follows the app's theme"
    )
    public static var statusRejected: Color { DSTheme.default.colors.statusRejected }

    @available(
      *, deprecated,
      message:
        "Read @Environment(\\.dsTheme).colors.statusCancelled so the value follows the app's theme"
    )
    public static var statusCancelled: Color { DSTheme.default.colors.statusCancelled }

    @available(
      *, deprecated,
      message:
        "Read @Environment(\\.dsTheme).colors.statusUnknown so the value follows the app's theme"
    )
    public static var statusUnknown: Color { DSTheme.default.colors.statusUnknown }
  }

  // MARK: - Spacing

  public struct Spacing: Sendable {
    public var xxs: CGFloat
    public var xs: CGFloat
    public var sm: CGFloat
    public var md: CGFloat
    public var lg: CGFloat
    public var xl: CGFloat
    public var xxl: CGFloat
    public var xxxl: CGFloat

    public init(
      xxs: CGFloat = 2,
      xs: CGFloat = 4,
      sm: CGFloat = 8,
      md: CGFloat = 12,
      lg: CGFloat = 16,
      xl: CGFloat = 24,
      xxl: CGFloat = 32,
      xxxl: CGFloat = 48
    ) {
      self.xxs = xxs
      self.xs = xs
      self.sm = sm
      self.md = md
      self.lg = lg
      self.xl = xl
      self.xxl = xxl
      self.xxxl = xxxl
    }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).spacing.xxs so the value follows the app's theme"
    )
    public static var xxs: CGFloat { DSTheme.default.spacing.xxs }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).spacing.xs so the value follows the app's theme"
    )
    public static var xs: CGFloat { DSTheme.default.spacing.xs }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).spacing.sm so the value follows the app's theme"
    )
    public static var sm: CGFloat { DSTheme.default.spacing.sm }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).spacing.md so the value follows the app's theme"
    )
    public static var md: CGFloat { DSTheme.default.spacing.md }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).spacing.lg so the value follows the app's theme"
    )
    public static var lg: CGFloat { DSTheme.default.spacing.lg }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).spacing.xl so the value follows the app's theme"
    )
    public static var xl: CGFloat { DSTheme.default.spacing.xl }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).spacing.xxl so the value follows the app's theme"
    )
    public static var xxl: CGFloat { DSTheme.default.spacing.xxl }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).spacing.xxxl so the value follows the app's theme"
    )
    public static var xxxl: CGFloat { DSTheme.default.spacing.xxxl }
  }

  // MARK: - Corner Radius

  public struct Radius: Sendable {
    public var xs: CGFloat
    public var sm: CGFloat
    public var md: CGFloat
    public var lg: CGFloat
    public var xl: CGFloat
    public var full: CGFloat

    public init(
      xs: CGFloat = 4,
      sm: CGFloat = 8,
      md: CGFloat = 10,
      lg: CGFloat = 16,
      xl: CGFloat = 20,
      full: CGFloat = 9999
    ) {
      self.xs = xs
      self.sm = sm
      self.md = md
      self.lg = lg
      self.xl = xl
      self.full = full
    }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).radius.xs so the value follows the app's theme"
    )
    public static var xs: CGFloat { DSTheme.default.radius.xs }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).radius.sm so the value follows the app's theme"
    )
    public static var sm: CGFloat { DSTheme.default.radius.sm }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).radius.md so the value follows the app's theme"
    )
    public static var md: CGFloat { DSTheme.default.radius.md }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).radius.lg so the value follows the app's theme"
    )
    public static var lg: CGFloat { DSTheme.default.radius.lg }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).radius.xl so the value follows the app's theme"
    )
    public static var xl: CGFloat { DSTheme.default.radius.xl }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).radius.full so the value follows the app's theme"
    )
    public static var full: CGFloat { DSTheme.default.radius.full }
  }

  // MARK: - Typography

  public struct Typography: Sendable {
    // Titles
    public var largeTitle: Font
    public var title1: Font
    public var title2: Font
    public var title3: Font

    // Body text
    public var bodyLarge: Font
    public var body: Font
    public var bodySmall: Font

    // Labels
    public var label: Font
    public var labelSmall: Font
    public var caption: Font
    public var captionSmall: Font

    // Special
    public var button: Font
    public var buttonSmall: Font

    public init(
      largeTitle: Font = Font.largeTitle.weight(.bold),
      title1: Font = Font.title.weight(.bold),
      title2: Font = Font.title2.weight(.bold),
      title3: Font = Font.title3.weight(.semibold),
      bodyLarge: Font = Font.body,
      body: Font = Font.subheadline,
      bodySmall: Font = Font.footnote,
      label: Font = Font.subheadline.weight(.medium),
      labelSmall: Font = Font.caption.weight(.medium),
      caption: Font = Font.caption,
      captionSmall: Font = Font.caption2,
      button: Font = Font.body.weight(.semibold),
      buttonSmall: Font = Font.subheadline.weight(.semibold)
    ) {
      self.largeTitle = largeTitle
      self.title1 = title1
      self.title2 = title2
      self.title3 = title3
      self.bodyLarge = bodyLarge
      self.body = body
      self.bodySmall = bodySmall
      self.label = label
      self.labelSmall = labelSmall
      self.caption = caption
      self.captionSmall = captionSmall
      self.button = button
      self.buttonSmall = buttonSmall
    }

    @available(
      *, deprecated,
      message:
        "Read @Environment(\\.dsTheme).typography.largeTitle so the value follows the app's theme"
    )
    public static var largeTitle: Font { DSTheme.default.typography.largeTitle }

    @available(
      *, deprecated,
      message:
        "Read @Environment(\\.dsTheme).typography.title1 so the value follows the app's theme"
    )
    public static var title1: Font { DSTheme.default.typography.title1 }

    @available(
      *, deprecated,
      message:
        "Read @Environment(\\.dsTheme).typography.title2 so the value follows the app's theme"
    )
    public static var title2: Font { DSTheme.default.typography.title2 }

    @available(
      *, deprecated,
      message:
        "Read @Environment(\\.dsTheme).typography.title3 so the value follows the app's theme"
    )
    public static var title3: Font { DSTheme.default.typography.title3 }

    @available(
      *, deprecated,
      message:
        "Read @Environment(\\.dsTheme).typography.bodyLarge so the value follows the app's theme"
    )
    public static var bodyLarge: Font { DSTheme.default.typography.bodyLarge }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).typography.body so the value follows the app's theme"
    )
    public static var body: Font { DSTheme.default.typography.body }

    @available(
      *, deprecated,
      message:
        "Read @Environment(\\.dsTheme).typography.bodySmall so the value follows the app's theme"
    )
    public static var bodySmall: Font { DSTheme.default.typography.bodySmall }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).typography.label so the value follows the app's theme"
    )
    public static var label: Font { DSTheme.default.typography.label }

    @available(
      *, deprecated,
      message:
        "Read @Environment(\\.dsTheme).typography.labelSmall so the value follows the app's theme"
    )
    public static var labelSmall: Font { DSTheme.default.typography.labelSmall }

    @available(
      *, deprecated,
      message:
        "Read @Environment(\\.dsTheme).typography.caption so the value follows the app's theme"
    )
    public static var caption: Font { DSTheme.default.typography.caption }

    @available(
      *, deprecated,
      message:
        "Read @Environment(\\.dsTheme).typography.captionSmall so the value follows the app's theme"
    )
    public static var captionSmall: Font { DSTheme.default.typography.captionSmall }

    @available(
      *, deprecated,
      message:
        "Read @Environment(\\.dsTheme).typography.button so the value follows the app's theme"
    )
    public static var button: Font { DSTheme.default.typography.button }

    @available(
      *, deprecated,
      message:
        "Read @Environment(\\.dsTheme).typography.buttonSmall so the value follows the app's theme"
    )
    public static var buttonSmall: Font { DSTheme.default.typography.buttonSmall }
  }

  // MARK: - Shadows

  public struct Shadows: Sendable {
    public var sm: ShadowStyle
    public var md: ShadowStyle
    public var lg: ShadowStyle

    public init(
      sm: ShadowStyle = ShadowStyle(color: .black.opacity(0.08), radius: 4, x: 0, y: 2),
      md: ShadowStyle = ShadowStyle(color: .black.opacity(0.1), radius: 8, x: 0, y: 4),
      lg: ShadowStyle = ShadowStyle(color: .black.opacity(0.12), radius: 16, x: 0, y: 8)
    ) {
      self.sm = sm
      self.md = md
      self.lg = lg
    }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).shadows.sm so the value follows the app's theme"
    )
    public static var sm: ShadowStyle { DSTheme.default.shadows.sm }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).shadows.md so the value follows the app's theme"
    )
    public static var md: ShadowStyle { DSTheme.default.shadows.md }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).shadows.lg so the value follows the app's theme"
    )
    public static var lg: ShadowStyle { DSTheme.default.shadows.lg }
  }

  // MARK: - Animation

  public struct Animation: Sendable {
    public var fast: SwiftUI.Animation
    public var normal: SwiftUI.Animation
    public var slow: SwiftUI.Animation
    public var spring: SwiftUI.Animation

    public init(
      fast: SwiftUI.Animation = SwiftUI.Animation.easeInOut(duration: 0.15),
      normal: SwiftUI.Animation = SwiftUI.Animation.easeInOut(duration: 0.25),
      slow: SwiftUI.Animation = SwiftUI.Animation.easeInOut(duration: 0.4),
      spring: SwiftUI.Animation = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
    ) {
      self.fast = fast
      self.normal = normal
      self.slow = slow
      self.spring = spring
    }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).animation.fast so the value follows the app's theme"
    )
    public static var fast: SwiftUI.Animation { DSTheme.default.animation.fast }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).animation.normal so the value follows the app's theme"
    )
    public static var normal: SwiftUI.Animation { DSTheme.default.animation.normal }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).animation.slow so the value follows the app's theme"
    )
    public static var slow: SwiftUI.Animation { DSTheme.default.animation.slow }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).animation.spring so the value follows the app's theme"
    )
    public static var spring: SwiftUI.Animation { DSTheme.default.animation.spring }
  }

  // MARK: - Icon Sizes

  public struct IconSize: Sendable {
    public var xs: CGFloat
    public var sm: CGFloat
    public var md: CGFloat
    public var lg: CGFloat
    public var xl: CGFloat
    public var xxl: CGFloat

    public init(
      xs: CGFloat = 12,
      sm: CGFloat = 16,
      md: CGFloat = 20,
      lg: CGFloat = 24,
      xl: CGFloat = 32,
      xxl: CGFloat = 48
    ) {
      self.xs = xs
      self.sm = sm
      self.md = md
      self.lg = lg
      self.xl = xl
      self.xxl = xxl
    }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).iconSize.xs so the value follows the app's theme"
    )
    public static var xs: CGFloat { DSTheme.default.iconSize.xs }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).iconSize.sm so the value follows the app's theme"
    )
    public static var sm: CGFloat { DSTheme.default.iconSize.sm }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).iconSize.md so the value follows the app's theme"
    )
    public static var md: CGFloat { DSTheme.default.iconSize.md }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).iconSize.lg so the value follows the app's theme"
    )
    public static var lg: CGFloat { DSTheme.default.iconSize.lg }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).iconSize.xl so the value follows the app's theme"
    )
    public static var xl: CGFloat { DSTheme.default.iconSize.xl }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).iconSize.xxl so the value follows the app's theme"
    )
    public static var xxl: CGFloat { DSTheme.default.iconSize.xxl }
  }

  // MARK: - Avatar Sizes

  public struct AvatarSize: Sendable {
    public var sm: CGFloat
    public var md: CGFloat
    public var lg: CGFloat
    public var xl: CGFloat
    public var xxl: CGFloat

    public init(
      sm: CGFloat = 32,
      md: CGFloat = 40,
      lg: CGFloat = 50,
      xl: CGFloat = 64,
      xxl: CGFloat = 80
    ) {
      self.sm = sm
      self.md = md
      self.lg = lg
      self.xl = xl
      self.xxl = xxl
    }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).avatarSize.sm so the value follows the app's theme"
    )
    public static var sm: CGFloat { DSTheme.default.avatarSize.sm }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).avatarSize.md so the value follows the app's theme"
    )
    public static var md: CGFloat { DSTheme.default.avatarSize.md }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).avatarSize.lg so the value follows the app's theme"
    )
    public static var lg: CGFloat { DSTheme.default.avatarSize.lg }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).avatarSize.xl so the value follows the app's theme"
    )
    public static var xl: CGFloat { DSTheme.default.avatarSize.xl }

    @available(
      *, deprecated,
      message: "Read @Environment(\\.dsTheme).avatarSize.xxl so the value follows the app's theme"
    )
    public static var xxl: CGFloat { DSTheme.default.avatarSize.xxl }
  }
}

// MARK: - Environment

extension EnvironmentValues {
  /// The theme components draw their tokens from. Defaults to `DSTheme.default`.
  @Entry public var dsTheme: DSTheme = .default
}

extension View {
  /// Set the theme for this view and everything inside it.
  public func dsTheme(_ theme: DSTheme) -> some View {
    environment(\.dsTheme, theme)
  }
}

// MARK: - Shadow Style Helper

public struct ShadowStyle: Sendable {
  public let color: Color
  public let radius: CGFloat
  public let x: CGFloat
  public let y: CGFloat

  public init(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
    self.color = color
    self.radius = radius
    self.x = x
    self.y = y
  }
}

// MARK: - View Extension for Shadows

extension View {
  public func dsShadow(_ style: ShadowStyle) -> some View {
    self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
  }
}
