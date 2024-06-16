//
//  OffsettableScrollView.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - OffsettableScrollView

struct OffsettableScrollView<T: View>: View {
  let axes: Axis.Set
  let showsIndicator: Bool
  let onOffsetChanged: (CGPoint) -> Void
  let content: T

  var body: some View {
    ScrollView(axes, showsIndicators: showsIndicator) {
      GeometryReader { proxy in
        Color.clear.preference(
          key: OffsetPreferenceKey.self,
          value: proxy.frame(
            in: .named("ScrollViewOrigin")).origin)
      }
      .frame(width: 0, height: 0)
      content
    }
    .coordinateSpace(name: "ScrollViewOrigin")
    .onPreferenceChange(
      OffsetPreferenceKey.self,
      perform: onOffsetChanged)
  }

  init(
    axes: Axis.Set = .vertical,
    showsIndicator: Bool = true,
    onOffsetChanged: @escaping (CGPoint) -> Void = { _ in },
    @ViewBuilder content: () -> T)
  {
    self.axes = axes
    self.showsIndicator = showsIndicator
    self.onOffsetChanged = onOffsetChanged
    self.content = content()
  }
}

// MARK: - OffsetPreferenceKey

private struct OffsetPreferenceKey: PreferenceKey {
  static var defaultValue: CGPoint = .zero

  static func reduce(value _: inout CGPoint, nextValue _: () -> CGPoint) { }
}
