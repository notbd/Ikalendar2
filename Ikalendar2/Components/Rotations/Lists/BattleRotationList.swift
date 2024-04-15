//
//  BattleRotationList.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - BattleRotationList

@MainActor
struct BattleRotationList: View {
  @Environment(IkaCatalog.self) private var ikaCatalog
  @Environment(IkaStatus.self) private var ikaStatus
  @EnvironmentObject private var ikaTimePublisher: IkaTimePublisher

  let specifiedBattleMode: BattleMode?

  private var validBattleRotations: [BattleRotation] {
    let battleMode: BattleMode =
      if let specifiedBattleMode { specifiedBattleMode } else { ikaStatus.currentBattleMode }

    // filter: display current and future rotations only
    return
      ikaCatalog.battleRotationDict[battleMode]!.filter { !$0.isExpired(ikaTimePublisher.currentTime) }
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

  // MARK: Lifecycle

  init(
    specifiedBattleMode: BattleMode? = nil)
  {
    self.specifiedBattleMode = specifiedBattleMode
  }
}
