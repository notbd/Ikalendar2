//
//  RotationsTabView.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

// MARK: - RotationsTabView

/// The view that displays the content in a navigation stack.
struct RotationsTabView: View {
  @Environment(IkaCatalog.self) private var ikaCatalog

  let adoptedFlatMode: FlatMode

  var body: some View {
    ZStack {
      content
        .navigationTitle(title.localizedStringKey)
        .overlay(
          ModeIconStamp(
            flatModeSelection: adoptedFlatMode,
            shouldOffset: true)
            .animation(
              .snappy,
              value: adoptedFlatMode),
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
      default:
        rotationList
    }
  }

  @ViewBuilder
  private var rotationList: some View {
    BattleRotationList()
    switch adoptedFlatMode {
      case .salmon:
        SalmonRotationList()
      default:
        BattleRotationList(specifiedBattleMode: BattleMode(rawValue: adoptedFlatMode.rawValue) ?? .default)
    }
  }

  private var title: String {
    adoptedFlatMode.name
  }
}

#Preview("Battle Tab") {
  RotationsTabView(adoptedFlatMode: .gachi)
    .ikaPreviewEnvironment()
}

#Preview("Salmon Tab") {
  RotationsTabView(adoptedFlatMode: .salmon)
    .ikaPreviewEnvironment()
}
