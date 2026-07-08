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
      if Self.isRunningTests {
        // Hosted unit tests only need a live host process, not the UI. A static
        // placeholder keeps the main thread free of RootView's animations and
        // timers (e.g. onboarding keyframes on a fresh simulator), so suites
        // aren't starved of the main actor on congested CI runners.
        TestHostPlaceholderView()
      }
      else {
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
  }

  init() {
    let networkService: any IkaNetworkService =
      Self.isRunningTests ? InertNetworkService() : IkaNetworkManager()
    let clock: IkaClock = .init()
    // The test host persists nothing real: its stores live on a wiped throwaway
    // suite so host state never depends on the simulator's UserDefaults history.
    let userDefaults: UserDefaults = Self.isRunningTests ? Self.makeTestHostDefaults() : .standard
    let preference: IkaPreference = .init(userDefaults: userDefaults)

    ikaNetworkService = networkService
    _ikaClock = State(initialValue: clock)
    _ikaPreference = State(initialValue: preference)
    _ikaDiscoveryLog = State(initialValue: IkaDiscoveryLog(userDefaults: userDefaults))
    _ikaStatus = State(initialValue: IkaStatus(ikaPreference: preference))
    _ikaCatalog = State(initialValue: IkaCatalog(
      ikaNetworkService: networkService,
      ikaClock: clock))
    _ikaDeviceMotionMonitor = State(initialValue: IkaDeviceMotionMonitor())
    _ikaOrientationMonitor = State(initialValue: IkaOrientationMonitor())
    _ikaConnectivityChecker = State(initialValue: IkaConnectivityChecker())
  }

  /// A throwaway UserDefaults suite for the unit-test host, wiped on every launch.
  static private func makeTestHostDefaults() -> UserDefaults {
    let suiteName = "ikalendar2-test-host"
    let userDefaults = UserDefaults(suiteName: suiteName) ?? .standard
    userDefaults.removePersistentDomain(forName: suiteName)
    return userDefaults
  }
}

// MARK: - TestHostPlaceholderView

/// Static stand-in for RootView while hosting unit tests: no animations, no timers,
/// nothing contending with the test suites for the main actor.
private struct TestHostPlaceholderView: View {
  var body: some View {
    Text("ikalendar2 unit test host")
      .foregroundStyle(.secondary)
  }
}

// MARK: - InertNetworkService

/// Fails every request immediately - used only when the app runs as a unit-test host.
private struct InertNetworkService: IkaNetworkService {
  func fetchLicense(from _: String) async throws -> IkaOpenSourceLicense {
    throw IkaError.connectionError
  }

  func fetchBattleRotationDict() async throws -> BattleRotationDict {
    throw IkaError.connectionError
  }

  func fetchSalmonRotations() async throws -> [SalmonRotation] {
    throw IkaError.connectionError
  }

  func fetchSalmonRewardApparelInfo() async throws -> SalmonApparelInfo {
    throw IkaError.connectionError
  }
}
