//
//  DSContentState.swift
//  DesignSystem
//
//  Design System Content State Components - Loading, Error, and Content wrapper
//

import SwiftUI

// MARK: - DSLoadingView

/// The look of `DSLoadingView`, `DSInitializingView` and the loading state of `DSContentState`. Set it with `.dsLoadingStyle(_:)`.
public protocol DSLoadingStyle: Sendable {
  typealias Configuration = DSLoadingStyleConfiguration
  associatedtype Body: View

  @MainActor @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

/// What a loading style draws.
public struct DSLoadingStyleConfiguration {
  public let message: String?
  public let size: DSLoadingView.Size
  public let theme: DSTheme
}

/// The look every loading view had before styles existed.
public struct DefaultDSLoadingStyle: DSLoadingStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    let theme = configuration.theme
    let size = configuration.size

    VStack(spacing: size.spacing(in: theme)) {
      ProgressView()
        .scaleEffect(size.progressScale)

      if let message = configuration.message {
        Text(message)
          .font(size.textFont(in: theme))
          .foregroundColor(theme.colors.textSecondary)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

extension DSLoadingStyle where Self == DefaultDSLoadingStyle {
  public static var `default`: DefaultDSLoadingStyle { DefaultDSLoadingStyle() }
}

extension AnyDSStyle where Configuration == DSLoadingStyleConfiguration {
  init(_ style: some DSLoadingStyle) {
    self.init { AnyView(style.makeBody(configuration: $0)) }
  }
}

extension EnvironmentValues {
  @Entry var dsLoadingStyle = AnyDSStyle(DefaultDSLoadingStyle())
}

extension View {
  /// Set the style of every `DSLoadingView`, `DSInitializingView` and `DSContentState` loading state inside this view.
  public func dsLoadingStyle(_ style: some DSLoadingStyle) -> some View {
    environment(\.dsLoadingStyle, AnyDSStyle(style))
  }
}

/// A consistent loading indicator view.
///
/// Usage:
/// ```swift
/// DSLoadingView()
/// DSLoadingView("Loading meals...")
/// DSLoadingView("Please wait", size: .large)
/// ```
public struct DSLoadingView: View {
  let message: String?
  let size: Size

  @Environment(\.dsTheme) private var theme
  @Environment(\.dsLoadingStyle) private var loadingStyle

  public enum Size: Sendable {
    case small
    case medium
    case large

    public var progressScale: CGFloat {
      switch self {
      case .small:
        return 0.8
      case .medium:
        return 1.0
      case .large:
        return 1.3
      }
    }

    public func textFont(in theme: DSTheme) -> Font {
      switch self {
      case .small:
        return theme.typography.caption
      case .medium:
        return theme.typography.body
      case .large:
        return theme.typography.label
      }
    }

    public func spacing(in theme: DSTheme) -> CGFloat {
      switch self {
      case .small:
        return theme.spacing.sm
      case .medium:
        return theme.spacing.md
      case .large:
        return theme.spacing.lg
      }
    }
  }

  public init(_ message: String? = "Loading...", size: Size = .medium) {
    self.message = message
    self.size = size
  }

  public var body: some View {
    loadingStyle.makeBody(DSLoadingStyleConfiguration(message: message, size: size, theme: theme))
  }
}

// MARK: - DSErrorView

/// The look of `DSErrorView` and the error state of `DSContentState`. Set it with `.dsErrorStyle(_:)`.
public protocol DSErrorStyle: Sendable {
  typealias Configuration = DSErrorStyleConfiguration
  associatedtype Body: View

  @MainActor @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

/// What an error style draws.
public struct DSErrorStyleConfiguration {
  public let title: String
  public let message: String
  /// An SF Symbol name.
  public let icon: String
  public let iconColor: Color
  public let retryTitle: String
  /// What the retry button does; nil when the caller offered no retry.
  public let onRetry: (() async -> Void)?
  /// Whatever the caller asked to show beneath the error; nil when it asked for nothing.
  public let accessory: AnyView?
  public let theme: DSTheme
}

/// The look every error view had before styles existed.
public struct DefaultDSErrorStyle: DSErrorStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    let theme = configuration.theme

    VStack(spacing: theme.spacing.lg) {
      Image(systemName: configuration.icon)
        .font(.system(size: theme.iconSize.xxl))
        .foregroundColor(configuration.iconColor)

      VStack(spacing: theme.spacing.sm) {
        Text(configuration.title)
          .font(theme.typography.title3)
          .foregroundColor(theme.colors.textPrimary)

        Text(configuration.message)
          .font(theme.typography.body)
          .foregroundColor(theme.colors.textSecondary)
          .multilineTextAlignment(.center)
          .padding(.horizontal, theme.spacing.xl)
      }

      if let onRetry = configuration.onRetry {
        DSButton(configuration.retryTitle, icon: "arrow.clockwise", style: .primary) {
          Task {
            await onRetry()
          }
        }
      }

      if let accessory = configuration.accessory {
        accessory
          .padding(.top, theme.spacing.sm)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

extension DSErrorStyle where Self == DefaultDSErrorStyle {
  public static var `default`: DefaultDSErrorStyle { DefaultDSErrorStyle() }
}

extension AnyDSStyle where Configuration == DSErrorStyleConfiguration {
  init(_ style: some DSErrorStyle) {
    self.init { AnyView(style.makeBody(configuration: $0)) }
  }
}

extension EnvironmentValues {
  @Entry var dsErrorStyle = AnyDSStyle(DefaultDSErrorStyle())
}

extension View {
  /// Set the style of every `DSErrorView` and `DSContentState` error state inside this view.
  public func dsErrorStyle(_ style: some DSErrorStyle) -> some View {
    environment(\.dsErrorStyle, AnyDSStyle(style))
  }
}

/// A consistent error display view with optional retry action.
///
/// Usage:
/// ```swift
/// DSErrorView("Something went wrong")
/// DSErrorView("Failed to load", onRetry: { await reload() })
/// DSErrorView("Network error", icon: "wifi.slash", onRetry: { await retry() })
/// ```
public struct DSErrorView: View {
  let message: String
  let title: String
  let icon: String
  let iconColor: Color?
  let retryTitle: String
  let onRetry: (() async -> Void)?
  let accessory: AnyView?

  @Environment(\.dsTheme) private var theme
  @Environment(\.dsErrorStyle) private var errorStyle

  /// `iconColor` defaults to the theme's `colors.warning`.
  public init(
    _ message: String,
    title: String = "Error",
    icon: String = "exclamationmark.triangle",
    iconColor: Color? = nil,
    retryTitle: String = "Retry",
    onRetry: (() async -> Void)? = nil,
    accessory: AnyView? = nil
  ) {
    self.message = message
    self.title = title
    self.icon = icon
    self.iconColor = iconColor
    self.retryTitle = retryTitle
    self.onRetry = onRetry
    self.accessory = accessory
  }

  public var body: some View {
    errorStyle.makeBody(
      DSErrorStyleConfiguration(
        title: title,
        message: message,
        icon: icon,
        iconColor: iconColor ?? theme.colors.warning,
        retryTitle: retryTitle,
        onRetry: onRetry,
        accessory: accessory,
        theme: theme
      )
    )
  }
}

// MARK: - DSContentState

/// A wrapper that handles loading, error, and content states.
///
/// Usage:
/// ```swift
/// DSContentState(
///   isLoading: viewModel.isLoading,
///   error: viewModel.errorMessage,
///   onRetry: { await viewModel.loadData() }
/// ) {
///   ScrollView {
///     // Your content here
///   }
/// }
///
/// // With custom loading message
/// DSContentState(
///   isLoading: viewModel.isLoading,
///   loadingMessage: "Fetching recipes...",
///   error: viewModel.errorMessage,
///   onRetry: { await viewModel.loadData() }
/// ) {
///   RecipeList(recipes: viewModel.recipes)
/// }
/// ```
public struct DSContentState<Content: View>: View {
  let isLoading: Bool
  let loadingMessage: String?
  let error: String?
  let errorTitle: String
  let errorIcon: String
  let errorIconColor: Color?
  let onRetry: (() async -> Void)?
  let errorAccessory: AnyView?
  @ViewBuilder let content: () -> Content

  /// `errorIconColor` defaults to the theme's `colors.warning`.
  public init(
    isLoading: Bool,
    loadingMessage: String? = "Loading...",
    error: String? = nil,
    errorTitle: String = "Error",
    errorIcon: String = "exclamationmark.triangle",
    errorIconColor: Color? = nil,
    onRetry: (() async -> Void)? = nil,
    errorAccessory: AnyView? = nil,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.isLoading = isLoading
    self.loadingMessage = loadingMessage
    self.error = error
    self.errorTitle = errorTitle
    self.errorIcon = errorIcon
    self.errorIconColor = errorIconColor
    self.onRetry = onRetry
    self.errorAccessory = errorAccessory
    self.content = content
  }

  public var body: some View {
    Group {
      if isLoading {
        DSLoadingView(loadingMessage)
      } else if let error = error {
        DSErrorView(
          error,
          title: errorTitle,
          icon: errorIcon,
          iconColor: errorIconColor,
          onRetry: onRetry,
          accessory: errorAccessory
        )
      } else {
        content()
      }
    }
  }
}
// MARK: - Initializing State View

/// A view for the initializing/setup state before the view model is ready.
///
/// Usage:
/// ```swift
/// if let viewModel = viewModel {
///   // ... normal content
/// } else {
///   DSInitializingView()
/// }
/// ```
public struct DSInitializingView: View {
  let message: String

  public init(_ message: String = "Initializing...") {
    self.message = message
  }

  public var body: some View {
    DSLoadingView(message)
  }
}

// MARK: - View Extension for Optional ViewModel Pattern

extension View {
  /// Wraps content in a DSContentState, handling the common optional viewModel pattern.
  ///
  /// Usage:
  /// ```swift
  /// someContent
  ///   .dsContentState(
  ///     viewModel: viewModel,
  ///     isLoading: \.isLoading,
  ///     error: \.errorMessage,
  ///     onRetry: { await $0.loadData() }
  ///   )
  /// ```
  @ViewBuilder
  public func dsHandleState<VM>(
    viewModel: VM?,
    isLoading: Bool,
    error: String?,
    initializingMessage: String = "Initializing...",
    loadingMessage: String = "Loading...",
    onRetry: (() async -> Void)? = nil
  ) -> some View {
    if viewModel != nil {
      DSContentState(
        isLoading: isLoading,
        loadingMessage: loadingMessage,
        error: error,
        onRetry: onRetry
      ) {
        self
      }
    } else {
      DSInitializingView(initializingMessage)
    }
  }
}

// MARK: - Preview

#Preview("Content States") {
  TabView {
    // Loading
    DSLoadingView("Loading recipes...")
      .tabItem { Label("Loading", systemImage: "hourglass") }

    // Error without retry
    DSErrorView("Unable to connect to the server. Please check your internet connection.")
      .tabItem { Label("Error", systemImage: "exclamationmark.triangle") }

    // Error with retry
    DSErrorView("Failed to load data", onRetry: { print("Retry tapped") })
      .tabItem { Label("Retry", systemImage: "arrow.clockwise") }

    // Content State wrapper - Loading
    DSContentState(isLoading: true, error: nil) {
      Text("Content")
    }
    .tabItem { Label("Wrapper", systemImage: "square.stack") }

    // Initializing
    DSInitializingView()
      .tabItem { Label("Init", systemImage: "gear") }
  }
}
