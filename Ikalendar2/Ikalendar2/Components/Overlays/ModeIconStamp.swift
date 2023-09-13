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
  @EnvironmentObject private var ikaCatalog: IkaCatalog
  @EnvironmentObject private var ikaStatus: IkaStatus
  @EnvironmentObject private var ikaDeviceMotionPublisher: IkaDeviceMotionPublisher
  @EnvironmentObject private var ikaInterfaceOrientationPublisher: IkaInterfaceOrientationPublisher

  private var x: CGFloat { ikaDeviceMotionPublisher.dx }
  private var y: CGFloat { ikaDeviceMotionPublisher.dy }
  private var rotationConstant: Double { Double((pow(x, 2) + pow(y, 2)).squareRoot()) }
  private var intensity: Double = 26

  private var giveByAxis: (x: CGFloat, y: CGFloat) {
    switch ikaInterfaceOrientationPublisher.currentOrientation {
    case .unknown:
      return (y, x)
    case .portrait:
      return (y, x)
    case .portraitUpsideDown:
      return (-y, -x)
    case .landscapeLeft:
      return (-x, y)
    case .landscapeRight:
      return (x, -y)
    @unknown default:
      return (y, x)
    }
  }

  var body: some View {
    icon
      .rotationEffect(.degrees(8))
      .rotation3DEffect(
        .degrees(rotationConstant * intensity),
        axis: (
          x: giveByAxis.x,
          y: giveByAxis.y,
          z: 0))
      .offset(x: -10, y: -90)
      .animation(
        .linear,
        value: x * y)
      .animation(
        .easeOut,
        value: ikaStatus.battleModeSelection)
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
    switch ikaStatus.gameModeSelection {
    case .battle:
      imgFiln = ikaStatus.battleModeSelection.imgFilnLarge
    case .salmon:
      imgFiln = "mr-grizz"
    }

    return
      Image(imgFiln)
        .antialiased(true)
        .resizable()
        .scaledToFit()
        .mask(gradientMask)
        .frame(width: 128, height: 128)
  }
}

// MARK: - FlatModeIconStamp_Previews

struct FlatModeIconStamp_Previews: PreviewProvider {
  static var previews: some View {
    ModeIconStamp()
  }
}
