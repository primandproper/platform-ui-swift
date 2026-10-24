//
//  DSListRow.swift
//  DesignSystem
//
//  Design System List Row Component - Consistent list row styling
//

import SwiftUI

// MARK: - List Row Variant

public enum DSListRowVariant: Sendable {
  case standard
  case card
  case plain
}

// MARK: - List Row Style

/// The look of `DSListRow` and `DSListRowLink`. Set it with `.dsListRowStyle(_:)`.
public protocol DSListRowStyle: Sendable {
  typealias Configuration = DSListRowStyleConfiguration
  associatedtype Body: View

  @MainActor @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

/// What a list row style draws.
public struct DSListRowStyleConfiguration {
  public let title: String
  public let subtitle: String?
  /// An SF Symbol name.
  public let icon: String?
  public let iconColor: Color
  public let variant: DSListRowVariant
  public let showChevron: Bool
  /// Whatever the caller put at the trailing edge; nil when it put nothing.
  public let trailing: AnyView?
  public let theme: DSTheme
}

/// The look every list row had before styles existed.
public struct DefaultDSListRowStyle: DSListRowStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    let theme = configuration.theme

    HStack(spacing: theme.spacing.md) {
      // Leading icon
      if let icon = configuration.icon {
        Image(systemName: icon)
          .font(.system(size: theme.iconSize.md))
          .foregroundColor(configuration.iconColor)
          .frame(width: theme.iconSize.lg)
      }

      // Title and subtitle
      VStack(alignment: .leading, spacing: theme.spacing.xxs) {
        Text(configuration.title)
          .font(theme.typography.label)
          .foregroundColor(theme.colors.textPrimary)

        if let subtitle = configuration.subtitle {
          Text(subtitle)
            .font(theme.typography.caption)
            .foregroundColor(theme.colors.textSecondary)
        }
      }

      Spacer()

      // Trailing content
      if let trailing = configuration.trailing {
        trailing
      }

      // Chevron
      if configuration.showChevron {
        Image(systemName: "chevron.right")
          .font(.system(size: theme.iconSize.sm))
          .foregroundColor(theme.colors.textTertiary)
      }
    }
    .contentShape(Rectangle())
    .modifier(VariantPadding(variant: configuration.variant, theme: theme))
  }

  private struct VariantPadding: ViewModifier {
    let variant: DSListRowVariant
    let theme: DSTheme

    func body(content: Content) -> some View {
      switch variant {
      case .standard:
        content
          .padding(.vertical, theme.spacing.md)
          .padding(.horizontal, theme.spacing.sm)
      case .card:
        content
          .padding(theme.spacing.lg)
          .background(theme.colors.cardBackground)
          .cornerRadius(theme.radius.md)
      case .plain:
        content
          .padding(.vertical, theme.spacing.sm)
      }
    }
  }
}

extension DSListRowStyle where Self == DefaultDSListRowStyle {
  public static var `default`: DefaultDSListRowStyle { DefaultDSListRowStyle() }
}

extension AnyDSStyle where Configuration == DSListRowStyleConfiguration {
  init(_ style: some DSListRowStyle) {
    self.init { AnyView(style.makeBody(configuration: $0)) }
  }
}

extension EnvironmentValues {
  @Entry var dsListRowStyle = AnyDSStyle(DefaultDSListRowStyle())
}

extension View {
  /// Set the style of every `DSListRow` and `DSListRowLink` inside this view.
  public func dsListRowStyle(_ style: some DSListRowStyle) -> some View {
    environment(\.dsListRowStyle, AnyDSStyle(style))
  }
}

// MARK: - DSListRow Component

/// A consistent list row with optional leading/trailing content and chevron.
///
/// Usage:
/// ```swift
/// DSListRow(title: "Settings")
/// DSListRow(title: "Profile", subtitle: "Edit your profile")
/// DSListRow(title: "Notifications", icon: "bell")
/// DSListRow(title: "Account", icon: "person", showChevron: true)
///
/// // As navigation link
/// DSListRow(title: "Settings", destination: SettingsView())
///
/// // With custom trailing
/// DSListRow(title: "Theme") {
///   Toggle("", isOn: $isDarkMode)
/// }
/// ```
public struct DSListRow<Trailing: View>: View {
  let title: String
  let subtitle: String?
  let icon: String?
  let iconColor: Color?
  let variant: DSListRowVariant
  let showChevron: Bool
  let trailing: (() -> Trailing)?
  let action: (() -> Void)?

  @Environment(\.dsTheme) private var theme
  @Environment(\.dsListRowStyle) private var listRowStyle

  /// `iconColor` defaults to the theme's `colors.textSecondary`.
  public init(
    title: String,
    subtitle: String? = nil,
    icon: String? = nil,
    iconColor: Color? = nil,
    style: DSListRowVariant = .standard,
    showChevron: Bool = false,
    action: (() -> Void)? = nil,
    @ViewBuilder trailing: @escaping () -> Trailing
  ) {
    self.title = title
    self.subtitle = subtitle
    self.icon = icon
    self.iconColor = iconColor
    self.variant = style
    self.showChevron = showChevron
    self.trailing = trailing
    self.action = action
  }

  public var body: some View {
    Group {
      if let action = action {
        Button(action: action) {
          rowContent
        }
        .buttonStyle(.plain)
      } else {
        rowContent
      }
    }
  }

  private var rowContent: some View {
    listRowStyle.makeBody(
      DSListRowStyleConfiguration(
        title: title,
        subtitle: subtitle,
        icon: icon,
        iconColor: iconColor ?? theme.colors.textSecondary,
        variant: variant,
        showChevron: showChevron,
        trailing: trailing.map { AnyView($0()) },
        theme: theme
      )
    )
  }
}

// MARK: - Convenience initializer without trailing

extension DSListRow where Trailing == EmptyView {
  /// `iconColor` defaults to the theme's `colors.textSecondary`.
  public init(
    title: String,
    subtitle: String? = nil,
    icon: String? = nil,
    iconColor: Color? = nil,
    style: DSListRowVariant = .standard,
    showChevron: Bool = false,
    action: (() -> Void)? = nil
  ) {
    self.title = title
    self.subtitle = subtitle
    self.icon = icon
    self.iconColor = iconColor
    self.variant = style
    self.showChevron = showChevron
    self.trailing = nil
    self.action = action
  }
}

// MARK: - Navigation Link Row

/// A list row that navigates to a destination.
public struct DSListRowLink<Destination: View>: View {
  let title: String
  let subtitle: String?
  let icon: String?
  let iconColor: Color?
  let variant: DSListRowVariant
  let destination: Destination

  @Environment(\.dsTheme) private var theme
  @Environment(\.dsListRowStyle) private var listRowStyle

  /// `iconColor` defaults to the theme's `colors.textSecondary`.
  public init(
    title: String,
    subtitle: String? = nil,
    icon: String? = nil,
    iconColor: Color? = nil,
    style: DSListRowVariant = .standard,
    destination: Destination
  ) {
    self.title = title
    self.subtitle = subtitle
    self.icon = icon
    self.iconColor = iconColor
    self.variant = style
    self.destination = destination
  }

  public var body: some View {
    NavigationLink(destination: destination) {
      listRowStyle.makeBody(
        DSListRowStyleConfiguration(
          title: title,
          subtitle: subtitle,
          icon: icon,
          iconColor: iconColor ?? theme.colors.textSecondary,
          variant: variant,
          showChevron: true,
          trailing: nil,
          theme: theme
        )
      )
    }
  }
}

// MARK: - Divider Row

/// A simple divider for use in lists.
public struct DSListDivider: View {
  let inset: CGFloat

  public init(inset: CGFloat = 0) {
    self.inset = inset
  }

  public var body: some View {
    DSDivider(style: .standard, horizontalInset: inset)
  }
}

// MARK: - Preview

#Preview("List Rows") {
  NavigationStack {
    ScrollView {
      VStack(spacing: 0) {
        Text("Standard Style").font(.caption).foregroundColor(.secondary).frame(
          maxWidth: .infinity, alignment: .leading
        ).padding()

        VStack(spacing: 0) {
          DSListRow(title: "Simple Row")
          DSListDivider()
          DSListRow(title: "With Subtitle", subtitle: "This is a subtitle")
          DSListDivider()
          DSListRow(title: "With Icon", icon: "star")
          DSListDivider()
          DSListRow(title: "With Chevron", icon: "gear", showChevron: true)
          DSListDivider()
          DSListRow(title: "Tappable", icon: "hand.tap", showChevron: true) {
            print("Tapped")
          }
        }
        .padding(.horizontal)

        Text("Card Style").font(.caption).foregroundColor(.secondary).frame(
          maxWidth: .infinity, alignment: .leading
        ).padding()

        VStack(spacing: DSTheme.default.spacing.sm) {
          DSListRow(title: "Card Row", icon: "folder", style: .card, showChevron: true)
          DSListRow(
            title: "With Subtitle", subtitle: "Additional info", icon: "doc", style: .card,
            showChevron: true)
        }
        .padding(.horizontal)

        Text("With Trailing Content").font(.caption).foregroundColor(.secondary).frame(
          maxWidth: .infinity, alignment: .leading
        ).padding()

        VStack(spacing: 0) {
          DSListRow(title: "Toggle Option", icon: "moon") {
            Toggle("", isOn: .constant(true))
              .labelsHidden()
          }
          DSListDivider()
          DSListRow(title: "Count", icon: "bell") {
            Text("5")
              .font(DSTheme.default.typography.caption)
              .foregroundColor(DSTheme.default.colors.textSecondary)
          }
        }
        .padding(.horizontal)

        Text("Navigation Link").font(.caption).foregroundColor(.secondary).frame(
          maxWidth: .infinity, alignment: .leading
        ).padding()

        VStack(spacing: DSTheme.default.spacing.sm) {
          DSListRowLink(
            title: "Go to Settings",
            icon: "gear",
            style: .card,
            destination: Text("Settings View")
          )
        }
        .padding(.horizontal)
      }
    }
    .navigationTitle("List Rows")
  }
}
