//
//  BattleRotationList.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - BattleRotationList

/// The battle rotation list for one mode: current rotation featured on top,
/// upcoming ones below.
struct BattleRotationList: View {
  @Environment(IkaCatalog.self) private var ikaCatalog
  @Environment(IkaClock.self) private var ikaClock

  let battleMode: BattleMode

  private var validBattleRotations: [BattleRotation] {
    (ikaCatalog.battleRotationDict[battleMode] ?? []).filter { !$0.isExpired(ikaClock.currentTime) }
  }

  var body: some View {
    GeometryReader { geo in
      // filter once per pass; both the rows and the animation value use it
      let rotations: [BattleRotation] = validBattleRotations

      List {
        ForEach(rotations) { rotation in
          BattleRotationRow(
            rotation: rotation,
            rowWidth: geo.size.width)
            .listRowSeparator(.hidden)
        }
      }
      .listStyle(.insetGrouped)
      // Animate on the start times only: the three modes share one schedule, so a mode switch
      // leaves the start times unchanged and does not animate, while a rotation rolling off or
      // arriving does.
      .animation(
        .bouncy,
        value: rotations.map { $0.startTime })
      .disabled(ikaCatalog.loadStatus != .loaded)
    }
  }
}

#Preview {
  // Renders straight from the preloaded preview catalog - the app's main surface.
  BattleRotationList(battleMode: .gachi)
    .ikaPreviewEnvironment()
}
