//
//  StyleConstants.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

/// Constant data holding `style` parameters for the app.
extension Constants.Style {
  enum Global {
    static let SHADOW_RADIUS: CGFloat = 4

    static let EXTERNAL_LINK_SFSYMBOL = "link"
    static let EXTERNAL_LINK_JUMP_SFSYMBOL = "arrow.up.forward.app.fill"
    static var EXTERNAL_LINK_JUMP_ICON: some View {
      Image(systemName: EXTERNAL_LINK_JUMP_SFSYMBOL)
        .symbolRenderingMode(.hierarchical)
    }
  }

  enum Carousel {
    static let COLUMN_FIXED_WIDTH: CGFloat = 390

    enum Column {
      static let LIST_OFFSET_V_FACTOR_PORTRAIT: CGFloat = 0.1
      static let LIST_OFFSET_V_FACTOR_LANDSCAPE: CGFloat = 0.12
      static let MODE_ICON_SIZE_FACTOR: CGFloat = 1.3

      static let MASK_GRADIENT_DENSITY_PORTRAIT: Int = 32
      static let MASK_GRADIENT_DENSITY_LANDSCAPE: Int = 24
    }
  }

  enum Overlay {
    enum Loading {
      static let FRAME_CORNER_RADIUS: CGFloat = 5
    }

    enum AutoLoading {
      static let SFSYMBOL_FONT: Font = .system(size: 20, weight: .medium)
      static let FRAME_SIDE: CGFloat = 36
      static let FRAME_CORNER_RADIUS: CGFloat = 5

      static let LOADING_SFSYMBOL = "arrow.triangle.2.circlepath.icloud.fill"
      static let LOADED_SUCCESS_SFSYMBOL = "checkmark.icloud.fill"
      static let LOADED_FAILURE_SFSYMBOL = "exclamationmark.icloud.fill"
    }

    enum ModeIcon {
      static let ROTATION_3D_INTENSITY: Double = 24
      static let ROTATION_2D_DEGREES: Double = 8
      static let ICON_OFFSET_X: CGFloat = -10
      static let ICON_OFFSET_Y: CGFloat = -90

      static let ICON_IMG_FILN_SALMON = "mr-grizz"
      static let ICON_SIZE: CGFloat = 128
    }
  }

  enum ToolbarButton {
    static let SFSYMBOL_FONT_SIZE_REG: Font = .system(.headline)
    static let SFSYMBOL_FONT_SIZE_SMALL: Font = .system(size: 15, weight: .medium)
    static let IMG_SIZE: CGFloat = 28

    static let FRAME_SIZE: CGFloat = 36
    static let FRAME_CORNER_RADIUS: CGFloat = 5

    static let GAME_MODE_SWITCH_SFSYMBOL = "rectangle.fill.on.rectangle.angled.fill"
  }

  enum Error {
    static let ERROR_SECTION_PADDING_TOP_HEIGHT_RATIO: CGFloat = 0.22
    static let ERROR_SECTION_SPACING_HEIGHT_RATIO: CGFloat = 0.14
    static let ERROR_IMG_HEIGHT_RATIO: CGFloat = 0.12

    static let TEXT_SECTION_SPACING: CGFloat = 40
    static let MESSAGE_LINE_SPACING: CGFloat = 6

    static let IF_USE_CUSTOM_FONT = true
    static let TITLE_CUSTOM_FONT_SIZE: CGFloat = 36
    static let MESSAGE_CUSTOM_FONT_SIZE: CGFloat = 19
  }

  enum Settings {
    enum Main {
      static let DEFAULT_MODE_PICKER_NAME_SHOWED_THRESHOLD: CGFloat = 375

      static let COLOR_SCHEME_SFSYMBOL = "circle.lefthalf.filled"
      static let COLOR_SCHEME_MENU_SFSYMBOL = "chevron.up.chevron.down"

      static let ADVANCED_OPTIONS_SFSYMBOL = "wand.and.rays"

      static let ABOUT_SFSYMBOL = "house.fill"

      static let CREDITS_SFSYMBOL = "bookmark.fill"

      static let DONE_BUTTON_FONT: Font = .headline
    }

    enum AltAppIcon {
      static let SPACING_H: CGFloat = 16

      static let APP_ICON_STROKE_COLOR: Color = .tertiaryLabel
      static let APP_ICON_STROKE_LINE_WIDTH: CGFloat = 1
      static let APP_ICON_STROKE_OPACITY: CGFloat = 0.4

      static let DISPLAY_NAME_COLOR: Color = .primary

      static let ACTIVE_INDICATOR_SFSYMBOL = "checkmark.circle.fill"
      static let ACTIVE_INDICATOR_FONT: Font = .title

      static let ROW_PADDING_V: CGFloat = 5
    }

    enum Advanced {
      static let BOTTOM_TOOLBAR_PICKER_POSITIONING_SFSYMBOL = "arrow.left.arrow.right"
      static let BOTTOM_TOOLBAR_PREVIEW_SHEET_DETENTS_FRACTION: CGFloat = 0.07
      static let BOTTOM_TOOLBAR_PREVIEW_PADDING_H: CGFloat = 14
      static let BOTTOM_TOOLBAR_PREVIEW_LINGER_INTERVAL: TimeInterval = 1.5

      static let ALT_STAGE_IMG_SFSYMBOL = "compass.drawing"
      static let ALT_STAGE_PREVIEW_SHUFFLE_SFSYMBOL = "arrow.triangle.2.circlepath"

      static let PREVIEW_CELL_MAX_WIDTH: CGFloat = 390
    }

    enum About {
      static let APP_ICON_STROKE_COLOR: Color = .tertiaryLabel
      static let APP_ICON_STROKE_LINE_WIDTH: CGFloat = 1
      static let APP_ICON_STROKE_OPACITY: CGFloat = 0.4
      static let APP_ICON_TITLE_FONT: Font = .system(.title, design: .rounded)
      static let APP_ICON_TITLE_FONT_WEIGHT: Font.Weight = .bold
      static let APP_ICON_SUBTITLE_FONT: Font = .system(.subheadline, design: .monospaced)
      static let APP_ICON_SUBTITLE_FONT_WEIGHT: Font.Weight = .regular

      static let SHARE_SFSYMBOL = "square.and.arrow.up"

      static let RATING_SFSYMBOL = "star.bubble.fill"
      static let REVIEW_SFSYMBOL = "highlighter"
      static let VIEW_ON_APP_STORE_SFSYMBOL = "doc.viewfinder.fill"

      static let TWITTER_ICON_NAME = "twitter_xsmall"
      static let TWITTER_ICON_SIZE_LARGE: CGFloat = 20
      static let TWITTER_ICON_SIZE_SMALL: CGFloat = 18
      static let EMAIL_SFSYMBOL = "envelope"

      static let SOURCE_CODE_SFSYMBOL = "chevron.left.slash.chevron.right"
      static let PRIVACY_POLICY_SFSYMBOL = "hand.raised"
      static let APP_WEBSITE_SFSYMBOL = "globe"
      static let DEBUG_OPTIONS_SFSYMBOL = "hammer"

      static let LITTLE_BUDDY_HEIGHT: CGFloat = 36
      static let SLOGAN_IKALENDAR3_FONT_SIZE: CGFloat = 13
    }

    enum Credits {
      static let CELL_SPACING_V: CGFloat = 4
      static let CELL_SPACING_V_SMALL: CGFloat = 6
      static let CELL_PADDING_V: CGFloat = 1
      static let CELL_CONTENT_FONT_PRIMARY: Font = .system(.subheadline, design: .rounded).bold()
      static let CELL_CONTENT_FONT_SECONDARY: Font = .system(.footnote, design: .rounded)
      static let DISCLAIMER_FONT_SIZE: CGFloat = 13
    }

    enum License {
      static let CONTENT_SPACING_V: CGFloat = 24
      static let LICENSE_SFSYMBOL = "doc.text"
      static let ERROR_SFSYMBOL = "exclamationmark.triangle.fill"
      static let LICENSE_ICON_FONT: Font = .largeTitle
      static let LICENSE_ICON_FONT_WEIGHT: Font.Weight = .medium
      static let LICENSE_CAPTION_FONT: Font = .caption
      static let LICENSE_TYPE_FONT: Font = .title
      static let LICENSE_CONTENT_FONT_COMPACT: Font = .system(size: 7.5, design: .monospaced)
      static let LICENSE_CONTENT_FONT_REGULAR: Font = .system(.caption, design: .monospaced)
    }
  }

  enum Onboarding {
    static let STROKE_COLOR: Color = .tertiaryLabel
    static let STROKE_LINE_WIDTH: CGFloat = 1
    static let STROKE_OPACITY: CGFloat = 0.3
    static let TITLE_FONT: Font = .system(size: 42, design: .rounded)
    static let TITLE_FONT_WEIGHT: Font.Weight = .heavy
    static let BUTTON_FONT: Font = .system(.headline, design: .rounded, weight: .semibold)
    static let BUTTON_TEXT_PADDING_V: CGFloat = 14
    static let BUTTON_RECT_CORNER_RADIUS: CGFloat = 12
  }

  enum Rotation {
    enum Label {
      static let TEXT_PADDING_H: CGFloat = 6
      static let TEXT_PADDING_V: CGFloat = 3
      static let BACKGROUND_CORNER_RADIUS: CGFloat = 4
    }

    enum Header {
      static let SPACING: CGFloat = 16

      static let PREFIX_FRAME_CORNER_RADIUS: CGFloat = 8
      static let PREFIX_FONT_SIZE: CGFloat = 16
      static let PREFIX_PADDING_H: CGFloat = 8

      static let CONTENT_FONT_SIZE: CGFloat = 16

      enum Battle {
        static let CURRENT_PREFIX_STRING = "Now:"
        static let NEXT_PREFIX_STRING = "Next:"
      }

      enum Salmon {
        static let FIRST_PREFIX_STRINGS = (pending: "Soon:", active: "Open!")
        static let SECOND_PREFIX_STRING = "Next:"
      }
    }

    // MARK: - BATTLE

    enum Battle {
      enum Cell {
        enum Primary {
          static let CELL_SPACING_V: CGFloat = 8
          static let PROGRESS_BAR_PADDING_BOTTOM: CGFloat = 8
          static let CELL_PADDING_TOP: CGFloat = 0
          static let CELL_PADDING_BOTTOM: CGFloat = 6

          static let RULE_SECTION_SPACING: CGFloat = 8
          static let RULE_SECTION_PADDING_LEADING: CGFloat = 10

          static let RULE_TITLE_FONT_SIZE_MAX: CGFloat = 48
          static let RULE_TITLE_TEXT_STYLE_RELATIVE_TO: Font.TextStyle = .title
          static let RULE_TITLE_PADDING_V: CGFloat = 4

          static let RULE_SECTION_WIDTH_RATIO: CGFloat = 0.45
          static let RULE_SECTION_HEIGHT_RATIO: CGFloat = 0.115

          static let REMAINING_TIME_FONT_SIZE: CGFloat = 15
          static let REMAINING_TIME_TEXT_STYLE_RELATIVE_TO: Font.TextStyle = .headline
          static let REMAINING_TIME_SECTION_WIDTH_RATIO: CGFloat = 0.32
        }

        enum Secondary {
          static let RULE_SECTION_SPACING: CGFloat = 2

          static let RULE_IMG_HEIGHT_RATIO: CGFloat = 0.1
          static let RULE_IMG_PADDING: CGFloat = 5
          static let RULE_IMG_FRAME_CORNER_RADIUS: CGFloat = 12

          static let RULE_FONT_SIZE: CGFloat = 18
          static let RULE_TITLE_HEIGHT: CGFloat = 24

          static let RULE_SECTION_WIDTH_RATIO: CGFloat = 0.16
          static let RULE_SECTION_PADDING_TRAILING: CGFloat = 10
        }
      }

      enum Card {
        enum Primary {
          static let IMG_CORNER_RADIUS: CGFloat = 4
          static let LABEL_FONT_SIZE: CGFloat = 13
          static let LABEL_PADDING_LEADING: CGFloat = 20
          static let LABEL_PADDING_BOTTOMTRAILING: CGFloat = 2
        }

        enum Secondary {
          static let SPACING_V: CGFloat = 4
          static let IMG_CORNER_RADIUS: CGFloat = 4
          static let FONT_SIZE: CGFloat = 12
        }
      }
    }

    // MARK: - SALMON RUN

    enum Salmon {
      enum Cell {
        static let CELL_SPACING: CGFloat = 10
        static let CELL_PADDING_VERTICAL: CGFloat = 6

        static let PROGRESS_FONT_SIZE: CGFloat = 16

        enum TimeTextSection {
          static let ICON_GOLDEN_EGG_SCALE_FACTOR: CGFloat = 1.5
          static let ICON_SALMON_FISH_SCALE_FACTOR: CGFloat = 0.9
          static let SALMON_ICON_HEIGHT_RATIO: CGFloat = 0.065
          static let TIME_TEXT_SPACING: CGFloat = 4
          static let TIME_TEXT_FONT_SIZE: CGFloat = 16
          static let TIME_TEXT_SINGLE_PADDING_H: CGFloat = 6
          static let TIME_TEXT_SINGLE_PADDING_V: CGFloat = 4
          static let TIME_TEXT_FRAME_CORNER_RADIUS: CGFloat = 6
        }
      }

      enum Card {
        enum Stage {
          static let STAGE_IMG_CORNER_RADIUS: CGFloat = 4

          static let LABEL_FONT_SIZE: CGFloat = 13
          static let OVERLAY_PADDING: CGFloat = 4

          static let APPAREL_IMG_PADDING: CGFloat = 2
          static let APPAREL_IMG_WIDTH_RATIO: CGFloat = 0.16
          static let APPAREL_FRAME_CORNER_RADIUS: CGFloat = 5
        }

        enum Weapon {
          static let IMG_PADDING: CGFloat = 3
          static let FRAME_CORNER_RADIUS: CGFloat = 5
        }
      }
    }
  }
}
