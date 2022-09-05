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
  var ikaCatalog = IkaCatalog()
  var ikaStatus: IkaStatus
  var ikaTimer = IkaTimer()
  var ikaPreference: IkaPreference
  var motionManager = MotionManager()

  var body: some Scene {
    WindowGroup {
//      NavViewNew()
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
    ikaPreference = IkaPreference()
    ikaStatus = IkaStatus()
  }
}
