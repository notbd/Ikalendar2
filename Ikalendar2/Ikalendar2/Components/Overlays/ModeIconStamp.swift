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
  @EnvironmentObject private var ikaMotionPublisher: IkaMotionPublisher

  private var x: CGFloat { ikaMotionPublisher.dx }
  private var y: CGFloat { ikaMotionPublisher.dy }
  private var rot: Double { Double((pow(x, 2) + pow(y, 2)).squareRoot()) }
  private var degrees: Double = 22

  var body: some View {
    icon
      .rotationEffect(.degrees(8))
      .rotation3DEffect(.degrees(degrees * rot), axis: (x: y, y: x, z: 0))
      .offset(x: -10, y: -90)
      .animation(
        .easeOut(duration: Constants.Style.Global.ANIMATION_DURATION),
        value: ikaMotionPublisher.dx * ikaMotionPublisher.dy)
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