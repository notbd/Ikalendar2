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
  /// If rotation is current according to the current time.
  var isCurrent: Bool {
    IkaTimePublisher.shared.currentTime > startTime && IkaTimePublisher.shared.currentTime < endTime
  }

  /// If rotation is expired according to the current time.
  var isExpired: Bool {
    endTime < IkaTimePublisher.shared.currentTime
  }

  /// If rotation is yet to be started according to the current time.
  var isFuture: Bool {
    IkaTimePublisher.shared.currentTime > startTime && IkaTimePublisher.shared.currentTime > endTime
  }
}
