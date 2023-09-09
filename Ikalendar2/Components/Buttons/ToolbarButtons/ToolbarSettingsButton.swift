//
//  ToolbarSettingsButton.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - ToolbarSettingsButton

/// A settings button in the toolbar.
struct ToolbarSettingsButton: View {
  typealias Scoped = Constants.Style.ToolbarButton

  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Image(systemName: "gear")
        .font(Scoped.SFSYMBOL_FONT_SIZE_REG)
        .foregroundColor(.primary)
        .shadow(radius: Constants.Style.Global.SHADOW_RADIUS)
        .frame(
          width: Scoped.FRAME_SIDE_LEN,
          height: Scoped.FRAME_SIDE_LEN)
        .background(.thinMaterial)
        .cornerRadius(Scoped.FRAME_CORNER_RADIUS)
    }
  }
}

// MARK: - ToolbarSettingsButton_Previews

struct ToolbarSettingsButton_Previews: PreviewProvider {
  static var previews: some View {
    ToolbarSettingsButton(
      action: { })
  }
}
