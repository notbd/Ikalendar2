//
//  TimeLength.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation

/// Represents a time duration broken down into days, hours, minutes, and seconds.
///
/// This struct is useful for converting a time interval into a human-readable, localized string.
public struct TimeLength {
  /// The number of days.
  public let days: Int

  /// The number of hours.
  public let hours: Int

  /// The number of minutes.
  public let minutes: Int

  /// The number of seconds.
  public let seconds: Int

  /// Initializes a `TimeLength` instance.
  /// - Parameters:
  ///   - days: The number of days. Defaults to `0`.
  ///   - hours: The number of hours. Defaults to `0`.
  ///   - minutes: The number of minutes. Defaults to `0`.
  ///   - seconds: The number of seconds. Defaults to `0`.
  public init(
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

  /// Generates a localized, human-readable string representation of the time duration.
  ///
  /// The format and separators are adjusted based on the specified locale. For example,
  /// some languages might not use spaces between components.
  ///
  /// - Parameter locale: The locale to use for localization. Defaults to `Locale.current`.
  /// - Returns: A localized string describing the time length (e.g., "1d 2h 3m 4s").
  public func getLocalizedDescriptionString(locale: Locale = .current) -> String {
    var elements: [String] = []

    // Determine the appropriate suffixes based on locale
    let (daysSuffix, hoursSuffix, minutesSuffix, secondsSuffix) = getLocalizedSuffixes(for: locale)

    if days > 0 {
      elements.append(String(days) + daysSuffix)
    }

    if hours > 0 {
      elements.append(String(hours) + hoursSuffix)
    }

    if minutes > 0 {
      elements.append(String(minutes) + minutesSuffix)
    }

    // Always include seconds
    elements.append(String(seconds) + secondsSuffix)

    // Determine separator based on locale
    let separator = getSeparator(for: locale)
    return elements.joined(separator: separator)
  }

  /// Returns locale-specific suffixes for time units.
  private func getLocalizedSuffixes(for locale: Locale)
    -> (days: String, hours: String, minutes: String, seconds: String)
  {
    if locale.identifier.starts(with: "ja") {
      ("日", "時間", "分", "秒")
    }
    else if
      locale.identifier.starts(with: "zh-Hans") ||
      locale.identifier.starts(with: "zh_Hans")
    {
      ("天", "小时", "分", "秒")
    }
    else if
      locale.identifier.starts(with: "zh-Hant") ||
      locale.identifier.starts(with: "zh_Hant")
    {
      ("天", "小時", "分", "秒")
    }
    else {
      // Default: English abbreviations
      ("d", "h", "m", "s")
    }
  }

  /// Returns the appropriate separator for joining time components based on locale.
  private func getSeparator(for locale: Locale) -> String {
    if
      locale.identifier.starts(with: "ja") ||
      locale.identifier.starts(with: "zh-Hans") ||
      locale.identifier.starts(with: "zh-Hant") ||
      locale.identifier.starts(with: "zh_Hans") ||
      locale.identifier.starts(with: "zh_Hant") ||
      locale.identifier.starts(with: "zh_CN") ||
      locale.identifier.starts(with: "zh_TW")
    {
      "" // No separator for these languages
    }
    else {
      " " // Space separator for other languages
    }
  }
}
