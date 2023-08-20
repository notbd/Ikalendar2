//
//  IkaMotionPublisher.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import Combine
import CoreMotion
import SwiftUI

/// A CoreMotion publisher class to broadcast device motions.
final class IkaMotionPublisher: ObservableObject {

  /// The shared singleton instance
  static let shared = IkaMotionPublisher()

  private let motionManager = CMMotionManager()
  private var cancellables = Set<AnyCancellable>()

  private var xs: [CGFloat] = []
  private var ys: [CGFloat] = []
  private var zs: [CGFloat] = []

  var dx: CGFloat = 0
  var dy: CGFloat = 0
  var dz: CGFloat = 0

  // MARK: Lifecycle

  private init() {
    setupMotionUpdates()
    subscribeToAppLifecycleEvents()
  }

  // MARK: Internal

  func shutdown() {
    motionManager.stopDeviceMotionUpdates()
  }

  // MARK: Private

  private func setupMotionUpdates() {
    let cycle = 10.0
    let interval = 0.1
    var arrayCapacity: Int { Int(cycle / interval) }

    motionManager.deviceMotionUpdateInterval = interval

    motionManager.startDeviceMotionUpdates(to: .main) { [self] data, _ in
      guard let newData = data?.gravity else { return }

      // Make sure the arrays contain `cycle` seconds of data at most
      if xs.count > arrayCapacity { xs.removeFirst() }
      if ys.count > arrayCapacity { ys.removeFirst() }
      if zs.count > arrayCapacity { zs.removeFirst() }

      xs.append(CGFloat(newData.x))
      ys.append(CGFloat(newData.y))
      zs.append(CGFloat(newData.z))

      // Calculate the difference between current value and array average
      dx = CGFloat(newData.x) - xs.reduce(0, +) / CGFloat(xs.count)
      dy = CGFloat(newData.y) - ys.reduce(0, +) / CGFloat(ys.count)
      dz = CGFloat(newData.z) - zs.reduce(0, +) / CGFloat(zs.count)

      // Send change
      objectWillChange.send()
    }
  }

  private func subscribeToAppLifecycleEvents() {
    let notificationCenter = NotificationCenter.default

    notificationCenter.publisher(for: UIScene.didActivateNotification)
      .sink { [weak self] _ in
        self?.startMotionUpdates()
      }
      .store(in: &cancellables)

    notificationCenter.publisher(for: UIScene.willDeactivateNotification)
      .sink { [weak self] _ in
        self?.stopMotionUpdates()
      }
      .store(in: &cancellables)
  }

  private func startMotionUpdates() {
    if !motionManager.isDeviceMotionActive {
      setupMotionUpdates()
    }
  }

  private func stopMotionUpdates() {
    if motionManager.isDeviceMotionActive {
      motionManager.stopDeviceMotionUpdates()
    }
  }

}
