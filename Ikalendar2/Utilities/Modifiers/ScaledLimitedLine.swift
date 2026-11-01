//
//  ScaledLimitedLine.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - ScaledLimitedLine

/// Caps text to a line limit and lets it shrink to fit instead of truncating.
struct ScaledLimitedLine: ViewModifier {
  let lineLimit: Int
  let minScaleFactor: CGFloat

  func body(content: Content) -> some View {
    content
      .lineLimit(lineLimit)
      .minimumScaleFactor(minScaleFactor)
  }
}

extension View {
  /// Caps text at `lineLimit` lines and shrinks it (down to `minScaleFactor`) instead of truncating.
  ///
  /// - Parameters:
  ///   - lineLimit: The max number of lines (default to 1).
  ///   - minScaleFactor: The minimum scale factor of the text (default to 0.3).
  /// - Returns: The modified view.
  func scaledLimitedLine(
    lineLimit: Int = 1,
    minScaleFactor: CGFloat = 0.3)
    -> some View
  {
    modifier(
      ScaledLimitedLine(
        lineLimit: lineLimit,
        minScaleFactor: minScaleFactor))
  }
}
