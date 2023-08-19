//
//  SalmonRotationListView.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - SalmonRotationListView

/// The view that displays a list of salmon rotations.
struct SalmonRotationListView: View {
  @EnvironmentObject var ikaCatalog: IkaCatalog
  @EnvironmentObject var ikaTimeManager: IkaTimeManager

  var salmonRotations: [SalmonRotation] {
    let rawRotations = ikaCatalog.salmonRotations
    func filterCurrent(rotation: some Rotation) -> Bool {
      !rotation.isExpired(currentTime: ikaTimeManager.currentTime)
    }
    let results = rawRotations.filter(filterCurrent)
    return results
  }

  var body: some View {
    GeometryReader { geo in
      List {
        ForEach(
          Array(salmonRotations.enumerated()),
          id: \.offset)
        { index, rotation in
          SalmonRotationRow(
            rotation: rotation,
            index: index,
            rowWidth: geo.size.width)
        }
      }
      .disabled(ikaCatalog.loadStatus != .loaded)
    }
  }
}

// MARK: - SalmonRotationListView_Previews

struct SalmonRotationListView_Previews: PreviewProvider {
  static var previews: some View {
    SalmonRotationListView()
  }
}
