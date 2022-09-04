//
//  SettingsAcknowledgementView.swift
//  Ikalendar2
//
//  Copyright (c) 2022 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - SettingsAcknowledgementView

/// The Acknowledgement page in App Settings.
struct SettingsAcknowledgementView: View {
  @Environment(\.openURL) var openURL

  var body: some View {
    Form { }
      .navigationTitle("Acknowledgement")
      .navigationBarTitleDisplayMode(.inline)
  }
}

// MARK: - SettingsAcknowledgementView_Previews

struct SettingsAcknowledgementView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsAcknowledgementView()
  }
}
