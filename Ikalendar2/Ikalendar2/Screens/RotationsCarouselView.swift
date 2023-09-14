//
//  RotationsCarouselView.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - RotationsCarouselView

struct RotationsCarouselView: View {

  var body: some View {
    ScrollView(.horizontal) {
      HStack {
        ForEach(BattleMode.allCases) { battleMode in
          CarouselBattleColumn(battleMode: battleMode)
            .frame(width: 375)
          Spacer()
        }

        CarouselSalmonColumn()
          .frame(width: 375)
      }
    }
    .navigationTitle(Constants.Key.BundleInfo.APP_DISPLAY_NAME)
  }
}

// MARK: - CarouselBattleColumn

struct CarouselBattleColumn: View {
  @EnvironmentObject private var ikaCatalog: IkaCatalog
  @EnvironmentObject private var ikaTimePublisher: IkaTimePublisher

  let battleMode: BattleMode

  private var battleRotations: [BattleRotation] {
    ikaCatalog.battleRotationDict[battleMode]!.filter { !$0.isExpired() }
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
      .animation(
        .spring(
          response: 0.6,
          dampingFraction: 0.8),
        value: battleRotations.map { $0.startTime })
      .disabled(ikaCatalog.loadStatus != .loaded)
    }
  }
}

// MARK: - CarouselSalmonColumn

struct CarouselSalmonColumn: View {
  @EnvironmentObject private var ikaCatalog: IkaCatalog
  @EnvironmentObject private var ikaTimePublisher: IkaTimePublisher

  private var salmonRotations: [SalmonRotation] {
    ikaCatalog.salmonRotations.filter { !$0.isExpired() }
  }

  var body: some View {
    GeometryReader { geo in
      List {
        ForEach(
          Array(zip(salmonRotations.indices, salmonRotations)),
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
        .spring(
          response: 0.6,
          dampingFraction: 0.8),
        value: salmonRotations)
      .disabled(ikaCatalog.loadStatus != .loaded)
    }
  }
}

// MARK: - RotationsCarouselView_Previews

struct RotationsCarouselView_Previews: PreviewProvider {
  static var previews: some View {
    RotationsCarouselView()
  }
}
