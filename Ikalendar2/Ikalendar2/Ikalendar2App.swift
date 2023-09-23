//
//  Ikalendar2App.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

/// Main Application Entry.
@main
struct Ikalendar2App: App {
  private let ikaPreference: IkaPreference
  private let ikaLog: IkaLog
  private let ikaCatalog: IkaCatalog
  private let ikaStatus: IkaStatus

  private let ikaTimePublisher: IkaTimePublisher
  private let ikaDeviceMotionPublisher: IkaDeviceMotionPublisher
  private let ikaInterfaceOrientationPublisher: IkaInterfaceOrientationPublisher

  var body: some Scene {
    WindowGroup {
      RootView()
        .accentColor(.orange)
        .environmentObject(ikaPreference)
        .environmentObject(ikaLog)
        .environmentObject(ikaCatalog)
        .environmentObject(ikaStatus)
        .environment(ikaTimePublisher)
        .environment(ikaDeviceMotionPublisher)
        .environment(ikaInterfaceOrientationPublisher)
        .onAppear {
          ikaInterfaceOrientationPublisher.setInitialOrientation()
        }
    }
  }

  // MARK: Lifecycle

  init() {
    UserDefaults.standard
      .register(defaults: [Constants.Key.AppStorage.DEFAULT_GAME_MODE: "battle"])
    UserDefaults.standard
      .register(defaults: [Constants.Key.AppStorage.DEFAULT_BATTLE_MODE: "gachi"])

    ikaPreference = .shared
    ikaLog = .shared
    ikaCatalog = .shared
    ikaStatus = .shared

    ikaTimePublisher = .shared
    ikaDeviceMotionPublisher = .shared
    ikaInterfaceOrientationPublisher = .shared
  }
}
