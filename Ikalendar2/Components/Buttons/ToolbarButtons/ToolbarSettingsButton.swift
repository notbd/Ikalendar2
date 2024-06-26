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
  typealias Scoped = Constants.Style.ToolbarButton

  @Environment(IkaStatus.self) private var ikaStatus
  @Environment(IkaCatalog.self) private var ikaCatalog

  @State private var buttonPressed: Int = 0

  var body: some View {
    Button {
      buttonPressed += 1
      ikaStatus.isSettingsPresented = true
    } label: {
      Image(systemName: "gear")
        .symbolEffect(
          .bounce.down,
          options: .speed(1.5),
          value: buttonPressed)
        .font(Scoped.SFSYMBOL_FONT_SIZE_REG)
        .foregroundStyle(Color.primary)
        .shadow(radius: Constants.Style.Global.SHADOW_RADIUS)
        .frame(
          width: Scoped.FRAME_SIZE,
          height: Scoped.FRAME_SIZE)
        .background(.thinMaterial)
        .cornerRadius(Scoped.FRAME_CORNER_RADIUS)
    }
  }
}

// MARK: - ToolbarSettingsButton_Previews

struct ToolbarSettingsButton_Previews: PreviewProvider {
  static var previews: some View {
    ToolbarSettingsButton()
  }
}
