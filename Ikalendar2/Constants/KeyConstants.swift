//
//  KeyConstants.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import Foundation

/// Constant data holding `keys` for the app.
extension Constants.Keys {
  enum Global {
    static let UNKNOWN = "UNKNOWN"
  }

  enum BundleInfo {
    static let APP_BUNDLE_NAME =
      Bundle.main.infoDictionary?["CFBundleName"] as? String ?? Constants.Keys.Global.UNKNOWN
    static let APP_DISPLAY_NAME =
      Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? Constants.Keys.Global.UNKNOWN
    static let APP_VERSION =
      Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? Constants.Keys.Global.UNKNOWN
    static let APP_BUILD =
      Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? Constants.Keys.Global.UNKNOWN
    static let APP_STORE_IDENTIFIER = "1529193361"
  }

  enum AppStorage {
    static let DEFAULT_GAME_MODE = "pref.default.game_mode"
    static let DEFAULT_BATTLE_MODE = "pref.default.battle_mode"

    static let PREFERRED_APP_COLOR_SCHEME = "pref.preferred_app_color_scheme"

    static let PREFERRED_APP_ICON = "pref.preferred_app_icon"

    static let IF_USE_ALT_STAGE_IMAGES = "pref.if_use_alt_stage_images"
    static let IF_SWAP_BOTTOM_TOOLBAR_PICKERS = "pref.if_swap_bottom_toolbar_pickers"
  }

  enum URL {
    static let TWITTER_BASE = "https://twitter.com"
    static let GITHUB_BASE = "https://github.com"

    static let BATTLE_ROTATIONS = "https://splatoon2.ink/data/schedules.json"
    static let SALMON_ROTATIONS = "https://splatoon2.ink/data/coop-schedules.json"
    static let SALMON_APPAREL_INFO = "https://splatoon2.ink/data/timeline.json"

    static let NINTENDO_SPLATOON2_PAGE =
      "https://www.nintendo.com/store/products/splatoon-2-switch/"
    static let DEVELOPER_TWITTER = "https://twitter.com/defnotbd"
    static let DEVELOPER_EMAIL = "mailto:defnotbd@outlook.com"
    static let APP_STORE_PAGE = "https://apps.apple.com/app/id1529193361"
    static let APP_STORE_PAGE_US = "https://apps.apple.com/us/app/ikalendar2/id1529193361"
    static let APP_STORE_REVIEW = "https://apps.apple.com/app/id1529193361?action=write-review"
    static let SOURCE_CODE_REPO = "https://github.com/notbd/Ikalendar2"
    static let PRIVACY_POLICY = "https://github.com/notbd/Ikalendar2/wiki/Privacy-Policy"

    static let THE_GOOD_STUFF = "https://www.youtube.com/watch?v=dQw4w9WgXcQ" // good stuff indeed!
  }

  enum Locale {
    static let EN = "English"
    static let JA = "日本語"
    static let ZH_HANS = "简体中文(beta)"
    static let ZH_HANT = "繁體中文(beta)"
  }

  enum Error {
    enum Title {
      static let SERVER_ERROR = "key.title.server_error"
      static let CONNECTION_ERROR = "key.title.connection_error"
      static let UNKNOWN_ERROR = "key.title.unknown_error"
      static let MAX_ATTEMPTS_EXCEEDED = "key.title.max_attempts_exceeded" // not used for now
    }

    enum Message {
      static let SERVER_ERROR_BAD_RESPONSE = "key.message.server_error.bad_response"
      static let SERVER_ERROR_BAD_DATA = "key.message.server_error.bad_data"
      static let CONNECTION_ERROR = "key.message.connection_error"
      static let UNKNOWN_ERROR = "key.message.unknown_error"
      static let MAX_ATTEMPTS_EXCEEDED = "key.message.max_attempts_exceeded" // not used for now
    }
  }
}
