//
//  ToolbarRefreshButton.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - ToolbarRefreshButton

/// A refresh button in the toolbar.
struct ToolbarRefreshButton: View {
  typealias Scoped = Constants.Styles.ToolbarButton

  let isDisabled: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Image(systemName: "arrow.triangle.2.circlepath")
        .font(Scoped.SFSYMBOL_FONT_SIZE_REG)
        .foregroundColor(.primary)
        .shadow(radius: Constants.Styles.Global.SHADOW_RADIUS)
        .frame(
          width: Scoped.FRAME_SIDE_LEN,
          height: Scoped.FRAME_SIDE_LEN)
        .background(.thinMaterial)
        .cornerRadius(Scoped.FRAME_CORNER_RADIUS)
    }
    .disabled(isDisabled)
  }
}

// MARK: - ToolbarRefreshButton_Previews

struct ToolbarRefreshButton_Previews: PreviewProvider {
  static var previews: some View {
    ToolbarRefreshButton(
      isDisabled: false,
      action: { })
  }
}
