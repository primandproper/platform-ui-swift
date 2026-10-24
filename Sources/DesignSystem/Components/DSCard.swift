//
//  DSCard.swift
//  DesignSystem
//
//  Design System Card Component - Consistent card styling
//

import SwiftUI

// MARK: - Card Variant

public enum DSCardVariant: Sendable {
  case standard
  case elevated
  case outlined
  case selected
  case interactive

  public func backgroundColor(in theme: DSTheme) -> Color {
    switch self {
    case .standard:
      return theme.colors.cardBackground
    case .elevated:
      return theme.colors.cardBackgroundElevated
    case .outlined:
      return theme.colors.background
    case .selected:
      return theme.colors.cardBackgroundSelected
    case .interactive:
      return theme.colors.cardBackground
    }
  }

  public func borderColor(in theme: DSTheme) -> Color? {
    switch self {
    case .outlined:
      return theme.colors.border
    case .selected:
      return theme.colors.borderSelected
    default:
      return nil
    }
  }

  public var borderWidth: CGFloat {
    switch self {
    case .outlined:
      return 1
    case .selected:
      return 2
    default:
      return 0
    }
  }

  public func shadow(in theme: DSTheme) -> ShadowStyle? {
    switch self {
    case .elevated:
      return theme.shadows.sm
    default:
      return nil
    }
  }
}

// MARK: - Card Style

/// The look of `DSCard` and `.dsCard()`. Set it with `.dsCardStyle(_:)`.
public protocol DSCardStyle: Sendable {
  typealias Configuration = DSCardStyleConfiguration
  associatedtype Body: View

  @MainActor @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

/// What a card style draws.
public struct DSCardStyleConfiguration {
  /// The card's contents, which the style wraps.
  public let content: AnyView
  public let variant: DSCardVariant
  public let padding: CGFloat
  public let cornerRadius: CGFloat
  public let theme: DSTheme
}

/// The look every card had before styles existed.
public struct DefaultDSCardStyle: DSCardStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    let theme = configuration.theme
    let variant = configuration.variant

    configuration.content
      .padding(configuration.padding)
      .background(variant.backgroundColor(in: theme))
      .cornerRadius(configuration.cornerRadius)
      .overlay(
        RoundedRectangle(cornerRadius: configuration.cornerRadius)
          .stroke(variant.borderColor(in: theme) ?? .clear, lineWidth: variant.borderWidth)
      )
      .ifLet(variant.shadow(in: theme)) { view, shadow in
        view.dsShadow(shadow)
      }
  }
}

extension DSCardStyle where Self == DefaultDSCardStyle {
  public static var `default`: DefaultDSCardStyle { DefaultDSCardStyle() }
}

extension AnyDSStyle where Configuration == DSCardStyleConfiguration {
  init(_ style: some DSCardStyle) {
    self.init { AnyView(style.makeBody(configuration: $0)) }
  }
}

extension EnvironmentValues {
  @Entry var dsCardStyle = AnyDSStyle(DefaultDSCardStyle())
}

extension View {
  /// Set the style of every `DSCard` and `.dsCard()` inside this view.
  public func dsCardStyle(_ style: some DSCardStyle) -> some View {
    environment(\.dsCardStyle, AnyDSStyle(style))
  }
}

// MARK: - DSCard Component

/// A styled card container with consistent padding, background, and corner radius.
///
/// Usage:
/// ```swift
/// DSCard {
///   HStack {
///     Text("Card content")
///     Spacer()
///   }
/// }
///
/// DSCard(style: .selected) {
///   Text("Selected card")
/// }
///
/// DSCard(style: .interactive, action: { handleTap() }) {
///   Text("Tappable card")
/// }
/// ```
public struct DSCard<Content: View>: View {
  let variant: DSCardVariant
  let padding: CGFloat?
  let cornerRadius: CGFloat?
  let action: (() -> Void)?
  @ViewBuilder let content: () -> Content

  @Environment(\.dsTheme) private var theme
  @Environment(\.dsCardStyle) private var cardStyle

  /// `padding` and `cornerRadius` default to the theme's `spacing.lg` and `radius.md`.
  public init(
    style: DSCardVariant = .standard,
    padding: CGFloat? = nil,
    cornerRadius: CGFloat? = nil,
    action: (() -> Void)? = nil,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.variant = style
    self.padding = padding
    self.cornerRadius = cornerRadius
    self.action = action
    self.content = content
  }

  public var body: some View {
    Group {
      if let action = action {
        Button(action: action) {
          cardContent
        }
        .buttonStyle(.plain)
      } else {
        cardContent
      }
    }
  }

  private var cardContent: some View {
    cardStyle.makeBody(
      DSCardStyleConfiguration(
        content: AnyView(content()),
        variant: variant,
        padding: padding ?? theme.spacing.lg,
        cornerRadius: cornerRadius ?? theme.radius.md,
        theme: theme
      )
    )
    .contentShape(Rectangle())
  }
}

// MARK: - View Modifier

public struct DSCardModifier: ViewModifier {
  let variant: DSCardVariant
  let padding: CGFloat?
  let cornerRadius: CGFloat?

  @Environment(\.dsTheme) private var theme
  @Environment(\.dsCardStyle) private var cardStyle

  /// `padding` and `cornerRadius` default to the theme's `spacing.lg` and `radius.md`.
  public init(style: DSCardVariant, padding: CGFloat? = nil, cornerRadius: CGFloat? = nil) {
    self.variant = style
    self.padding = padding
    self.cornerRadius = cornerRadius
  }

  public func body(content: Content) -> some View {
    cardStyle.makeBody(
      DSCardStyleConfiguration(
        content: AnyView(content),
        variant: variant,
        padding: padding ?? theme.spacing.lg,
        cornerRadius: cornerRadius ?? theme.radius.md,
        theme: theme
      )
    )
  }
}

// MARK: - View Extension

extension View {
  /// Apply card styling to any view.
  ///
  /// Usage:
  /// ```swift
  /// HStack {
  ///   Text("Content")
  ///   Spacer()
  /// }
  /// .dsCard()
  ///
  /// VStack { ... }
  /// .dsCard(style: .elevated)
  /// ```
  public func dsCard(
    style: DSCardVariant = .standard,
    padding: CGFloat? = nil,
    cornerRadius: CGFloat? = nil
  ) -> some View {
    self.modifier(DSCardModifier(style: style, padding: padding, cornerRadius: cornerRadius))
  }
}

// MARK: - Helper Extension

extension View {
  /// Conditionally applies a transformation if the value is non-nil.
  @ViewBuilder
  public func ifLet<T, Result: View>(_ value: T?, transform: (Self, T) -> Result) -> some View {
    if let value = value {
      transform(self, value)
    } else {
      self
    }
  }
}

// MARK: - Preview

#Preview("Card Styles") {
  ScrollView {
    VStack(spacing: DSTheme.default.spacing.lg) {
      DSCard {
        HStack {
          Text("Standard Card")
          Spacer()
        }
      }

      DSCard(style: .elevated) {
        HStack {
          Text("Elevated Card")
          Spacer()
        }
      }

      DSCard(style: .outlined) {
        HStack {
          Text("Outlined Card")
          Spacer()
        }
      }

      DSCard(style: .selected) {
        HStack {
          Text("Selected Card")
          Spacer()
        }
      }

      DSCard(style: .interactive, action: { print("Tapped") }) {
        HStack {
          Text("Interactive Card - Tap me")
          Spacer()
          Image(systemName: "chevron.right")
            .foregroundColor(.secondary)
        }
      }

      // Using modifier
      HStack {
        Text("Using .dsCard() modifier")
        Spacer()
      }
      .dsCard(style: .elevated)
    }
    .padding()
  }
}
