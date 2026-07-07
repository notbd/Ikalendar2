//
//  BattleRotationList.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - BattleRotationList

struct BattleRotationList: View {
  @Environment(IkaCatalog.self) private var ikaCatalog
  @Environment(IkaStatus.self) private var ikaStatus
  @Environment(IkaClock.self) private var ikaClock

  let specifiedBattleMode: BattleMode?

  private var validBattleRotations: [BattleRotation] {
    let battleMode: BattleMode =
      if let specifiedBattleMode { specifiedBattleMode } else { ikaStatus.currentBattleMode }

    // filter: display current and future rotations only
    return
      (ikaCatalog.battleRotationDict[battleMode] ?? []).filter { !$0.isExpired(ikaClock.currentTime) }
  }

  var body: some View {
    GeometryReader { geo in
      List {
        ForEach(validBattleRotations) { rotation in
          BattleRotationRow(
            rotation: rotation,
            rowWidth: geo.size.width)
            .listRowSeparator(.hidden)
        }
      }
      .listStyle(.insetGrouped)
      // map animation value to startTime to avoid animation during battle mode switch
      .animation(
        .bouncy,
        value: validBattleRotations.map { $0.startTime })
      .disabled(ikaCatalog.loadStatus != .loaded)
    }
  }

  init(
    specifiedBattleMode: BattleMode? = nil)
  {
    self.specifiedBattleMode = specifiedBattleMode
  }
}

#Preview {
  // Renders straight from the preloaded preview catalog - the app's main surface.
  BattleRotationList(specifiedBattleMode: .gachi)
    .ikaPreviewEnvironment()
}
