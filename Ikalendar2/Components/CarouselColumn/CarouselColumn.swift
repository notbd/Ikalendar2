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

  /// How far the fade has grown in: 0 with the list at rest, 1 once it has scrolled up
  /// `maskFadeInTravel`. Clamped in the transform, so further scrolling updates nothing.
  @State private var maskFadeIn: Double = 0

  /// The list fades in over a thin top band (1 / (density - 1) of its height) and is opaque
  /// below. The band only fades as far as the list has scrolled, so rows at rest are never dimmed.
  private var maskGradient: Gradient {
    .init(stops: [
      .init(color: .black.opacity(1 - maskFadeIn), location: 0),
      .init(color: .black, location: 1 / CGFloat(maskGradientDensity - 1)),
    ])
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
            .frame(height: geo.size.height * listVOffsetFactor)

          rotationList
            .onScrollGeometryChange(for: Double.self) { geometry in
              let travel: CGFloat = geometry.contentOffset.y + geometry.contentInsets.top
              return min(max(Double(travel / Scoped.maskFadeInTravel), 0), 1)
            } action: { _, fadeIn in
              maskFadeIn = fadeIn
            }
            .mask(
              LinearGradient(
                gradient: maskGradient,
                startPoint: .top,
                endPoint: .bottom))
            .contentMargins(
              .vertical, Scoped.scrollIndicatorMarginV,
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
