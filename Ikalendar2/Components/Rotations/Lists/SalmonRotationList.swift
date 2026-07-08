//
//  SalmonRotationList.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

/// The salmon rotation list: the open/soonest shift first, later ones below.
struct SalmonRotationList: View {
  @Environment(IkaCatalog.self) private var ikaCatalog
  @Environment(IkaClock.self) private var ikaClock

  private var validSalmonRotations: [SalmonRotation] {
    // filter: display current and future rotations only
    ikaCatalog.salmonRotations.filter { !$0.isExpired(ikaClock.currentTime) }
  }

  var body: some View {
    GeometryReader { geo in
      List {
        ForEach(
          Array(zip(validSalmonRotations.indices, validSalmonRotations)),
          id: \.1)
        { index, rotation in
          SalmonRotationRow(
            rotation: rotation,
            index: index,
            rowWidth: geo.size.width)
            .listRowSeparator(.hidden)
        }
      }
      .listStyle(.insetGrouped)
      .animation(
        .bouncy,
        value: validSalmonRotations)
      .disabled(ikaCatalog.loadStatus != .loaded)
    }
  }
}

#Preview {
  SalmonRotationList()
    .ikaPreviewEnvironment()
}
