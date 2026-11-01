//
//  ModeIconStampMathTests.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI
import Testing
@testable import Ikalendar2

// MARK: - ModeIconStampMathTests

/// Pins the stamp's tilt math: how each interface orientation remaps the device's gravity deltas
/// into screen axes, and how the 3D angle follows the length of the delta.
@Suite("ModeIconStamp math")
struct ModeIconStampMathTests {
  typealias Tilt = ModeIconStamp.Tilt

  /// The sample device-space tilt (dx 0.3, dy -0.2) remapped for `orientation`.
  private func screenTilt(_ orientation: UIInterfaceOrientation) -> Tilt {
    ModeIconStamp.screenTilt(dx: 0.3, dy: -0.2, orientation: orientation)
  }

  @Test
  func `Portrait and unknown pass the device tilt through unchanged`() {
    let deviceTilt: Tilt = .init(dx: 0.3, dy: -0.2)

    #expect(screenTilt(.portrait) == deviceTilt)
    #expect(screenTilt(.unknown) == deviceTilt)
  }

  @Test
  func `Upside down negates both axes`() {
    #expect(screenTilt(.portraitUpsideDown) == Tilt(dx: -0.3, dy: 0.2))
  }

  @Test
  func `Landscape left turns the tilt a quarter turn`() {
    #expect(screenTilt(.landscapeLeft) == Tilt(dx: -0.2, dy: -0.3))
  }

  @Test
  func `Landscape right is the mirror of landscape left`() {
    let left: Tilt = screenTilt(.landscapeLeft)

    #expect(screenTilt(.landscapeRight) == Tilt(dx: 0.2, dy: 0.3))
    #expect(screenTilt(.landscapeRight) == Tilt(dx: -left.dx, dy: -left.dy))
  }

  @Test(arguments: [
    UIInterfaceOrientation.unknown,
    .portrait,
    .portraitUpsideDown,
    .landscapeLeft,
    .landscapeRight,
  ])
  func `Every orientation preserves the tilt magnitude`(orientation: UIInterfaceOrientation) {
    let tilt: Tilt = screenTilt(orientation)

    #expect(abs(hypot(tilt.dx, tilt.dy) - hypot(0.3, -0.2)) < 1e-9)
  }

  @Test
  func `Rotation angle is zero at rest and scales linearly`() {
    #expect(ModeIconStamp.rotationAngle(for: Tilt(dx: 0, dy: 0)) == 0)
    // A delta of length 0.5 at 24 degrees per unit.
    #expect(abs(ModeIconStamp.rotationAngle(for: Tilt(dx: 0.3, dy: 0.4)) - 12) < 1e-9)
  }
}
