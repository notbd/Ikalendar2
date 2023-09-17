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
  @EnvironmentObject private var ikaTimePublisher: IkaTimePublisher

  let specifiedBattleMode: BattleMode?

  private var battleRotations: [BattleRotation] {
    let battleMode: BattleMode

    if let specifiedBattleMode { battleMode = specifiedBattleMode }
    else { battleMode = ikaStatus.currentBattleMode }

    // filter: display current and future rotations only
    return
      ikaCatalog.battleRotationDict[battleMode]!.filter { !$0.isExpired() }
  }

  var body: some View {
    GeometryReader { geo in
      List {
        ForEach(battleRotations) { rotation in
          BattleRotationRow(
            rotation: rotation,
            rowWidth: geo.size.width)
            .listRowSeparator(.hidden)
        }
      }
      .listStyle(.insetGrouped)
      // map animation value to startTime to avoid animation during battle mode switch
      .animation(
        Constants.Config.Animation.spring,
        value: battleRotations.map { $0.startTime })
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
