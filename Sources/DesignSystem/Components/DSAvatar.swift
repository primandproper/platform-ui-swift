//
//  DSAvatar.swift
//  DesignSystem
//
//  Design System Avatar Component - User avatars with initials fallback
//

import SwiftUI

// MARK: - Avatar Size

public enum DSAvatarSize: Sendable {
  case xs
  case sm
  case md
  case lg
  case xl
  case xxl
  case custom(CGFloat)

  public func dimension(in theme: DSTheme) -> CGFloat {
    switch self {
    case .xs:
      return theme.avatarSize.sm - 8  // 24
    case .sm:
      return theme.avatarSize.sm  // 32
    case .md:
      return theme.avatarSize.md  // 40
    case .lg:
      return theme.avatarSize.lg  // 50
    case .xl:
      return theme.avatarSize.xl  // 64
    case .xxl:
      return theme.avatarSize.xxl  // 80
    case .custom(let size):
      return size
    }
  }

  public var font: Font {
    switch self {
    case .xs:
      return .system(size: 10, weight: .semibold)
    case .sm:
      return .system(size: 12, weight: .semibold)
    case .md:
      return .system(size: 14, weight: .semibold)
    case .lg:
      return .system(size: 18, weight: .semibold)
    case .xl:
      return .system(size: 22, weight: .semibold)
    case .xxl:
      return .system(size: 28, weight: .semibold)
    case .custom(let size):
      return .system(size: size * 0.35, weight: .semibold)
    }
  }
}

// MARK: - Avatar Variant

public enum DSAvatarVariant: Sendable {
  case circle
  case rounded
  case square
}

// MARK: - Avatar Style

/// The look of `DSAvatar`, `DSAvatarView` and the avatars in `DSAvatarGroup`. Set it with `.dsAvatarStyle(_:)`.
public protocol DSAvatarStyle: Sendable {
  typealias Configuration = DSAvatarStyleConfiguration
  associatedtype Body: View

  @MainActor @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

/// What an avatar style draws.
public struct DSAvatarStyleConfiguration {
  /// One or two uppercase letters.
  public let initials: String
  /// An image to show instead of the initials; nil when there is none.
  public let imageURL: URL?
  public let size: DSAvatarSize
  /// The size's width and height in the current theme.
  public let dimension: CGFloat
  public let variant: DSAvatarVariant
  public let backgroundColor: Color
  public let foregroundColor: Color
  public let theme: DSTheme
}

/// The look every avatar had before styles existed.
public struct DefaultDSAvatarStyle: DSAvatarStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    let dimension = configuration.dimension

    if let url = configuration.imageURL {
      AsyncImage(url: url) { phase in
        switch phase {
        case .success(let image):
          image
            .resizable()
            .aspectRatio(contentMode: .fill)
        case .failure, .empty:
          initials(configuration)
        @unknown default:
          initials(configuration)
        }
      }
      .frame(width: dimension, height: dimension)
      .clipShape(shape(configuration))
    } else {
      initials(configuration)
        .frame(width: dimension, height: dimension)
    }
  }

  private func initials(_ configuration: Configuration) -> some View {
    shape(configuration)
      .fill(configuration.backgroundColor)
      .overlay {
        Text(configuration.initials)
          .font(configuration.size.font)
          .foregroundColor(configuration.foregroundColor)
      }
  }

  private func shape(_ configuration: Configuration) -> AnyShape {
    switch configuration.variant {
    case .circle:
      AnyShape(Circle())
    case .rounded:
      AnyShape(RoundedRectangle(cornerRadius: configuration.dimension * 0.2))
    case .square:
      AnyShape(RoundedRectangle(cornerRadius: configuration.theme.radius.xs))
    }
  }
}

extension DSAvatarStyle where Self == DefaultDSAvatarStyle {
  public static var `default`: DefaultDSAvatarStyle { DefaultDSAvatarStyle() }
}

extension AnyDSStyle where Configuration == DSAvatarStyleConfiguration {
  init(_ style: some DSAvatarStyle) {
    self.init { AnyView(style.makeBody(configuration: $0)) }
  }
}

extension EnvironmentValues {
  @Entry var dsAvatarStyle = AnyDSStyle(DefaultDSAvatarStyle())
}

extension View {
  /// Set the style of every `DSAvatar`, `DSAvatarView` and `DSAvatarGroup` avatar inside this view.
  public func dsAvatarStyle(_ style: some DSAvatarStyle) -> some View {
    environment(\.dsAvatarStyle, AnyDSStyle(style))
  }
}

// MARK: - DSAvatar Component

/// A user avatar with initials fallback and optional image.
///
/// Usage:
/// ```swift
/// // With name (generates initials automatically)
/// DSAvatar(name: "John Doe")
/// DSAvatar(name: "Jane Smith", size: .lg)
///
/// // With explicit initials
/// DSAvatar(initials: "JD")
///
/// // With image URL (when supported)
/// DSAvatar(name: "John Doe", imageURL: user.avatarURL)
///
/// // Custom color
/// DSAvatar(name: "John Doe", backgroundColor: .purple)
/// ```
public struct DSAvatar: View {
  let initials: String
  let size: DSAvatarSize
  let variant: DSAvatarVariant
  let backgroundColor: Color
  let foregroundColor: Color?
  let imageURL: URL?

  @Environment(\.dsTheme) private var theme
  @Environment(\.dsAvatarStyle) private var avatarStyle

  /// `foregroundColor` defaults to the theme's `colors.textSecondary`.
  public init(
    name: String,
    size: DSAvatarSize = .md,
    style: DSAvatarVariant = .circle,
    backgroundColor: Color? = nil,
    foregroundColor: Color? = nil,
    imageURL: URL? = nil
  ) {
    self.initials = Self.generateInitials(from: name)
    self.size = size
    self.variant = style
    self.backgroundColor = backgroundColor ?? Self.colorForName(name)
    self.foregroundColor = foregroundColor
    self.imageURL = imageURL
  }

  /// `foregroundColor` defaults to the theme's `colors.textSecondary`.
  public init(
    initials: String,
    size: DSAvatarSize = .md,
    style: DSAvatarVariant = .circle,
    backgroundColor: Color? = nil,
    foregroundColor: Color? = nil,
    imageURL: URL? = nil
  ) {
    self.initials = String(initials.prefix(2)).uppercased()
    self.size = size
    self.variant = style
    self.backgroundColor = backgroundColor ?? .gray.opacity(0.3)
    self.foregroundColor = foregroundColor
    self.imageURL = imageURL
  }

  public var body: some View {
    avatarStyle.makeBody(
      DSAvatarStyleConfiguration(
        initials: initials,
        imageURL: imageURL,
        size: size,
        dimension: size.dimension(in: theme),
        variant: variant,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor ?? theme.colors.textSecondary,
        theme: theme
      )
    )
  }

  /// Generate initials from a name.
  public static func generateInitials(from name: String) -> String {
    let words = name.split(separator: " ")
    if words.isEmpty {
      return "?"
    }
    if words.count == 1 {
      return String(words[0].prefix(1)).uppercased()
    }
    let firstInitial = words.first.map { String($0.prefix(1)) } ?? ""
    let lastInitial = words.last.map { String($0.prefix(1)) } ?? ""
    return (firstInitial + lastInitial).uppercased()
  }

  /// Generate a consistent color based on the name.
  public static func colorForName(_ name: String) -> Color {
    let colors: [Color] = [
      .blue.opacity(0.3),
      .green.opacity(0.3),
      .orange.opacity(0.3),
      .purple.opacity(0.3),
      .pink.opacity(0.3),
      .teal.opacity(0.3),
      .indigo.opacity(0.3),
      .mint.opacity(0.3),
    ]
    let hash = abs(name.hashValue)
    return colors[hash % colors.count]
  }
}

// MARK: - Simpler Avatar View

/// A simpler avatar implementation that avoids complex generics
public struct DSAvatarView: View {
  let initials: String
  let size: DSAvatarSize
  let backgroundColor: Color
  let foregroundColor: Color?

  @Environment(\.dsTheme) private var theme
  @Environment(\.dsAvatarStyle) private var avatarStyle

  /// `foregroundColor` defaults to the theme's `colors.textSecondary`.
  public init(
    name: String,
    size: DSAvatarSize = .md,
    backgroundColor: Color? = nil,
    foregroundColor: Color? = nil
  ) {
    self.initials = DSAvatar.generateInitials(from: name)
    self.size = size
    self.backgroundColor = backgroundColor ?? DSAvatar.colorForName(name)
    self.foregroundColor = foregroundColor
  }

  /// `foregroundColor` defaults to the theme's `colors.textSecondary`.
  public init(
    initials: String,
    size: DSAvatarSize = .md,
    backgroundColor: Color = .gray.opacity(0.3),
    foregroundColor: Color? = nil
  ) {
    self.initials = String(initials.prefix(2)).uppercased()
    self.size = size
    self.backgroundColor = backgroundColor
    self.foregroundColor = foregroundColor
  }

  public var body: some View {
    avatarStyle.makeBody(
      DSAvatarStyleConfiguration(
        initials: initials,
        imageURL: nil,
        size: size,
        dimension: size.dimension(in: theme),
        variant: .circle,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor ?? theme.colors.textSecondary,
        theme: theme
      )
    )
  }
}

// MARK: - Avatar Group

/// A group of overlapping avatars.
///
/// Usage:
/// ```swift
/// DSAvatarGroup(names: ["John", "Jane", "Bob"], maxVisible: 3)
/// ```
public struct DSAvatarGroup: View {
  let names: [String]
  let size: DSAvatarSize
  let maxVisible: Int
  let overlapOffset: CGFloat?

  @Environment(\.dsTheme) private var theme

  /// `overlapOffset` defaults to 60% of the avatar size.
  public init(
    names: [String],
    size: DSAvatarSize = .sm,
    maxVisible: Int = 4,
    overlapOffset: CGFloat? = nil
  ) {
    self.names = names
    self.size = size
    self.maxVisible = maxVisible
    self.overlapOffset = overlapOffset
  }

  public var body: some View {
    let dimension = size.dimension(in: theme)
    let offset = overlapOffset ?? (dimension * 0.6)

    HStack(spacing: -offset + dimension) {
      ForEach(Array(visibleNames.enumerated()), id: \.offset) { index, name in
        DSAvatarView(name: name, size: size)
          .overlay(
            Circle()
              .stroke(theme.colors.background, lineWidth: 2)
          )
          .zIndex(Double(visibleNames.count - index))
      }

      if remainingCount > 0 {
        Circle()
          .fill(theme.colors.cardBackground)
          .frame(width: dimension, height: dimension)
          .overlay {
            Text("+\(remainingCount)")
              .font(size.font)
              .foregroundColor(theme.colors.textSecondary)
          }
          .overlay(
            Circle()
              .stroke(theme.colors.background, lineWidth: 2)
          )
      }
    }
  }

  private var visibleNames: [String] {
    Array(names.prefix(maxVisible))
  }

  private var remainingCount: Int {
    max(0, names.count - maxVisible)
  }
}

// MARK: - Preview

#Preview("Avatars") {
  ScrollView {
    VStack(spacing: DSTheme.default.spacing.xl) {
      Group {
        Text("Sizes").font(.caption).foregroundColor(.secondary)
        HStack(spacing: DSTheme.default.spacing.md) {
          DSAvatarView(name: "John Doe", size: .xs)
          DSAvatarView(name: "John Doe", size: .sm)
          DSAvatarView(name: "John Doe", size: .md)
          DSAvatarView(name: "John Doe", size: .lg)
          DSAvatarView(name: "John Doe", size: .xl)
        }
      }

      Divider()

      Group {
        Text("Different Names").font(.caption).foregroundColor(.secondary)
        HStack(spacing: DSTheme.default.spacing.md) {
          DSAvatarView(name: "Alice")
          DSAvatarView(name: "Bob Smith")
          DSAvatarView(name: "Charlie Brown")
          DSAvatarView(name: "Diana Prince")
        }
      }

      Divider()

      Group {
        Text("Custom Initials").font(.caption).foregroundColor(.secondary)
        HStack(spacing: DSTheme.default.spacing.md) {
          DSAvatarView(initials: "AB", size: .lg)
          DSAvatarView(initials: "XY", size: .lg, backgroundColor: .purple.opacity(0.3))
          DSAvatarView(initials: "?", size: .lg, backgroundColor: .red.opacity(0.3))
        }
      }

      Divider()

      Group {
        Text("Avatar Group").font(.caption).foregroundColor(.secondary)
        DSAvatarGroup(
          names: ["Alice", "Bob", "Charlie", "Diana", "Eve", "Frank"],
          size: .md,
          maxVisible: 4
        )
      }

      Group {
        Text("Small Avatar Group").font(.caption).foregroundColor(.secondary)
        DSAvatarGroup(
          names: ["Alice", "Bob", "Charlie"],
          size: .sm,
          maxVisible: 5
        )
      }
    }
    .padding()
  }
}
