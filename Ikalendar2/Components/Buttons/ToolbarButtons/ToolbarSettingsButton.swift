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
  typealias Scoped = Constants.Styles.ToolbarButton

  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Image(systemName: "gear")
        .font(Scoped.SFSYMBOL_FONT_SIZE_REG)
        .foregroundColor(.primary)
        .shadow(radius: Constants.Styles.Global.SHADOW_RADIUS)
        .frame(width: Scoped.SILHOUETTE_SIDE_LEN, height: Scoped.SILHOUETTE_SIDE_LEN)
        .background(.thinMaterial)
        .cornerRadius(Scoped.SILHOUETTE_CORNER_RADIUS)
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
