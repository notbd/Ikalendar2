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

  @Environment(IkaDeviceMotionMonitor.self) private var ikaDeviceMotionMonitor
  @Environment(IkaOrientationMonitor.self) private var ikaOrientationMonitor

  let iconSize: CGFloat
  let gameModeSelection: GameMode
  let battleModeSelection: BattleMode
  let shouldAnimate: Bool

  private var tilt: Tilt {
    Self.screenTilt(
      dx: ikaDeviceMotionMonitor.dx,
      dy: ikaDeviceMotionMonitor.dy,
      orientation: ikaOrientationMonitor.currentOrientation)
  }

  var body: some View {
    icon
      .rotationEffect(.degrees(Scoped.rotation2dDegrees))
      // Applied at 0 degrees rather than dropped when not animating, so the view keeps its identity.
      .rotation3DEffect(
        .degrees(shouldAnimate ? Self.rotationAngle(for: tilt) : 0),
        axis: (
          x: tilt.dy,
          y: tilt.dx,
          z: 0))
      .animation(
        .default,
        value: tilt)
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
      Image(decorative: imageName)
        .ikaFitted()
        .mask(gradientMask)
        .frame(
          width: iconSize,
          height: iconSize)
  }

  /// Built once because `body` re-runs with every motion update.
  /// The mask color does not matter as long as it's not .clear; only opacity matters.
  static private let maskGradient: Gradient = .init(colors: [
    Color.primary.opacity(1),
    Color.primary.opacity(0.95),
    Color.primary.opacity(0.9),
    Color.primary.opacity(0.85),
    Color.primary.opacity(0.8),
    Color.primary.opacity(0.7),
    Color.primary.opacity(0.4),
    Color.primary.opacity(0.2),
    Color.primary.opacity(0.1),
    Color.primary.opacity(0.05),
    Color.primary.opacity(0),
  ])

  private var gradientMask: some View {
    LinearGradient(
      gradient: Self.maskGradient,
      startPoint: .top,
      endPoint: .bottom)
  }

  init(
    iconSize: CGFloat = Scoped.iconSize,
    gameModeSelection: GameMode,
    battleModeSelection: BattleMode,
    shouldAnimate: Bool = true)
  {
    self.iconSize = iconSize
    self.gameModeSelection = gameModeSelection
    self.battleModeSelection = battleModeSelection
    self.shouldAnimate = shouldAnimate
  }

  init(
    iconSize: CGFloat = Scoped.iconSize,
    flatModeSelection: FlatMode,
    shouldAnimate: Bool = true)
  {
    self.iconSize = iconSize
    gameModeSelection = flatModeSelection.gameMode
    battleModeSelection = flatModeSelection.battleMode ?? .default
    self.shouldAnimate = shouldAnimate
  }
}

// MARK: - Tilt math

extension ModeIconStamp {
  /// A gravity delta in the interface's axes: `dx` toward the screen's right edge, `dy` toward its top.
  struct Tilt: Equatable {
    var dx: CGFloat
    var dy: CGFloat
  }

  /// Remaps the device-space gravity deltas into the interface's axes for `orientation`, so the
  /// stamp tilts with the physical device. Every mapping is a quarter-turn rotation or a flip, so
  /// the magnitude is unchanged.
  nonisolated static func screenTilt(
    dx: CGFloat,
    dy: CGFloat,
    orientation: UIInterfaceOrientation)
    -> Tilt
  {
    switch orientation {
      case .unknown:
        .init(dx: dx, dy: dy)
      case .portrait:
        .init(dx: dx, dy: dy)
      case .portraitUpsideDown:
        .init(dx: -dx, dy: -dy)
      case .landscapeLeft:
        .init(dx: dy, dy: -dx)
      case .landscapeRight:
        .init(dx: -dy, dy: dx)
      @unknown default:
        .init(dx: dx, dy: dy)
    }
  }

  /// The 3D tilt in degrees: proportional to the length of the gravity delta.
  nonisolated static func rotationAngle(for tilt: Tilt) -> Double {
    Double(hypot(tilt.dx, tilt.dy)) * Scoped.rotation3dIntensity
  }
}

#Preview {
  ModeIconStamp(
    gameModeSelection: .battle,
    battleModeSelection: .gachi)
    .ikaPreviewEnvironment()
}
