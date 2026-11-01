//
//  AdaptiveGlassEffect.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - AdaptiveGlassEffect

/// A glass effect, interactive unless told otherwise, that adapts to the color scheme:
/// `.clear` on dark (regular glass washes out there), `.regular` on light.
private struct AdaptiveGlassEffect<EffectShape: Shape>: ViewModifier {
  @Environment(\.colorScheme) private var colorScheme

  let tint: Color?
  let isInteractive: Bool
  let shape: EffectShape

  func body(content: Content) -> some View {
    let baseGlass: Glass = colorScheme == .dark ? .clear : .regular
    let tintedGlass = tint.map { baseGlass.tint($0) } ?? baseGlass

    content
      .glassEffect(tintedGlass.interactive(isInteractive), in: shape)
  }
}

extension View {
  /// Applies a color-scheme-aware glass effect, interactive by default.
  func adaptiveGlassEffect(
    tint: Color? = nil,
    isInteractive: Bool = true,
    in shape: some Shape)
    -> some View
  {
    modifier(AdaptiveGlassEffect(tint: tint, isInteractive: isInteractive, shape: shape))
  }
}
