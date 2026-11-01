//
//  SettingsRowLabel.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - SettingsRowLabel

/// The title and icon of a settings row.
///
/// Each row passes its own `titleStyle`: Button rows use `Color.primary`, because the
/// hierarchical `.primary` would resolve against the button's tint; the other rows use `.primary`.
struct SettingsRowLabel<TitleStyle: ShapeStyle, Icon: View>: View {
  private let title: LocalizedStringKey
  private let titleStyle: TitleStyle
  private let icon: Icon

  var body: some View {
    Label {
      Text(title)
        .foregroundStyle(titleStyle)
    } icon: {
      icon
    }
  }

  init(
    _ title: LocalizedStringKey,
    titleStyle: TitleStyle,
    @ViewBuilder icon: () -> Icon)
  {
    self.title = title
    self.titleStyle = titleStyle
    self.icon = icon()
  }
}

extension SettingsRowLabel where Icon == SettingsRowSymbol {
  /// A row with the usual icon: an accent-colored SF Symbol at medium scale.
  init(
    _ title: LocalizedStringKey,
    titleStyle: TitleStyle,
    systemImage: String,
    renderingMode: SymbolRenderingMode = .hierarchical)
  {
    self.init(title, titleStyle: titleStyle) {
      SettingsRowSymbol(
        systemName: systemImage,
        renderingMode: renderingMode)
    }
  }
}

// MARK: - SettingsRowSymbol

/// The usual settings row icon: an accent-colored SF Symbol at medium scale.
struct SettingsRowSymbol: View {
  let systemName: String
  let renderingMode: SymbolRenderingMode

  var body: some View {
    Image(systemName: systemName)
      .imageScale(.medium)
      .symbolRenderingMode(renderingMode)
      .foregroundStyle(Color.accentColor)
  }
}
