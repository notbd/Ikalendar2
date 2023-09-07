//
//  SettingsCreditsView.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

// MARK: - SettingsCreditsView

/// The Credits page in App Settings.
struct SettingsCreditsView: View {

  @Environment(\.openURL) private var openURL

  var body: some View {
    List {
      Section(header: Text("Data Source")) {
        rowSplatoon2Ink
      }
    }
    .navigationTitle("Credits")
    .navigationBarTitleDisplayMode(.large)
    .listStyle(.insetGrouped)
  }

  private var rowSplatoon2Ink: some View {
    Button {
      guard let url = URL(string: "https://splatoon2.ink") else { return }
      SimpleHaptics.generateTask(.selection)
      openURL(url)
    } label: {
      HStack {
        VStack(alignment: .leading) {
          Text("Splatoon2.ink")
            .foregroundColor(.primary)
            .font(.headline)

          Text("splatoon2.ink/about")
            .foregroundColor(.secondary)
            .font(.callout)
        }

        Spacer()

        Image(systemName: "arrow.up.right.circle.fill")
          .foregroundColor(.secondary)
      }
    }
  }
}

// MARK: - SettingsCreditsView_Previews

struct SettingsCreditsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsCreditsView()
  }
}
