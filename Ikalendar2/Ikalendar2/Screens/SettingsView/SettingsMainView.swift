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
  typealias Scoped = Constants.Style.Settings.Main

  @Environment(\.openURL) private var openURL
  @Environment(\.dismiss) private var dismiss

  @EnvironmentObject private var ikaCatalog: IkaCatalog
  @EnvironmentObject private var ikaStatus: IkaStatus
  @EnvironmentObject private var ikaPreference: IkaPreference

  private var currentLanguage: String {
    if Locale.current.identifier.starts(with: "en") { return Constants.Key.Locale.EN }
    if Locale.current.identifier.starts(with: "ja") { return Constants.Key.Locale.JA }
    if Locale.current.identifier.starts(with: "zh_Hans") { return Constants.Key.Locale.ZH_HANS }
    if Locale.current.identifier.starts(with: "zh_Hant") { return Constants.Key.Locale.ZH_HANT }
    else { return Constants.Key.Placeholder.UNKNOWN }
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
      .navigationBarItems(trailing: doneButton)
      .listStyle(.insetGrouped)
    }
    .navigationViewStyle(StackNavigationViewStyle())
    .overlay(
      AutoLoadingOverlay(autoLoadStatus: ikaCatalog.autoLoadStatus),
      alignment: .bottomTrailing)
  }

  // MARK: - Default Mode Section

  private var rowDefaultGameMode: some View {
    HStack {
      Label(
        "Game",
        systemImage: Scoped.DEFAULT_GAME_MODE_SFSYMBOL)
        .symbolRenderingMode(.palette)
        .foregroundStyle(.primary, Color.accentColor)
        .layoutPriority(1)

      Spacer()

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
      .fixedSize()
    }
  }

  private var rowDefaultBattleMode: some View {
    HStack {
      Label(
        "Battle",
        systemImage: Scoped.DEFAULT_BATTLE_MODE_SFSYMBOL)
        .symbolRenderingMode(.palette)
        .foregroundStyle(.primary, Color.accentColor)

      Spacer()

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
      .fixedSize()
      .disabled(ikaPreference.defaultGameMode != .battle)
    }
  }

  // MARK: - Appearance Section

  private var rowColorScheme: some View {
    HStack {
      Label(
        "Color Scheme",
        systemImage: Scoped.COLOR_SCHEME_SFSYMBOL)

      Spacer()

      Menu {
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
      } label: {
        HStack {
          Image(systemName: ikaPreference.preferredAppColorScheme.sfSymbol)
            .foregroundColor(.secondary)

          Image(systemName: Scoped.COLOR_SCHEME_MENU_SFSYMBOL)
            .foregroundColor(.tertiaryLabel)
        }
      }
    }
  }

  private var rowSwitchAppIcon: some View {
    NavigationLink(destination: SettingsAltAppIconView()) {
      Label(
        "App Icon",
        systemImage: Scoped.ALT_APP_ICON_SFSYMBOL)
    }
  }

  private var rowAdvancedOptions: some View {
    NavigationLink(destination: SettingsAdvancedOptionsView()) {
      Label(
        "Advanced Options",
        systemImage: Scoped.ADVANCED_OPTIONS_SFSYMBOL)
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
        }
        icon: {
          Image(systemName: Scoped.PREF_LANG_SFSYMBOL)
        }

        Spacer()

        Text(currentLanguage)
          .foregroundColor(.secondary)

        Constants.Style.Global.EXTERNAL_LINK_JUMP_ICON
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
      SimpleHaptics.generateTask(.medium)
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
