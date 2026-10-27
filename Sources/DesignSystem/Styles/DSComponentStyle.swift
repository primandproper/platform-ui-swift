//
//  DSComponentStyle.swift
//  DesignSystem
//
//  Type erasure shared by every component's style protocol
//

import SwiftUI

// Every component renders through a style found in the environment, the way SwiftUI's `Button`
// renders through a `ButtonStyle`: the component owns state, actions and accessibility, and hands
// its style a `Configuration` describing what to draw. Each component has its own protocol
// (`DSButtonStyle`, `DSCardStyle`, …), a `Default…Style` built from the theme, and a modifier to
// set it (`.dsButtonStyle(_:)`). The protocols share no parent because a shared associated type
// would make every conformer spell out its configuration type; this keeps `Configuration`
// available to them exactly as `ButtonStyle` does.

/// A type-erased style, so the environment can hold whichever one an app set.
struct AnyDSStyle<Configuration>: Sendable {
  private let make: @MainActor @Sendable (Configuration) -> AnyView

  init(_ make: @escaping @MainActor @Sendable (Configuration) -> AnyView) {
    self.make = make
  }

  @MainActor func makeBody(_ configuration: Configuration) -> AnyView {
    make(configuration)
  }
}
