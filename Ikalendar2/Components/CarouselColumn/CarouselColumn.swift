//
//  CarouselColumn.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - CarouselColumn

/// One mode's rotation list inside the iPad carousel, stamped with its mode icon.
struct CarouselColumn: View {
  typealias Scoped = Constants.Style.Carousel.Column

  @Environment(IkaOrientationMonitor.self) private var ikaOrientationMonitor
  private var isPortrait: Bool { ikaOrientationMonitor.currentOrientation.isPortrait }

  let gameMode: GameMode
  let battleMode: BattleMode

  private var listVOffsetFactor: CGFloat {
    isPortrait
      ? Scoped.listOffsetVFactorPortrait
      : Scoped.listOffsetVFactorLandscape }

  private var modeIconSizeFactor: CGFloat { listVOffsetFactor * Scoped.modeIconSizeFactor }

  private var maskGradientDensity: Int {
    isPortrait
      ? Scoped.maskGradientDensityPortrait
      : Scoped.maskGradientDensityLandscape }

  private var maskGradient: Gradient {
    .init(
      colors:
      (0 ..< maskGradientDensity)
        .map { $0 == 0
          ? Color.primary.opacity(0)
          : Color.primary }) }

  @ViewBuilder
  private var rotationList: some View {
    switch gameMode {
      case .battle:
        BattleRotationList(specifiedBattleMode: battleMode)
      default:
        SalmonRotationList()
    }
  }

  var body: some View {
    GeometryReader { geo in
      ZStack {
        VStack {
          Spacer()
            .frame(height: geo.size.height * listVOffsetFactor)

          rotationList
            .mask(
              LinearGradient(
                gradient: maskGradient,
                startPoint: .top,
                endPoint: .bottom))
            .contentMargins(
              .vertical, 20,
              for: .scrollIndicators)
        }

        ModeIconStamp(
          iconSize: geo.size.height * modeIconSizeFactor,
          gameModeSelection: gameMode,
          battleModeSelection: battleMode)
          .vAlignment(.top)
          .hAlignment(.center)
      }
    }
  }

  init(
    gameMode: GameMode,
    battleMode: BattleMode = .gachi)
  {
    self.gameMode = gameMode
    self.battleMode = battleMode
  }
}

#Preview(traits: .landscapeLeft) {
  // One iPad carousel column; landscape mirrors its real habitat.
  CarouselColumn(gameMode: .battle, battleMode: .gachi)
    .ikaPreviewEnvironment()
}
