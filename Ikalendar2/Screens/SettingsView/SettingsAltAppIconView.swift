//
//  SettingsAltAppIconView.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - SettingsAltAppIconView

/// The Settings page for switching alternate App Icons.
struct SettingsAltAppIconView: View {
  var body: some View {
    List {
      Section(header: Spacer()) {
        ForEach(IkaAppIcon.allCases) { ikaAppIcon in
          SettingsAltAppIconRow(ikaAppIcon: ikaAppIcon)
        }
      }
    }
    .navigationTitle("App Icon")
    .navigationBarTitleDisplayMode(.large)
    .listStyle(.insetGrouped)
  }
}

// MARK: - SettingsAltAppIconRow

struct SettingsAltAppIconRow: View {
  typealias Scoped = Constants.Styles.Settings.AltAppIcon

  @EnvironmentObject private var ikaPreference: IkaPreference

  let ikaAppIcon: IkaAppIcon

  var body: some View {
    Button {
      setAltAppIcon(ikaAppIcon)
    }
    label: {
      HStack(spacing: Scoped.SPACING_H) {
        Image(ikaAppIcon.getImageName(.small))
          .antialiased(true)
          .resizable()
          .scaledToFit()
          .frame(
            width: IkaAppIcon.DisplayMode.small.sideLen,
            height: IkaAppIcon.DisplayMode.small.sideLen)
          .clipShape(
            IkaAppIcon.DisplayMode.small.clipShape)
          .overlay(
            IkaAppIcon.DisplayMode.small.clipShape
              .stroke(Scoped.STROKE_COLOR, lineWidth: Scoped.STROKE_LINE_WIDTH)
              .opacity(Scoped.STROKE_OPACITY))
          .shadow(radius: Constants.Styles.Global.SHADOW_RADIUS)

        Text(ikaAppIcon.displayName.localizedStringKey)
          .foregroundColor(Scoped.DISPLAY_NAME_COLOR)

        Spacer()

        if ikaAppIcon == ikaPreference.preferredAppIcon {
          Image(systemName: Scoped.ACTIVE_INDICATOR_SFSYMBOL)
            .font(Scoped.ACTIVE_INDICATOR_FONT)
            .symbolRenderingMode(.palette)
            .foregroundStyle(Color.accentColor, Color.tertiarySystemGroupedBackground)
        }
      }
      .padding(.vertical, Scoped.ROW_PADDING_V)
    }
  }

  // MARK: Private

  private func setAltAppIcon(_ ikaAppIcon: IkaAppIcon) {
    guard ikaPreference.preferredAppIcon != ikaAppIcon else { return }
    ikaPreference.preferredAppIcon = ikaAppIcon
  }
}

// MARK: - SettingsAppIconView_Previews

struct SettingsAppIconView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsAltAppIconView()
  }
}
