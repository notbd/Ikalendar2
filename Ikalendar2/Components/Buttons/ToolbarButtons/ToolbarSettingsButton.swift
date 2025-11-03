//
//  ToolbarSettingsButton.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - ToolbarSettingsButton

/// A settings button in the toolbar.
@MainActor
struct ToolbarSettingsButton: View {
  @Environment(IkaStatus.self) private var ikaStatus
  @Environment(IkaCatalog.self) private var ikaCatalog

  var body: some View {
    Button {
      ikaStatus.isSettingsPresented = true
    } label: {
      Image(systemName: "gear")
    }
  }
}

// MARK: - ToolbarSettingsButton_Previews

struct ToolbarSettingsButton_Previews: PreviewProvider {
  static var previews: some View {
    ToolbarSettingsButton()
  }
}
