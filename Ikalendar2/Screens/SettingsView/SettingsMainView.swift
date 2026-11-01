//
//  SettingsMainView.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

// MARK: - SettingsMainView

/// The main page for App Settings.
struct SettingsMainView: View {
  typealias Scoped = Constants.Style.Settings.Main

  @Environment(\.openURL) private var openURL
  @Environment(\.dismiss) private var dismiss
  @Environment(\.locale) private var currentLocale

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  private var isHorizontalCompact: Bool { horizontalSizeClass == .compact }

  @Environment(IkaDiscoveryLog.self) private var ikaDiscoveryLog
  @Environment(IkaPreference.self) private var ikaPreference

  var body: some View {
    List {
      Section {
        if isHorizontalCompact {
          rowDefaultTab
        }
        else {
          rowDefaultGameMode
          rowDefaultBattleMode
        }
      } header: {
        Text("Default Mode")
      } footer: {
        if !isHorizontalCompact {
          Text("Certain options only apply to smaller screen widths.")
            .font(.footnote)
        }
      }

      Section {
        rowColorScheme
        rowAltAppIcon
        rowAdvancedOptions
      } header: { Text("Appearance") }

      Section {
        rowAppLanguage
      } header: { Text("Language") }

      Section {
        rowAbout
        rowCredits
      }
    }
    .navigationTitle("Settings")
    .navigationBarTitleDisplayMode(.large)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) { closeButton }
    }
    .listStyle(.insetGrouped)
  }

  // MARK: - Default Mode Section

  private var rowDefaultTab: some View {
    @Bindable var ikaPreference = ikaPreference
    return Picker(
      selection: $ikaPreference.preferredDefaultFlatMode,
      label: SettingsRowLabel("Default Tab", titleStyle: .primary) {
        Image(systemName: ikaPreference.preferredDefaultFlatMode.sfSymbolNameSelected)
          .imageScale(.medium)
          .contentTransition(.symbolEffect(.replace.offUp))
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(ikaPreference.preferredDefaultFlatMode.themeColor)
      })
    {
      ForEach(FlatMode.allCases) { flatMode in
        Text(flatMode.name.localizedStringKey)
          .tag(flatMode)
      }
    }
  }

  private var rowDefaultGameMode: some View {
    @Bindable var ikaPreference = ikaPreference
    return HStack {
      SettingsRowLabel("Default Game Mode", titleStyle: .primary) {
        Image(systemName: ikaPreference.preferredDefaultGameMode.sfSymbolNameSelected)
          .imageScale(.medium)
          .contentTransition(.symbolEffect(.replace.offUp))
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(Color.accentColor)
      }

      Spacer()

      Picker(
        selection: $ikaPreference.preferredDefaultGameMode,
        label: Text("Default Game Mode"))
      {
        ForEach(GameMode.allCases) { gameMode in
          Text(gameMode.name.localizedStringKey)
            .tag(gameMode)
        }
      }
      .pickerStyle(.segmented)
      .fixedSize()
    }
  }

  private var rowDefaultBattleMode: some View {
    @Bindable var ikaPreference = ikaPreference
    return HStack {
      SettingsRowLabel("Default Battle Mode", titleStyle: .primary) {
        Image(
          systemName: ikaPreference.preferredDefaultBattleMode.sfSymbolNameSelected)
          .imageScale(.medium)
          .contentTransition(.symbolEffect(.replace.offUp))
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(Color.secondary)
      }

      Spacer()

      Picker(
        selection: $ikaPreference.preferredDefaultBattleMode,
        label: Text("Default Battle Mode"))
      {
        ForEach(BattleMode.allCases) { battleMode in
          Text(battleMode.shortName.localizedStringKey)
            .tag(battleMode)
        }
      }
      .pickerStyle(.segmented)
      .fixedSize()
      // iPad shows every battle mode side by side; the default only matters on iPhone (see footer).
      .disabled(true)
    }
  }

  // MARK: - Appearance Section

  private var rowColorScheme: some View {
    @Bindable var ikaPreference = ikaPreference
    return Picker(
      selection: $ikaPreference.preferredAppColorScheme,
      label: SettingsRowLabel(
        "Color Scheme",
        titleStyle: .primary,
        systemImage: Scoped.colorSchemeSFSymbol))
    {
      ForEach(IkaPreferredColorScheme.allCases) { preferredColorScheme in
        Label(
          preferredColorScheme.name.localizedStringKey,
          systemImage: preferredColorScheme.sfSymbolName)
          .tag(preferredColorScheme)
      }
    }
  }

  private var rowAltAppIcon: some View {
    NavigationLink(destination: SettingsAltAppIconView()) {
      SettingsRowLabel("App Icon", titleStyle: .primary) {
        Image(systemName: ikaPreference.preferredAppIcon.settingsMainSFSymbolName)
          .iconNudge(isActive: !ikaDiscoveryLog.hasDiscoveredAltAppIcon)
          .imageScale(.medium)
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(Color.accentColor)
      }
    }
  }

  private var rowAdvancedOptions: some View {
    let customizations = [
      ikaPreference.shouldMinimizeTabBar,
      ikaPreference.shouldUseAltStageImages,
    ]
    let customizedPercentage = Double(customizations.count(where: { $0 })) / Double(customizations.count)

    return NavigationLink(destination: SettingsAdvancedOptionsView()) {
      SettingsRowLabel("Advanced Options", titleStyle: .primary) {
        Image(
          systemName: Scoped.advancedOptionsSFSymbol,
          variableValue: customizedPercentage)
          .imageScale(.medium)
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(Color.accentColor)
      }
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
        SettingsRowLabel(
          "Preferred Language",
          titleStyle: Color.primary,
          systemImage: currentLocale.toIkaLocale().sfSymbolName)

        Spacer()

        Text(currentLocale.toIkaLocale().displayName)
          .foregroundStyle(Color.secondary)

        Constants.Style.Global.externalLinkJumpIcon
          .foregroundStyle(Color.secondary)
      }
    }
  }

  // MARK: - About and Credits

  private var rowAbout: some View {
    NavigationLink(destination: SettingsAboutView()) {
      SettingsRowLabel(
        "About",
        titleStyle: .primary,
        systemImage: Scoped.aboutSFSymbol)
    }
  }

  private var rowCredits: some View {
    NavigationLink(destination: SettingsCreditsView()) {
      SettingsRowLabel(
        "Credits",
        titleStyle: .primary,
        systemImage: Scoped.creditsSFSymbol)
    }
  }

  // MARK: - Toolbar Buttons

  private var closeButton: some View {
    Button(
      "Done",
      systemImage: "checkmark",
      role: .close)
    {
      dismiss()
    }
  }
}

#Preview {
  NavigationStack {
    SettingsMainView()
  }
  .ikaPreviewEnvironment()
}
