//
//  SettingsEntryView.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

struct SettingsEntryView: View {
  @EnvironmentObject private var ikaLog: IkaLog

  var body: some View {
    NavigationView {
      SettingsMainView()
    }
    .presentationSizing(.page)
    .navigationViewStyle(StackNavigationViewStyle())
    .overlay(
      AutoLoadingOverlay(),
      alignment: .bottom)
  }
}
