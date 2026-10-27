//
//  ThemingTests.swift
//  DesignSystemTests
//
//  Tests that themes and styles set in the environment reach the components
//

import DesignSystem
import SwiftUI
import Testing
import UIKit

// MARK: - Helpers

@MainActor
private final class Recorder {
  var buttonConfigurations: [DSButtonStyleConfiguration] = []
}

/// Draws a fixed-size box and remembers what it was asked to draw.
private struct RecordingButtonStyle: DSButtonStyle {
  let recorder: Recorder

  func makeBody(configuration: Configuration) -> some View {
    recorder.buttonConfigurations.append(configuration)
    return Color.red.frame(width: 123, height: 45)
  }
}

/// A look tokens alone can't produce: square, outlined, uppercase.
private struct BlockButtonStyle: DSButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    Text((configuration.title ?? "").uppercased())
      .font(.system(.body, design: .monospaced))
      .padding(configuration.theme.spacing.md)
      .frame(maxWidth: configuration.fullWidth ? .infinity : nil)
      .overlay(Rectangle().stroke(configuration.theme.colors.primary, lineWidth: 3))
  }
}

private struct FlatCardStyle: DSCardStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.content
      .padding(configuration.padding)
      .overlay(alignment: .leading) {
        Rectangle().fill(configuration.theme.colors.primary).frame(width: 4)
      }
  }
}

@MainActor
private func render(_ view: some View) -> UIImage? {
  let renderer = ImageRenderer(content: view)
  renderer.scale = 1
  return renderer.uiImage
}

private var alternateTheme: DSTheme {
  var theme = DSTheme.default
  theme.colors.primary = Color(red: 0.1, green: 0.6, blue: 0.3)
  theme.colors.cardBackground = Color(red: 0.98, green: 0.95, blue: 0.88)
  theme.spacing.lg = 20
  theme.radius.md = 0
  return theme
}

/// The same screen an app might build, independent of how it looks.
private struct SampleScreen: View {
  var body: some View {
    VStack(spacing: 16) {
      DSSection("Household", subtitle: "Two people") {
        DSCard {
          DSListRow(title: "Alice", icon: "person")
        }
      }
      DSStatusBadge(.accepted, style: .pill)
      DSButton("Save", fullWidth: true) {}
    }
    .padding()
    .frame(width: 320)
  }
}

// MARK: - Theme Tests

@MainActor
struct ThemeEnvironmentTests {
  @Test("A theme set in the environment reaches a component's style")
  func testThemeReachesStyle() throws {
    let recorder = Recorder()
    let theme = alternateTheme

    _ = render(
      DSButton("Save") {}
        .dsButtonStyle(RecordingButtonStyle(recorder: recorder))
        .dsTheme(theme)
    )

    let configuration = try #require(recorder.buttonConfigurations.last)
    #expect(configuration.theme.colors.primary == theme.colors.primary)
    #expect(configuration.theme.spacing.lg == 20)
    #expect(configuration.title == "Save")
  }

  @Test("Without a theme, components get the default one")
  func testDefaultTheme() throws {
    let recorder = Recorder()

    _ = render(DSButton("Save") {}.dsButtonStyle(RecordingButtonStyle(recorder: recorder)))

    let configuration = try #require(recorder.buttonConfigurations.last)
    #expect(configuration.theme.colors.primary == DSTheme.default.colors.primary)
    #expect(configuration.theme.spacing.lg == DSTheme.default.spacing.lg)
  }

  @Test("The default card style pads with the theme's spacing")
  func testDefaultStyleReadsTheme() throws {
    let content = Color.clear.frame(width: 10, height: 10)

    let standard = try #require(render(DSCard { content }))
    let themed = try #require(render(DSCard { content }.dsTheme(alternateTheme)))

    #expect(standard.size == CGSize(width: 10 + 2 * 16, height: 10 + 2 * 16))
    #expect(themed.size == CGSize(width: 10 + 2 * 20, height: 10 + 2 * 20))
  }

  @Test("An explicit value still beats the theme")
  func testExplicitValueBeatsTheme() throws {
    let image = try #require(
      render(
        DSCard(padding: 5) { Color.clear.frame(width: 10, height: 10) }.dsTheme(alternateTheme))
    )

    #expect(image.size == CGSize(width: 20, height: 20))
  }
}

// MARK: - Style Tests

@MainActor
struct StyleEnvironmentTests {
  @Test("A custom style replaces a component's body")
  func testCustomStyleReplacesBody() throws {
    let recorder = Recorder()

    let image = try #require(
      render(DSButton("Save") {}.dsButtonStyle(RecordingButtonStyle(recorder: recorder)))
    )

    #expect(image.size == CGSize(width: 123, height: 45))
  }

  @Test("A style reaches every component that shares it")
  func testStyleCoversButtonFamily() {
    let recorder = Recorder()

    _ = render(
      VStack {
        DSButton("Save", isLoading: true) {}
        DSIconButton("plus", isDisabled: true) {}
        NavigationStack { DSButtonLink("Next", destination: EmptyView()) }
      }
      .dsButtonStyle(RecordingButtonStyle(recorder: recorder))
    )

    let titles = recorder.buttonConfigurations.map(\.title)
    #expect(titles.contains("Save"))
    #expect(titles.contains(nil))
    #expect(titles.contains("Next"))
    #expect(recorder.buttonConfigurations.contains { $0.title == "Save" && $0.isLoading })
    #expect(recorder.buttonConfigurations.contains { $0.title == nil && $0.isDisabled })
  }

  @Test("The innermost style wins, and .default restores the library's")
  func testInnermostStyleWins() throws {
    let recorder = Recorder()

    let image = try #require(
      render(
        DSButton("Save") {}
          .dsButtonStyle(.default)
          .dsButtonStyle(RecordingButtonStyle(recorder: recorder))
      )
    )

    #expect(recorder.buttonConfigurations.isEmpty)
    #expect(image.size != CGSize(width: 123, height: 45))
  }

  @Test("One screen, two themes and style sets, two different looks")
  func testSameScreenTwoLooks() throws {
    let standard = try #require(render(SampleScreen())?.pngData())
    let alternate = try #require(
      render(
        SampleScreen()
          .dsTheme(alternateTheme)
          .dsButtonStyle(BlockButtonStyle())
          .dsCardStyle(FlatCardStyle())
      )?.pngData()
    )

    #expect(standard != alternate)
  }
}
