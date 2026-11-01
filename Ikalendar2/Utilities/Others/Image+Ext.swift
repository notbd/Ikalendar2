//
//  Image+Ext.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

extension Image {
  /// The antialiased, resizable, aspect-fit chain the app's bitmap images use.
  func ikaFitted() -> some View {
    antialiased(true)
      .resizable()
      .scaledToFit()
  }
}
