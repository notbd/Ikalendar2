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
  private var ikaCatalog: IkaCatalog
  private var ikaStatus: IkaStatus
  private var ikaPreference: IkaPreference
  private var ikaTimePublisher: IkaTimePublisher
  private var ikaMotionPublisher: IkaMotionPublisher

  var body: some Scene {
    WindowGroup {
      RootView()
        .environmentObject(ikaCatalog)
        .environmentObject(ikaStatus)
        .environmentObject(ikaPreference)
        .environmentObject(ikaTimePublisher)
        .environmentObject(ikaMotionPublisher)
        .accentColor(.orange)
    }
  }

  // MARK: Lifecycle

  init() {
    UserDefaults.standard
      .register(defaults: [Constants.Keys.AppStorage.DEFAULT_GAME_MODE: "battle"])
    UserDefaults.standard
      .register(defaults: [Constants.Keys.AppStorage.DEFAULT_BATTLE_MODE: "gachi"])

    ikaCatalog = .shared
    ikaStatus = .shared
    ikaPreference = .shared
    ikaTimePublisher = .shared
    ikaMotionPublisher = .shared
  }
}
