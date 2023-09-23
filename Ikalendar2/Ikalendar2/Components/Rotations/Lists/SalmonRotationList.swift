//
//  SalmonRotationList.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

struct SalmonRotationList: View {
  @EnvironmentObject private var ikaCatalog: IkaCatalog
  @Environment(IkaTimePublisher.self) private var ikaTimePublisher

  private var validSalmonRotations: [SalmonRotation] {
    // filter: display current and future rotations only
    ikaCatalog.salmonRotations.filter { !$0.isExpired }
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
