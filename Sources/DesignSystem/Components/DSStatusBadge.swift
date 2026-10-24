//
//  DSStatusBadge.swift
//  DesignSystem
//
//  Design System Status Badge Component - Status indicators with color coding
//

import SwiftUI

// MARK: - Status Type

public enum DSStatusType: Sendable {
  case pending
  case accepted
  case rejected
  case cancelled
  case success
  case warning
  case error
  case info
  case custom(String, Color)

  public var label: String {
    switch self {
    case .pending:
      return "Pending"
    case .accepted:
      return "Accepted"
    case .rejected:
      return "Rejected"
    case .cancelled:
      return "Cancelled"
    case .success:
      return "Success"
    case .warning:
      return "Warning"
    case .error:
      return "Error"
    case .info:
      return "Info"
    case .custom(let label, _):
      return label
    }
  }

  public func color(in theme: DSTheme) -> Color {
    switch self {
    case .pending:
      return theme.colors.statusPending
    case .accepted, .success:
      return theme.colors.statusAccepted
    case .rejected, .error:
      return theme.colors.statusRejected
    case .cancelled:
      return theme.colors.statusCancelled
    case .warning:
      return theme.colors.warning
    case .info:
      return theme.colors.info
    case .custom(_, let color):
      return color
    }
  }

  /// Create a status type from a raw string value (e.g., from API)
  public static func from(_ rawValue: String) -> DSStatusType {
    switch rawValue.lowercased() {
    case "pending":
      return .pending
    case "accepted":
      return .accepted
    case "rejected":
      return .rejected
    case "cancelled", "canceled":
      return .cancelled
    case "success":
      return .success
    case "warning":
      return .warning
    case "error":
      return .error
    case "info":
      return .info
    default:
      return .custom(rawValue.isEmpty ? "Unknown" : rawValue.capitalized, .secondary)
    }
  }
}

// MARK: - Badge Variant

public enum DSBadgeVariant: Sendable {
  case dot  // Colored dot + text
  case pill  // Colored background pill
  case outline  // Outlined pill
  case minimal  // Just text with color
}

// MARK: - Badge Size

public enum DSBadgeSize: Sendable {
  case small
  case medium
  case large

  public var dotSize: CGFloat {
    switch self {
    case .small:
      return 6
    case .medium:
      return 8
    case .large:
      return 10
    }
  }

  public func font(in theme: DSTheme) -> Font {
    switch self {
    case .small:
      return theme.typography.captionSmall
    case .medium:
      return theme.typography.caption
    case .large:
      return theme.typography.labelSmall
    }
  }

  public func padding(in theme: DSTheme) -> EdgeInsets {
    let spacing = theme.spacing
    switch self {
    case .small:
      return EdgeInsets(
        top: spacing.xxs, leading: spacing.sm, bottom: spacing.xxs, trailing: spacing.sm)
    case .medium:
      return EdgeInsets(
        top: spacing.xs, leading: spacing.sm, bottom: spacing.xs, trailing: spacing.sm)
    case .large:
      return EdgeInsets(
        top: spacing.sm, leading: spacing.md, bottom: spacing.sm, trailing: spacing.md)
    }
  }
}

// MARK: - Status Badge Style

/// The look of `DSStatusBadge` and `DSStatusDot`. Set it with `.dsStatusBadgeStyle(_:)`.
public protocol DSStatusBadgeStyle: Sendable {
  typealias Configuration = DSStatusBadgeStyleConfiguration
  associatedtype Body: View

  @MainActor @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

/// What a status badge style draws.
public struct DSStatusBadgeStyleConfiguration {
  public let status: DSStatusType
  /// The text to show; nil for a `DSStatusDot`, which shows none.
  public let label: String?
  /// The status's color in the current theme.
  public let color: Color
  public let variant: DSBadgeVariant
  public let size: DSBadgeSize
  public let theme: DSTheme
}

/// The look every status badge had before styles existed.
public struct DefaultDSStatusBadgeStyle: DSStatusBadgeStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    let theme = configuration.theme
    let size = configuration.size
    let color = configuration.color

    if let label = configuration.label {
      switch configuration.variant {
      case .dot:
        HStack(spacing: theme.spacing.sm) {
          dot(configuration)

          Text(label)
            .font(size.font(in: theme))
            .foregroundColor(theme.colors.textSecondary)
        }
      case .pill:
        Text(label)
          .font(size.font(in: theme))
          .foregroundColor(.white)
          .padding(size.padding(in: theme))
          .background(color)
          .cornerRadius(theme.radius.full)
      case .outline:
        Text(label)
          .font(size.font(in: theme))
          .foregroundColor(color)
          .padding(size.padding(in: theme))
          .background(color.opacity(0.1))
          .cornerRadius(theme.radius.full)
          .overlay(
            RoundedRectangle(cornerRadius: theme.radius.full)
              .stroke(color, lineWidth: 1)
          )
      case .minimal:
        Text(label)
          .font(size.font(in: theme))
          .foregroundColor(color)
      }
    } else {
      dot(configuration)
    }
  }

  private func dot(_ configuration: Configuration) -> some View {
    Circle()
      .fill(configuration.color)
      .frame(width: configuration.size.dotSize, height: configuration.size.dotSize)
  }
}

extension DSStatusBadgeStyle where Self == DefaultDSStatusBadgeStyle {
  public static var `default`: DefaultDSStatusBadgeStyle { DefaultDSStatusBadgeStyle() }
}

extension AnyDSStyle where Configuration == DSStatusBadgeStyleConfiguration {
  init(_ style: some DSStatusBadgeStyle) {
    self.init { AnyView(style.makeBody(configuration: $0)) }
  }
}

extension EnvironmentValues {
  @Entry var dsStatusBadgeStyle = AnyDSStyle(DefaultDSStatusBadgeStyle())
}

extension View {
  /// Set the style of every `DSStatusBadge` and `DSStatusDot` inside this view.
  public func dsStatusBadgeStyle(_ style: some DSStatusBadgeStyle) -> some View {
    environment(\.dsStatusBadgeStyle, AnyDSStyle(style))
  }
}

// MARK: - DSStatusBadge Component

/// A status indicator badge with consistent styling.
///
/// Usage:
/// ```swift
/// DSStatusBadge(.pending)
/// DSStatusBadge(.accepted, style: .pill)
/// DSStatusBadge(.custom("Active", .purple), size: .large)
///
/// // From raw string
/// DSStatusBadge(status: invitation.status)
/// ```
public struct DSStatusBadge: View {
  let status: DSStatusType
  let variant: DSBadgeVariant
  let size: DSBadgeSize

  @Environment(\.dsTheme) private var theme
  @Environment(\.dsStatusBadgeStyle) private var statusBadgeStyle

  public init(
    _ status: DSStatusType,
    style: DSBadgeVariant = .dot,
    size: DSBadgeSize = .medium
  ) {
    self.status = status
    self.variant = style
    self.size = size
  }

  /// Convenience initializer for raw string status values
  public init(
    status: String,
    style: DSBadgeVariant = .dot,
    size: DSBadgeSize = .medium
  ) {
    self.status = DSStatusType.from(status)
    self.variant = style
    self.size = size
  }

  public var body: some View {
    statusBadgeStyle.makeBody(
      DSStatusBadgeStyleConfiguration(
        status: status,
        label: status.label,
        color: status.color(in: theme),
        variant: variant,
        size: size,
        theme: theme
      )
    )
  }
}

// MARK: - Status Dot Only

/// A simple colored status dot without text.
///
/// Usage:
/// ```swift
/// DSStatusDot(.pending)
/// DSStatusDot(.accepted, size: .large)
/// ```
public struct DSStatusDot: View {
  let status: DSStatusType
  let size: DSBadgeSize

  @Environment(\.dsTheme) private var theme
  @Environment(\.dsStatusBadgeStyle) private var statusBadgeStyle

  public init(_ status: DSStatusType, size: DSBadgeSize = .medium) {
    self.status = status
    self.size = size
  }

  public init(status: String, size: DSBadgeSize = .medium) {
    self.status = DSStatusType.from(status)
    self.size = size
  }

  public var body: some View {
    statusBadgeStyle.makeBody(
      DSStatusBadgeStyleConfiguration(
        status: status,
        label: nil,
        color: status.color(in: theme),
        variant: .dot,
        size: size,
        theme: theme
      )
    )
  }
}

// MARK: - Preview

#Preview("Status Badges") {
  ScrollView {
    VStack(spacing: DSTheme.default.spacing.xl) {
      Group {
        Text("Dot Style (default)").font(.caption).foregroundColor(.secondary)
        HStack(spacing: DSTheme.default.spacing.lg) {
          DSStatusBadge(.pending)
          DSStatusBadge(.accepted)
          DSStatusBadge(.rejected)
          DSStatusBadge(.cancelled)
        }
      }

      Group {
        Text("Pill Style").font(.caption).foregroundColor(.secondary)
        HStack(spacing: DSTheme.default.spacing.sm) {
          DSStatusBadge(.pending, style: .pill)
          DSStatusBadge(.accepted, style: .pill)
          DSStatusBadge(.rejected, style: .pill)
        }
      }

      Group {
        Text("Outline Style").font(.caption).foregroundColor(.secondary)
        HStack(spacing: DSTheme.default.spacing.sm) {
          DSStatusBadge(.pending, style: .outline)
          DSStatusBadge(.accepted, style: .outline)
          DSStatusBadge(.rejected, style: .outline)
        }
      }

      Group {
        Text("Minimal Style").font(.caption).foregroundColor(.secondary)
        HStack(spacing: DSTheme.default.spacing.lg) {
          DSStatusBadge(.pending, style: .minimal)
          DSStatusBadge(.accepted, style: .minimal)
          DSStatusBadge(.rejected, style: .minimal)
        }
      }

      Divider()

      Group {
        Text("Sizes").font(.caption).foregroundColor(.secondary)
        VStack(spacing: DSTheme.default.spacing.md) {
          DSStatusBadge(.pending, style: .pill, size: .small)
          DSStatusBadge(.pending, style: .pill, size: .medium)
          DSStatusBadge(.pending, style: .pill, size: .large)
        }
      }

      Divider()

      Group {
        Text("From Raw String").font(.caption).foregroundColor(.secondary)
        VStack(spacing: DSTheme.default.spacing.sm) {
          DSStatusBadge(status: "pending")
          DSStatusBadge(status: "ACCEPTED")
          DSStatusBadge(status: "cancelled")
          DSStatusBadge(status: "unknown_status")
        }
      }

      Divider()

      Group {
        Text("Custom").font(.caption).foregroundColor(.secondary)
        HStack(spacing: DSTheme.default.spacing.sm) {
          DSStatusBadge(.custom("Active", .purple), style: .pill)
          DSStatusBadge(.custom("Draft", .cyan), style: .outline)
          DSStatusBadge(.info)
          DSStatusBadge(.warning)
        }
      }

      Divider()

      Group {
        Text("Status Dots Only").font(.caption).foregroundColor(.secondary)
        HStack(spacing: DSTheme.default.spacing.lg) {
          DSStatusDot(.pending)
          DSStatusDot(.accepted)
          DSStatusDot(.rejected)
          DSStatusDot(.cancelled)
        }
      }
    }
    .padding()
  }
}
