//
//  MainView.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - MainView

/// The main view of the app.
/// Will set different layout for iPhone and iPad depending on the current horizontal size.
struct MainView: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  var body: some View {
    NavigationStack {
      if horizontalSizeClass == .compact {
//        SettingsAdvancedView()
        ContentView()
      }
      else {
        ContentView()
      }
    }
  }
}

// MARK: - MainView_Previews

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
  }
}
