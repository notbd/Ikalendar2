//
//  SettingsAppIconView.swift
//  Ikalendar2
//
//  Copyright (c) 2022 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - SettingsAppIconView

/// The page for App Icon Settings.
struct SettingsAppIconView: View {
  var body: some View {
    HStack {
      Image(systemName: "paintbrush.fill")
      Text("In Development...")
    }
    .foregroundColor(.secondary)
    .navigationTitle("App Icon")
    .navigationBarTitleDisplayMode(.inline)
  }
}

// MARK: - SettingsAppIconView_Previews

struct SettingsAppIconView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsAppIconView()
  }
}
