//
//  KeyConstants.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import Foundation

/// Constant data holding `keys` for the app.
extension Constants.Keys {
  static let appBundleName =
    Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "UNKNOWN"
  static let appDisplayName =
    Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "UNKNOWN"
  static let appVersion =
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
  static let appBuildNumber =
    Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
  static let appStoreIdentifier = "1529193361"

  enum AppStorage {
    static let DEFAULT_GAME_MODE = "pref.default.game_mode"
    static let DEFAULT_BATTLE_MODE = "pref.default.battle_mode"

    static let APP_PREFERRED_COLOR_SCHEME = "pref.app_preferred_color_scheme"

    static let IF_SWAP_BOTTOM_TOOLBAR_PICKERS = "pref.if_swap_bottom_toolbar_pickers"
  }

  enum URL {
    static let BATTLE_ROTATIONS = "https://splatoon2.ink/data/schedules.json"
    static let OATMEALDOME = "https://files.oatmealdome.me/bcat/coop.json"
    static let SALMON_ROTATIONS = "https://splatoon2.ink/data/coop-schedules.json"
    static let TIMELINE = "https://splatoon2.ink/data/timeline.json"

    static let NINTENDO_SPLATOON2_PAGE =
      "https://www.nintendo.com/store/products/splatoon-2-switch/"
    static let DEVELOPER_TWITTER = "https://twitter.com/zhang13music"
    static let DEVELOPER_EMAIL = "mailto:zhang13music@outlook.com"
    static let APP_STORE_PAGE = "https://apps.apple.com/app/id1529193361"
    static let APP_STORE_PAGE_US = "https://apps.apple.com/us/app/ikalendar2/id1529193361"
    static let APP_STORE_REVIEW = "https://apps.apple.com/app/id1529193361?action=write-review"
    static let SOURCE_CODE_REPO = "https://github.com/zhang13music/Ikalendar2"
    static let PRIVACY_POLICY = "https://github.com/zhang13music/Ikalendar2/wiki/Privacy-Policy"

    static let THE_GOOD_STUFF = "https://www.youtube.com/watch?v=dQw4w9WgXcQ" // good stuff indeed!
  }

  enum Error {
    enum Title {
      static let SERVER_ERROR = "key.title.server_error"
      static let CONNECTION_ERROR = "key.title.connection_error"
      static let UNKNOWN_ERROR = "key.title.unknown_error"
    }

    enum Message {
      static let SERVER_ERROR_BAD_RESPONSE = "key.message.server_error.bad_response"
      static let SERVER_ERROR_BAD_DATA = "key.message.server_error.bad_data"
      static let CONNECTION_ERROR = "key.message.connection_error"
      static let UNKNOWN_ERROR = "key.message.unknown_error"
    }
  }
}
