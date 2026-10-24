//
//  DSStepper.swift
//  DesignSystem
//
//  Design System Stepper - Increment/decrement buttons for scale and numeric inputs
//

import SwiftUI

// MARK: - Stepper Style

/// The look of `DSStepperButtons`. Set it with `.dsStepperStyle(_:)`.
public protocol DSStepperStyle: Sendable {
  typealias Configuration = DSStepperStyleConfiguration
  associatedtype Body: View

  @MainActor @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

/// What a stepper style draws.
public struct DSStepperStyleConfiguration {
  public let onDecrement: () -> Void
  public let onIncrement: () -> Void
  /// Whatever the caller put between the buttons, usually the current value.
  public let center: AnyView
  public let theme: DSTheme
}

/// The look every stepper had before styles existed.
public struct DefaultDSStepperStyle: DSStepperStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    let theme = configuration.theme

    HStack(spacing: theme.spacing.sm) {
      Button(action: configuration.onDecrement) {
        Image(systemName: "minus.circle")
          .font(.system(size: theme.iconSize.lg))
          .foregroundColor(theme.colors.textPrimary)
      }
      .buttonStyle(.plain)

      configuration.center

      Button(action: configuration.onIncrement) {
        Image(systemName: "plus.circle")
          .font(.system(size: theme.iconSize.lg))
          .foregroundColor(theme.colors.textPrimary)
      }
      .buttonStyle(.plain)
    }
    .padding(.horizontal, theme.spacing.sm)
    .padding(.vertical, theme.spacing.xs)
    .background(theme.colors.cardBackgroundElevated)
    .cornerRadius(theme.radius.sm)
  }
}

extension DSStepperStyle where Self == DefaultDSStepperStyle {
  public static var `default`: DefaultDSStepperStyle { DefaultDSStepperStyle() }
}

extension AnyDSStyle where Configuration == DSStepperStyleConfiguration {
  init(_ style: some DSStepperStyle) {
    self.init { AnyView(style.makeBody(configuration: $0)) }
  }
}

extension EnvironmentValues {
  @Entry var dsStepperStyle = AnyDSStyle(DefaultDSStepperStyle())
}

extension View {
  /// Set the style of every `DSStepperButtons` inside this view.
  public func dsStepperStyle(_ style: some DSStepperStyle) -> some View {
    environment(\.dsStepperStyle, AnyDSStyle(style))
  }
}

// MARK: - DSStepperButtons

/// A reusable increment/decrement control with optional center content.
/// Use for scale inputs, meal assignment, and other numeric steppers.
///
/// Usage:
/// ```swift
/// // Just the buttons
/// DSStepperButtons(onDecrement: { scale -= 0.25 }, onIncrement: { scale += 0.25 })
///
/// // With center value display
/// DSStepperButtons(onDecrement: { ... }, onIncrement: { ... }) {
///   Text("1.0")
///     .font(.subheadline)
///     .frame(minWidth: 36, alignment: .center)
/// }
/// ```
public struct DSStepperButtons<Center: View>: View {
  let onDecrement: () -> Void
  let onIncrement: () -> Void
  @ViewBuilder let center: () -> Center

  @Environment(\.dsTheme) private var theme
  @Environment(\.dsStepperStyle) private var stepperStyle

  public init(
    onDecrement: @escaping () -> Void,
    onIncrement: @escaping () -> Void,
    @ViewBuilder center: @escaping () -> Center
  ) {
    self.onDecrement = onDecrement
    self.onIncrement = onIncrement
    self.center = center
  }

  public var body: some View {
    stepperStyle.makeBody(
      DSStepperStyleConfiguration(
        onDecrement: onDecrement,
        onIncrement: onIncrement,
        center: AnyView(center()),
        theme: theme
      )
    )
  }
}

// MARK: - Convenience initializer without center content

extension DSStepperButtons where Center == EmptyView {
  public init(onDecrement: @escaping () -> Void, onIncrement: @escaping () -> Void) {
    self.onDecrement = onDecrement
    self.onIncrement = onIncrement
    self.center = { EmptyView() }
  }
}

// MARK: - Preview

#Preview("DSStepperButtons") {
  VStack(spacing: DSTheme.default.spacing.lg) {
    DSStepperButtons(onDecrement: {}, onIncrement: {})

    DSStepperButtons(onDecrement: {}, onIncrement: {}) {
      Text("1.0")
        .font(DSTheme.default.typography.body)
        .frame(minWidth: 36, alignment: .center)
    }
  }
  .padding()
}
