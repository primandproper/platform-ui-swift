//
//  DSEmptyState.swift
//  DesignSystem
//
//  Design System Empty State Component - Consistent empty state display
//

import SwiftUI

// MARK: - Empty State Size

public enum DSEmptyStateSize: Sendable {
  case compact
  case standard
  case large

  public func iconSize(in theme: DSTheme) -> CGFloat {
    switch self {
    case .compact:
      return theme.iconSize.xl
    case .standard:
      return theme.iconSize.xxl
    case .large:
      return 64
    }
  }

  public func titleFont(in theme: DSTheme) -> Font {
    switch self {
    case .compact:
      return theme.typography.label
    case .standard:
      return theme.typography.title3
    case .large:
      return theme.typography.title2
    }
  }

  public func messageFont(in theme: DSTheme) -> Font {
    switch self {
    case .compact:
      return theme.typography.caption
    case .standard, .large:
      return theme.typography.body
    }
  }

  public func spacing(in theme: DSTheme) -> CGFloat {
    switch self {
    case .compact:
      return theme.spacing.sm
    case .standard:
      return theme.spacing.md
    case .large:
      return theme.spacing.lg
    }
  }
}

// MARK: - Empty State Style

/// The look of `DSEmptyState`. Set it with `.dsEmptyStateStyle(_:)`.
public protocol DSEmptyStateStyle: Sendable {
  typealias Configuration = DSEmptyStateStyleConfiguration
  associatedtype Body: View

  @MainActor @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

/// What an empty state style draws.
public struct DSEmptyStateStyleConfiguration {
  /// An SF Symbol name.
  public let icon: String?
  public let title: String?
  public let message: String
  public let size: DSEmptyStateSize
  /// The call to action, present only when the caller gave both a title and an action.
  public let actionTitle: String?
  public let action: (() -> Void)?
  public let theme: DSTheme
}

/// The look every empty state had before styles existed.
public struct DefaultDSEmptyStateStyle: DSEmptyStateStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    let theme = configuration.theme
    let size = configuration.size

    VStack(spacing: size.spacing(in: theme)) {
      if let icon = configuration.icon {
        Image(systemName: icon)
          .font(.system(size: size.iconSize(in: theme)))
          .foregroundColor(theme.colors.textTertiary)
      }

      VStack(spacing: theme.spacing.xs) {
        if let title = configuration.title {
          Text(title)
            .font(size.titleFont(in: theme))
            .foregroundColor(theme.colors.textPrimary)
        }

        Text(configuration.message)
          .font(size.messageFont(in: theme))
          .foregroundColor(theme.colors.textSecondary)
          .multilineTextAlignment(.center)
      }

      if let actionTitle = configuration.actionTitle, let action = configuration.action {
        DSButton(actionTitle, style: .primary, size: .small, action: action)
          .padding(.top, theme.spacing.sm)
      }
    }
    .padding(size == .compact ? theme.spacing.md : theme.spacing.xl)
    .frame(maxWidth: size == .compact ? nil : .infinity)
  }
}

extension DSEmptyStateStyle where Self == DefaultDSEmptyStateStyle {
  public static var `default`: DefaultDSEmptyStateStyle { DefaultDSEmptyStateStyle() }
}

extension AnyDSStyle where Configuration == DSEmptyStateStyleConfiguration {
  init(_ style: some DSEmptyStateStyle) {
    self.init { AnyView(style.makeBody(configuration: $0)) }
  }
}

extension EnvironmentValues {
  @Entry var dsEmptyStateStyle = AnyDSStyle(DefaultDSEmptyStateStyle())
}

extension View {
  /// Set the style of every `DSEmptyState` inside this view.
  public func dsEmptyStateStyle(_ style: some DSEmptyStateStyle) -> some View {
    environment(\.dsEmptyStateStyle, AnyDSStyle(style))
  }
}

// MARK: - DSEmptyState Component

/// A consistent empty state view with icon, title, message, and optional action.
///
/// Usage:
/// ```swift
/// DSEmptyState(
///   icon: "tray",
///   title: "No Items",
///   message: "You haven't added any items yet."
/// )
///
/// DSEmptyState(
///   icon: "magnifyingglass",
///   title: "No Results",
///   message: "Try adjusting your search.",
///   actionTitle: "Clear Search",
///   action: { clearSearch() }
/// )
///
/// // Compact for inline use
/// DSEmptyState(
///   icon: "doc",
///   message: "No documents",
///   size: .compact
/// )
/// ```
public struct DSEmptyState: View {
  let icon: String?
  let title: String?
  let message: String
  let actionTitle: String?
  let size: DSEmptyStateSize
  let action: (() -> Void)?

  @Environment(\.dsTheme) private var theme
  @Environment(\.dsEmptyStateStyle) private var emptyStateStyle

  public init(
    icon: String? = nil,
    title: String? = nil,
    message: String,
    actionTitle: String? = nil,
    size: DSEmptyStateSize = .standard,
    action: (() -> Void)? = nil
  ) {
    self.icon = icon
    self.title = title
    self.message = message
    self.actionTitle = actionTitle
    self.size = size
    self.action = action
  }

  public var body: some View {
    let hasAction = actionTitle != nil && action != nil

    emptyStateStyle.makeBody(
      DSEmptyStateStyleConfiguration(
        icon: icon,
        title: title,
        message: message,
        size: size,
        actionTitle: hasAction ? actionTitle : nil,
        action: hasAction ? action : nil,
        theme: theme
      )
    )
  }
}

// MARK: - Preview

#Preview("Empty States") {
  ScrollView {
    VStack(spacing: DSTheme.default.spacing.xxl) {
      DSEmptyState(
        icon: "tray",
        title: "No Items",
        message: "You haven't added any items yet."
      )

      Divider()

      DSEmptyState(
        icon: "magnifyingglass",
        title: "No Results Found",
        message: "Try adjusting your search or filters.",
        actionTitle: "Clear Filters"
      ) {
        print("Clear filters")
      }

      Divider()

      DSEmptyState(
        icon: "person.2",
        title: "No Members",
        message: "Invite someone to join your household.",
        actionTitle: "Send Invite",
        size: .large
      ) {
        print("Send invite")
      }

      Divider()

      Text("Compact (inline)").font(.caption).foregroundColor(.secondary)
      DSEmptyState(
        icon: "doc",
        message: "No documents available",
        size: .compact
      )
    }
    .padding()
  }
}
