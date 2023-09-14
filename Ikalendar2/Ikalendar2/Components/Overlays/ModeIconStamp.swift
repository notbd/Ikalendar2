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

  let gameModeSelection: GameMode
  let battleModeSelection: BattleMode
  let ifOffset: Bool

  private var dx: CGFloat { ikaDeviceMotionPublisher.dx }
  private var dy: CGFloat { ikaDeviceMotionPublisher.dy }
  private var rotationConstant: Double { Double((pow(dx, 2) + pow(dy, 2)).squareRoot()) }
  private var intensity: Double = Scoped.ROTATION_3D_INTENSITY

  private var axisRotationWeight: (x: CGFloat, y: CGFloat) {
    switch ikaInterfaceOrientationPublisher.currentOrientation {
    case .unknown:
      return (dy, dx)
    case .portrait:
      return (dy, dx)
    case .portraitUpsideDown:
      return (-dy, -dx)
    case .landscapeLeft:
      return (-dx, dy)
    case .landscapeRight:
      return (dx, -dy)
    @unknown default:
      return (dy, dx)
    }
  }

  var body: some View {
    icon
      .rotationEffect(.degrees(Scoped.ROTATION_2D_DEGREES))
      .rotation3DEffect(
        .degrees(rotationConstant * intensity),
        axis: (
          x: axisRotationWeight.x,
          y: axisRotationWeight.y,
          z: 0))
      .if(ifOffset) {
        $0
          .offset(
            x: Scoped.ICON_OFFSET_X,
            y: Scoped.ICON_OFFSET_Y)
      }
      .animation(
        .linear,
        value: dx * dy)
  }

  private var gradientMask: some View {
    // mask color does not matter; only opacity matters
    let maskColor = Color(UIColor.systemBackground)
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

  private var icon: some View {
    let imgFiln: String
    switch gameModeSelection {
    case .battle:
      imgFiln = battleModeSelection.imgFilnLarge
    case .salmon:
      imgFiln = Scoped.ICON_IMG_FILN_SALMON
    }

    return
      Image(imgFiln)
        .antialiased(true)
        .resizable()
        .scaledToFit()
        .mask(gradientMask)
        .frame(
          width: Scoped.ICON_SIZE,
          height: Scoped.ICON_SIZE)
  }

  // MARK: Lifecycle

  init(
    gameModeSelection: GameMode,
    battleModeSelection: BattleMode,
    ifOffset: Bool = false)
  {
    self.gameModeSelection = gameModeSelection
    self.battleModeSelection = battleModeSelection
    self.ifOffset = ifOffset
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
