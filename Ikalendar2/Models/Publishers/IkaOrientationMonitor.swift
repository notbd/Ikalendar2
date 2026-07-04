//
//  IkaOrientationMonitor.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import UIKit

// MARK: - IkaOrientationMonitor

/// An observable monitor that publishes changes to the device's interface orientation.
/// App-lifetime object: its notification observation lives for the process duration.
@MainActor
@Observable
final class IkaOrientationMonitor {
  /// The current orientation of the interface.
  var currentOrientation: UIInterfaceOrientation

  init() {
    UIDevice.current.beginGeneratingDeviceOrientationNotifications()

    // window is not available yet at init
    currentOrientation = .unknown

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(orientationChanged(_:)),
      name: UIDevice.orientationDidChangeNotification,
      object: nil)
  }

  /// Should be called once the first active scene appears.
  func setInitialOrientation() {
    guard currentOrientation == .unknown else { return }

    updateCurrentOrientation()
  }

  /// Triggered when the device reports an orientation change.
  @objc
  private func orientationChanged(_: Notification) {
    // Defer the read to the next main-actor turn: when this notification fires,
    // the window scene's `effectiveGeometry` has not been updated yet.
    // Synchronous reads observe the STALE orientation (iPadOS lag, fixed in 00fe4e4).
    Task { self.updateCurrentOrientation() }
  }

  /// Updates the `currentOrientation` property according to the active window scene's orientation.
  private func updateCurrentOrientation() {
    guard
      let windowScene = UIApplication.shared
        .connectedScenes
        .compactMap({ $0 as? UIWindowScene })
        .first,
      let interfaceOrientation = windowScene.windows.first?.windowScene?
        .effectiveGeometry.interfaceOrientation
    else { return }

    currentOrientation = interfaceOrientation
  }
}

// MARK: - UIInterfaceOrientation+Description

extension UIInterfaceOrientation {
  /// Readable textual description of the orientation.
  var description: String {
    switch self {
      case .unknown: "Unknown"
      case .portrait: "Portrait"
      case .portraitUpsideDown: "PortraitUpsideDown"
      case .landscapeLeft: "LandscapeLeft"
      case .landscapeRight: "LandscapeRight"
      @unknown default: "Unknown"
    }
  }
}
