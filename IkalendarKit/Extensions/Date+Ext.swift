//
//  Date+Ext.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import SwiftUI

extension Date {
  /// Calculates the time interval between two dates.
  ///
  /// - Parameters:
  ///   - lhs: The later date.
  ///   - rhs: The earlier date.
  /// - Returns: The time interval (in seconds) between the two dates.
  static public func - (
    lhs: Date,
    rhs: Date)
    -> TimeInterval
  {
    lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
  }
}

extension Date {
  /// Returns a new `Date` object with the minutes, seconds, and nanoseconds set to zero.
  ///
  /// This is useful for rounding a date down to the beginning of the hour.
  ///
  /// - Returns: A new `Date` object, or `nil` if the components could not be reassembled into a valid date.
  public func removeMinutes() -> Date? {
    let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: self)
    return Calendar.current.date(from: components)
  }
}

extension Date {
  static private let ikaTimeFormatter: DateFormatter = .init(ikaType: .time)
  static private let ikaDateFormatter: DateFormatter = .init(ikaType: .date)

  /// Formats the date as a string suitable for displaying battle rotation times.
  ///
  /// The format is localized. If `shouldIncludeDate` is `true`, it may also include a relative
  /// date specifier like "Today", "Yesterday", or "Tomorrow".
  ///
  /// - Parameters:
  ///   - shouldIncludeDate: A Boolean value that determines whether to include the date.
  ///     The default is `false`.
  ///   - currentTime: The date to compare against for relative terms. If `nil`, uses the current date.
  ///     The default is `nil`.
  /// - Returns: A formatted time string.
  public func toBattleTimeString(
    shouldIncludeDate: Bool = false,
    currentTime: Date? = nil)
    -> String
  {
    let timeString = Date.ikaTimeFormatter.string(from: self)

    guard shouldIncludeDate
    else { return timeString }

    let calendar = Calendar.current
    let reference = currentTime ?? Date()

    guard !calendar.isDate(self, inSameDayAs: reference)
    else { return String(localized: "Today") + " " + timeString }

    // Check if this date is yesterday relative to reference
    if
      let yesterday = calendar.date(byAdding: .day, value: -1, to: reference),
      calendar.isDate(self, inSameDayAs: yesterday)
    {
      return String(localized: "Yesterday") + " " + timeString
    }

    // Check if this date is tomorrow relative to reference
    if
      let tomorrow = calendar.date(byAdding: .day, value: 1, to: reference),
      calendar.isDate(self, inSameDayAs: tomorrow)
    {
      return String(localized: "Tomorrow") + " " + timeString
    }

    // Battle time should always be within the next 24 hours, therefore
    // other cases do not matter.
    return timeString
  }

  /// Formats the date as a string suitable for displaying Salmon Run schedule times.
  ///
  /// The format is localized. If `shouldIncludeDate` is `true`, it may also include a relative
  /// date specifier like "Today", "Yesterday", "Tomorrow", or the full date for other days.
  ///
  /// - Parameters:
  ///   - shouldIncludeDate: A Boolean value that determines whether to include the date.
  ///     The default is `false`.
  ///   - currentTime: The date to compare against for relative terms. If `nil`, uses the current date.
  ///     The default is `nil`.
  /// - Returns: A formatted time string, potentially including the date.
  public func toSalmonTimeString(
    shouldIncludeDate: Bool = false,
    currentTime: Date? = nil)
    -> String
  {
    let timeString = Date.ikaTimeFormatter.string(from: self)

    guard shouldIncludeDate
    else { return timeString }

    let calendar = Calendar.current
    let reference = currentTime ?? Date()

    guard !calendar.isDate(self, inSameDayAs: reference)
    else { return String(localized: "Today") + " " + timeString }

    // Check if this date is yesterday relative to reference
    if
      let yesterday = calendar.date(byAdding: .day, value: -1, to: reference),
      calendar.isDate(self, inSameDayAs: yesterday)
    {
      return String(localized: "Yesterday") + " " + timeString
    }

    // Check if this date is tomorrow relative to reference
    if
      let tomorrow = calendar.date(byAdding: .day, value: 1, to: reference),
      calendar.isDate(self, inSameDayAs: tomorrow)
    {
      return String(localized: "Tomorrow") + " " + timeString
    }

    // other than Today, Yesterday or Tomorrow
    let dateString = Date.ikaDateFormatter.string(from: self)
    return dateString + timeString
  }

  /// Generates a localized string key that describes the time remaining until a future deadline.
  ///
  /// The resulting key can be used with SwiftUI's `Text` view for localization.
  /// The output format is "remaining [time]", e.g., "remaining 1h 23m".
  /// If the deadline has passed, it returns "Time's Up".
  ///
  /// - Parameters:
  ///   - deadline: The future `Date` to calculate the remaining time against.
  /// - Returns: A `LocalizedStringKey` representing the remaining time.
  public func toTimeRemainingStringKey(until deadline: Date) -> LocalizedStringKey {
    let remainingTime = Int(deadline - self)
    // if time has already passed
    if remainingTime < 0 { return "Time's Up" }
    // convert time interval to TimeLength
    let days = remainingTime / (24 * 60 * 60)
    let hours = (remainingTime / (60 * 60)) % 24
    let minutes = (remainingTime / 60) % 60
    let seconds = remainingTime % 60
    let timeLength = TimeLength(days: days, hours: hours, minutes: minutes, seconds: seconds)
    let timeLengthString = timeLength.getLocalizedDescriptionString()

    return "remaining \(timeLengthString)"
  }

  /// Generates a localized string key that describes the duration until a future deadline.
  ///
  /// The resulting key can be used with SwiftUI's `Text` view for localization.
  /// The output format is "[time] until", e.g., "1h 23m until".
  /// If the deadline has passed, it returns "Time's Up".
  ///
  /// - Parameters:
  ///   - deadline: The future `Date` to calculate the duration against.
  /// - Returns: A `LocalizedStringKey` representing the time until the deadline.
  public func toTimeUntilStringKey(until deadline: Date) -> LocalizedStringKey {
    let untilTime = Int(deadline - self)
    // if time has already passed
    if untilTime < 0 { return "Time's Up" }
    // convert time interval to TimeLength
    let days = untilTime / (24 * 60 * 60)
    let hours = (untilTime / (60 * 60)) % 24
    let minutes = (untilTime / 60) % 60
    let seconds = untilTime % 60
    let timeLength = TimeLength(days: days, hours: hours, minutes: minutes, seconds: seconds)
    let timeLengthString = timeLength.getLocalizedDescriptionString()

    return "\(timeLengthString) until"
  }
}
