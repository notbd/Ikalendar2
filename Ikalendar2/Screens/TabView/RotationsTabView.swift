//
//  RotationsTabView.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

// MARK: - RotationsTabView

/// One tab's content for `flatMode`: its rotation list (or ErrorView), the mode stamp, and pull-to-refresh.
struct RotationsTabView: View {
  @Environment(IkaCatalog.self) private var ikaCatalog

  let flatMode: FlatMode

  var body: some View {
    ZStack {
      content
        .navigationTitle(title.localizedStringKey)
        .overlay(
          ModeIconStamp(flatModeSelection: flatMode)
            .offset(
              x: Constants.Style.Overlay.ModeIcon.iconOffsetX,
              y: Constants.Style.Overlay.ModeIcon.iconOffsetY),
          alignment: .topTrailing)
        .refreshable {
          await ikaCatalog.refresh()
        }

      LoadingOverlay()
    }
  }

  @ViewBuilder
  private var content: some View {
    switch ikaCatalog.loadResultStatus {
      case .error(let ikaError):
        ErrorView(error: ikaError)
      case .loading,
           .loaded:
        rotationList
    }
  }

  @ViewBuilder
  private var rotationList: some View {
    if let battleMode = flatMode.battleMode {
      BattleRotationList(battleMode: battleMode)
    }
    else {
      SalmonRotationList()
    }
  }

  private var title: String {
    flatMode.name
  }
}

#Preview("Battle Tab") {
  RotationsTabView(flatMode: .gachi)
    .ikaPreviewEnvironment()
}

#Preview("Salmon Tab") {
  RotationsTabView(flatMode: .salmon)
    .ikaPreviewEnvironment()
}
