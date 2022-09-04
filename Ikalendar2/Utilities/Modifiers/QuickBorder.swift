//
//  QuickBorder.swift
//  Ikalendar2
//
//  Copyright (c) 2022 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

/// A modifier that quickly applies a colored border to the view.
/// <FOR DEBUGGING PURPOSES>
extension View {
  func quickBorderRed() -> some View {
    modifier(QuickBorder(color: Color.red))
  }

  func quickBorderBlue() -> some View {
    modifier(QuickBorder(color: Color.blue))
  }

  func quickBorderYellow() -> some View {
    modifier(QuickBorder(color: Color.yellow))
  }

  func quickBorderOrange() -> some View {
    modifier(QuickBorder(color: Color.orange))
  }

  func quickBorderPurple() -> some View {
    modifier(QuickBorder(color: Color.purple))
  }

  func quickBorderGreen() -> some View {
    modifier(QuickBorder(color: Color.green))
  }
}

// MARK: - QuickBorder

struct QuickBorder: ViewModifier {
  var color: Color

  // MARK: Internal

  func body(content: Content) -> some View {
    content
      .border(color)
  }
}
