//
//  IkaInterfaceOrientationPublisher.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Combine
import UIKit

// MARK: - IkaInterfaceOrientationPublisher

/// An ObservableObject that publishes changes to the device's interface orientation.
@Observable
final class IkaInterfaceOrientationPublisher {
  static let shared: IkaInterfaceOrientationPublisher = .init()

  /// The current orientation of the interface.
  var currentOrientation: UIInterfaceOrientation

  /// Private initializer.
  private init() {
    UIDevice.current.beginGeneratingDeviceOrientationNotifications()

    // window is not available yet at init
    currentOrientation = .unknown

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(orientationChanged(_:)),
      name: UIDevice.orientationDidChangeNotification,
      object: nil)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
    UIDevice.current.endGeneratingDeviceOrientationNotifications()
  }

  /// Should be called once the first active scene appears.
  func setInitialOrientation() {
    guard currentOrientation == .unknown else { return }

    updateCurrentOrientation()
  }

  /// Triggered when the device reports an orientation change.
  @objc
  private func orientationChanged(_: Notification) {
    DispatchQueue.main.async {
      self.updateCurrentOrientation()
    }
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
