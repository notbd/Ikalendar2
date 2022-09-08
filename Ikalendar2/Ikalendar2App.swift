//
//  Ikalendar2App.swift
//  Ikalendar2
//
//  Copyright (c) 2022 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

/// Main Application Entry.
@main
struct Ikalendar2App: App {
  private var ikaCatalog = IkaCatalog()
  private var ikaStatus: IkaStatus
  private var ikaTimer = IkaTimer()
  private var ikaPreference: IkaPreference
  private var motionManager = MotionManager()

  var body: some Scene {
    WindowGroup {
      RootView()
        .environmentObject(ikaCatalog)
        .environmentObject(ikaStatus)
        .environmentObject(ikaTimer)
        .environmentObject(ikaPreference)
        .environmentObject(motionManager)
        .accentColor(.orange)
    }
  }

  // MARK: Lifecycle

  init() {
    UIKitIntegration.customizeNavigationTitleText()
//    UIKitIntegration.customizePickerText()

    UserDefaults.standard
      .register(defaults: [Constants.Keys.AppStorage.DEFAULT_GAME_MODE: "battle"])
    UserDefaults.standard
      .register(defaults: [Constants.Keys.AppStorage.DEFAULT_BATTLE_MODE: "gachi"])

    // init these here to avoid crash
    ikaPreference = IkaPreference()
    ikaStatus = IkaStatus()
  }
}
