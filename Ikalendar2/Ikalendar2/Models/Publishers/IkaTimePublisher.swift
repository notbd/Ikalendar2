//
//  IkaTimePublisher.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import Combine
import Foundation

/// `IkaTimePublisher` is an observable object designed to provide time-based events to subscribers.
/// It publishes the current time every second and publish signals with respect to their respective
/// config value for the time interval.
/// This behavior persists even when the app transitions to the background.
@Observable
final class IkaTimePublisher {

  static let shared = IkaTimePublisher()

  /// Updates every `1` second.
  private(set) var currentTime: Date = .init()
  /// Signals auto-load checks every `2` seconds.
  let autoLoadCheckPublisher: PassthroughSubject<Void, Never> = .init()
  /// Signals icon bounces every `7` seconds.
  let bounceSignalPublisher: PassthroughSubject<Void, Never> = .init()

  /// Contains all the active subscriptions for this object.
  @ObservationIgnored private var cancellables = Set<AnyCancellable>()

  // MARK: Lifecycle

  private init() {
    startPublishingCurrentTime()
    startPublishingAutoLoadChecks()
    startPublishingBounceSignal()
  }

  // MARK: Private

  /// Starts the process of publishing the `currentTime` property every second.
  private func startPublishingCurrentTime() {
    Timer
      .publish(
        every: 1,
        tolerance: 0.1,
        on: .main,
        in: .common)
      .autoconnect()
      .sink { [weak self] time in
        self?.currentTime = time
      }
      .store(in: &cancellables)
  }

  /// Starts the process of publishing auto-load check signals every `autoLoadCheckSignalInterval`.
  private func startPublishingAutoLoadChecks() {
    Timer
      .publish(
        every: Constants.Config.Timer.autoLoadCheckSignalInterval,
        tolerance: 0.1,
        on: .main,
        in: .common)
      .autoconnect()
      .sink { [weak self] _ in
        self?.autoLoadCheckPublisher.send(())
      }
      .store(in: &cancellables)
  }

  /// Starts the process of publishing bounce signals every `bounceSignalInterval`.
  private func startPublishingBounceSignal() {
    Timer
      .publish(
        every: Constants.Config.Timer.bounceSignalInterval,
        tolerance: 0.1,
        on: .main,
        in: .common)
      .autoconnect()
      .sink { [weak self] _ in
        self?.bounceSignalPublisher.send(())
      }
      .store(in: &cancellables)
  }
}
