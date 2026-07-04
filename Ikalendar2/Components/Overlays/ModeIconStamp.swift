//
//  ModeIconStamp.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - ModeIconStamp

/// A mode icon overlay of the RotationsView.
struct ModeIconStamp: View {
  typealias Scoped = Constants.Style.Overlay.ModeIcon

  @Environment(IkaStatus.self) private var ikaStatus
  @Environment(IkaDeviceMotionMonitor.self) private var ikaDeviceMotionMonitor
  @Environment(IkaOrientationMonitor.self) private var ikaOrientationMonitor

  let iconSize: CGFloat
  let gameModeSelection: GameMode
  let battleModeSelection: BattleMode
  let shouldOffset: Bool
  let shouldAnimate: Bool

  private var dx: CGFloat { ikaDeviceMotionMonitor.dx }
  private var dy: CGFloat { ikaDeviceMotionMonitor.dy }
  private var rotationConstant: Double { Double((pow(dx, 2) + pow(dy, 2)).squareRoot()) }
  private var intensity: Double = Scoped.rotation3dIntensity

  private var axisRotationWeight: (x: CGFloat, y: CGFloat) {
    switch ikaOrientationMonitor.currentOrientation {
      case .unknown:
        (dy, dx)
      case .portrait:
        (dy, dx)
      case .portraitUpsideDown:
        (-dy, -dx)
      case .landscapeLeft:
        (-dx, dy)
      case .landscapeRight:
        (dx, -dy)
      @unknown default:
        (dy, dx)
    }
  }

  var body: some View {
    icon
      .rotationEffect(.degrees(Scoped.rotation2dDegrees))
      .if(shouldAnimate) {
        $0
          .rotation3DEffect(
            .degrees(rotationConstant * intensity),
            axis: (
              x: axisRotationWeight.x,
              y: axisRotationWeight.y,
              z: 0))
          .animation(
            .default,
            value: dx * dy)
      }
      .if(shouldOffset) {
        $0
          .offset(
            x: Scoped.iconOffsetX,
            y: Scoped.iconOffsetY)
      }
  }

  private var icon: some View {
    let imageName: String =
      switch gameModeSelection {
        case .battle:
          battleModeSelection.imageNameLarge
        case .salmon:
          Scoped.iconImageNameSalmon
      }

    return
      Image(imageName)
        .antialiased(true)
        .resizable()
        .scaledToFit()
        .mask(gradientMask)
        .frame(
          width: iconSize,
          height: iconSize)
  }

  private var gradientMask: some View {
    // mask color does not matter as long as it's not .clear; only opacity matters
    let maskColor: Color = .primary
    return LinearGradient(
      gradient: Gradient(colors: [
        maskColor.opacity(1),
        maskColor.opacity(0.95),
        maskColor.opacity(0.9),
        maskColor.opacity(0.85),
        maskColor.opacity(0.8),
        maskColor.opacity(0.7),
        maskColor.opacity(0.4),
        maskColor.opacity(0.2),
        maskColor.opacity(0.1),
        maskColor.opacity(0.05),
        maskColor.opacity(0),
      ]),
      startPoint: .top,
      endPoint: .bottom)
  }

  init(
    iconSize: CGFloat = Scoped.iconSize,
    gameModeSelection: GameMode,
    battleModeSelection: BattleMode,
    shouldOffset: Bool = false,
    shouldAnimate: Bool = true)
  {
    self.iconSize = iconSize
    self.gameModeSelection = gameModeSelection
    self.battleModeSelection = battleModeSelection
    self.shouldOffset = shouldOffset
    self.shouldAnimate = shouldAnimate
  }

  init(
    iconSize: CGFloat = Scoped.iconSize,
    flatModeSelection: FlatMode,
    shouldOffset: Bool = false,
    shouldAnimate: Bool = true)
  {
    self.iconSize = iconSize
    gameModeSelection = flatModeSelection == .salmon
      ? .salmon
      : .battle
    battleModeSelection = flatModeSelection == .salmon
      ? .default
      : BattleMode(rawValue: flatModeSelection.rawValue)!
    self.shouldOffset = shouldOffset
    self.shouldAnimate = shouldAnimate
  }
}

// MARK: - FlatModeIconStamp_Previews

struct FlatModeIconStamp_Previews: PreviewProvider {
  static var previews: some View {
    ModeIconStamp(
      gameModeSelection: .battle,
      battleModeSelection: .gachi)
  }
}
