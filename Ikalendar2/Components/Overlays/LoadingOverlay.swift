//
//  LoadingOverlay.swift
//  Ikalendar2
//
//  Copyright (c) 2022 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - LoadingOverlay

/// An overlay indicating the loading status of the app.
struct LoadingOverlay: View {
  typealias Scoped = Constants.Styles.Overlay.Loading

  var loadingStatus: IkaCatalog.LoadingStatus

  var isLoading: Bool {
    loadingStatus == .loading
  }

  var body: some View {
    ZStack {
      blurOverlay
//      loadingIndicator
    }
    .animation(
      .easeOut(duration: Constants.Styles.Global.ANIMATION_DURATION),
      value: loadingStatus)
  }

  var loadingIndicator: some View {
    ProgressView()
      .padding()
      .silhouetteFrame(cornerRadius: Scoped.SILHOUETTE_CORNER_RADIUS)
      .opacity(isLoading ? 1 : 0)
  }

  var blurOverlay: some View {
    Blur(style: .regular)
      .edgesIgnoringSafeArea(.all)
      .opacity(isLoading ? 1 : 0)
  }
}

// MARK: - LoadingOverlay_Previews

struct LoadingOverlay_Previews: PreviewProvider {
  static var previews: some View {
    LoadingOverlay(loadingStatus: .loading)
  }
}
