//
//  DSTextField.swift
//  DesignSystem
//
//  Design System TextField Component - Consistent text input styling
//

import SwiftUI

// MARK: - Text Field Type

public enum DSTextFieldType {
  case text
  case username
  case email
  case password
  case phone
  case number
  case multiline

  public var keyboardType: UIKeyboardType {
    switch self {
    case .email:
      return .emailAddress
    case .phone:
      return .phonePad
    case .number:
      return .decimalPad
    default:
      return .default
    }
  }

  public var textContentType: UITextContentType? {
    switch self {
    case .email:
      return .emailAddress
    case .username:
      return .username
    case .password:
      return .password
    case .phone:
      return .telephoneNumber
    default:
      return nil
    }
  }

  public var autocapitalization: TextInputAutocapitalization {
    switch self {
    case .email, .password, .username:
      return .never
    default:
      return .sentences
    }
  }

  public var disableAutocorrection: Bool {
    switch self {
    case .email, .password, .username:
      return true
    default:
      return false
    }
  }
}

// MARK: - Text Field Variant

public enum DSTextFieldVariant: Sendable {
  case standard
  case outlined
  case filled

  public func backgroundColor(in theme: DSTheme) -> Color {
    switch self {
    case .standard:
      return .clear
    case .outlined:
      return .clear
    case .filled:
      return theme.colors.cardBackground
    }
  }

  public func borderColor(in theme: DSTheme) -> Color {
    switch self {
    case .standard:
      return .clear
    case .outlined:
      return theme.colors.border
    case .filled:
      return .clear
    }
  }
}

// MARK: - Text Field Style

/// The look of `DSTextField`. Set it with `.dsTextFieldStyle(_:)`.
public protocol DSTextFieldStyle: Sendable {
  typealias Configuration = DSTextFieldStyleConfiguration
  associatedtype Body: View

  @MainActor @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

/// What a text field style draws.
public struct DSTextFieldStyleConfiguration {
  /// The input itself, already wired to the binding, keyboard and focus. The style places and
  /// decorates it, and can set its font and color; it shouldn't replace it.
  public let field: AnyView
  public let type: DSTextFieldType
  public let variant: DSTextFieldVariant
  public let label: String?
  public let helperText: String?
  /// The error message, or nil when there is none. Never an empty string.
  public let error: String?
  /// An SF Symbol name.
  public let icon: String?
  public let isFocused: Bool
  public let isDisabled: Bool
  public let theme: DSTheme
}

/// The look every text field had before styles existed.
public struct DefaultDSTextFieldStyle: DSTextFieldStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    let theme = configuration.theme

    VStack(alignment: .leading, spacing: theme.spacing.xs) {
      // Label
      if let label = configuration.label {
        Text(label)
          .font(theme.typography.labelSmall)
          .foregroundColor(theme.colors.textSecondary)
      }

      // Input field
      HStack(spacing: theme.spacing.sm) {
        if let icon = configuration.icon {
          Image(systemName: icon)
            .font(.system(size: theme.iconSize.sm))
            .foregroundColor(theme.colors.textSecondary)
        }

        configuration.field
          .font(theme.typography.body)
          .foregroundColor(
            configuration.isDisabled ? theme.colors.textTertiary : theme.colors.textPrimary)
      }
      .padding(.horizontal, theme.spacing.md)
      .padding(.vertical, theme.spacing.md)
      .background(backgroundColor(configuration))
      .cornerRadius(theme.radius.sm)
      .overlay(
        RoundedRectangle(cornerRadius: theme.radius.sm)
          .stroke(borderColor(configuration), lineWidth: 1)
      )

      // Helper text or error
      if let error = configuration.error {
        Text(error)
          .font(theme.typography.caption)
          .foregroundColor(theme.colors.error)
      } else if let helperText = configuration.helperText {
        Text(helperText)
          .font(theme.typography.caption)
          .foregroundColor(theme.colors.textTertiary)
      }
    }
  }

  private func backgroundColor(_ configuration: Configuration) -> Color {
    if configuration.isDisabled {
      return configuration.theme.colors.cardBackground.opacity(0.5)
    }
    return configuration.variant.backgroundColor(in: configuration.theme)
  }

  private func borderColor(_ configuration: Configuration) -> Color {
    let colors = configuration.theme.colors
    if configuration.error != nil {
      return colors.error
    }
    if configuration.isFocused {
      return colors.primary
    }
    if configuration.isDisabled {
      return colors.border.opacity(0.5)
    }
    switch configuration.variant {
    case .standard:
      return colors.border
    case .outlined:
      return colors.border
    case .filled:
      return .clear
    }
  }
}

extension DSTextFieldStyle where Self == DefaultDSTextFieldStyle {
  public static var `default`: DefaultDSTextFieldStyle { DefaultDSTextFieldStyle() }
}

extension AnyDSStyle where Configuration == DSTextFieldStyleConfiguration {
  init(_ style: some DSTextFieldStyle) {
    self.init { AnyView(style.makeBody(configuration: $0)) }
  }
}

extension EnvironmentValues {
  @Entry var dsTextFieldStyle = AnyDSStyle(DefaultDSTextFieldStyle())
}

extension View {
  /// Set the style of every `DSTextField` inside this view.
  public func dsTextFieldStyle(_ style: some DSTextFieldStyle) -> some View {
    environment(\.dsTextFieldStyle, AnyDSStyle(style))
  }
}

// MARK: - DSTextField Component

/// A styled text field with consistent appearance and behavior.
///
/// Usage:
/// ```swift
/// DSTextField("Username", text: $username, type: .username)
/// DSTextField("Email", text: $email, type: .email)
/// DSTextField("Password", text: $password, type: .password)
/// DSTextField("Phone", text: $phone, type: .phone)
/// DSTextField("Notes", text: $notes, type: .multiline)
///
/// // With label
/// DSTextField("Email Address", text: $email, type: .email, label: "Contact Email")
///
/// // With error
/// DSTextField("Email", text: $email, type: .email, error: emailError)
///
/// // Disabled
/// DSTextField("Email", text: $email, isDisabled: true)
/// ```
public struct DSTextField: View {
  let placeholder: String
  @Binding var text: String
  let type: DSTextFieldType
  let variant: DSTextFieldVariant
  let label: String?
  let helperText: String?
  let error: String?
  let icon: String?
  let isDisabled: Bool
  let lineLimit: ClosedRange<Int>?

  @FocusState private var isFocused: Bool
  @Environment(\.dsTheme) private var theme
  @Environment(\.dsTextFieldStyle) private var textFieldStyle

  public init(
    _ placeholder: String,
    text: Binding<String>,
    type: DSTextFieldType = .text,
    style: DSTextFieldVariant = .standard,
    label: String? = nil,
    helperText: String? = nil,
    error: String? = nil,
    icon: String? = nil,
    isDisabled: Bool = false,
    lineLimit: ClosedRange<Int>? = nil
  ) {
    self.placeholder = placeholder
    self._text = text
    self.type = type
    self.variant = style
    self.label = label
    self.helperText = helperText
    self.error = error
    self.icon = icon
    self.isDisabled = isDisabled
    self.lineLimit = lineLimit ?? (type == .multiline ? 3...6 : 1...1)
  }

  public var body: some View {
    textFieldStyle.makeBody(
      DSTextFieldStyleConfiguration(
        field: AnyView(inputField),
        type: type,
        variant: variant,
        label: label,
        helperText: helperText,
        error: error.flatMap { $0.isEmpty ? nil : $0 },
        icon: icon,
        isFocused: isFocused,
        isDisabled: isDisabled,
        theme: theme
      )
    )
  }

  @ViewBuilder
  private var inputField: some View {
    Group {
      switch type {
      case .password:
        SecureField(placeholder, text: $text)
      case .multiline:
        TextField(placeholder, text: $text, axis: .vertical)
          .lineLimit(lineLimit ?? 3...6)
      default:
        TextField(placeholder, text: $text)
      }
    }
    .keyboardType(type.keyboardType)
    .textInputAutocapitalization(type.autocapitalization)
    .autocorrectionDisabled(type.disableAutocorrection)
    .disabled(isDisabled)
    .focused($isFocused)
  }
}

// MARK: - Labeled Field Group

/// The look of `DSFieldGroup`. Set it with `.dsFieldGroupStyle(_:)`.
public protocol DSFieldGroupStyle: Sendable {
  typealias Configuration = DSFieldGroupStyleConfiguration
  associatedtype Body: View

  @MainActor @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

/// What a field group style draws.
public struct DSFieldGroupStyleConfiguration {
  public let label: String
  /// The group's fields.
  public let content: AnyView
  public let spacing: CGFloat
  public let theme: DSTheme
}

/// The look every field group had before styles existed.
public struct DefaultDSFieldGroupStyle: DSFieldGroupStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    VStack(alignment: .leading, spacing: configuration.theme.spacing.sm) {
      Text(configuration.label)
        .font(configuration.theme.typography.label)
        .foregroundColor(configuration.theme.colors.textSecondary)

      VStack(spacing: configuration.spacing) {
        configuration.content
      }
    }
  }
}

extension DSFieldGroupStyle where Self == DefaultDSFieldGroupStyle {
  public static var `default`: DefaultDSFieldGroupStyle { DefaultDSFieldGroupStyle() }
}

extension AnyDSStyle where Configuration == DSFieldGroupStyleConfiguration {
  init(_ style: some DSFieldGroupStyle) {
    self.init { AnyView(style.makeBody(configuration: $0)) }
  }
}

extension EnvironmentValues {
  @Entry var dsFieldGroupStyle = AnyDSStyle(DefaultDSFieldGroupStyle())
}

extension View {
  /// Set the style of every `DSFieldGroup` inside this view.
  public func dsFieldGroupStyle(_ style: some DSFieldGroupStyle) -> some View {
    environment(\.dsFieldGroupStyle, AnyDSStyle(style))
  }
}

/// A group of text fields with a shared label.
///
/// Usage:
/// ```swift
/// DSFieldGroup("Address") {
///   DSTextField("Street", text: $street)
///   DSTextField("City", text: $city)
///   DSTextField("Zip", text: $zip, type: .number)
/// }
/// ```
public struct DSFieldGroup<Content: View>: View {
  let label: String
  let spacing: CGFloat?
  @ViewBuilder let content: () -> Content

  @Environment(\.dsTheme) private var theme
  @Environment(\.dsFieldGroupStyle) private var fieldGroupStyle

  /// `spacing` defaults to the theme's `spacing.md`.
  public init(
    _ label: String,
    spacing: CGFloat? = nil,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.label = label
    self.spacing = spacing
    self.content = content
  }

  public var body: some View {
    fieldGroupStyle.makeBody(
      DSFieldGroupStyleConfiguration(
        label: label,
        content: AnyView(content()),
        spacing: spacing ?? theme.spacing.md,
        theme: theme
      )
    )
  }
}

// MARK: - Preview

#Preview("Text Field Styles") {
  ScrollView {
    VStack(spacing: DSTheme.default.spacing.xl) {
      Group {
        Text("Standard").font(.caption).foregroundColor(.secondary)
        DSTextField("Email", text: .constant(""), type: .email)

        Text("With Label").font(.caption).foregroundColor(.secondary)
        DSTextField("Enter password", text: .constant(""), type: .password, label: "Password")

        Text("With Icon").font(.caption).foregroundColor(.secondary)
        DSTextField("Search", text: .constant(""), icon: "magnifyingglass")

        Text("With Error").font(.caption).foregroundColor(.secondary)
        DSTextField(
          "Email", text: .constant("invalid"), type: .email, error: "Please enter a valid email")

        Text("With Helper").font(.caption).foregroundColor(.secondary)
        DSTextField(
          "Username", text: .constant(""), type: .username, helperText: "Choose a unique username")

        Text("Disabled").font(.caption).foregroundColor(.secondary)
        DSTextField("Email", text: .constant("disabled@example.com"), isDisabled: true)
      }

      Divider()

      Group {
        Text("Multiline").font(.caption).foregroundColor(.secondary)
        DSTextField("Enter notes...", text: .constant(""), type: .multiline)

        Text("Phone").font(.caption).foregroundColor(.secondary)
        DSTextField("Phone number", text: .constant(""), type: .phone)

        Text("Number").font(.caption).foregroundColor(.secondary)
        DSTextField("Amount", text: .constant(""), type: .number)
      }

      Divider()

      DSFieldGroup("Contact Information") {
        DSTextField("Email", text: .constant(""), type: .email)
        DSTextField("Phone", text: .constant(""), type: .phone)
      }
    }
    .padding()
  }
}
