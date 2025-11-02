//
//  BlurFade.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

extension View {
  @ViewBuilder
  func blurFade(isShown: Bool) -> some View {
    blur(radius: isShown ? 0 : 5)
      .opacity(isShown ? 1 : 0)
  }
}
