//
//  SettingsEntryView.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

struct SettingsEntryView: View {
  @Environment(IkaDiscoveryLog.self) private var ikaDiscoveryLog

  var body: some View {
    // NavigationStack replaces the deprecated NavigationView; stack behavior
    // (previously forced via StackNavigationViewStyle) is its native semantics.
    NavigationStack {
      SettingsMainView()
    }
    .presentationSizing(.page)
    .overlay(
      AutoLoadingOverlay(),
      alignment: .bottomTrailing)
  }
}

#Preview {
  SettingsEntryView()
    .ikaPreviewEnvironment()
}
