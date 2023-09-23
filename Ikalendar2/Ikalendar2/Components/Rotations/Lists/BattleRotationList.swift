//
//  BattleRotationList.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - BattleRotationList

struct BattleRotationList: View {
  @EnvironmentObject private var ikaCatalog: IkaCatalog
  @EnvironmentObject private var ikaStatus: IkaStatus
  @Environment(IkaTimePublisher.self) private var ikaTimePublisher

  let specifiedBattleMode: BattleMode?

  private var validBattleRotations: [BattleRotation] {
    let battleMode: BattleMode = if let specifiedBattleMode { specifiedBattleMode }
    else { ikaStatus.currentBattleMode }

    // filter: display current and future rotations only
    return
      ikaCatalog.battleRotationDict[battleMode]!.filter { !$0.isExpired }
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
