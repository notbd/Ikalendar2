//
//  ScrollView+Ext.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

extension ScrollView {
  /// Fix the flickering of a ScrollView inside a NavigationView.
  /// - Returns: The fixed ScrollView.
  func fixFlickering() -> some View {
    fixFlickering { scrollView in
      scrollView
    }
  }

  /// Fix the flickering of a ScrollView inside a NavigationView
  /// with chance to setup the nested ScrollView inside the closure.
  /// - Parameter configurator: The configuration of the ScrollView.
  /// - Returns: The fixed ScrollView.
  func fixFlickering<T: View>(
    @ViewBuilder configurator: @escaping (ScrollView<AnyView>) -> T)
    -> some View
  {
    GeometryReader { geoWithSafeArea in
      GeometryReader { _ in
        configurator(
          ScrollView<AnyView>(self.axes, showsIndicators: self.showsIndicators) {
            AnyView(
              VStack { self.content }
                .padding(.top, geoWithSafeArea.safeAreaInsets.top)
                .padding(.bottom, geoWithSafeArea.safeAreaInsets.bottom)
                .padding(.leading, geoWithSafeArea.safeAreaInsets.leading)
                .padding(.trailing, geoWithSafeArea.safeAreaInsets.trailing))
          })
      }
      .edgesIgnoringSafeArea(.all)
    }
  }
}
