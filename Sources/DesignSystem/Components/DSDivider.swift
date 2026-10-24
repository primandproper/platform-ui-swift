//
//  DSDivider.swift
//  DesignSystem
//
//  Design System Divider - Consistent divider styling with standard and soft variants
//

import SwiftUI

// MARK: - DSDivider Variant

public enum DSDividerVariant: Sendable {
  /// System divider for standard separation
  case standard
  /// Softer divider with reduced opacity and optional horizontal inset
  case soft
}

// MARK: - Divider Style

/// The look of `DSDivider`, `DSSoftDivider` and `DSListDivider`. Set it with `.dsDividerStyle(_:)`.
public protocol DSDividerStyle: Sendable {
  typealias Configuration = DSDividerStyleConfiguration
  associatedtype Body: View

  @MainActor @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

/// What a divider style draws.
public struct DSDividerStyleConfiguration {
  public let variant: DSDividerVariant
  /// The inset the caller asked for; 0 when it asked for none.
  public let horizontalInset: CGFloat
  public let theme: DSTheme
}

/// The look every divider had before styles existed.
public struct DefaultDSDividerStyle: DSDividerStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    switch configuration.variant {
    case .standard:
      Divider()
        .padding(.leading, configuration.horizontalInset)
    case .soft:
      Rectangle()
        .fill(configuration.theme.colors.border.opacity(0.5))
        .frame(height: 1)
        .frame(maxWidth: .infinity)
        .padding(
          .horizontal,
          configuration.horizontalInset > 0
            ? configuration.horizontalInset : configuration.theme.spacing.xl * 2
        )
    }
  }
}

extension DSDividerStyle where Self == DefaultDSDividerStyle {
  public static var `default`: DefaultDSDividerStyle { DefaultDSDividerStyle() }
}

extension AnyDSStyle where Configuration == DSDividerStyleConfiguration {
  init(_ style: some DSDividerStyle) {
    self.init { AnyView(style.makeBody(configuration: $0)) }
  }
}

extension EnvironmentValues {
  @Entry var dsDividerStyle = AnyDSStyle(DefaultDSDividerStyle())
}

extension View {
  /// Set the style of every `DSDivider`, `DSSoftDivider` and `DSListDivider` inside this view.
  public func dsDividerStyle(_ style: some DSDividerStyle) -> some View {
    environment(\.dsDividerStyle, AnyDSStyle(style))
  }
}

// MARK: - DSDivider

/// A theme-consistent divider with standard and soft variants.
///
/// Usage:
/// ```swift
/// DSDivider()
/// DSDivider(style: .soft)
/// DSDivider(style: .soft, horizontalInset: 48)
/// ```
public struct DSDivider: View {
  var variant: DSDividerVariant = .standard
  var horizontalInset: CGFloat = 0

  @Environment(\.dsTheme) private var theme
  @Environment(\.dsDividerStyle) private var dividerStyle

  public init(style: DSDividerVariant = .standard, horizontalInset: CGFloat = 0) {
    self.variant = style
    self.horizontalInset = horizontalInset
  }

  public var body: some View {
    dividerStyle.makeBody(
      DSDividerStyleConfiguration(
        variant: variant,
        horizontalInset: horizontalInset,
        theme: theme
      )
    )
  }
}

// MARK: - DSSoftDivider

/// A soft divider with vertical spacing, for use between content sections.
/// Replaces the softSeparator pattern (Rectangle with opacity, horizontal padding, vertical spacing).
///
/// Usage:
/// ```swift
/// DSSoftDivider()
/// DSSoftDivider(verticalSpacing: 16)
/// ```
public struct DSSoftDivider: View {
  var verticalSpacing: CGFloat?
  var horizontalInset: CGFloat?

  @Environment(\.dsTheme) private var theme

  /// `verticalSpacing` and `horizontalInset` default to the theme's `spacing.md` and twice its
  /// `spacing.xl`.
  public init(verticalSpacing: CGFloat? = nil, horizontalInset: CGFloat? = nil) {
    self.verticalSpacing = verticalSpacing
    self.horizontalInset = horizontalInset
  }

  public var body: some View {
    let spacing = verticalSpacing ?? theme.spacing.md

    VStack(spacing: 0) {
      Spacer()
        .frame(height: spacing)
      DSDivider(style: .soft, horizontalInset: horizontalInset ?? theme.spacing.xl * 2)
      Spacer()
        .frame(height: spacing)
    }
  }
}

// MARK: - Preview

#Preview("DSDivider") {
  VStack(spacing: DSTheme.default.spacing.lg) {
    Text("Above")
    DSDivider()
    Text("Below")

    Text("Above soft")
    DSDivider(style: .soft)
    Text("Below soft")

    Text("Above DSSoftDivider")
    DSSoftDivider()
    Text("Below DSSoftDivider")
  }
  .padding()
}
