//
//  AdaptiveGlassEffect.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - AdaptiveGlassEffect

/// An interactive glass effect that adapts to the color scheme:
/// `.clear` on dark (regular glass washes out there), `.regular` on light.
struct AdaptiveGlassEffect<EffectShape: Shape>: ViewModifier {
  @Environment(\.colorScheme) private var colorScheme

  let tint: Color?
  let shape: EffectShape

  func body(content: Content) -> some View {
    let baseGlass: Glass = colorScheme == .dark ? .clear : .regular
    let tintedGlass = tint.map { baseGlass.tint($0) } ?? baseGlass

    content
      .glassEffect(tintedGlass.interactive(), in: shape)
  }
}

extension View {
  /// Applies an interactive, color-scheme-aware glass effect.
  func adaptiveGlassEffect(
    tint: Color? = nil,
    in shape: some Shape)
    -> some View
  {
    modifier(AdaptiveGlassEffect(tint: tint, shape: shape))
  }
}
