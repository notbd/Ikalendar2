//
//  IkaDeviceMotionPublisher.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Combine
import CoreMotion
import UIKit

/// `IkaDeviceMotionPublisher` is responsible for broadcasting device motion updates.
/// It captures the gravitational force changes on x, y, and z axes and computes the difference between the
/// current value
/// and the average of the recently stored values over a specified duration.
@Observable
final class IkaDeviceMotionPublisher {
  /// The shared singleton instance
  static let shared: IkaDeviceMotionPublisher = .init()

  /// An instance of `CMMotionManager` to access motion data.
  @ObservationIgnored private let motionManager: CMMotionManager = .init()
  /// Contains all active subscriptions, primarily for lifecycle management.
  @ObservationIgnored private var cancellables: Set<AnyCancellable> = .init()

  /// Arrays storing the x, y, and z gravitational force components over a duration.
  @ObservationIgnored private var xs: [CGFloat] = []
  @ObservationIgnored private var ys: [CGFloat] = []
  @ObservationIgnored private var zs: [CGFloat] = []

  /// The difference between the current gravitational force component and its average
  /// of recently stored values for x, y, and z axes.
  var dx: CGFloat = 0
  var dy: CGFloat = 0
  var dz: CGFloat = 0

  private init() {
    subscribeToAppLifecycleEvents()
  }

  /// Subscribes to application lifecycle events to start or stop motion updates appropriately.
  private func subscribeToAppLifecycleEvents() {
    let notificationCenter: NotificationCenter = .default

    notificationCenter.publisher(for: UIScene.didActivateNotification)
      .sink { [weak self] _ in
        self?.setupMotionUpdates()
      }
      .store(in: &cancellables)

    notificationCenter.publisher(for: UIScene.willDeactivateNotification)
      .sink { [weak self] _ in
        self?.shutdownMotionUpdates()
      }
      .store(in: &cancellables)
  }

  /// Configures and begins capturing device motion data.
  /// Processes the gravitational data to compute the difference between the current and average force
  /// components over a specific duration.
  private func setupMotionUpdates() {
    let cycle = 10.0
    let interval = 0.1
    var arrayCapacity: Int { Int(cycle / interval) }

    motionManager.deviceMotionUpdateInterval = interval

    motionManager.startDeviceMotionUpdates(to: .main) { [self] data, _ in
      guard let newData = data?.gravity else { return }

      // Make sure the arrays contain `cycle` seconds of data at most
      appendData(CGFloat(newData.x), to: &xs, maxCapacity: arrayCapacity)
      appendData(CGFloat(newData.y), to: &ys, maxCapacity: arrayCapacity)
      appendData(CGFloat(newData.z), to: &zs, maxCapacity: arrayCapacity)

      // Calculate the difference between current value and array average
      dx = CGFloat(newData.x) - xs.reduce(0, +) / CGFloat(xs.count)
      dy = CGFloat(newData.y) - ys.reduce(0, +) / CGFloat(ys.count)
      dz = CGFloat(newData.z) - zs.reduce(0, +) / CGFloat(zs.count)
    }
  }

  /// Stops any ongoing motion updates.
  private func shutdownMotionUpdates() {
    motionManager.stopDeviceMotionUpdates()
  }

  /// Appends a value to the provided array ensuring the array's size doesn't exceed the specified capacity.
  /// - Parameters:
  ///   - value: The value to append.
  ///   - array: The array to append the value to.
  ///   - maxCapacity: The maximum number of elements the array should hold.
  private func appendData(
    _ value: CGFloat,
    to array: inout [CGFloat],
    maxCapacity: Int)
  {
    if array.count > maxCapacity { array.removeFirst() }
    array.append(value)
  }
}
