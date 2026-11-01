//
//  ToolbarSettingsButton.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - ToolbarSettingsButton

/// A settings button in the toolbar.
struct ToolbarSettingsButton: View {
  @Environment(IkaStatus.self) private var ikaStatus

  var body: some View {
    Button {
      ikaStatus.isSettingsPresented = true
    } label: {
      Image(systemName: "gear")
    }
    .accessibilityLabel(Text("Settings"))
  }
}

#Preview {
  ToolbarSettingsButton()
    .ikaPreviewEnvironment()
}
