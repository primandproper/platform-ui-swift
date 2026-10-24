//
//  View+DesignSystem.swift
//  DesignSystem
//
//  Design System View Extensions - Convenience modifiers for common patterns
//

import SwiftUI

// MARK: - Theme Access

/// Applies a transform that needs the current theme, for modifiers that have no view of their own
/// to hold an `@Environment` property.
private struct ThemedModifier<Result: View>: ViewModifier {
  @Environment(\.dsTheme) private var theme
  let transform: (AnyView, DSTheme) -> Result

  func body(content: Content) -> some View {
    transform(AnyView(content), theme)
  }
}

extension View {
  fileprivate func themed<Result: View>(
    _ transform: @escaping (AnyView, DSTheme) -> Result
  ) -> some View {
    modifier(ThemedModifier(transform: transform))
  }
}

// MARK: - Conditional Modifiers

extension View {
  /// Apply a modifier conditionally.
  @ViewBuilder
  public func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
    if condition {
      transform(self)
    } else {
      self
    }
  }

  /// Apply a modifier conditionally with an else clause.
  @ViewBuilder
  public func `if`<TrueContent: View, FalseContent: View>(
    _ condition: Bool,
    then trueTransform: (Self) -> TrueContent,
    else falseTransform: (Self) -> FalseContent
  ) -> some View {
    if condition {
      trueTransform(self)
    } else {
      falseTransform(self)
    }
  }
}

// MARK: - Loading Overlay

extension View {
  /// Add a loading overlay to any view.
  public func dsLoading(_ isLoading: Bool, message: String? = nil) -> some View {
    themed { content, theme in
      content
        .overlay {
          if isLoading {
            ZStack {
              theme.colors.background.opacity(0.8)
              DSLoadingView(message)
            }
          }
        }
        .disabled(isLoading)
    }
  }
}

// MARK: - Semantic Styling

extension View {
  /// Apply primary action styling.
  public func dsPrimaryStyle() -> some View {
    themed { content, theme in
      content
        .font(theme.typography.button)
        .foregroundColor(theme.colors.textOnPrimary)
        .padding(.vertical, theme.spacing.md)
        .padding(.horizontal, theme.spacing.lg)
        .background(theme.colors.primary)
        .cornerRadius(theme.radius.md)
    }
  }

  /// Apply secondary styling.
  public func dsSecondaryStyle() -> some View {
    themed { content, theme in
      content
        .font(theme.typography.button)
        .foregroundColor(theme.colors.primary)
        .padding(.vertical, theme.spacing.md)
        .padding(.horizontal, theme.spacing.lg)
        .background(theme.colors.primary.opacity(0.1))
        .cornerRadius(theme.radius.md)
    }
  }
}

// MARK: - Full Width

extension View {
  /// Make a view full width.
  public func dsFullWidth(alignment: Alignment = .center) -> some View {
    self.frame(maxWidth: .infinity, alignment: alignment)
  }
}

// MARK: - Standard Padding

extension View {
  /// Apply standard screen padding.
  public func dsScreenPadding() -> some View {
    themed { content, theme in content.padding(theme.spacing.lg) }
  }

  /// Apply standard section spacing.
  public func dsSectionSpacing() -> some View {
    themed { content, theme in content.padding(.vertical, theme.spacing.xl) }
  }
}

// MARK: - Divider with Spacing

extension View {
  /// Add a divider below the view with standard spacing. `spacing` defaults to the theme's
  /// `spacing.md`.
  public func dsDivided(spacing: CGFloat? = nil) -> some View {
    themed { content, theme in
      VStack(spacing: spacing ?? theme.spacing.md) {
        content
        Divider()
      }
    }
  }
}

// MARK: - Hide/Show

extension View {
  /// Conditionally hide the view.
  @ViewBuilder
  public func dsHidden(_ hidden: Bool) -> some View {
    if hidden {
      self.hidden()
    } else {
      self
    }
  }
}

// MARK: - Redacted Loading

extension View {
  /// Apply redacted placeholder styling when loading.
  public func dsRedactedWhenLoading(_ isLoading: Bool) -> some View {
    self.redacted(reason: isLoading ? .placeholder : [])
  }
}

// MARK: - Error Border

extension View {
  /// Apply error border when there's an error.
  public func dsErrorBorder(_ hasError: Bool) -> some View {
    themed { content, theme in
      content.overlay(
        RoundedRectangle(cornerRadius: theme.radius.sm)
          .stroke(hasError ? theme.colors.error : .clear, lineWidth: 1)
      )
    }
  }
}

// MARK: - Navigation Bar Styling

extension View {
  /// Apply standard navigation bar styling.
  public func dsNavigationBar(
    title: String, displayMode: NavigationBarItem.TitleDisplayMode = .large
  )
    -> some View
  {
    self
      .navigationTitle(title)
      .navigationBarTitleDisplayMode(displayMode)
  }
}

// MARK: - Async Button Action

extension View {
  /// Wrap an async action for use in buttons.
  public func dsAsyncAction(_ action: @escaping () async -> Void) -> () -> Void {
    return {
      Task {
        await action()
      }
    }
  }
}
