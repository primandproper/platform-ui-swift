//
//  DSButton.swift
//  DesignSystem
//
//  Design System Button Component - Consistent button styling with variants
//

import SwiftUI

// MARK: - Button Variant

public enum DSButtonVariant: Sendable {
  case primary
  case secondary
  case tertiary
  case destructive
  case destructiveGhost
  case ghost
  case outline

  public func backgroundColor(in theme: DSTheme) -> Color {
    switch self {
    case .primary:
      return theme.colors.primary
    case .secondary:
      return theme.colors.secondary
    case .tertiary:
      return theme.colors.tertiary
    case .destructive:
      return theme.colors.error
    case .destructiveGhost, .ghost, .outline:
      return .clear
    }
  }

  public func foregroundColor(in theme: DSTheme) -> Color {
    switch self {
    case .primary, .secondary, .tertiary, .destructive:
      return theme.colors.textOnPrimary
    case .destructiveGhost:
      return theme.colors.error
    case .ghost:
      return theme.colors.primary
    case .outline:
      return theme.colors.textPrimary
    }
  }

  public func borderColor(in theme: DSTheme) -> Color? {
    switch self {
    case .outline:
      return theme.colors.border
    default:
      return nil
    }
  }

  public var disabledBackgroundColor: Color {
    switch self {
    case .destructiveGhost, .ghost, .outline:
      return .clear
    default:
      return Color.gray.opacity(0.3)
    }
  }

  public var disabledForegroundColor: Color {
    return Color.gray
  }
}

// MARK: - Button Size

public enum DSButtonSize: Sendable {
  case small
  case medium
  case large

  public func verticalPadding(in theme: DSTheme) -> CGFloat {
    switch self {
    case .small:
      return theme.spacing.sm
    case .medium:
      return theme.spacing.md
    case .large:
      return theme.spacing.lg
    }
  }

  public func horizontalPadding(in theme: DSTheme) -> CGFloat {
    switch self {
    case .small:
      return theme.spacing.md
    case .medium:
      return theme.spacing.lg
    case .large:
      return theme.spacing.xl
    }
  }

  public func font(in theme: DSTheme) -> Font {
    switch self {
    case .small:
      return theme.typography.buttonSmall
    case .medium, .large:
      return theme.typography.button
    }
  }

  public func iconSize(in theme: DSTheme) -> CGFloat {
    switch self {
    case .small:
      return theme.iconSize.sm
    case .medium:
      return theme.iconSize.md
    case .large:
      return theme.iconSize.lg
    }
  }

  /// The diameter of an icon-only button.
  public var iconButtonDimension: CGFloat {
    switch self {
    case .small:
      return 32
    case .medium:
      return 40
    case .large:
      return 48
    }
  }
}

// MARK: - Button Style

/// The look of `DSButton`, `DSButtonLink` and `DSIconButton`. Set it with `.dsButtonStyle(_:)`.
public protocol DSButtonStyle: Sendable {
  typealias Configuration = DSButtonStyleConfiguration
  associatedtype Body: View

  @MainActor @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

/// What a button style draws.
public struct DSButtonStyleConfiguration {
  /// The button's text; nil for an icon-only `DSIconButton`.
  public let title: String?
  /// An SF Symbol name.
  public let icon: String?
  public let iconPosition: DSButton.IconPosition
  public let variant: DSButtonVariant
  public let size: DSButtonSize
  public let fullWidth: Bool
  public let isLoading: Bool
  public let isDisabled: Bool
  public internal(set) var isPressed: Bool
  public let theme: DSTheme
}

/// The look every button had before styles existed.
public struct DefaultDSButtonStyle: DSButtonStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    if let title = configuration.title {
      labeledButton(configuration, title: title)
    } else {
      iconButton(configuration)
    }
  }

  @ViewBuilder
  private func labeledButton(_ configuration: Configuration, title: String) -> some View {
    let theme = configuration.theme
    let size = configuration.size
    let variant = configuration.variant
    let foreground = foregroundColor(configuration)

    HStack(spacing: theme.spacing.sm) {
      if configuration.isLoading {
        ProgressView()
          .progressViewStyle(CircularProgressViewStyle(tint: foreground))
          .scaleEffect(0.8)
      } else if let icon = configuration.icon, configuration.iconPosition == .leading {
        Image(systemName: icon)
          .font(.system(size: size.iconSize(in: theme)))
      }

      Text(title)
        .font(size.font(in: theme))

      if !configuration.isLoading, let icon = configuration.icon,
        configuration.iconPosition == .trailing
      {
        Image(systemName: icon)
          .font(.system(size: size.iconSize(in: theme)))
      }
    }
    .frame(maxWidth: configuration.fullWidth ? .infinity : nil)
    .padding(.vertical, size.verticalPadding(in: theme))
    .padding(.horizontal, size.horizontalPadding(in: theme))
    .foregroundColor(foreground)
    .background(backgroundColor(configuration))
    .cornerRadius(theme.radius.md)
    .overlay(
      RoundedRectangle(cornerRadius: theme.radius.md)
        .stroke(
          configuration.isDisabled
            ? Color.gray.opacity(0.3) : (variant.borderColor(in: theme) ?? .clear),
          lineWidth: variant.borderColor(in: theme) != nil ? 1 : 0
        )
    )
    .opacity(configuration.isPressed ? 0.7 : 1)
  }

  private func iconButton(_ configuration: Configuration) -> some View {
    let dimension = configuration.size.iconButtonDimension

    return Image(systemName: configuration.icon ?? "")
      .font(.system(size: configuration.size.iconSize(in: configuration.theme)))
      .foregroundColor(foregroundColor(configuration))
      .frame(width: dimension, height: dimension)
      .background(backgroundColor(configuration))
      .clipShape(Circle())
      .opacity(configuration.isPressed ? 0.7 : 1)
  }

  private func foregroundColor(_ configuration: Configuration) -> Color {
    configuration.isDisabled
      ? configuration.variant.disabledForegroundColor
      : configuration.variant.foregroundColor(in: configuration.theme)
  }

  private func backgroundColor(_ configuration: Configuration) -> Color {
    configuration.isDisabled
      ? configuration.variant.disabledBackgroundColor
      : configuration.variant.backgroundColor(in: configuration.theme)
  }
}

extension DSButtonStyle where Self == DefaultDSButtonStyle {
  public static var `default`: DefaultDSButtonStyle { DefaultDSButtonStyle() }
}

extension AnyDSStyle where Configuration == DSButtonStyleConfiguration {
  init(_ style: some DSButtonStyle) {
    self.init { AnyView(style.makeBody(configuration: $0)) }
  }
}

extension EnvironmentValues {
  @Entry var dsButtonStyle = AnyDSStyle(DefaultDSButtonStyle())
}

extension View {
  /// Set the style of every `DSButton`, `DSButtonLink` and `DSIconButton` inside this view.
  public func dsButtonStyle(_ style: some DSButtonStyle) -> some View {
    environment(\.dsButtonStyle, AnyDSStyle(style))
  }
}

/// Hands a DS button style to SwiftUI's button machinery, which is what knows whether the
/// button is pressed.
private struct DSButtonStyleBridge: ButtonStyle {
  let style: AnyDSStyle<DSButtonStyleConfiguration>
  let configuration: DSButtonStyleConfiguration

  func makeBody(configuration: ButtonStyleConfiguration) -> some View {
    var dsConfiguration = self.configuration
    dsConfiguration.isPressed = configuration.isPressed
    return style.makeBody(dsConfiguration)
  }
}

// MARK: - DSButton Component

/// A styled button with consistent appearance and behavior.
///
/// Usage:
/// ```swift
/// DSButton("Submit") { handleSubmit() }
/// DSButton("Delete", style: .destructive) { handleDelete() }
/// DSButton("View Details", icon: "chevron.right", style: .ghost) { showDetails() }
///
/// // Async action
/// DSButton("Save", isLoading: isSaving) { await save() }
///
/// // Full width
/// DSButton("Continue", fullWidth: true) { next() }
/// ```
///
/// - Note: For sheet/toolbar Cancel and Save actions, use SwiftUI's `Button("Cancel")` /
///   `Button("Save")` in `cancellationAction` / `confirmationAction`; they receive system styling automatically.
public struct DSButton: View {
  let title: String
  let icon: String?
  let iconPosition: IconPosition
  let variant: DSButtonVariant
  let size: DSButtonSize
  let fullWidth: Bool
  let isLoading: Bool
  let isDisabled: Bool
  let action: () -> Void

  @Environment(\.dsTheme) private var theme
  @Environment(\.dsButtonStyle) private var buttonStyle

  public enum IconPosition: Sendable {
    case leading
    case trailing
  }

  public init(
    _ title: String,
    icon: String? = nil,
    iconPosition: IconPosition = .leading,
    style: DSButtonVariant = .primary,
    size: DSButtonSize = .medium,
    fullWidth: Bool = false,
    isLoading: Bool = false,
    isDisabled: Bool = false,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.icon = icon
    self.iconPosition = iconPosition
    self.variant = style
    self.size = size
    self.fullWidth = fullWidth
    self.isLoading = isLoading
    self.isDisabled = isDisabled
    self.action = action
  }

  public var body: some View {
    Button(action: action) {
      Text(title)
    }
    .buttonStyle(
      DSButtonStyleBridge(
        style: buttonStyle,
        configuration: DSButtonStyleConfiguration(
          title: title,
          icon: icon,
          iconPosition: iconPosition,
          variant: variant,
          size: size,
          fullWidth: fullWidth,
          isLoading: isLoading,
          isDisabled: isDisabled,
          isPressed: false,
          theme: theme
        )
      )
    )
    .disabled(isDisabled || isLoading)
  }
}

// MARK: - Navigation Link Button

/// A navigation link styled as a button.
///
/// Usage:
/// ```swift
/// DSButtonLink("View Recipes", icon: "book.closed", destination: RecipeListView())
/// DSButtonLink("Settings", style: .secondary, destination: SettingsView())
/// ```
public struct DSButtonLink<Destination: View>: View {
  let title: String
  let icon: String?
  let iconPosition: DSButton.IconPosition
  let variant: DSButtonVariant
  let size: DSButtonSize
  let fullWidth: Bool
  let destination: Destination

  @Environment(\.dsTheme) private var theme
  @Environment(\.dsButtonStyle) private var buttonStyle

  public init(
    _ title: String,
    icon: String? = nil,
    iconPosition: DSButton.IconPosition = .leading,
    style: DSButtonVariant = .primary,
    size: DSButtonSize = .medium,
    fullWidth: Bool = false,
    destination: Destination
  ) {
    self.title = title
    self.icon = icon
    self.iconPosition = iconPosition
    self.variant = style
    self.size = size
    self.fullWidth = fullWidth
    self.destination = destination
  }

  public var body: some View {
    NavigationLink(destination: destination) {
      Text(title)
    }
    .buttonStyle(
      DSButtonStyleBridge(
        style: buttonStyle,
        configuration: DSButtonStyleConfiguration(
          title: title,
          icon: icon,
          iconPosition: iconPosition,
          variant: variant,
          size: size,
          fullWidth: fullWidth,
          isLoading: false,
          isDisabled: false,
          isPressed: false,
          theme: theme
        )
      )
    )
  }
}

// MARK: - Icon Button

/// A circular icon-only button.
///
/// Usage:
/// ```swift
/// DSIconButton("plus") { addItem() }
/// DSIconButton("trash", style: .destructive) { deleteItem() }
/// ```
public struct DSIconButton: View {
  let icon: String
  let variant: DSButtonVariant
  let size: DSButtonSize
  let isDisabled: Bool
  let action: () -> Void

  @Environment(\.dsTheme) private var theme
  @Environment(\.dsButtonStyle) private var buttonStyle

  public init(
    _ icon: String,
    style: DSButtonVariant = .ghost,
    size: DSButtonSize = .medium,
    isDisabled: Bool = false,
    action: @escaping () -> Void
  ) {
    self.icon = icon
    self.variant = style
    self.size = size
    self.isDisabled = isDisabled
    self.action = action
  }

  public var body: some View {
    Button(action: action) {
      Image(systemName: icon)
    }
    .buttonStyle(
      DSButtonStyleBridge(
        style: buttonStyle,
        configuration: DSButtonStyleConfiguration(
          title: nil,
          icon: icon,
          iconPosition: .leading,
          variant: variant,
          size: size,
          fullWidth: false,
          isLoading: false,
          isDisabled: isDisabled,
          isPressed: false,
          theme: theme
        )
      )
    )
    .disabled(isDisabled)
  }
}

// MARK: - Preview

#Preview("Button Styles") {
  ScrollView {
    VStack(spacing: DSTheme.default.spacing.lg) {
      Group {
        Text("Primary").font(.caption).foregroundColor(.secondary)
        DSButton("Primary Button", icon: "star.fill") { print("Tapped") }

        Text("Secondary").font(.caption).foregroundColor(.secondary)
        DSButton("Secondary Button", style: .secondary) { print("Tapped") }

        Text("Tertiary").font(.caption).foregroundColor(.secondary)
        DSButton("Tertiary Button", style: .tertiary) { print("Tapped") }

        Text("Destructive").font(.caption).foregroundColor(.secondary)
        DSButton("Delete", icon: "trash", style: .destructive) { print("Tapped") }

        Text("Destructive Ghost").font(.caption).foregroundColor(.secondary)
        DSButton("Sign Out", style: .destructiveGhost) { print("Tapped") }

        Text("Ghost").font(.caption).foregroundColor(.secondary)
        DSButton("Ghost Button", style: .ghost) { print("Tapped") }

        Text("Outline").font(.caption).foregroundColor(.secondary)
        DSButton("Outline Button", style: .outline) { print("Tapped") }
      }

      Divider()

      Group {
        Text("Full Width").font(.caption).foregroundColor(.secondary)
        DSButton("Full Width Button", fullWidth: true) { print("Tapped") }

        Text("Loading").font(.caption).foregroundColor(.secondary)
        DSButton("Saving...", isLoading: true) { print("Tapped") }

        Text("Disabled").font(.caption).foregroundColor(.secondary)
        DSButton("Disabled", isDisabled: true) { print("Tapped") }
      }

      Divider()

      Group {
        Text("Sizes").font(.caption).foregroundColor(.secondary)
        HStack {
          DSButton("Small", size: .small) { print("Tapped") }
          DSButton("Medium", size: .medium) { print("Tapped") }
          DSButton("Large", size: .large) { print("Tapped") }
        }
      }

      Divider()

      Group {
        Text("Icon Buttons").font(.caption).foregroundColor(.secondary)
        HStack(spacing: DSTheme.default.spacing.md) {
          DSIconButton("plus", style: .primary) { print("Plus") }
          DSIconButton("heart.fill", style: .destructive) { print("Heart") }
          DSIconButton("gear") { print("Gear") }
          DSIconButton("trash", style: .ghost, isDisabled: true) { print("Trash") }
        }
      }
    }
    .padding()
  }
}
