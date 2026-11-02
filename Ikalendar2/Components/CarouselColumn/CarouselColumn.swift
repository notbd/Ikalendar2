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

  /// Fades rows out over the list's top `listFadeHeight` and leaves the rest opaque.
  private var fadeMask: some View {
    VStack(spacing: 0) {
      LinearGradient(
        colors: [.clear, .black],
        startPoint: .top,
        endPoint: .bottom)
        .frame(height: Scoped.listFadeHeight)

      Rectangle()
    }
  }

  @ViewBuilder
  private var rotationList: some View {
    switch gameMode {
      case .battle:
        BattleRotationList(battleMode: battleMode)
      case .salmon:
        SalmonRotationList()
    }
  }

  var body: some View {
    GeometryReader { geo in
      ZStack {
        VStack {
          Spacer()
            .frame(height: max(geo.size.height * listVOffsetFactor - Scoped.listFadeHeight, 0))

          // The list starts one fade height higher and insets its content and indicators by the
          // same amount, so at rest the first row sits below the fade, unfaded, where it would
          // be without it; only rows scrolled up pass through the fade.
          rotationList
            .contentMargins(.top, Scoped.listFadeHeight, for: .scrollContent)
            .mask(fadeMask)
            .contentMargins(.top, Scoped.scrollIndicatorMarginV + Scoped.listFadeHeight, for: .scrollIndicators)
            .contentMargins(.bottom, Scoped.scrollIndicatorMarginV, for: .scrollIndicators)
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
