//
//  TimeLength.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import Foundation

/// A custom time interval struct that provides quick conversion into descriptive strings.
struct TimeLength {
  let days: Int
  let hours: Int
  let minutes: Int
  let seconds: Int

  // MARK: Lifecycle

  init(
    days: Int = 0,
    hours: Int = 0,
    minutes: Int = 0,
    seconds: Int = 0)
  {
    self.days = days
    self.hours = hours
    self.minutes = minutes
    self.seconds = seconds
  }

  // MARK: Internal

  /// Generate a localized string representation for the interval.
  ///   - locale: The locale of the translation(default to .current).
  /// - Returns: The localized description String.
  func getLocalizedDescriptionString(locale: Locale = .current) -> String {
    var elements: [String] = []

    if days > 0 {
      elements.append(String(days) + String(localized: "days"))
    }

    if hours > 0 {
      elements.append(String(hours) + String(localized: "hours"))
    }

    if minutes > 0 {
      elements.append(String(minutes) + String(localized: "minutes"))
    }

    // Always include seconds
    elements.append(String(seconds) + String(localized: "seconds"))

    // Japanese
    if locale.identifier.starts(with: "ja") {
      return elements.joined()
    }

    // Simplified Chinese
    else if locale.identifier.starts(with: "zh_Hans") {
      return elements.joined()
    }

    // Traditional Chinese
    else if locale.identifier.starts(with: "zh_Hant") {
      return elements.joined()
    }

    // default: English
    else {
      return elements.joined(separator: " ")
    }
  }
}
