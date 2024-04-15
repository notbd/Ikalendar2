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

extension View {
  /// A modifier function that quickly applies a custom ika font to the view.
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

// MARK: - IkaFontTextStyle

struct IkaFontTextStyle: ViewModifier {
  var ikaFont: IkaFont
  var size: CGFloat
  var textStyle: Font.TextStyle

  func body(content: Content) -> some View {
    content
      .font(
        .custom(
          ikaFont.rawValue,
          size: size,
          relativeTo: textStyle))
  }
}
