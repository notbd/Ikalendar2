//
//  AutoLoadingOverlay.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - AutoLoadingOverlay

struct AutoLoadingOverlay: View {
  typealias Scoped = Constants.Style.Overlay.AutoLoading

  @EnvironmentObject private var ikaCatalog: IkaCatalog

  var body: some View {
    Image(systemName: iconName)
      .symbolEffect(.pulse.byLayer, isActive: ikaCatalog.autoLoadStatus == .autoLoading)
      .contentTransition(.symbolEffect(.replace.offUp))
      .foregroundStyle(Color.primary)
      .font(Scoped.SFSYMBOL_FONT)
      .frame(
        width: Scoped.FRAME_SIDE,
        height: Scoped.FRAME_SIDE)
      .background(.thinMaterial)
      .cornerRadius(Scoped.FRAME_CORNER_RADIUS)
      .opacity(ikaCatalog.autoLoadStatus == .idle ? 0 : 1)
      .padding()
      .animation(
        .default,
        value: ikaCatalog.autoLoadStatus)
  }

  private var iconName: String {
    switch ikaCatalog.autoLoadDelayedIdleStatus {
    case .autoLoading:
      Scoped.LOADING_SFSYMBOL
    case .autoLoaded(let loadedStatus):
      switch loadedStatus {
      case .success:
        Scoped.LOADED_SUCCESS_SFSYMBOL
      case .failure:
        Scoped.LOADED_FAILURE_SFSYMBOL
      }
    case .idle:
      Scoped.LOADING_SFSYMBOL
    }
  }
}

// MARK: - AutoLoadingOverlay_Previews

struct AutoLoadingOverlay_Previews: PreviewProvider {
  static var previews: some View {
    AutoLoadingOverlay()
  }
}
