//
//  BattleRotationListView.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - BattleRotationListView

/// The view that displays a list of battle rotations.
struct BattleRotationListView: View {
  @EnvironmentObject var ikaCatalog: IkaCatalog
  @EnvironmentObject var ikaStatus: IkaStatus
  @EnvironmentObject var ikaTimeManager: IkaTimeManager

  var battleRotations: [BattleRotation] {
    let rawRotations = ikaCatalog.battleRotationDict[ikaStatus.battleModeSelection]!
    func filterCurrent(rotation: some Rotation) -> Bool {
      !rotation.isExpired(currentTime: ikaTimeManager.currentTime)
    }
    let results = rawRotations.filter(filterCurrent)
    return results
  }

  var body: some View {
    GeometryReader { geo in
      Form {
        ForEach(
          Array(battleRotations.enumerated()),
          id: \.offset)
        { index, rotation in
          BattleRotationRow(
            rotation: rotation,
            index: index,
            width: geo.size.width)
        }
      }
      .disabled(ikaCatalog.loadStatus != .loaded)
    }
  }
}

// MARK: - BattleRotationListView_Previews

struct BattleRotationListView_Previews: PreviewProvider {
  static var previews: some View {
    BattleRotationListView()
      .environmentObject(IkaCatalog.shared)
  }
}
