//
//  IkaFont.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - IkaFont

enum IkaFont: String {
  case ika1 = "Splatfont1-Regular"
  case ika2 = "Splatfont2-Regular"
}

// MARK: - IkaFontTextStyle

private struct IkaFontTextStyle: ViewModifier {
  let ikaFont: IkaFont
  let size: CGFloat
  let textStyle: Font.TextStyle

  func body(content: Content) -> some View {
    content
      .font(
        .custom(
          ikaFont.rawValue,
          size: size,
          relativeTo: textStyle))
  }
}

extension View {
  /// Applies one of the two Splatoon fonts at `size`, scaling with Dynamic Type relative to `textStyle`.
  ///
  /// - Parameters:
  ///   - ikaFont: The type of the ika font.
  ///   - size: The size of the ika font.
  ///   - textStyle: The text style that this size is relative to.
  /// - Returns: The modified view.
  func ikaFont(
    _ ikaFont: IkaFont,
    size: CGFloat,
    relativeTo textStyle: Font.TextStyle)
    -> some View
  {
    modifier(
      IkaFontTextStyle(
        ikaFont: ikaFont,
        size: size,
        textStyle: textStyle))
  }
}
