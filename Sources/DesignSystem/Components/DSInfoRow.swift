//
//  DSInfoRow.swift
//  DesignSystem
//
//  Design System Info Row - Card-style row with icon, text, and optional chevron
//

import SwiftUI

// MARK: - Info Row Style

/// The look of `DSInfoRow`. Set it with `.dsInfoRowStyle(_:)`.
public protocol DSInfoRowStyle: Sendable {
  typealias Configuration = DSInfoRowStyleConfiguration
  associatedtype Body: View

  @MainActor @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

/// What an info row style draws.
public struct DSInfoRowStyleConfiguration {
  /// An SF Symbol name.
  public let icon: String
  public let text: String
  public let color: Color
  public let showChevron: Bool
  public let strikethrough: Bool
  public let theme: DSTheme
}

/// The look every info row had before styles existed.
public struct DefaultDSInfoRowStyle: DSInfoRowStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    let theme = configuration.theme

    HStack(spacing: theme.spacing.md) {
      ZStack {
        Circle()
          .fill(configuration.color.opacity(0.15))
          .frame(width: 36, height: 36)

        Image(systemName: configuration.icon)
          .font(.system(size: 15, weight: .medium))
          .foregroundColor(configuration.color)
      }

      Text(configuration.text)
        .font(theme.typography.label)
        .foregroundColor(theme.colors.textPrimary)
        .strikethrough(configuration.strikethrough)

      Spacer()

      if configuration.showChevron {
        Image(systemName: "chevron.right")
          .font(.system(size: 13, weight: .semibold))
          .foregroundColor(theme.colors.textTertiary)
      }
    }
    .padding(theme.spacing.md)
    .background(theme.colors.cardBackground)
    .cornerRadius(theme.radius.lg)
    .overlay(
      RoundedRectangle(cornerRadius: theme.radius.lg)
        .stroke(theme.colors.border, lineWidth: 1)
    )
  }
}

extension DSInfoRowStyle where Self == DefaultDSInfoRowStyle {
  public static var `default`: DefaultDSInfoRowStyle { DefaultDSInfoRowStyle() }
}

extension AnyDSStyle where Configuration == DSInfoRowStyleConfiguration {
  init(_ style: some DSInfoRowStyle) {
    self.init { AnyView(style.makeBody(configuration: $0)) }
  }
}

extension EnvironmentValues {
  @Entry var dsInfoRowStyle = AnyDSStyle(DefaultDSInfoRowStyle())
}

extension View {
  /// Set the style of every `DSInfoRow` inside this view.
  public func dsInfoRowStyle(_ style: some DSInfoRowStyle) -> some View {
    environment(\.dsInfoRowStyle, AnyDSStyle(style))
  }
}

// MARK: - DSInfoRow

/// A card-style row with an icon in a colored circle, text, and optional chevron.
/// Use for navigation links (e.g. task summary, grocery list) inside NavigationLink or Button.
///
/// Usage:
/// ```swift
/// NavigationLink(destination: TaskListView(...)) {
///   DSInfoRow(icon: "checklist", text: "3 tasks remaining", color: .orange)
/// }
/// .buttonStyle(.plain)
///
/// DSInfoRow(icon: "cart.fill", text: "Grocery List (2 needed)", color: .blue, showChevron: false)
/// ```
public struct DSInfoRow: View {
  let icon: String
  let text: String
  let color: Color
  var showChevron: Bool = true
  var strikethrough: Bool = false

  @Environment(\.dsTheme) private var theme
  @Environment(\.dsInfoRowStyle) private var infoRowStyle

  public init(
    icon: String,
    text: String,
    color: Color,
    showChevron: Bool = true,
    strikethrough: Bool = false
  ) {
    self.icon = icon
    self.text = text
    self.color = color
    self.showChevron = showChevron
    self.strikethrough = strikethrough
  }

  public var body: some View {
    infoRowStyle.makeBody(
      DSInfoRowStyleConfiguration(
        icon: icon,
        text: text,
        color: color,
        showChevron: showChevron,
        strikethrough: strikethrough,
        theme: theme
      )
    )
  }
}

// MARK: - Preview

#Preview("DSInfoRow") {
  VStack(spacing: DSTheme.default.spacing.md) {
    DSInfoRow(icon: "checklist", text: "3 tasks remaining", color: DSTheme.default.colors.warning)
    DSInfoRow(
      icon: "cart.fill", text: "Grocery List (2 ingredients needed)",
      color: DSTheme.default.colors.primary)
    DSInfoRow(
      icon: "checkmark.circle", text: "All ingredients acquired",
      color: DSTheme.default.colors.success)
    DSInfoRow(
      icon: "info.circle", text: "Without chevron", color: DSTheme.default.colors.info,
      showChevron: false)
  }
  .padding()
}
