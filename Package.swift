// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "platform-ui-swift",
  // iOS only: the components lean on UIKit-backed colors and iOS-only modifiers (keyboard types,
  // navigation bar display modes), and every consumer is an iPhone app.
  platforms: [.iOS(.v18)],
  products: [
    .library(name: "DesignSystem", targets: ["DesignSystem"])
  ],
  targets: [
    .target(
      name: "DesignSystem",
      swiftSettings: [.swiftLanguageMode(.v6)]
    ),
    .testTarget(
      name: "DesignSystemTests",
      dependencies: ["DesignSystem"],
      swiftSettings: [.swiftLanguageMode(.v6)]
    ),
  ]
)
