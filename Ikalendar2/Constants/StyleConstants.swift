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
    static let shadowRadius: CGFloat = 2

    static let externalLinkJumpSFSymbol = "arrow.up.forward.app.fill"
    static var externalLinkJumpIcon: some View {
      Image(systemName: externalLinkJumpSFSymbol)
        .symbolRenderingMode(.hierarchical)
    }
  }

  enum Carousel {
    /// The window width from which iPad landscape shows every column at once.
    static let allColumnsMinWidth: CGFloat = 1024

    enum Column {
      static let listOffsetVFactorPortrait: CGFloat = 0.1
      static let listOffsetVFactorLandscape: CGFloat = 0.12
      static let modeIconSizeFactor: CGFloat = 1.3

      /// The band at the list's top over which scrolled rows fade out.
      static let listFadeHeight: CGFloat = 32

      static let scrollIndicatorMarginV: CGFloat = 20
    }
  }

  enum Overlay {
    enum AutoLoading {
      static let glassEffectContainerSpacing: CGFloat = 28
      static let symbolFont: Font = .system(size: 18)
      static let subtitle: String = "Autoloading..."
      static let subtitleFont: Font = .system(size: 14, weight: .medium, design: .rounded)
      static let subtitlePaddingH: CGFloat = 10
      static let frameSide: CGFloat = 44
      static let frameCornerRadius: CGFloat = 14
      static let loadingSymbolRepeatDelay: TimeInterval = 0.2

      static let loadingSFSymbol = "arrow.trianglehead.2.clockwise.rotate.90.icloud.fill"
      static let loadedSuccessSFSymbol = "checkmark.circle.fill"
      static let loadedFailureSFSymbol = "exclamationmark.triangle.fill"
    }

    enum ModeIcon {
      static let rotation3dIntensity: Double = 24
      static let rotation2dDegrees: Double = 8
      static let iconOffsetX: CGFloat = -10
      static let iconOffsetY: CGFloat = -90

      static let iconImageNameSalmon = "mr-grizz"
      static let iconSize: CGFloat = 128

      /// The scroll distance over which the stamp docks into the nav bar badge.
      static let dockTravel: CGFloat = 44
      static let dockedScale: Double = 0.65
      /// The dock progress by which the stamp has faded out.
      static let dockFadeOutEnd: Double = 0.7
      /// The dock progress from which the badge fades in.
      static let badgeFadeInStart: Double = 0.5
      static let badgeSize: CGFloat = 44
      static let badgeImageSize: CGFloat = 28
      /// For the regular and salmon images, whose artwork looks smaller at the same size.
      static let badgeImageSizeSparse: CGFloat = 30
    }
  }

  enum Error {
    static let errorSectionPaddingTopHeightRatio: CGFloat = 0.22
    static let errorSectionSpacingHeightRatio: CGFloat = 0.14
    static let errorImageHeightRatio: CGFloat = 0.12

    static let textSectionSpacing: CGFloat = 40
    static let messageLineSpacing: CGFloat = 6

    static let titleCustomFontSize: CGFloat = 36
    static let messageCustomFontSize: CGFloat = 19
  }

  enum Settings {
    enum Main {
      static let colorSchemeSFSymbol = "circle.lefthalf.filled"

      static let advancedOptionsSFSymbol = "wand.and.rays"

      static let aboutSFSymbol = "house.fill"

      static let creditsSFSymbol = "bookmark.fill"
    }

    enum AltAppIcon {
      static let modalDimmingLayerOpacity: CGFloat = 0.35

      /// Opacity of the hidden "Tap Me :)" trigger before the egg is discovered: faint on light
      /// mode and compact width, fainter on dark mode at regular width.
      static let hintOpacityCompact: Double = 0.07
      static let hintOpacityRegular: Double = 0.03

      static let safeAreaBarGlassEffectSpacing: CGFloat = 8
      static let safeAreaBarDefaultFont: Font = .headline
      static let colorVariantPickerFont: Font = .system(.title3, design: .rounded, weight: .medium)

      static let slideShowControlButtonSize: CGFloat = 44
      static let slideShowControlPickerNameLabelPaddingH: CGFloat = 18
      static let slideShowNextButtonDisabledOpacity: CGFloat = 0.3
      static let slideShowProgressBarOpacity: CGFloat = 0.8
      static let slideShowProgressBarHeight: CGFloat = 1
      static let slideShowProgressBarPaddingH: CGFloat = 8

      enum Row {
        static let spacingH: CGFloat = 16

        static let displayNameColor: Color = .primary

        static let activeIndicatorSFSymbol = "checkmark.circle.fill"
        static let activeIndicatorFont: Font = .title

        static let rowPaddingV: CGFloat = 5
      }
    }

    enum Advanced {
      static let tabBarMinimizingOffSFSymbol = "arrow.left.and.line.vertical.and.arrow.right"
      static let tabBarMinimizingOnSFSymbol = "arrow.right.and.line.vertical.and.arrow.left"

      static let altStageImageSFSymbol = "compass.drawing"
      static let altStagePreviewShuffleSFSymbol = "arrow.triangle.2.circlepath"

      static let previewCellMaxWidth: CGFloat = 390
      static let previewCellCornerRadius: CGFloat = 28
    }

    enum About {
      static let appIconTitleFont: Font = .system(.title, design: .rounded)
      static let appIconTitleFontWeight: Font.Weight = .bold
      static let appIconSubtitleFont: Font = .system(.subheadline, design: .monospaced)
      static let appIconSubtitleFontWeight: Font.Weight = .regular

      static let shareSFSymbol = "square.and.arrow.up"

      static let ratingSFSymbol = "star.bubble.fill"
      static let reviewSFSymbol = "highlighter"
      static let viewOnAppStoreSFSymbol = "doc.viewfinder.fill"

      static let twitterIconName = "twitter_xsmall"
      static let twitterIconSizeLarge: CGFloat = 20
      static let twitterIconSizeSmall: CGFloat = 18
      static let emailSFSymbol = "envelope"

      static let sourceCodeSFSymbol = "chevron.left.slash.chevron.right"
      static let privacyPolicySFSymbol = "hand.raised"
      static let appWebsiteSFSymbol = "globe"
      static let debugOptionsSFSymbol = "hammer"

      static let littleBuddyHeight: CGFloat = 36
      static let littleBuddyPaddingTrailing: CGFloat = 10
      static let sloganIkalendar3FontSize: CGFloat = 13
    }

    enum Credits {
      static let cellSpacingV: CGFloat = 4
      static let cellSpacingVSmall: CGFloat = 6
      static let cellPaddingV: CGFloat = 1
      static let cellContentFontPrimary: Font = .system(.subheadline, design: .rounded).bold()
      static let cellContentFontSecondary: Font = .system(.footnote, design: .rounded)
      static let disclaimerFontSize: CGFloat = 13
    }

    enum License {
      static let contentSpacingV: CGFloat = 24
      static let licenseSFSymbol = "doc.text"
      static let errorSFSymbol = "exclamationmark.triangle.fill"
      static let licenseIconFont: Font = .largeTitle
      static let licenseIconFontWeight: Font.Weight = .medium
      static let licenseCaptionFont: Font = .caption
      static let licenseTypeFont: Font = .title
      static let licenseContentFontCompact: Font = .system(size: 7.5, design: .monospaced)
      static let licenseContentFontRegular: Font = .system(.caption, design: .monospaced)
    }
  }

  enum Onboarding {
    static let titleFont: Font = .system(size: 42, design: .rounded)
    static let titleFontWeight: Font.Weight = .heavy
    static let buttonFont: Font = .system(.headline, design: .rounded, weight: .semibold)
    static let buttonTextPaddingV: CGFloat = 10
  }

  enum Rotation {
    enum Label {
      static let textPaddingH: CGFloat = 6
      static let textPaddingV: CGFloat = 3
      static let clipShapeCornerRadius: CGFloat = 8
    }

    enum Header {
      static let spacing: CGFloat = 16

      static let prefixFrameCornerRadius: CGFloat = 8
      static let prefixFontSize: CGFloat = 16
      static let prefixPaddingH: CGFloat = 8

      static let contentFontSize: CGFloat = 16

      enum Battle {
        static let currentPrefixString = "Now:"
        static let nextPrefixString = "Next:"
      }

      enum Salmon {
        static let firstPrefixStrings = (pending: "Soon:", active: "Open!")
        static let secondPrefixString = "Next:"
      }
    }

    // MARK: - Battle

    enum Battle {
      enum Cell {
        enum Primary {
          static let cellSpacingV: CGFloat = 8
          static let stagesSpacingH: CGFloat = 10

          static let progressBarPaddingBottom: CGFloat = 8
          static let cellPaddingTop: CGFloat = 0
          static let cellPaddingBottom: CGFloat = 6

          static let ruleSectionSpacing: CGFloat = 8

          static let ruleTitleFontSizeMax: CGFloat = 48
          static let ruleTitleTextStyleRelativeTo: Font.TextStyle = .title
          static let ruleTitlePaddingV: CGFloat = 4

          static let ruleSectionWidthRatio: CGFloat = 0.45
          static let ruleSectionHeightRatio: CGFloat = 0.115

          static let remainingTimeFontSize: CGFloat = 15
          static let remainingTimeTextStyleRelativeTo: Font.TextStyle = .headline
          static let remainingTimeSectionWidthRatio: CGFloat = 0.32
        }

        enum Secondary {
          static let ruleSectionSpacing: CGFloat = 2

          static let ruleImageHeightRatio: CGFloat = 0.1
          static let ruleImagePadding: CGFloat = 5
          static let ruleImageFrameCornerRadius: CGFloat = 12

          static let ruleFontSize: CGFloat = 18
          static let ruleTitleHeight: CGFloat = 24

          static let ruleSectionWidthRatio: CGFloat = 0.16
          static let ruleSectionPaddingTrailing: CGFloat = 10
        }
      }

      enum Card {
        enum Primary {
          static let imageCornerRadius: CGFloat = 12
          static let labelFontSize: CGFloat = 13
          static let labelPaddingLeading: CGFloat = 20
          static let labelPaddingBottomTrailing: CGFloat = 2.5
        }

        enum Secondary {
          static let spacingV: CGFloat = 4
          static let imageCornerRadius: CGFloat = 12
          static let fontSize: CGFloat = 12
        }
      }
    }

    // MARK: - Salmon Run

    enum Salmon {
      enum Cell {
        static let cellSpacing: CGFloat = 10
        static let cellPaddingV: CGFloat = 6

        static let progressFontSize: CGFloat = 16

        enum TimeTextSection {
          static let iconGoldenEggScaleFactor: CGFloat = 1.1
          static let iconSalmonFishScaleFactor: CGFloat = 0.9
          static let salmonIconHeightRatio: CGFloat = 0.065
          static let timeTextSpacing: CGFloat = 4
          static let timeTextFontSize: CGFloat = 16
          static let timeTextSinglePaddingH: CGFloat = 6
          static let timeTextSinglePaddingV: CGFloat = 4
          static let timeTextFrameCornerRadius: CGFloat = 6
        }
      }

      enum Card {
        enum Stage {
          static let stageImageCornerRadius: CGFloat = 12

          /// The card width before its first layout pass, and the width from which the larger
          /// stage image is used.
          static let initialCardWidth: CGFloat = 150
          static let largeImageMinWidth: CGFloat = 200

          static let labelFontSize: CGFloat = 13
          static let overlayPadding: CGFloat = 4

          static let apparelImagePadding: CGFloat = 4
          static let apparelImageWidthRatio: CGFloat = 0.16
          static let apparelFrameCornerRadius: CGFloat = 7
        }

        enum Weapon {
          static let imagePadding: CGFloat = 3
          static let frameCornerRadius: CGFloat = 12
        }
      }
    }
  }
}
