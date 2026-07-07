//
//  GlobalPosition.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - GlobalPosition

/// Positions a view at a fixed point in the global coordinate space.
/// Used to overlay an unclipped copy exactly on top of a list cell.
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
