//
//  ToolbarRefreshButton.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - ToolbarRefreshButton

/// A refresh button in the toolbar.
@MainActor
struct ToolbarRefreshButton: View {
  typealias Scoped = Constants.Style.ToolbarButton

  @Environment(IkaCatalog.self) private var ikaCatalog

  private var isRefreshing: Bool { ikaCatalog.loadStatus == .loading }

  var body: some View {
    Button {
      Task {
        await ikaCatalog.refresh()
      }
    } label: {
      icon
        .frame(
          width: Scoped.FRAME_SIZE,
          height: Scoped.FRAME_SIZE)
        .background(.thinMaterial)
        .cornerRadius(Scoped.FRAME_CORNER_RADIUS)
    }
    .disabled(ikaCatalog.loadStatus == .loading)
  }

  private var icon: some View {
    Image(
      systemName: isRefreshing
        ? "antenna.radiowaves.left.and.right"
        : "arrow.triangle.2.circlepath")
      .contentTransition(.symbolEffect(.replace.offUp))
      .symbolEffect(
        .variableColor,
        options: .speed(2),
        isActive: isRefreshing)
      .font(Scoped.SFSYMBOL_FONT_SIZE_REG)
      .foregroundStyle(Color.primary)
      .shadow(radius: Constants.Style.Global.SHADOW_RADIUS)
  }
}

// MARK: - ToolbarRefreshButton_Previews

struct ToolbarRefreshButton_Previews: PreviewProvider {
  static var previews: some View {
    ToolbarRefreshButton()
  }
}
