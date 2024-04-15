//
//  LoadingOverlay.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - LoadingOverlay

/// An overlay indicating the loading status of the app.
@MainActor
struct LoadingOverlay: View {
  typealias Scoped = Constants.Style.Overlay.Loading

  @Environment(IkaCatalog.self) private var ikaCatalog

  private var isLoading: Bool {
    ikaCatalog.loadStatus == .loading
  }

  var body: some View {
    Color.clear
      .edgesIgnoringSafeArea(.all)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(.ultraThinMaterial)
      .opacity(isLoading ? 1 : 0)
      .animation(
        .default,
        value: ikaCatalog.loadStatus)
  }
}

// MARK: - LoadingOverlay_Previews

struct LoadingOverlay_Previews: PreviewProvider {
  static var previews: some View {
    LoadingOverlay()
  }
}
