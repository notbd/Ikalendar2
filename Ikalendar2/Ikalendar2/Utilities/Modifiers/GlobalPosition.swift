//
//  GlobalPosition.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - GlobalPosition

struct GlobalPosition: ViewModifier {

  let x: CGFloat
  let y: CGFloat

  func body(content: Content) -> some View {
    GeometryReader { proxy in
      content
        .position(
          x: proxy.size.width / 2 + (x - proxy.frame(in: .global).midX),
          y: proxy.size.height / 2 + (y - proxy.frame(in: .global).midY))
    }
  }
}

extension View {
  func globalPosition(x: CGFloat, y: CGFloat) -> some View {
    modifier(GlobalPosition(x: x, y: y))
  }
}
