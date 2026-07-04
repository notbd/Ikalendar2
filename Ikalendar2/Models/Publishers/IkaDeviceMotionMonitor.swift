//
//  IkaDeviceMotionMonitor.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import CoreMotion
import UIKit

/// `IkaDeviceMotionMonitor` is an observable monitor broadcasting device motion updates.
/// It captures the gravitational force changes on x, y, and z axes and computes the difference
/// between the current value and the average of the recently stored values over a specified duration.
/// App-lifetime object: its scene-lifecycle observation lives for the process duration.
@MainActor
@Observable
final class IkaDeviceMotionMonitor {
  /// An instance of `CMMotionManager` to access motion data.
  @ObservationIgnored private let motionManager: CMMotionManager = .init()

  /// Long-running observation loops for scene activation/deactivation.
  @ObservationIgnored private var sceneActivationTask: Task<Void, Never>?
  @ObservationIgnored private var sceneDeactivationTask: Task<Void, Never>?

  /// Arrays storing the x, y, and z gravitational force components over a duration.
  @ObservationIgnored private var xs: [CGFloat] = []
  @ObservationIgnored private var ys: [CGFloat] = []
  @ObservationIgnored private var zs: [CGFloat] = []

  /// The difference between the current gravitational force component and its average
  /// of recently stored values for x, y, and z axes.
  var dx: CGFloat = 0
  var dy: CGFloat = 0
  var dz: CGFloat = 0

  init() {
    subscribeToAppLifecycleEvents()
  }

  deinit {
    // Legal in a nonisolated deinit: Task is Sendable and cancel() is nonisolated.
    sceneActivationTask?.cancel()
    sceneDeactivationTask?.cancel()
  }

  /// Subscribes to application lifecycle events to start or stop motion updates appropriately.
  /// [weak self] with per-iteration re-acquire keeps preview/test instances deallocatable.
  private func subscribeToAppLifecycleEvents() {
    sceneActivationTask = Task { [weak self] in
      for await _ in NotificationCenter.default.notifications(named: UIScene.didActivateNotification) {
        guard let self else { return }

        setupMotionUpdates()
      }
    }

    sceneDeactivationTask = Task { [weak self] in
      for await _ in NotificationCenter.default.notifications(named: UIScene.willDeactivateNotification) {
        guard let self else { return }

        shutdownMotionUpdates()
      }
    }
  }

  /// Configures and begins capturing device motion data.
  /// Processes the gravitational data to compute the difference between the current and average force
  /// components over a specific duration.
  private func setupMotionUpdates() {
    let interval = 0.1

    motionManager.deviceMotionUpdateInterval = interval

    motionManager.startDeviceMotionUpdates(to: .main) { data, _ in
      // The handler is delivered on OperationQueue.main, i.e. the main thread.
      MainActor.assumeIsolated {
        guard let gravity = data?.gravity else { return }

        self.processMotionUpdate(gravity)
      }
    }
  }

  /// Stops any ongoing motion updates.
  private func shutdownMotionUpdates() {
    motionManager.stopDeviceMotionUpdates()
  }

  /// Folds a new gravity sample into the rolling window and refreshes the deltas.
  private func processMotionUpdate(_ gravity: CMAcceleration) {
    let cycle = 10.0
    let interval = 0.1
    let arrayCapacity: Int = .init(cycle / interval)

    // Make sure the arrays contain `cycle` seconds of data at most
    appendData(CGFloat(gravity.x), to: &xs, maxCapacity: arrayCapacity)
    appendData(CGFloat(gravity.y), to: &ys, maxCapacity: arrayCapacity)
    appendData(CGFloat(gravity.z), to: &zs, maxCapacity: arrayCapacity)

    // Calculate the difference between current value and array average
    dx = CGFloat(gravity.x) - xs.reduce(0, +) / CGFloat(xs.count)
    dy = CGFloat(gravity.y) - ys.reduce(0, +) / CGFloat(ys.count)
    dz = CGFloat(gravity.z) - zs.reduce(0, +) / CGFloat(zs.count)
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
