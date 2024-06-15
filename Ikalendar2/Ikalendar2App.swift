//
//  Ikalendar2App.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

/// Main Application Entry.
@main
struct Ikalendar2App: App {
  private let ikaCatalog: IkaCatalog
  private let ikaStatus: IkaStatus

  private let ikaTimePublisher: IkaTimePublisher
  private let ikaDeviceMotionPublisher: IkaDeviceMotionPublisher
  private let ikaInterfaceOrientationPublisher: IkaInterfaceOrientationPublisher

  private let ikaPreference: IkaPreference
  private let ikaLog: IkaLog

  var body: some Scene {
    WindowGroup {
      RootView()
        .accentColor(.orange)
        .environment(ikaCatalog)
        .environment(ikaStatus)
        .environmentObject(ikaTimePublisher)
        .environment(ikaDeviceMotionPublisher)
        .environment(ikaInterfaceOrientationPublisher)
        .environmentObject(ikaPreference)
        .environmentObject(ikaLog)
        .onAppear {
          ikaInterfaceOrientationPublisher.setInitialOrientation()
        }
    }
  }

  init() {
    ikaCatalog = .shared
    ikaStatus = .shared

    ikaTimePublisher = .shared
    ikaDeviceMotionPublisher = .shared
    ikaInterfaceOrientationPublisher = .shared

    ikaPreference = .shared
    ikaLog = .shared
  }
}
