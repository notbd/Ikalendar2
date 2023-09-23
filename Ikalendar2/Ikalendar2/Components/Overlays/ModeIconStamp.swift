//
//  ModeIconStamp.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - ModeIconStamp

/// A mode icon overlay of the RotationsView.
struct ModeIconStamp: View {
  typealias Scoped = Constants.Style.Overlay.ModeIcon

  @EnvironmentObject private var ikaStatus: IkaStatus
  @EnvironmentObject private var ikaDeviceMotionPublisher: IkaDeviceMotionPublisher
  @EnvironmentObject private var ikaInterfaceOrientationPublisher: IkaInterfaceOrientationPublisher

  let iconSize: CGFloat
  let gameModeSelection: GameMode
  let battleModeSelection: BattleMode
  let ifOffset: Bool
  let ifAnimated: Bool

  private var dx: CGFloat { ikaDeviceMotionPublisher.dx }
  private var dy: CGFloat { ikaDeviceMotionPublisher.dy }
  private var rotationConstant: Double { Double((pow(dx, 2) + pow(dy, 2)).squareRoot()) }
  private var intensity: Double = Scoped.ROTATION_3D_INTENSITY

  private var axisRotationWeight: (x: CGFloat, y: CGFloat) {
    switch ikaInterfaceOrientationPublisher.currentOrientation {
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
      .rotationEffect(.degrees(Scoped.ROTATION_2D_DEGREES))
      .if(ifAnimated) {
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
      .if(ifOffset) {
        $0
          .offset(
            x: Scoped.ICON_OFFSET_X,
            y: Scoped.ICON_OFFSET_Y)
      }
  }

  private var icon: some View {
    let imgFiln: String = switch gameModeSelection {
    case .battle:
      battleModeSelection.imgFilnLarge
    case .salmon:
      Scoped.ICON_IMG_FILN_SALMON
    }

    return
      Image(imgFiln)
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
    let maskColor = Color.primary
    return LinearGradient(
      gradient: Gradient(colors: [
        maskColor.opacity(1),
        maskColor.opacity(0.95),
        maskColor.opacity(0.9),
        maskColor.opacity(0.85),
        maskColor.opacity(0.8),
        maskColor.opacity(0.6),
        maskColor.opacity(0.5),
        maskColor.opacity(0.2),
        maskColor.opacity(0.08),
        maskColor.opacity(0.02),
        maskColor.opacity(0),
      ]),
      startPoint: .top,
      endPoint: .bottom)
  }

  // MARK: Lifecycle

  init(
    iconSize: CGFloat = Scoped.ICON_SIZE,
    gameModeSelection: GameMode,
    battleModeSelection: BattleMode,
    ifOffset: Bool = false,
    ifAnimated: Bool = true)
  {
    self.iconSize = iconSize
    self.gameModeSelection = gameModeSelection
    self.battleModeSelection = battleModeSelection
    self.ifOffset = ifOffset
    self.ifAnimated = ifAnimated
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
