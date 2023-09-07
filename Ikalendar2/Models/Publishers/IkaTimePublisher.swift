//
//  IkaTimePublisher.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import Combine
import Foundation
import UIKit

/// `IkaTimePublisher` is an observable object designed to provide time-based events to subscribers.
/// It publishes the current time every second and provides signals for auto-loading checks based on
/// the `autoLoadAttemptInterval` value.
/// This behavior persists even when the app transitions to the background.
final class IkaTimePublisher: ObservableObject {

  /// The shared singleton instance
  static let shared = IkaTimePublisher()

  /// Represents the current time and updates every second.
  @Published private(set) var currentTime = Date()
  /// A publisher that sends out a signal for auto-load checks every two seconds.
  let autoLoadCheckPublisher = PassthroughSubject<Void, Never>()

  /// Contains all the active subscriptions for this object.
  private var cancellables = Set<AnyCancellable>()

  // MARK: Lifecycle

  private init() {
    startPublishingCurrentTime()
    startPublishingAutoLoadChecks()
  }

  // MARK: Private

  /// Starts the process of publishing the `currentTime` property every second.
  private func startPublishingCurrentTime() {
    Timer
      .publish(
        every: 1,
        tolerance: 0.2,
        on: .main,
        in: .common)
      .autoconnect()
      .sink { [weak self] time in
        self?.currentTime = time
      }
      .store(in: &cancellables)
  }

  /// Starts the process of publishing auto-load check signals every `autoLoadAttemptInterval`.
  private func startPublishingAutoLoadChecks() {
    Timer
      .publish(
        every: Constants.Configs.Catalog.autoLoadAttemptInterval,
        tolerance: 0.2,
        on: .main,
        in: .common)
      .autoconnect()
      .sink { [weak self] _ in
        self?.autoLoadCheckPublisher.send(())
      }
      .store(in: &cancellables)
  }
}
