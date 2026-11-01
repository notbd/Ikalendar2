//
//  RotationProtocol.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation

// MARK: - Rotation

/// Protocol that defines the requirements for a rotation.
///
/// A rotation event has a unique identifier, a time range during which it occurs,
/// and should be describable, equatable, and hashable.
///
/// Conforming types should primarily implement the `description` property and set
/// the values for `startTime` and `endTime`.
protocol Rotation: Identifiable, CustomStringConvertible, Equatable, Hashable {
  /// Uniquely identifies a rotation event based on its time range.
  ///
  /// The default implementation joins the `description`s of `startTime` and `endTime`
  /// (e.g. `2023-11-14 22:00:00 +0000-2023-11-16 16:00:00 +0000`).
  var id: String { get }

  /// Provides a string representation of a rotation event.
  ///
  /// This is primarily used for debugging and also serves as the basis for generating hash values.
  var description: String { get }

  /// The time when the rotation event starts.
  var startTime: Date { get }

  /// The date and time when the rotation event ends.
  var endTime: Date { get }
}

extension Rotation {
  /// Default implementation of the `id` property.
  ///
  /// Constructs the ID by joining the `description`s of the `startTime` and `endTime` properties.
  var id: String { "\(startTime)-\(endTime)" }

  /// Equates two `Rotation` instances based on their `description`s, the same value
  /// `hash(into:)` hashes (exact, unlike comparing `hashValue`s, which can collide; 4ca6526).
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.description == rhs.description
  }

  /// Hashes `description`, the same value `==` compares. Needed because SalmonRotation holds
  /// `[SalmonWeapon]?`, which is Equatable but not Hashable.
  func hash(into hasher: inout Hasher) {
    hasher.combine(description)
  }
}

extension Rotation {
  /// Determines whether the rotation has expired based on the current time.
  func isExpired(_ currentTime: Date) -> Bool {
    endTime <= currentTime
  }

  /// Determines whether the rotation is currently active based on the current time.
  func isCurrent(_ currentTime: Date) -> Bool {
    startTime <= currentTime &&
      endTime > currentTime
  }

  /// Determines whether the rotation is scheduled for the future based on the current time.
  func isFuture(_ currentTime: Date) -> Bool {
    startTime > currentTime
  }
}
