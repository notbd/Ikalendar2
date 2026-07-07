//
//  Ikalendar2App.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - Ikalendar2App

/// Main Application Entry.
/// Acts as the composition root: long-lived model objects are constructed here once,
/// wired together through initializers, and injected into the view hierarchy.
@main
struct Ikalendar2App: App {
  @State private var ikaClock: IkaClock
  @State private var ikaPreference: IkaPreference
  @State private var ikaDiscoveryLog: IkaDiscoveryLog
  @State private var ikaStatus: IkaStatus
  @State private var ikaCatalog: IkaCatalog
  @State private var ikaDeviceMotionMonitor: IkaDeviceMotionMonitor
  @State private var ikaOrientationMonitor: IkaOrientationMonitor
  @State private var ikaConnectivityChecker: IkaConnectivityChecker

  private let ikaNetworkService: any IkaNetworkService

  /// Hosted unit tests launch the real app as their host process. The host must not
  /// fire real network traffic or contend with the test suites for the main actor,
  /// so its catalog gets an inert service that fails fast instead.
  static private var isRunningTests: Bool {
    ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
      || ProcessInfo.processInfo.environment["XCTestSessionIdentifier"] != nil
  }

  var body: some Scene {
    WindowGroup {
      RootView()
        // Deliberately .accentColor, not .tint: it also sets the environment
        // accent, which is what makes every `Color.accentColor` in the app
        // resolve to the brand orange. (Deprecated, kept on purpose.)
        .accentColor(.orange)
        .environment(ikaCatalog)
        .environment(ikaStatus)
        .environment(ikaClock)
        .environment(ikaDeviceMotionMonitor)
        .environment(ikaOrientationMonitor)
        .environment(ikaPreference)
        .environment(ikaDiscoveryLog)
        .environment(ikaConnectivityChecker)
        .environment(\.ikaNetworkService, ikaNetworkService)
    }
  }

  init() {
    let networkService: any IkaNetworkService =
      Self.isRunningTests ? InertNetworkService() : IkaNetworkManager()
    let clock: IkaClock = .init()
    let preference: IkaPreference = .init()

    ikaNetworkService = networkService
    _ikaClock = State(initialValue: clock)
    _ikaPreference = State(initialValue: preference)
    _ikaDiscoveryLog = State(initialValue: IkaDiscoveryLog())
    _ikaStatus = State(initialValue: IkaStatus(ikaPreference: preference))
    _ikaCatalog = State(initialValue: IkaCatalog(
      ikaNetworkService: networkService,
      ikaClock: clock))
    _ikaDeviceMotionMonitor = State(initialValue: IkaDeviceMotionMonitor())
    _ikaOrientationMonitor = State(initialValue: IkaOrientationMonitor())
    _ikaConnectivityChecker = State(initialValue: IkaConnectivityChecker())
  }
}

// MARK: - InertNetworkService

/// Fails every request immediately - used only when the app runs as a unit-test host.
private struct InertNetworkService: IkaNetworkService {
  func fetchLicense(from _: String) async throws -> IkaOpenSourceLicense {
    throw IkaError.connectionError
  }

  func getBattleRotationDict() async throws -> BattleRotationDict {
    throw IkaError.connectionError
  }

  func getSalmonRotations() async throws -> [SalmonRotation] {
    throw IkaError.connectionError
  }

  func getSalmonRewardApparelInfo() async throws -> SalmonApparelInfo {
    throw IkaError.connectionError
  }
}
