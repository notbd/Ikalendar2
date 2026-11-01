//
//  Date+Ext.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import os
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
  /// Cached formatters: they sit on per-second refresh paths and are expensive to create.
  /// `DateFormatter` snapshots the time zone when it is created, so each one is re-synced
  /// with the requested zone before every use (see `string(from:using:in:)`); otherwise
  /// times would keep rendering in the launch-time zone after the device changes zones
  /// (f8ed5d5; pinned by DateTimeZoneTests).
  /// The lock makes that mutation safe from any isolation domain (iOS 17+).
  static private let ikaTimeFormatter: OSAllocatedUnfairLock<DateFormatter> =
    .init(initialState: .init(ikaType: .time))
  static private let ikaDateFormatter: OSAllocatedUnfairLock<DateFormatter> =
    .init(initialState: .init(ikaType: .date))

  /// Formats `date` with a cached formatter after pointing it at `timeZone`.
  static private func string(
    from date: Date,
    using lockedFormatter: OSAllocatedUnfairLock<DateFormatter>,
    in timeZone: TimeZone)
    -> String
  {
    lockedFormatter.withLock { formatter in
      if formatter.timeZone != timeZone { formatter.timeZone = timeZone }
      return formatter.string(from: date)
    }
  }

  /// The time of day in the app's format (e.g. `10:00 PM`), rendered in `timeZone`.
  func ikaTimeString(in timeZone: TimeZone = .current) -> String {
    Date.string(from: self, using: Date.ikaTimeFormatter, in: timeZone)
  }

  /// The date in the app's format (e.g. `Sat, 10/26, `), rendered in `timeZone`.
  func ikaDateString(in timeZone: TimeZone = .current) -> String {
    Date.string(from: self, using: Date.ikaDateFormatter, in: timeZone)
  }

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
    let timeString = ikaTimeString()

    guard shouldIncludeDate
    else { return timeString }

    if let relativeDayString = relativeDayString(to: currentTime ?? Date()) {
      return relativeDayString + " " + timeString
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
    let timeString = ikaTimeString()

    guard shouldIncludeDate
    else { return timeString }

    if let relativeDayString = relativeDayString(to: currentTime ?? Date()) {
      return relativeDayString + " " + timeString
    }

    // other than Today, Yesterday or Tomorrow
    return ikaDateString() + timeString
  }

  /// The localized "Today", "Yesterday" or "Tomorrow" for this date relative to `reference`,
  /// or `nil` for any other day.
  private func relativeDayString(to reference: Date) -> String? {
    let calendar: Calendar = .current

    if calendar.isDate(self, inSameDayAs: reference) {
      return String(localized: "Today")
    }

    // Check if this date is yesterday relative to reference
    if
      let yesterday = calendar.date(byAdding: .day, value: -1, to: reference),
      calendar.isDate(self, inSameDayAs: yesterday)
    {
      return String(localized: "Yesterday")
    }

    // Check if this date is tomorrow relative to reference
    if
      let tomorrow = calendar.date(byAdding: .day, value: 1, to: reference),
      calendar.isDate(self, inSameDayAs: tomorrow)
    {
      return String(localized: "Tomorrow")
    }

    return nil
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
    guard let timeLengthString = timeLengthString(until: deadline)
    else { return "Time's Up" }

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
    guard let timeLengthString = timeLengthString(until: deadline)
    else { return "Time's Up" }

    return "\(timeLengthString) until"
  }

  /// The localized length of time from this date until `deadline` (e.g. "1h 23m"),
  /// or `nil` if the deadline has already passed.
  private func timeLengthString(until deadline: Date) -> String? {
    let remainingTime: Int = .init(deadline - self)
    // if time has already passed
    guard remainingTime >= 0 else { return nil }

    // convert time interval to TimeLength
    let days = remainingTime / (24 * 60 * 60)
    let hours = (remainingTime / (60 * 60)) % 24
    let minutes = (remainingTime / 60) % 60
    let seconds = remainingTime % 60
    let timeLength: TimeLength = .init(days: days, hours: hours, minutes: minutes, seconds: seconds)
    return timeLength.localizedDescription()
  }
}
