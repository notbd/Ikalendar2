//
//  SettingsEntryView.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

struct SettingsEntryView: View {
  @EnvironmentObject private var ikaLog: IkaLog

  var body: some View {
    NavigationView {
      SettingsMainView()
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
}
