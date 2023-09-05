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
  @EnvironmentObject private var ikaCatalog: IkaCatalog
  @EnvironmentObject private var ikaStatus: IkaStatus
  @EnvironmentObject private var ikaTimePublisher: IkaTimePublisher

  private var battleRotations: [BattleRotation] {
    // filter: display current and future rotations only
    ikaCatalog.battleRotationDict[ikaStatus.battleModeSelection]!.filter { !$0.isExpired() }
  }

  var body: some View {
    GeometryReader { geo in
      List {
        ForEach(battleRotations)
        { rotation in
          BattleRotationRow(
            rotation: rotation,
            rowWidth: geo.size.width)
            .listRowSeparator(.hidden)
        }
      }
      .listStyle(.insetGrouped)
      // map animation value to startTime to avoid animation during battle mode switch
      .animation(
        .spring(
          response: 0.6,
          dampingFraction: 0.8),
        value: battleRotations.map { $0.startTime })
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
