//
//  IkaDeviceMotionMonitor.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import CoreMotion
import UIKit

// MARK: - IkaDeviceMotionMonitor

/// Publishes how far the device's gravity vector has moved on x and y from its 10 s rolling
/// mean (`dx`, `dy`). Sampling runs only while a scene is active.
@MainActor
@Observable
final class IkaDeviceMotionMonitor {
  /// Gravity sampling period (10 Hz).
  static let updateInterval: TimeInterval = 0.1
  /// How far back the rolling mean reaches: a held tilt decays to zero over this long.
  static let windowLength: TimeInterval = 10

  @ObservationIgnored private let motionManager: CMMotionManager = .init()

  /// Long-running observation loops for scene activation/deactivation.
  @ObservationIgnored private var sceneActivationTask: Task<Void, Never>?
  @ObservationIgnored private var sceneDeactivationTask: Task<Void, Never>?

  /// Rolling windows of the x and y gravity components.
  @ObservationIgnored private var xWindow: GravityDeltaWindow
  @ObservationIgnored private var yWindow: GravityDeltaWindow

  /// The difference between the current gravitational force component and its average
  /// of recently stored values for the x and y axes.
  private(set) var dx: CGFloat = 0
  private(set) var dy: CGFloat = 0

  init() {
    let window: GravityDeltaWindow = .init(windowLength: Self.windowLength, updateInterval: Self.updateInterval)
    xWindow = window
    yWindow = window
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
      let activations = NotificationCenter.default.notifications(named: UIScene.didActivateNotification)
      // This task starts after init returns, so the first activation may have been posted already:
      // start now if the app is active. Subscribing before the check leaves no gap between them.
      if UIApplication.shared.applicationState == .active { self?.setupMotionUpdates() }

      for await _ in activations {
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

  /// Configures and begins capturing device motion data, where the device has it (not the simulator).
  private func setupMotionUpdates() {
    guard motionManager.isDeviceMotionAvailable else { return }

    motionManager.deviceMotionUpdateInterval = Self.updateInterval

    // Weak self: the manager retains this handler, so a strong capture would pin the
    // monitor until updates stop (1b694aa).
    motionManager.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
      // The handler is delivered on OperationQueue.main, i.e. the main thread.
      MainActor.assumeIsolated {
        guard let gravity = data?.gravity else { return }

        self?.processMotionUpdate(gravity)
      }
    }
  }

  private func shutdownMotionUpdates() {
    motionManager.stopDeviceMotionUpdates()
  }

  /// Folds a new gravity sample into the rolling windows and refreshes the deltas.
  private func processMotionUpdate(_ gravity: CMAcceleration) {
    dx = xWindow.push(CGFloat(gravity.x))
    dy = yWindow.push(CGFloat(gravity.y))
  }
}

// MARK: - GravityDeltaWindow

/// A rolling window of one gravity component. `push` returns the new sample minus the window mean,
/// so a held tilt decays to zero over the window length and only motion shows.
struct GravityDeltaWindow {
  /// The most samples the window holds: one window length at the update interval.
  let capacity: Int

  /// Oldest first.
  private(set) var samples: [CGFloat] = []

  init(windowLength: TimeInterval, updateInterval: TimeInterval) {
    capacity = Int(windowLength / updateInterval)
  }

  /// Appends `sample`, dropping the oldest once the window is full, and returns `sample` minus the
  /// mean of the window (which includes `sample`).
  mutating func push(_ sample: CGFloat) -> CGFloat {
    if samples.count >= capacity { samples.removeFirst() }
    samples.append(sample)
    return sample - samples.reduce(0, +) / CGFloat(samples.count)
  }
}
