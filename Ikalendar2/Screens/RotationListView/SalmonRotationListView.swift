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
  @EnvironmentObject var ikaTimer: IkaTimer

  var salmonRotations: [SalmonRotation] {
    let rawRotations = ikaCatalog.salmonRotations
    func filterCurrent<T: Rotation>(rotation: T) -> Bool {
      !rotation.isExpired(currentTime: ikaTimer.currentTime)
    }
    let results = rawRotations.filter(filterCurrent)
    return results
  }

  var body: some View {
    GeometryReader { geo in
      Form {
        ForEach(
          Array(salmonRotations.enumerated()),
          id: \.offset)
        { index, rotation in
          SalmonRotationRow(
            rotation: rotation,
            index: index,
            width: geo.size.width)
        }
      }
      .disabled(ikaCatalog.loadingStatus != .loaded)
    }
  }
}

// MARK: - SalmonRotationListView_Previews

struct SalmonRotationListView_Previews: PreviewProvider {
  static var previews: some View {
    SalmonRotationListView()
  }
}
