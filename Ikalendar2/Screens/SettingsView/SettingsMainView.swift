//
//  SettingsMainView.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

// MARK: - SettingsMainView

/// The main page for App Settings.
struct SettingsMainView: View {
  typealias Scoped = Constants.Styles.Settings.Main

  @Environment(\.openURL) private var openURL
  @Environment(\.dismiss) private var dismiss

  @EnvironmentObject private var ikaCatalog: IkaCatalog
  @EnvironmentObject private var ikaStatus: IkaStatus
  @EnvironmentObject private var ikaPreference: IkaPreference

  @State private var refreshableID = UUID()

  private var currentLanguage: String {
    if Locale.current.identifier.starts(with: "en") { return "English" }
    if Locale.current.identifier.starts(with: "ja") { return "日本語" }
    if Locale.current.identifier.starts(with: "zh_Hans") { return "简体中文(beta)" }
    if Locale.current.identifier.starts(with: "zh_Hant") { return "繁體中文(beta)" }
    else { return "Unknown" }
  }

  var body: some View {
    NavigationView {
      // not using NavigationStack for Settings as of iOS 16 because of titleDisplayMode bug
      List {
        Section(header: Text("Default Mode")) {
          rowDefaultGameMode
          rowDefaultBattleMode
        }

        Section(header: Text("Appearance")) {
          rowColorScheme
          rowSwitchAppIcon
          rowAdvancedOptions
        }

        Section(header: Text("Language")) {
          rowAppLanguage
        }

        Section {
          rowAbout
          rowCredits
        }
      }
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.large)
      .listStyle(.insetGrouped)
      .navigationBarItems(trailing: doneButton)
    }
    .id(refreshableID)
    .navigationViewStyle(StackNavigationViewStyle())
    .overlay(
      AutoLoadingOverlay(autoLoadStatus: ikaCatalog.autoLoadStatus),
      alignment: .bottomTrailing)
    .onReceive(DynamicTextStyleObserver.shared.textSizeDidChange) {
      // force the view to refresh when the text size changes
      refreshableID = UUID()
    }
  }

  // MARK: - Default Mode Section

  private var rowDefaultGameMode: some View {
    HStack {
      Label(
        "Game",
        systemImage: Scoped.DEFAULT_GAME_MODE_SFSYMBOL)
        .symbolRenderingMode(.palette)
        .foregroundStyle(.primary, Color.accentColor)

      Spacer().frame(width: Scoped.DEFAULT_MODE_PICKER_SPACING)

      Picker(
        selection: $ikaPreference.defaultGameMode
          .onSet { _ in SimpleHaptics.generateTask(.selection) },
        label: Text("Default Game Mode"))
      {
        ForEach(GameMode.allCases) { gameMode in
          Text(gameMode.name.localizedStringKey)
            .tag(gameMode)
        }
      }
      .pickerStyle(SegmentedPickerStyle())
    }
  }

  private var rowDefaultBattleMode: some View {
    HStack {
      Label(
        "Battle",
        systemImage: Scoped.DEFAULT_BATTLE_MODE_SFSYMBOL)
        .symbolRenderingMode(.palette)
        .foregroundStyle(.primary, Color.accentColor)

      Spacer().frame(width: Scoped.DEFAULT_MODE_PICKER_SPACING)

      Picker(
        selection: $ikaPreference.defaultBattleMode
          .onSet { _ in SimpleHaptics.generateTask(.selection) },
        label: Text("Default Battle Mode"))
      {
        ForEach(BattleMode.allCases) { battleMode in
          Text(battleMode.shortName.localizedStringKey)
            .tag(battleMode)
        }
      }
      .pickerStyle(SegmentedPickerStyle())
      .disabled(ikaPreference.defaultGameMode != .battle)
    }
  }

  // MARK: - Appearance Section

  private var rowColorScheme: some View {
    HStack {
      Label(
        "Color Scheme",
        systemImage: Scoped.COLOR_SCHEME_SFSYMBOL)
        .scaledLimitedLine()

      Picker(
        selection: $ikaPreference.preferredAppColorScheme
          .onSet { _ in SimpleHaptics.generateTask(.selection) },
        label: EmptyView())
      {
        ForEach(IkaColorSchemeManager.PreferredAppColorScheme.allCases) { appPreferredColorScheme in
          Label(
            appPreferredColorScheme.name.localizedStringKey,
            systemImage: appPreferredColorScheme.sfSymbol)
            .tag(appPreferredColorScheme)
        }
      }
    }
  }

  private var rowSwitchAppIcon: some View {
    NavigationLink(destination: SettingsAltAppIconView()) {
      Label(
        "App Icon",
        systemImage: Scoped.SWITCH_APP_ICON_SFSYMBOL)
    }
  }

  private var rowAdvancedOptions: some View {
    NavigationLink(destination: SettingsAdvancedOptionsView()) {
      Label(
        "Advanced Options",
        systemImage: Scoped.ADVANCED_SFSYMBOL)
    }
  }

  // MARK: - Language Section

  private var rowAppLanguage: some View {
    Button {
      guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
      SimpleHaptics.generateTask(.selection)
      openURL(url)
    } label: {
      HStack {
        Label {
          Text("Preferred Language")
            .foregroundColor(.primary)
            .scaledLimitedLine()
        }
        icon: {
          Image(systemName: Scoped.PREF_LANG_SFSYMBOL)
        }

        Spacer()

        Text(currentLanguage)
          .foregroundColor(.secondary)

        Image(systemName: Scoped.PREF_LANG_JUMP_SFSYMBOL)
          .foregroundColor(.secondary)
          .symbolRenderingMode(.hierarchical)
      }
    }
  }

  // MARK: - Others Section

  private var rowAbout: some View {
    NavigationLink(destination: SettingsAboutView()) {
      Label(
        "About",
        systemImage: Scoped.ABOUT_SFSYMBOL)
    }
  }

  private var rowCredits: some View {
    NavigationLink(destination: SettingsCreditsView()) {
      Label(
        "Credits",
        systemImage: Scoped.CREDITS_SFSYMBOL)
    }
  }

  // MARK: - Toolbar Buttons

  private var doneButton: some View {
    Button {
      dismiss()
    } label: {
      Text("Done")
        .fontWeight(Scoped.DONE_BUTTON_FONT_WEIGHT)
    }
  }
}

// MARK: - SettingsMainView_Previews

struct SettingsMainView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsMainView()
  }
}
