//
//  AppTheme.swift
//  DesignSystem
//
//  Design System Theme - Central configuration for colors, spacing, typography, and radii
//

import SwiftUI

// MARK: - Design System Theme

/// Central theme configuration for the app's design system.
/// Use these tokens throughout the app for consistent styling.
public enum DSTheme {

  // MARK: - Colors

  public enum Colors {
    // Brand colors
    public static let primary = Color.blue
    public static let secondary = Color.purple
    public static let tertiary = Color.orange

    // Semantic colors
    public static let success = Color.green
    public static let warning = Color.orange
    public static let error = Color.red
    public static let info = Color.blue

    // Background colors
    public static let cardBackground = Color(.systemGray6)
    public static let cardBackgroundSelected = Color.blue.opacity(0.1)
    public static let cardBackgroundElevated = Color(.systemGray5)

    // Text colors
    public static let textPrimary = Color.primary
    public static let textSecondary = Color.secondary
    public static let textTertiary = Color(.tertiaryLabel)
    public static let textOnPrimary = Color.white

    // Border colors
    public static let border = Color(.separator)
    public static let borderSelected = Color.blue
    public static let borderSubtle = Color(.systemGray4)

    // Status colors (for badges, indicators)
    public static let statusPending = Color.orange
    public static let statusAccepted = Color.green
    public static let statusRejected = Color.red
    public static let statusCancelled = Color.gray
    public static let statusUnknown = Color.secondary
  }

  // MARK: - Spacing

  public enum Spacing {
    public static let xxs: CGFloat = 2
    public static let xs: CGFloat = 4
    public static let sm: CGFloat = 8
    public static let md: CGFloat = 12
    public static let lg: CGFloat = 16
    public static let xl: CGFloat = 24
    public static let xxl: CGFloat = 32
    public static let xxxl: CGFloat = 48
  }

  // MARK: - Corner Radius

  public enum Radius {
    public static let xs: CGFloat = 4
    public static let sm: CGFloat = 8
    public static let md: CGFloat = 10
    public static let lg: CGFloat = 16
    public static let xl: CGFloat = 20
    public static let full: CGFloat = 9999  // For circular elements
  }

  // MARK: - Typography

  public enum Typography {
    // Titles
    public static let largeTitle = Font.largeTitle.weight(.bold)
    public static let title1 = Font.title.weight(.bold)
    public static let title2 = Font.title2.weight(.bold)
    public static let title3 = Font.title3.weight(.semibold)

    // Body text
    public static let bodyLarge = Font.body
    public static let body = Font.subheadline
    public static let bodySmall = Font.footnote

    // Labels
    public static let label = Font.subheadline.weight(.medium)
    public static let labelSmall = Font.caption.weight(.medium)
    public static let caption = Font.caption
    public static let captionSmall = Font.caption2

    // Special
    public static let button = Font.body.weight(.semibold)
    public static let buttonSmall = Font.subheadline.weight(.semibold)
  }

  // MARK: - Shadows

  public enum Shadows {
    public static let sm = ShadowStyle(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    public static let md = ShadowStyle(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    public static let lg = ShadowStyle(color: .black.opacity(0.12), radius: 16, x: 0, y: 8)
  }

  // MARK: - Animation

  public enum Animation {
    public static let fast = SwiftUI.Animation.easeInOut(duration: 0.15)
    public static let normal = SwiftUI.Animation.easeInOut(duration: 0.25)
    public static let slow = SwiftUI.Animation.easeInOut(duration: 0.4)
    public static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
  }

  // MARK: - Icon Sizes

  public enum IconSize {
    public static let xs: CGFloat = 12
    public static let sm: CGFloat = 16
    public static let md: CGFloat = 20
    public static let lg: CGFloat = 24
    public static let xl: CGFloat = 32
    public static let xxl: CGFloat = 48
  }

  // MARK: - Avatar Sizes

  public enum AvatarSize {
    public static let sm: CGFloat = 32
    public static let md: CGFloat = 40
    public static let lg: CGFloat = 50
    public static let xl: CGFloat = 64
    public static let xxl: CGFloat = 80
  }
}

// MARK: - Shadow Style Helper

public struct ShadowStyle: Sendable {
  public let color: Color
  public let radius: CGFloat
  public let x: CGFloat
  public let y: CGFloat

  public init(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
    self.color = color
    self.radius = radius
    self.x = x
    self.y = y
  }
}

// MARK: - View Extension for Shadows

extension View {
  public func dsShadow(_ style: ShadowStyle) -> some View {
    self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
  }
}
