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
  typealias Scoped = Constants.Style.ToolbarButton

  @EnvironmentObject private var ikaCatalog: IkaCatalog

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
    Group {
      switch ikaCatalog.loadStatus {
      case .loading:
        ProgressView()
      default:
        Image(systemName: "arrow.triangle.2.circlepath")
          .font(Scoped.SFSYMBOL_FONT_SIZE_REG)
          .foregroundColor(.primary)
          .shadow(radius: Constants.Style.Global.SHADOW_RADIUS)
      }
    }
  }
}

// MARK: - ToolbarRefreshButton_Previews

struct ToolbarRefreshButton_Previews: PreviewProvider {
  static var previews: some View {
    ToolbarRefreshButton()
  }
}
