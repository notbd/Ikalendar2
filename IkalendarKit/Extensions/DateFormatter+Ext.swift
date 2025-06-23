//
//  DateFormatter+Ext.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation

extension DateFormatter {
  /// Pre-defined date formatter types for common use cases within the app.
  public enum IkaDateFormatterType {
    /// A time-only formatter.
    ///
    /// The format is automatically localized for supported languages.
    /// - **Examples:**
    ///   - `ah:mm` for Japanese (`午後10:00`)
    ///   - `h:mm a` for English (`10:00 PM`)
    case time

    /// A date-only formatter.
    ///
    /// The format is automatically localized for supported languages.
    /// - **Examples:**
    ///   - `M/d(E)` for Japanese (`10/26(土)`)
    ///   - `E, M/d,` for English (`Sat, 10/26,`)
    case date
  }

  /// Creates a `DateFormatter` with a pre-defined, localized format.
  ///
  /// This initializer simplifies the creation of date formatters for common app-specific needs
  /// by providing a set of `IkaDateFormatterType` cases. The resulting formatter is automatically
  /// configured with a locale-aware date format.
  ///
  /// - Parameters:
  ///   - ikaType: The `IkaDateFormatterType` that specifies the desired format.
  ///   - locale: The locale to use for formatting. If `nil`, uses `Locale.current`.
  convenience public init(ikaType: IkaDateFormatterType, locale: Locale? = nil) {
    self.init()

    let targetLocale = locale ?? Locale.current
    self.locale = targetLocale

    switch ikaType {
      case .time:
        if targetLocale.identifier.starts(with: "ja") {
          // Japanese
          dateFormat = "ah:mm"
        }
//      else if targetLocale.identifier.starts(with: "zh_Hans") {
//        // Simplified Han
//        dateFormat = "a h:mm"
//      }
//      else if targetLocale.identifier.starts(with: "zh_Hant") {
//        // Traditional Han
//        dateFormat = "a h:mm"
//      }
        else {
          // default: English
          dateFormat = "h:mm a"
        }

      case .date:
        if targetLocale.identifier.starts(with: "ja") {
          // Japanese
          dateFormat = "M/d(E) "
        }
//      else if targetLocale.identifier.starts(with: "zh_Hans") {
//        // Simplified Han
//        dateFormat = "ah:mm"
//      }
//
//      else if targetLocale.identifier.starts(with: "zh_Hant") {
//        // Traditional Han
//        dateFormat = "ah:mm"
//      }
        else {
          // default: English
          dateFormat = "E, M/d, "
        }
    }
  }
}
