//
//  LoadingOverlay.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - LoadingOverlay

/// An overlay indicating the loading status of the app.
struct LoadingOverlay: View {
  typealias Scoped = Constants.Style.Overlay.Loading

  var loadStatus: IkaCatalog.LoadStatus

  private var isLoading: Bool {
    loadStatus == .loading
  }

  var body: some View {
    ZStack {
      Spacer()
        .background(.ultraThinMaterial)
        .edgesIgnoringSafeArea(.all)
        .opacity(isLoading ? 1 : 0)
    }
    .animation(
      .easeOut(duration: Constants.Style.Global.ANIMATION_DURATION),
      value: loadStatus)
  }
}

// MARK: - LoadingOverlay_Previews

struct LoadingOverlay_Previews: PreviewProvider {
  static var previews: some View {
    LoadingOverlay(loadStatus: .loading)
  }
}
