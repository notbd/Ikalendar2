//
//  IkaTimePublisher.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import Combine
import Foundation
import UIKit

/// An EnvObj class that is shared among all the views.
/// Will publish the current time every second.
/// Will also publish signals for auto load every 2 seconds.
/// Publishing purposefully kept alive when app goes to background.
final class IkaTimePublisher: ObservableObject {

  /// The shared singleton instance
  static let shared = IkaTimePublisher()

  /// Properties to be subscribed to
  @Published private(set) var currentTime = Date()
  let autoLoadCheckPublisher = PassthroughSubject<Void, Never>()

  /// Cancellable subscriptions
  private var cancellables = Set<AnyCancellable>()

  // MARK: Lifecycle

  private init() {
    startUpdatingCurrentTime()
    startPublishingAutoLoadChecks()
  }

  // MARK: Private

  private func startUpdatingCurrentTime() {
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
