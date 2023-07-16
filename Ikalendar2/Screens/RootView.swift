//
//  RootView.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

/// The entry view of the app.
/// Provide an interface for some upfront View-level configurations.
struct RootView: View {
  @Environment(\.colorScheme) var deviceColorScheme

  @EnvironmentObject var ikaStatus: IkaStatus
  @EnvironmentObject var ikaPreference: IkaPreference

  var body: some View {
    MainView()
      .onAppear {
        // Apply correct colorScheme upon launch
        IkaColorSchemeManager.shared.handleTheme(for: ikaPreference.appColorScheme)
      }
      .onChange(of: ikaPreference.appColorScheme) { colorScheme in
        IkaColorSchemeManager.shared.handleTheme(for: colorScheme)
      }
      .fullScreenCover(isPresented: $ikaStatus.isSettingsPresented) {
        SettingsMainView()
          .environmentObject(ikaStatus)
          .environmentObject(ikaPreference)
          .accentColor(.orange)
      }
  }

  // MARK: Lifecycle

  init() {
    UIKitIntegration.customizeNavigationTitleText()
//    UIKitIntegration.customizePickerText()
  }
}
