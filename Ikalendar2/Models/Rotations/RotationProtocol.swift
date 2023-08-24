//
//  RotationProtocol.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import Foundation

// MARK: - Rotation

/// Protocol for the rotation
protocol Rotation: Identifiable, Equatable, CustomStringConvertible {
  var id: String { get }
  var description: String { get }
  var startTime: Date { get }
  var endTime: Date { get }
}

extension Rotation {
  /// Check if rotation is current according to the current time.
  /// - Parameter currentTime: The current time.
  /// - Returns: The boolean val.
  func isCurrent(currentTime: Date) -> Bool {
    currentTime > startTime && currentTime < endTime
  }

  /// Check if rotation is expired according to the current time.
  /// - Parameter currentTime: The current time.
  /// - Returns: The boolean val.
  func isExpired(currentTime: Date) -> Bool {
    endTime < currentTime
  }

  /// Check if rotation is yet to be started according to the current time.
  /// - Parameter currentTime: The current time.
  /// - Returns: The boolean val.
  func isFuture(currentTime: Date) -> Bool {
    currentTime > startTime && currentTime > endTime
  }
}
