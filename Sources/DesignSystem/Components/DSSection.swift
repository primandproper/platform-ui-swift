//
//  DSSection.swift
//  DesignSystem
//
//  Design System Section Component - Section with header and optional subtitle
//

import SwiftUI

// MARK: - Section Variant

public enum DSSectionVariant: Sendable {
  case standard
  case compact
  case card
}

// MARK: - Section Style

/// The look of `DSSection`. Set it with `.dsSectionStyle(_:)`.
public protocol DSSectionStyle: Sendable {
  typealias Configuration = DSSectionStyleConfiguration
  associatedtype Body: View

  @MainActor @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

/// What a section style draws.
public struct DSSectionStyleConfiguration {
  /// The section's header, already rendered through the header style.
  public let header: AnyView
  public let content: AnyView
  public let variant: DSSectionVariant
  public let spacing: CGFloat
  public let showDivider: Bool
  public let theme: DSTheme
}

/// The look every section had before styles existed.
public struct DefaultDSSectionStyle: DSSectionStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    VStack(alignment: .leading, spacing: configuration.spacing) {
      configuration.header

      if configuration.showDivider {
        Divider()
      }

      if configuration.variant == .card {
        DSCard {
          VStack(alignment: .leading, spacing: configuration.spacing) {
            configuration.content
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }
      } else {
        configuration.content
      }
    }
  }
}

extension DSSectionStyle where Self == DefaultDSSectionStyle {
  public static var `default`: DefaultDSSectionStyle { DefaultDSSectionStyle() }
}

extension AnyDSStyle where Configuration == DSSectionStyleConfiguration {
  init(_ style: some DSSectionStyle) {
    self.init { AnyView(style.makeBody(configuration: $0)) }
  }
}

extension EnvironmentValues {
  @Entry var dsSectionStyle = AnyDSStyle(DefaultDSSectionStyle())
}

extension View {
  /// Set the style of every `DSSection` inside this view.
  public func dsSectionStyle(_ style: some DSSectionStyle) -> some View {
    environment(\.dsSectionStyle, AnyDSStyle(style))
  }
}

// MARK: - DSSection Component

/// A section container with a styled header and optional subtitle.
///
/// Usage:
/// ```swift
/// DSSection("Members") {
///   ForEach(members) { MemberRow(member: $0) }
/// }
///
/// DSSection("Household", subtitle: "People in your household") {
///   ForEach(members) { MemberRow(member: $0) }
/// }
///
/// DSSection("Tasks", style: .compact) {
///   TaskList()
/// }
/// ```
public struct DSSection<Content: View>: View {
  let title: String
  let subtitle: String?
  let variant: DSSectionVariant
  let spacing: CGFloat?
  let showDivider: Bool
  @ViewBuilder let content: () -> Content

  @Environment(\.dsTheme) private var theme
  @Environment(\.dsSectionStyle) private var sectionStyle

  /// `spacing` defaults to the theme's `spacing.sm` for `.compact` and `spacing.md` otherwise.
  public init(
    _ title: String,
    subtitle: String? = nil,
    style: DSSectionVariant = .standard,
    spacing: CGFloat? = nil,
    showDivider: Bool = false,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.title = title
    self.subtitle = subtitle
    self.variant = style
    self.spacing = spacing
    self.showDivider = showDivider
    self.content = content
  }

  public var body: some View {
    sectionStyle.makeBody(
      DSSectionStyleConfiguration(
        header: AnyView(DSSectionHeader(title: title, subtitle: subtitle, style: headerVariant)),
        content: AnyView(content()),
        variant: variant,
        spacing: spacing ?? (variant == .compact ? theme.spacing.sm : theme.spacing.md),
        showDivider: showDivider,
        theme: theme
      )
    )
  }

  private var headerVariant: DSSectionHeaderVariant {
    switch variant {
    case .compact:
      return .compact
    default:
      return .standard
    }
  }
}

// MARK: - Section Header Variant

public enum DSSectionHeaderVariant: Sendable {
  case standard
  case compact
  case large
  /// Caption-sized label for drawer sections and small headers
  case label
}

// MARK: - Section Header Style

/// The look of `DSSectionHeader`, including the one inside `DSSection`. Set it with `.dsSectionHeaderStyle(_:)`.
public protocol DSSectionHeaderStyle: Sendable {
  typealias Configuration = DSSectionHeaderStyleConfiguration
  associatedtype Body: View

  @MainActor @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

/// What a section header style draws.
public struct DSSectionHeaderStyleConfiguration {
  public let title: String
  public let subtitle: String?
  /// An SF Symbol name.
  public let systemImage: String?
  public let variant: DSSectionHeaderVariant
  public let titleColor: Color
  /// Whatever the caller put at the trailing edge; `EmptyView` when it put nothing.
  public let trailing: AnyView
  public let theme: DSTheme
}

/// The look every section header had before styles existed.
public struct DefaultDSSectionHeaderStyle: DSSectionHeaderStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    let theme = configuration.theme

    VStack(alignment: .leading, spacing: theme.spacing.xs) {
      HStack {
        if let systemImage = configuration.systemImage {
          Label(configuration.title, systemImage: systemImage)
            .font(titleFont(configuration))
            .foregroundColor(configuration.titleColor)
        } else {
          Text(configuration.title)
            .font(titleFont(configuration))
            .foregroundColor(configuration.titleColor)
        }

        Spacer()

        configuration.trailing
      }

      if let subtitle = configuration.subtitle, !subtitle.isEmpty {
        Text(subtitle)
          .font(subtitleFont(configuration))
          .foregroundColor(theme.colors.textSecondary)
      }
    }
    .padding(.horizontal, horizontalPadding(configuration))
  }

  private func titleFont(_ configuration: Configuration) -> Font {
    let typography = configuration.theme.typography
    switch configuration.variant {
    case .large:
      return typography.title1
    case .standard:
      return typography.title2
    case .compact:
      return typography.title3
    case .label:
      return typography.caption.weight(.semibold)
    }
  }

  private func subtitleFont(_ configuration: Configuration) -> Font {
    let typography = configuration.theme.typography
    switch configuration.variant {
    case .large:
      return typography.body
    case .standard, .compact, .label:
      return typography.bodySmall
    }
  }

  private func horizontalPadding(_ configuration: Configuration) -> CGFloat {
    let spacing = configuration.theme.spacing
    switch configuration.variant {
    case .compact:
      return spacing.xxs
    case .label:
      return spacing.md
    default:
      return spacing.xs
    }
  }
}

extension DSSectionHeaderStyle where Self == DefaultDSSectionHeaderStyle {
  public static var `default`: DefaultDSSectionHeaderStyle { DefaultDSSectionHeaderStyle() }
}

extension AnyDSStyle where Configuration == DSSectionHeaderStyleConfiguration {
  init(_ style: some DSSectionHeaderStyle) {
    self.init { AnyView(style.makeBody(configuration: $0)) }
  }
}

extension EnvironmentValues {
  @Entry var dsSectionHeaderStyle = AnyDSStyle(DefaultDSSectionHeaderStyle())
}

extension View {
  /// Set the style of every `DSSectionHeader` inside this view.
  public func dsSectionHeaderStyle(_ style: some DSSectionHeaderStyle) -> some View {
    environment(\.dsSectionHeaderStyle, AnyDSStyle(style))
  }
}

// MARK: - DSSectionHeader Component

/// A standalone section header that can be used independently.
///
/// Usage:
/// ```swift
/// DSSectionHeader(title: "Members")
/// DSSectionHeader(title: "Details", subtitle: "Additional information")
/// DSSectionHeader(title: "Future Meal Plans", systemImage: "calendar.badge.clock")
/// DSSectionHeader(title: "Upcoming", systemImage: "calendar") {
///   Text("3 plans").font(.caption).foregroundColor(.secondary)
/// }
/// ```
public struct DSSectionHeader<Trailing: View>: View {
  let title: String
  let subtitle: String?
  let systemImage: String?
  let variant: DSSectionHeaderVariant
  let titleColor: Color?
  @ViewBuilder let trailing: () -> Trailing

  @Environment(\.dsTheme) private var theme
  @Environment(\.dsSectionHeaderStyle) private var sectionHeaderStyle

  /// `titleColor` defaults to the theme's `colors.textSecondary` for `.label` and
  /// `colors.textPrimary` otherwise.
  public init(
    title: String,
    subtitle: String? = nil,
    systemImage: String? = nil,
    style: DSSectionHeaderVariant = .standard,
    titleColor: Color? = nil,
    @ViewBuilder trailing: @escaping () -> Trailing
  ) {
    self.title = title
    self.subtitle = subtitle
    self.systemImage = systemImage
    self.variant = style
    self.titleColor = titleColor
    self.trailing = trailing
  }

  public var body: some View {
    sectionHeaderStyle.makeBody(
      DSSectionHeaderStyleConfiguration(
        title: title,
        subtitle: subtitle,
        systemImage: systemImage,
        variant: variant,
        titleColor: titleColor
          ?? (variant == .label ? theme.colors.textSecondary : theme.colors.textPrimary),
        trailing: AnyView(trailing()),
        theme: theme
      )
    )
  }
}

// MARK: - DSSectionHeader without trailing

extension DSSectionHeader where Trailing == EmptyView {
  /// `titleColor` defaults to the theme's `colors.textSecondary` for `.label` and
  /// `colors.textPrimary` otherwise.
  public init(
    title: String,
    subtitle: String? = nil,
    systemImage: String? = nil,
    style: DSSectionHeaderVariant = .standard,
    titleColor: Color? = nil
  ) {
    self.title = title
    self.subtitle = subtitle
    self.systemImage = systemImage
    self.variant = style
    self.titleColor = titleColor
    self.trailing = { EmptyView() }
  }
}

// MARK: - Rule-Flanked Header

/// The look of `DSRuleFlankedHeader`. Set it with `.dsRuleFlankedHeaderStyle(_:)`.
public protocol DSRuleFlankedHeaderStyle: Sendable {
  typealias Configuration = DSRuleFlankedHeaderStyleConfiguration
  associatedtype Body: View

  @MainActor @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

/// What a rule-flanked header style draws.
public struct DSRuleFlankedHeaderStyleConfiguration {
  public let title: String
  public let color: Color
  public let strikethrough: Bool
  public let theme: DSTheme
}

/// The look every rule-flanked header had before styles existed.
public struct DefaultDSRuleFlankedHeaderStyle: DSRuleFlankedHeaderStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    HStack(spacing: 12) {
      Rectangle()
        .fill(Color.secondary.opacity(0.5))
        .frame(height: 1)
        .frame(maxWidth: .infinity)
      Text(configuration.title)
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundColor(configuration.color)
        .strikethrough(configuration.strikethrough)
      Rectangle()
        .fill(Color.secondary.opacity(0.5))
        .frame(height: 1)
        .frame(maxWidth: .infinity)
    }
    .padding(.vertical, 8)
    .frame(maxWidth: .infinity)
    .background(configuration.theme.colors.background)
  }
}

extension DSRuleFlankedHeaderStyle where Self == DefaultDSRuleFlankedHeaderStyle {
  public static var `default`: DefaultDSRuleFlankedHeaderStyle { DefaultDSRuleFlankedHeaderStyle() }
}

extension AnyDSStyle where Configuration == DSRuleFlankedHeaderStyleConfiguration {
  init(_ style: some DSRuleFlankedHeaderStyle) {
    self.init { AnyView(style.makeBody(configuration: $0)) }
  }
}

extension EnvironmentValues {
  @Entry var dsRuleFlankedHeaderStyle = AnyDSStyle(DefaultDSRuleFlankedHeaderStyle())
}

extension View {
  /// Set the style of every `DSRuleFlankedHeader` inside this view.
  public func dsRuleFlankedHeaderStyle(_ style: some DSRuleFlankedHeaderStyle) -> some View {
    environment(\.dsRuleFlankedHeaderStyle, AnyDSStyle(style))
  }
}

/// A section header with horizontal rules flanking the title, matching the recipe step flow style.
///
/// Usage:
/// ```swift
/// DSRuleFlankedHeader(title: "Up Next", color: .orange)
/// DSRuleFlankedHeader(title: "Have", color: .green)
/// ```
public struct DSRuleFlankedHeader: View {
  let title: String
  let color: Color
  var strikethrough: Bool = false

  @Environment(\.dsTheme) private var theme
  @Environment(\.dsRuleFlankedHeaderStyle) private var ruleFlankedHeaderStyle

  public init(title: String, color: Color, strikethrough: Bool = false) {
    self.title = title
    self.color = color
    self.strikethrough = strikethrough
  }

  public var body: some View {
    ruleFlankedHeaderStyle.makeBody(
      DSRuleFlankedHeaderStyleConfiguration(
        title: title,
        color: color,
        strikethrough: strikethrough,
        theme: theme
      )
    )
  }
}

// MARK: - Empty Section Content

/// The look of `DSSectionEmptyContent`. Set it with `.dsSectionEmptyContentStyle(_:)`.
public protocol DSSectionEmptyContentStyle: Sendable {
  typealias Configuration = DSSectionEmptyContentStyleConfiguration
  associatedtype Body: View

  @MainActor @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

/// What a section empty-content style draws.
public struct DSSectionEmptyContentStyleConfiguration {
  public let message: String
  /// An SF Symbol name.
  public let icon: String?
  public let theme: DSTheme
}

/// The look every section empty-content view had before styles existed.
public struct DefaultDSSectionEmptyContentStyle: DSSectionEmptyContentStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    let theme = configuration.theme

    HStack(spacing: theme.spacing.sm) {
      if let icon = configuration.icon {
        Image(systemName: icon)
          .font(.subheadline)
          .foregroundColor(theme.colors.textSecondary)
      }

      Text(configuration.message)
        .font(theme.typography.body)
        .foregroundColor(theme.colors.textSecondary)
    }
    .padding(.vertical, theme.spacing.sm)
    .padding(.horizontal, theme.spacing.xs)
  }
}

extension DSSectionEmptyContentStyle where Self == DefaultDSSectionEmptyContentStyle {
  public static var `default`: DefaultDSSectionEmptyContentStyle {
    DefaultDSSectionEmptyContentStyle()
  }
}

extension AnyDSStyle where Configuration == DSSectionEmptyContentStyleConfiguration {
  init(_ style: some DSSectionEmptyContentStyle) {
    self.init { AnyView(style.makeBody(configuration: $0)) }
  }
}

extension EnvironmentValues {
  @Entry var dsSectionEmptyContentStyle = AnyDSStyle(DefaultDSSectionEmptyContentStyle())
}

extension View {
  /// Set the style of every `DSSectionEmptyContent` inside this view.
  public func dsSectionEmptyContentStyle(_ style: some DSSectionEmptyContentStyle) -> some View {
    environment(\.dsSectionEmptyContentStyle, AnyDSStyle(style))
  }
}

/// A helper view for displaying empty state within a section.
public struct DSSectionEmptyContent: View {
  let message: String
  let icon: String?

  @Environment(\.dsTheme) private var theme
  @Environment(\.dsSectionEmptyContentStyle) private var sectionEmptyContentStyle

  public init(_ message: String, icon: String? = nil) {
    self.message = message
    self.icon = icon
  }

  public var body: some View {
    sectionEmptyContentStyle.makeBody(
      DSSectionEmptyContentStyleConfiguration(message: message, icon: icon, theme: theme)
    )
  }
}

// MARK: - Preview

#Preview("Section Styles") {
  ScrollView {
    VStack(spacing: DSTheme.default.spacing.xl) {
      DSSection("Standard Section") {
        Text("Content goes here")
          .dsCard()
      }

      DSSection("With Subtitle", subtitle: "This is additional context") {
        Text("More content")
          .dsCard()
      }

      DSSection("Compact Style", style: .compact) {
        VStack(spacing: DSTheme.default.spacing.sm) {
          Text("Item 1")
          Text("Item 2")
          Text("Item 3")
        }
        .dsCard()
      }

      DSSection("Card Style", subtitle: "Content wrapped in a card", style: .card) {
        VStack(alignment: .leading, spacing: DSTheme.default.spacing.sm) {
          Text("Item 1")
          Divider()
          Text("Item 2")
          Divider()
          Text("Item 3")
        }
      }

      DSSection("Empty Section") {
        DSSectionEmptyContent("No items available", icon: "tray")
      }
    }
    .padding()
  }
}
