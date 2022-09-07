//
//  SettingsMainView.swift
//  Ikalendar2
//
//  Copyright (c) 2022 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - SettingsMainView

/// The main page for App Settings.
struct SettingsMainView: View {
  @Environment(\.openURL) var openURL

  @EnvironmentObject var ikaStatus: IkaStatus
  @EnvironmentObject var ikaPreference: IkaPreference

  private var currLanguage: String {
    if Locale.current.identifier.starts(with: "en") { return "English" }
    if Locale.current.identifier.starts(with: "ja") { return "日本語" }
    if Locale.current.identifier.starts(with: "zh_Hans") { return "简体中文(beta)" }
    if Locale.current.identifier.starts(with: "zh_Hant") { return "繁體中文(beta)" }
    else { return "Unknown" }
  }

  var body: some View {
    NavigationStack {
      Form {
        Section(header: Text("Default Mode")) {
          rowDefaultGameMode
          rowDefaultBattleMode
        }

        Section(header: Text("Appearance")) {
          rowColorScheme
          rowShuffleImages
          rowAppIcon
        }

        Section(header: Text("Language")) {
          rowAppLanguage
        }

        Section {
          rowAbout
          rowAcknowledgement
        }
      }
      .navigationTitle("Settings")
      .navigationBarItems(trailing: doneButton)
    }
  }

  // MARK: - Components ↓↓↓

  // MARK: - Default Mode Section

  private var rowDefaultGameMode: some View {
    HStack {
      Label(
        "Game",
        systemImage: "rectangle.topthird.inset")

      Spacer().frame(width: 50)

      Picker(
        selection: $ikaPreference.defaultGameMode.onSet { _ in Haptics.generate(.selection) },
        label: Text("Default Game Mode"))
      {
        ForEach(GameMode.allCases) { gameMode in
          Text(gameMode.name.localizedStringKey())
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
        systemImage: "rectangle.bottomthird.inset.fill")

      Spacer().frame(width: 50)

      Picker(
        selection: $ikaPreference.defaultBattleMode.onSet { _ in Haptics.generate(.selection) },
        label: Text("Default Battle Mode"))
      {
        ForEach(BattleMode.allCases) { battleMode in
          Text(battleMode.shortName.localizedStringKey())
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
        systemImage: "circle.lefthalf.fill")

      Spacer()
        .frame(maxWidth: 20)

      Picker(
        selection: $ikaPreference.appColorScheme.onSet { _ in Haptics.generate(.selection) },
        label: Text("App Color Scheme"))
      {
        ForEach(ColorSchemeManager.AppColorScheme.allCases) { appColorScheme in
          Text(appColorScheme.name.localizedStringKey())
            .tag(appColorScheme)
        }
      }
      .pickerStyle(SegmentedPickerStyle())
    }
  }

  private var rowShuffleImages: some View {
    Toggle(isOn: .constant(true)) {
      Label(
        "Shuffle Cover Images",
        systemImage: "shuffle")
    }
    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
  }

  private var rowAppIcon: some View {
    NavigationLink(destination: SettingsAppIconView()) {
      Label(
        "App Icon",
        systemImage: "square.stack")
    }
  }

  // MARK: - Language Section

  private var rowAppLanguage: some View {
    Button {
      Haptics.generate(.selection)
      if let url = URL(string: UIApplication.openSettingsURLString) {
        openURL(url)
      }
    } label: {
      HStack {
        Label {
          Text("App Language")
            .foregroundColor(.primary)
        }
        icon: {
          Image(systemName: "globe")
        }

        Spacer()

        Text(currLanguage)
          .foregroundColor(.secondary)

        Image(systemName: "arrow.up.forward.app.fill")
          .foregroundColor(.secondary)
      }
    }
  }

  // MARK: - Others Section

  private var rowAbout: some View {
    NavigationLink(destination: SettingsAboutView()) {
      Label(
        "About",
        systemImage: "house.fill")
    }
  }

  private var rowAcknowledgement: some View {
    NavigationLink(destination: SettingsAcknowledgementView()) {
      Label(
        "Acknowledgement",
        systemImage: "bookmark.fill")
    }
  }

  // MARK: - Toolbar Buttons

  private var doneButton: some View {
    Button {
      Haptics.generate(.selection)
      ikaStatus.isSettingsPresented.toggle()
    } label: {
      Text("Done")
        .fontWeight(.semibold)
    }
  }
}

// MARK: - SettingsMainView_Previews

struct SettingsMainView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsMainView()
  }
}
