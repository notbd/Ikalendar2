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
  /// 0 = at rest, 1 = docked into the nav bar badge (iPhone only; the iPad carousel stays at 0).
  let dockProgress: Double

  private var tilt: Tilt {
    Self.screenTilt(
      dx: ikaDeviceMotionMonitor.dx,
      dy: ikaDeviceMotionMonitor.dy,
      orientation: ikaOrientationMonitor.currentOrientation)
  }

  var body: some View {
    let style: DockStyle = Self.dockStyle(progress: dockProgress)

    icon
      .rotationEffect(.degrees(Scoped.rotation2dDegrees * style.parallaxGain))
      // Applied at 0 degrees rather than dropped when not animating, so the view keeps its identity.
      .rotation3DEffect(
        .degrees(shouldAnimate ? Self.rotationAngle(for: tilt) * style.parallaxGain : 0),
        axis: (
          x: tilt.dy,
          y: tilt.dx,
          z: 0))
      .animation(
        .default,
        value: tilt)
      // After the tilt animation, so docking follows the scroll without easing.
      .scaleEffect(style.scale, anchor: .topTrailing)
      .opacity(style.opacity)
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
    shouldAnimate: Bool = true,
    dockProgress: Double = 0)
  {
    self.iconSize = iconSize
    self.gameModeSelection = gameModeSelection
    self.battleModeSelection = battleModeSelection
    self.shouldAnimate = shouldAnimate
    self.dockProgress = dockProgress
  }

  init(
    iconSize: CGFloat = Scoped.iconSize,
    flatModeSelection: FlatMode,
    shouldAnimate: Bool = true,
    dockProgress: Double = 0)
  {
    self.iconSize = iconSize
    gameModeSelection = flatModeSelection.gameMode
    battleModeSelection = flatModeSelection.battleMode ?? .default
    self.shouldAnimate = shouldAnimate
    self.dockProgress = dockProgress
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
  /// stamp tilts with the physical device. Each mapping only swaps and negates the axes, so the
  /// magnitude is unchanged.
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

// MARK: - Dock math

extension ModeIconStamp {
  /// How the stamp looks at a dock progress: `parallaxGain` scales both the 2D and the 3D tilt.
  struct DockStyle: Equatable {
    var scale: Double
    var opacity: Double
    var parallaxGain: Double
  }

  /// The share of `dockTravel` scrolled, clamped to 0...1. Pulling to refresh (negative travel)
  /// leaves the stamp at rest.
  nonisolated static func dockProgress(
    travel: CGFloat,
    dockTravel: CGFloat = Scoped.dockTravel)
    -> Double
  {
    guard dockTravel > 0 else { return 1 }

    return min(max(Double(travel / dockTravel), 0), 1)
  }

  /// The dock progress for a content offset, with the travel measured from where the list rests
  /// under the expanded large title (`restingTopInset`) rather than from the current inset. The
  /// inset shrinks by the title height as the title collapses, and stays shrunk when rows above
  /// the viewport are removed while scrolled (a rotation rolling off): the list then sits at its
  /// new top under a collapsed bar, which the current inset reads as no travel at all.
  nonisolated static func dockProgress(
    contentOffsetY: CGFloat,
    restingTopInset: CGFloat,
    dockTravel: CGFloat = Scoped.dockTravel)
    -> Double
  {
    dockProgress(travel: contentOffsetY + restingTopInset, dockTravel: dockTravel)
  }

  /// The stamp shrinks toward its top-trailing corner, is gone by `dockFadeOutEnd`, and stops
  /// tilting once docked.
  nonisolated static func dockStyle(progress: Double) -> DockStyle {
    .init(
      scale: 1 - (1 - Scoped.dockedScale) * progress,
      opacity: 1 - min(progress / Scoped.dockFadeOutEnd, 1),
      parallaxGain: 1 - progress)
  }

  /// The badge fades in from `badgeFadeInStart`, before the stamp has faded out, so the two
  /// overlap and the mode never disappears.
  nonisolated static func badgeOpacity(progress: Double) -> Double {
    max(0, (progress - Scoped.badgeFadeInStart) / (1 - Scoped.badgeFadeInStart))
  }
}

#Preview {
  ModeIconStamp(
    gameModeSelection: .battle,
    battleModeSelection: .gachi)
    .ikaPreviewEnvironment()
}
