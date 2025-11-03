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
  @Environment(IkaCatalog.self) private var ikaCatalog

  private var isRefreshing: Bool { ikaCatalog.loadStatus == .loading }

  var body: some View {
    Button {
      Task { await ikaCatalog.refresh() }
    } label: {
      Image(
        systemName: isRefreshing
          ? "antenna.radiowaves.left.and.right"
          : "arrow.trianglehead.2.clockwise.rotate.90")
        .contentTransition(.symbolEffect(.replace.offUp))
        .symbolEffect(
          .variableColor,
          options: .speed(2),
          isActive: isRefreshing)
    }
    .disabled(isRefreshing)
  }
}

// MARK: - ToolbarRefreshButton_Previews

struct ToolbarRefreshButton_Previews: PreviewProvider {
  static var previews: some View {
    ToolbarRefreshButton()
  }
}
