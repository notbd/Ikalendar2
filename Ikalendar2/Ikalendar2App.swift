//
//  Ikalendar2App.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

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

  private let ikaNetworkService: IkaNetworkManager

  var body: some Scene {
    WindowGroup {
      RootView()
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
    let networkService: IkaNetworkManager = .init()
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
