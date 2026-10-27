//
//  DesignSystemTests.swift
//  DesignSystemTests
//
//  Tests for the Design System components and theme tokens
//

import DesignSystem
import Foundation
import SwiftUI
import Testing

// MARK: - Theme Token Tests

struct ThemeSpacingTests {
  @Test("Spacing tokens have correct relative sizes")
  func testSpacingRelativeSizes() {
    #expect(DSTheme.default.spacing.xxs < DSTheme.default.spacing.xs)
    #expect(DSTheme.default.spacing.xs < DSTheme.default.spacing.sm)
    #expect(DSTheme.default.spacing.sm < DSTheme.default.spacing.md)
    #expect(DSTheme.default.spacing.md < DSTheme.default.spacing.lg)
    #expect(DSTheme.default.spacing.lg < DSTheme.default.spacing.xl)
    #expect(DSTheme.default.spacing.xl < DSTheme.default.spacing.xxl)
  }

  @Test("Spacing tokens are positive values")
  func testSpacingPositiveValues() {
    #expect(DSTheme.default.spacing.xxs > 0)
    #expect(DSTheme.default.spacing.xs > 0)
    #expect(DSTheme.default.spacing.sm > 0)
    #expect(DSTheme.default.spacing.md > 0)
    #expect(DSTheme.default.spacing.lg > 0)
    #expect(DSTheme.default.spacing.xl > 0)
    #expect(DSTheme.default.spacing.xxl > 0)
  }
}

struct ThemeRadiusTests {
  @Test("Radius tokens have correct relative sizes")
  func testRadiusRelativeSizes() {
    #expect(DSTheme.default.radius.xs < DSTheme.default.radius.sm)
    #expect(DSTheme.default.radius.sm < DSTheme.default.radius.md)
    #expect(DSTheme.default.radius.md < DSTheme.default.radius.lg)
    #expect(DSTheme.default.radius.lg < DSTheme.default.radius.xl)
  }

  @Test("Full radius is large enough for pill shapes")
  func testFullRadius() {
    #expect(DSTheme.default.radius.full >= 100)
  }
}

struct ThemeIconSizeTests {
  @Test("Icon sizes have correct relative sizes")
  func testIconSizeRelativeSizes() {
    #expect(DSTheme.default.iconSize.sm < DSTheme.default.iconSize.md)
    #expect(DSTheme.default.iconSize.md < DSTheme.default.iconSize.lg)
    #expect(DSTheme.default.iconSize.lg < DSTheme.default.iconSize.xl)
  }
}

struct ThemeAvatarSizeTests {
  @Test("Avatar sizes have correct relative sizes")
  func testAvatarSizeRelativeSizes() {
    #expect(DSTheme.default.avatarSize.sm < DSTheme.default.avatarSize.md)
    #expect(DSTheme.default.avatarSize.md < DSTheme.default.avatarSize.lg)
    #expect(DSTheme.default.avatarSize.lg < DSTheme.default.avatarSize.xl)
    #expect(DSTheme.default.avatarSize.xl < DSTheme.default.avatarSize.xxl)
  }
}

// MARK: - Button Style Tests

struct DSButtonStyleTests {
  @Test("Primary style has primary background color")
  func testPrimaryStyleBackground() {
    let style = DSButtonVariant.primary
    #expect(style.backgroundColor(in: .default) == DSTheme.default.colors.primary)
  }

  @Test("Destructive style has error background color")
  func testDestructiveStyleBackground() {
    let style = DSButtonVariant.destructive
    #expect(style.backgroundColor(in: .default) == DSTheme.default.colors.error)
  }

  @Test("Ghost style has clear background")
  func testGhostStyleBackground() {
    let style = DSButtonVariant.ghost
    #expect(style.backgroundColor(in: .default) == .clear)
  }

  @Test("Outline style has clear background")
  func testOutlineStyleBackground() {
    let style = DSButtonVariant.outline
    #expect(style.backgroundColor(in: .default) == .clear)
  }

  @Test("Outline style has border color")
  func testOutlineStyleHasBorder() {
    let style = DSButtonVariant.outline
    #expect(style.borderColor(in: .default) != nil)
  }

  @Test("Primary style has no border")
  func testPrimaryStyleNoBorder() {
    let style = DSButtonVariant.primary
    #expect(style.borderColor(in: .default) == nil)
  }
}

struct DSButtonSizeTests {
  @Test("Button sizes have increasing padding")
  func testButtonSizePadding() {
    #expect(
      DSButtonSize.small.verticalPadding(in: .default)
        < DSButtonSize.medium.verticalPadding(in: .default))
    #expect(
      DSButtonSize.medium.verticalPadding(in: .default)
        < DSButtonSize.large.verticalPadding(in: .default))
  }

  @Test("Button sizes have increasing horizontal padding")
  func testButtonSizeHorizontalPadding() {
    #expect(
      DSButtonSize.small.horizontalPadding(in: .default)
        < DSButtonSize.medium.horizontalPadding(in: .default))
    #expect(
      DSButtonSize.medium.horizontalPadding(in: .default)
        < DSButtonSize.large.horizontalPadding(in: .default))
  }
}

// MARK: - Status Type Tests

struct DSStatusTypeTests {
  @Test("Status type pending has correct label")
  func testPendingLabel() {
    #expect(DSStatusType.pending.label == "Pending")
  }

  @Test("Status type success has correct label")
  func testSuccessLabel() {
    #expect(DSStatusType.success.label == "Success")
  }

  @Test("Status type error has correct label")
  func testErrorLabel() {
    #expect(DSStatusType.error.label == "Error")
  }

  @Test("Status type from string returns pending for 'pending'")
  func testFromStringPending() {
    #expect(DSStatusType.from("pending").label == "Pending")
    #expect(DSStatusType.from("Pending").label == "Pending")
  }

  @Test("Status type from string returns accepted for 'accepted'")
  func testFromStringAccepted() {
    #expect(DSStatusType.from("accepted").label == "Accepted")
  }

  @Test("Status type from string returns cancelled for 'cancelled'")
  func testFromStringCancelled() {
    #expect(DSStatusType.from("cancelled").label == "Cancelled")
    #expect(DSStatusType.from("canceled").label == "Cancelled")
  }

  @Test("Status types have distinct colors")
  func testStatusTypesHaveDistinctColors() {
    // These should have different colors for visual distinction
    let pendingColor = DSStatusType.pending.color(in: .default)
    let successColor = DSStatusType.success.color(in: .default)
    let errorColor = DSStatusType.error.color(in: .default)

    #expect(pendingColor != successColor)
    #expect(successColor != errorColor)
  }
}

// MARK: - Avatar Size Tests

struct DSAvatarSizeTests {
  @Test("Avatar size dimensions are correct")
  func testAvatarSizeDimensions() {
    #expect(DSAvatarSize.xs.dimension(in: .default) < DSAvatarSize.sm.dimension(in: .default))
    #expect(DSAvatarSize.sm.dimension(in: .default) < DSAvatarSize.md.dimension(in: .default))
    #expect(DSAvatarSize.md.dimension(in: .default) < DSAvatarSize.lg.dimension(in: .default))
    #expect(DSAvatarSize.lg.dimension(in: .default) < DSAvatarSize.xl.dimension(in: .default))
    #expect(DSAvatarSize.xl.dimension(in: .default) < DSAvatarSize.xxl.dimension(in: .default))
  }

  @Test("Custom avatar size uses provided value")
  func testCustomAvatarSize() {
    let customSize: CGFloat = 100
    #expect(DSAvatarSize.custom(customSize).dimension(in: .default) == customSize)
  }
}

// MARK: - Card Style Tests

struct DSCardStyleTests {
  @Test("All card styles are distinct")
  func testCardStylesAreDistinct() {
    let styles: [DSCardVariant] = [.standard, .elevated, .outlined, .selected, .interactive]
    let uniqueCount = Set(styles.map { "\($0)" }).count
    #expect(uniqueCount == styles.count)
  }
}

// MARK: - Empty State Size Tests

struct DSEmptyStateSizeTests {
  @Test("Empty state sizes have increasing icon sizes")
  func testEmptyStateSizes() {
    #expect(
      DSEmptyStateSize.compact.iconSize(in: .default)
        < DSEmptyStateSize.standard.iconSize(in: .default))
    #expect(
      DSEmptyStateSize.standard.iconSize(in: .default)
        < DSEmptyStateSize.large.iconSize(in: .default))
  }

  @Test("Empty state sizes have increasing spacing")
  func testEmptyStateSpacing() {
    #expect(
      DSEmptyStateSize.compact.spacing(in: .default)
        < DSEmptyStateSize.standard.spacing(in: .default))
    #expect(
      DSEmptyStateSize.standard.spacing(in: .default) < DSEmptyStateSize.large.spacing(in: .default)
    )
  }
}

// MARK: - Component Instantiation Tests

struct ComponentInstantiationTests {
  @Test("DSButton can be instantiated with default parameters")
  @MainActor
  func testDSButtonInstantiation() {
    _ = DSButton("Test") {}
  }

  @Test("DSButton can be instantiated with all style variants")
  @MainActor
  func testDSButtonStyles() {
    let styles: [DSButtonVariant] = [
      .primary, .secondary, .tertiary, .destructive, .ghost, .outline,
    ]
    for style in styles {
      _ = DSButton("Test", style: style) {}
    }
  }

  @Test("DSCard can be instantiated with all style variants")
  @MainActor
  func testDSCardStyles() {
    let styles: [DSCardVariant] = [.standard, .elevated, .outlined, .selected, .interactive]
    for style in styles {
      _ = DSCard(style: style) {
        Text("Content")
      }
    }
  }

  @Test("DSTextField can be instantiated with all type variants")
  @MainActor
  func testDSTextFieldTypes() {
    let binding = Binding<String>(get: { "" }, set: { _ in })
    let types: [DSTextFieldType] = [
      .text, .username, .email, .password, .phone, .number, .multiline,
    ]
    for type in types {
      _ = DSTextField("Label", text: binding, type: type)
    }
  }

  @Test("DSStatusBadge can be instantiated with status types")
  @MainActor
  func testDSStatusBadgeTypes() {
    let types: [DSStatusType] = [.pending, .success, .error, .warning, .info, .cancelled]
    for type in types {
      _ = DSStatusBadge(type)
    }
  }

  @Test("DSEmptyState can be instantiated with all size variants")
  @MainActor
  func testDSEmptyStateSizes() {
    let sizes: [DSEmptyStateSize] = [.compact, .standard, .large]
    for size in sizes {
      _ = DSEmptyState(
        icon: "star",
        title: "Title",
        message: "Message",
        size: size
      )
    }
  }

  @Test("DSAvatarView can be instantiated with name")
  @MainActor
  func testDSAvatarViewWithName() {
    _ = DSAvatarView(name: "John Doe", size: .md)
  }

  @Test("DSSection can be instantiated with title and content")
  @MainActor
  func testDSSectionInstantiation() {
    _ = DSSection("Title") {
      Text("Content")
    }
  }

  @Test("DSLoadingView can be instantiated")
  @MainActor
  func testDSLoadingViewInstantiation() {
    _ = DSLoadingView("Loading...")
  }

  @Test("DSInitializingView can be instantiated")
  @MainActor
  func testDSInitializingViewInstantiation() {
    _ = DSInitializingView()
  }

  @Test("DSIconButton can be instantiated")
  @MainActor
  func testDSIconButtonInstantiation() {
    _ = DSIconButton("star.fill") {}
  }

  @Test("DSStatusDot can be instantiated with all status types")
  @MainActor
  func testDSStatusDotTypes() {
    let types: [DSStatusType] = [.pending, .success, .error, .warning, .info, .cancelled]
    for type in types {
      _ = DSStatusDot(type)
    }
  }

  @Test("DSListRow can be instantiated")
  @MainActor
  func testDSListRowInstantiation() {
    _ = DSListRow(title: "Title")
  }
}

// MARK: - Public Construction Tests

/// Built through the public API alone (this target imports DesignSystem without @testable), so
/// a component whose initializer is internal fails to compile here rather than in an app.
@MainActor
struct PublicConstructionTests {
  @Test("Every component can be constructed from outside the module")
  func testPublicInitializers() {
    _ = DSButton("Title") {}
    _ = DSButtonLink("Title", destination: EmptyView())
    _ = DSIconButton("plus") {}
    _ = DSCard { EmptyView() }
    _ = EmptyView().dsCard()
    _ = DSCardModifier(style: .standard, padding: 0, cornerRadius: 0)
    _ = DSDivider()
    _ = DSDivider(style: .soft, horizontalInset: 8)
    _ = DSSoftDivider()
    _ = DSSoftDivider(verticalSpacing: 4, horizontalInset: 8)
    _ = DSInfoRow(icon: "cart", text: "Text", color: .blue)
    _ = DSInfoRow(icon: "cart", text: "Text", color: .blue, showChevron: false, strikethrough: true)
    _ = DSStepperButtons(onDecrement: {}, onIncrement: {})
    _ = DSLoadingView()
    _ = DSErrorView("Message", accessory: AnyView(Text("Accessory")))
    _ = DSContentState(isLoading: false) { EmptyView() }
    _ = DSInitializingView()
    _ = DSEmptyState(icon: "tray", title: "Title", message: "Message")
    _ = DSSection("Title") { EmptyView() }
    _ = DSSectionHeader(title: "Title")
    _ = DSRuleFlankedHeader(title: "Title", color: .orange)
    _ = DSSectionEmptyContent("Message")
    _ = DSListRow(title: "Title")
    _ = DSListRowLink(title: "Title", destination: EmptyView())
    _ = DSListDivider()
    _ = DSTextField("Placeholder", text: .constant(""))
    _ = DSFieldGroup("Label") { EmptyView() }
    _ = DSAvatar(name: "Jane Doe")
    _ = DSAvatarView(initials: "JD")
    _ = DSAvatarGroup(names: ["Jane", "John"])
    _ = DSStatusBadge(.pending)
    _ = DSStatusDot(status: "accepted")
  }
}
