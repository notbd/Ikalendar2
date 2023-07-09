//
//  IkaTimer.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import Combine
import Foundation

/// An EnvObj class that is shared among all the views.
/// Will publish the current time `EVERY SECOND`.
final class IkaTimer: ObservableObject {
  @Published private(set) var currentTime = Date()

  private var cancellables = Set<AnyCancellable>()
  private var timePublisher =
    Timer.publish(
      every: 1,
      tolerance: 0.2,
      on: .main,
      in: .common)
    .autoconnect()

  // MARK: Lifecycle

  init() {
    setUpTimerPublisher()
  }

  // MARK: Internal

  func setUpTimerPublisher() {
    timePublisher
      .receive(on: DispatchQueue.main)
      .sink { value in
        self.currentTime = value
      }
      .store(in: &cancellables)
  }
}
