//
//  IkaInterfaceOrientationPublisher.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import Combine
import UIKit

// MARK: - IkaInterfaceOrientationPublisher

/// An ObservableObject to monitor changes in the device's interface orientation.
///
@Observable
final class IkaInterfaceOrientationPublisher {

  static let shared: IkaInterfaceOrientationPublisher = .init()

  /// The current orientation of the device.
  var currentOrientation: UIInterfaceOrientation

  // MARK: Lifecycle

  /// Private initializer.
  private init() {
    UIDevice.current.beginGeneratingDeviceOrientationNotifications()

    // Cannot read initial orientation here because window is not ready yet.
    // Needs to call setInitialOrientation() once RootView appears.
    currentOrientation = UIInterfaceOrientation.unknown

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(orientationChanged),
      name: UIDevice.orientationDidChangeNotification,
      object: nil)
  }

  /// Removes the observer and stops generating orientation notifications.
  deinit {
    NotificationCenter.default.removeObserver(self)
    UIDevice.current.endGeneratingDeviceOrientationNotifications()
  }

  // MARK: Internal

  /// Sets the initial orientation, typically called when the RootView appears.
  func setInitialOrientation() {
    guard currentOrientation == .unknown else { return }
    updateCurrentOrientation()
  }

  // MARK: Private

  /// Handles the device orientation change event.
  @objc
  private func orientationChanged(_: Notification) {
    updateCurrentOrientation()
  }

  /// Updates the `currentOrientation` property with the current window's orientation.
  private func updateCurrentOrientation() {
    guard
      let windowScene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first,
      let currentWindowInterfaceOrientation = windowScene.windows.first?.windowScene?.interfaceOrientation
    else { return }
    currentOrientation = currentWindowInterfaceOrientation
  }
}

extension UIInterfaceOrientation {
  /// A textual representation of `UIInterfaceOrientation`.
  var description: String {
    switch self {
    case .unknown:
      "Unknown"
    case .portrait:
      "Portrait"
    case .portraitUpsideDown:
      "PortraitUpsideDown"
    case .landscapeLeft:
      "LandscapeLeft"
    case .landscapeRight:
      "LandscapeRight"
    @unknown default:
      "Unknown"
    }
  }
}
