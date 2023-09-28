//
//  SalmonRotationList.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

@MainActor
struct SalmonRotationList: View {
  @Environment(IkaCatalog.self) private var ikaCatalog
  @EnvironmentObject private var ikaTimePublisher: IkaTimePublisher

  private var validSalmonRotations: [SalmonRotation] {
    // filter: display current and future rotations only
    ikaCatalog.salmonRotations.filter { !$0.isExpired(ikaTimePublisher.currentTime) }
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
