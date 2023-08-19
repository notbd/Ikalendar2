//
//  StyleConstants.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

/// Constant data holding `style parameters` for the app.
extension Constants.Styles {
  enum Global {
    static let SHADOW_RADIUS: CGFloat = 6
    static let MIN_TEXT_SCALE_FACTOR: CGFloat = 0.3
    static let ANIMATION_DURATION = 0.2
  }

  enum Frame {
    static let MIN_TAPPABLE_AREA_SIDE: CGFloat = 44
  }

  enum Overlay {
    enum Loading {
      static let FRAME_CORNER_RADIUS: CGFloat = 5
    }

    enum AutoLoading {
      static let SFSYMBOL_FONT: Font = .system(size: 20, weight: .medium)
      static let FRAME_SIDE: CGFloat = 36
      static let FRAME_CORNER_RADIUS: CGFloat = 5

      static let LOADING_SFSYMBOL = "icloud.and.arrow.down.fill"
      static let LOADED_SUCCESS_SFSYMBOL = "checkmark.icloud.fill"
      static let LOADED_FAILURE_SFSYMBOL = "exclamationmark.icloud.fill"
      static let REGULAR_SFSYMBOL = "icloud.fill"
    }
  }

  enum ToolbarButton {
    static let SFSYMBOL_FONT_SIZE_REG: Font = .system(size: 17, weight: .medium)
    static let SFSYMBOL_FONT_SIZE_SMALL: Font = .system(size: 15, weight: .medium)
    static let IMG_SIDE_LEN: CGFloat = 28

    static let FRAME_SIDE_LEN: CGFloat = 36
    static let FRAME_CORNER_RADIUS: CGFloat = 5

    static let GAME_MODE_SWITCH_SFSYMBOL = "rectangle.fill.on.rectangle.angled.fill"
  }

  enum Error {
    static let CONTENT_WIDTH_RATIO: CGFloat = 0.8

    static let IF_USE_CUSTOM_FONT = true
    static let TITLE_CUSTOM_FONT_SIZE: CGFloat = 36
    static let MESSAGE_CUSTOM_FONT_SIZE: CGFloat = 19
    static let TITLE_MESSAGE_SPACING: CGFloat = 4
  }

  enum Settings {
    enum Main {
      static let DEFAULT_GAME_MODE_SFSYMBOL = "rectangle.topthird.inset.filled"
      static let DEFAULT_BATTLE_MODE_SFSYMBOL = "rectangle.bottomthird.inset.filled"
      static let DEFAULT_MODE_PICKER_SPACING: CGFloat = 40

      static let COLOR_SCHEME_SFSYMBOL = "circle.lefthalf.fill"
      static let COLOR_SCHEME_PICKER_SPACING_en: CGFloat = 20
      static let COLOR_SCHEME_PICKER_SPACING_ja: CGFloat = 16

      static let APP_ICON_SFSYMBOL = "square.stack"

      static let ADVANCED_SFSYMBOL = "wand.and.stars"

      static let PREF_LANG_SFSYMBOL = "globe"
      static let PREF_LANG_JUMP_SFSYMBOL = "arrow.up.forward.app.fill"

      static let ABOUT_SFSYMBOL = "house.fill"

      static let CREDITS_SFSYMBOL = "bookmark.fill"

      static let DONE_BUTTON_FONT_WEIGHT: Font.Weight = .semibold
    }

    enum Advanced {
      static let ALT_STAGE_IMG_SFSYMBOL = "compass.drawing"

      static let BOTTOM_TOOLBAR_PICKER_POSITIONING_SFSYMBOL = "arrow.left.arrow.right"
    }

    enum About {
      static let APP_ICON_NAME = "AppIcon"
      static let APP_ICON_SIDE_LEN: CGFloat = 120
      static let APP_ICON_CORNER_RADIUS: CGFloat = 16
      static let APP_ICON_TITLE_FONT: Font = .system(.largeTitle, design: .rounded)
      static let APP_ICON_TITLE_FONT_WEIGHT: Font.Weight = .bold
      static let APP_ICON_SUBTITLE_FONT: Font = .system(.subheadline, design: .monospaced)
      static let APP_ICON_SUBTITLE_FONT_WEIGHT: Font.Weight = .regular

      static let SHARE_SFSYMBOL = "square.and.arrow.up"

      static let TWITTER_ICON_NAME = "twitter_xsmall"
      static let TWITTER_ICON_SIDE_LEN: CGFloat = 17

      static let EMAIL_SFSYMBOL = "envelope"

      static let RATING_SFSYMBOL = "star.leadinghalf.filled"

      static let REVIEW_SFSYMBOL = "highlighter"

      static let VIEW_ON_APP_STORE_SFSYMBOL = "doc.text.fill.viewfinder"

      static let SOURCE_CODE_SFSYMBOL = "chevron.left.slash.chevron.right"

      static let PRIVACY_POLICY_SFSYMBOL = "hand.raised.fill"
    }
  }

  enum Rotation {
    enum Label {
      static let BACKGROUND_CORNER_RADIUS: CGFloat = 5
      static let TEXT_PADDING_HORIZONTAL: CGFloat = 6
    }

    // MARK: - SALMON RUN

    enum Salmon {
      enum Header {
        static let FIRST_PREFIX_STRINGS = (active: "Open!", idle: "Soon:")
        static let SECOND_PREFIX_STRINGS = (active: "Next:", idle: "After the Next:")

        static let PREFIX_FRAME_CORNER_RADIUS: CGFloat = 8
        static let FONT_SIZE: CGFloat = 15
        static let PREFIX_PADDING: CGFloat = 8
      }

      enum Cell {
        static let STAGE_HEIGHT_RATIO: CGFloat = 0.36
        static let STAGE_HEIGHT_ADJUSTMENT_CONSTANT: CGFloat = -25

        static let CELL_SPACING: CGFloat = 10
        static let CELL_PADDING_TOP: CGFloat = 2
        static let CELL_PADDING_BOTTOM: CGFloat = 6

        static let PROGRESS_FONT_SIZE: CGFloat = 15

        enum TimeTextSection {
          static let SALMON_ICON_WIDTH_RATIO: CGFloat = 0.08
          static let TIME_TEXT_SPACING: CGFloat = 4
          static let TIME_TEXT_FONT_SIZE: CGFloat = 20
          static let TIME_TEXT_SINGLE_PADDING_HORIZONTAL: CGFloat = 5
          static let TIME_TEXT_FRAME_CORNER_RADIUS: CGFloat = 6
        }
      }

      enum Card {
        enum Stage {
          static let STAGE_IMG_CORNER_RADIUS: CGFloat = 4

          static let LABEL_FONT_SIZE: CGFloat = 12
          static let OVERLAY_PADDING: CGFloat = 4

          static let APPAREL_IMG_PADDING: CGFloat = 2
          static let APPAREL_IMG_WIDTH_RATIO: CGFloat = 0.15
          static let APPAREL_FRAME_CORNER_RADIUS: CGFloat = 5
        }

        enum Weapon {
          static let IMG_PADDING: CGFloat = 3
          static let FRAME_CORNER_RADIUS: CGFloat = 5
        }
      }
    }

    // MARK: - BATTLE

    enum Battle {
      enum Header {
        static let CURRENT_PREFIX_STRING = "Now:"
        static let NEXT_PREFIX_STRING = "Next:"

        static let SPACING: CGFloat = 16

        static let PREFIX_FRAME_CORNER_RADIUS: CGFloat = 8
        static let PREFIX_FONT_SIZE: CGFloat = 16
        static let PREFIX_PADDING: CGFloat = 8

        static let CONTENT_FONT_SIZE: CGFloat = 14
      }

      enum Cell {
        enum Primary {
          static let PROGRESS_BAR_PADDING_TOP: CGFloat = 8
          static let PROGRESS_BAR_PADDING_BOTTOM: CGFloat = 16
          static let STAGE_SECTION_SPACING_RATIO: CGFloat = 0.04
          static let CELL_PADDING_TOP: CGFloat = 0
          static let CELL_PADDING_BOTTOM: CGFloat = 8

          static let RULE_SECTION_SPACING: CGFloat = 10
          static let RULE_IMG_MAX_WIDTH_RATIO: CGFloat = 0.09
          static let RULE_FONT_SIZE_COMPACT: CGFloat = 28
          static let RULE_FONT_SIZE_REGULAR: CGFloat = 48
          static let RULE_SECTION_HEIGHT_RATIO: CGFloat = 0.12

          static let REMAINING_TIME_FONT_RATIO: CGFloat = 0.038
          static let REMAINING_TIME_TEXT_MAX_WIDTH_RATIO: CGFloat = 0.34
          static let REMAINING_TIME_SECTION_WIDTH_RATIO: CGFloat = 0.35
        }

        enum Secondary {
          static let RULE_SECTION_SPACING: CGFloat = 2

          static let RULE_IMG_MAX_WIDTH: CGFloat = 0.1
          static let RULE_IMG_PADDING: CGFloat = 5
          static let RULE_IMG_FRAME_CORNER_RADIUS: CGFloat = 12

          static let RULE_FONT_SIZE: CGFloat = 18
          static let RULE_TITLE_HEIGHT: CGFloat = 24

          static let RULE_SECTION_WIDTH_RATIO: CGFloat = 0.16
          static let RULE_SECTION_PADDING_TRAILING: CGFloat = 10

          static let STAGE_SECTION_SPACING_RATIO: CGFloat = 0.04
          static let STAGE_SECTION_SPACING_ADJUSTMENT_CONSTANT: CGFloat = -6
        }
      }

      enum Card {
        enum Primary {
          static let IMG_CORNER_RADIUS: CGFloat = 4
          static let LABEL_FONT_SIZE: CGFloat = 12
          static let LABEL_PADDING_LEADING: CGFloat = 20
          static let LABEL_PADDING_BOTTOMTRAILING: CGFloat = 2
        }

        enum Secondary {
          static let IMG_CORNER_RADIUS: CGFloat = 4
          static let STAGE_IMG_OFFSET_Y: CGFloat = 6
          static let FONT_SIZE: CGFloat = 11
        }
      }
    }
  }
}
