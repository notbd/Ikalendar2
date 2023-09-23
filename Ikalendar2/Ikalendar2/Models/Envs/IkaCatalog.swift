//
//  IkaCatalog.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import Combine
import SimpleHaptics
import SwiftUI

// MARK: - IkaCatalog

/// An EnvObj class that is shared among all the views.
/// Contains the rotation data and its loading status.
@MainActor
final class IkaCatalog: ObservableObject {
  typealias Scoped = Constants.Config.Catalog

  static let shared = IkaCatalog()

  @Published private(set) var battleRotationDict = BattleRotationDict()
  @Published private(set) var salmonRotations = [SalmonRotation]()

  // MARK: Load related

  enum LoadStatus: Equatable {
    case loading
    case loaded
    case error(IkaError)
  }

  @Published private(set) var loadStatus: LoadStatus = .loading
  {
    willSet {
      guard newValue != loadStatus else { return }

      switch newValue {
      case .loading:
        // Note: As of iOS 17.0 SDK, `.refreshable` comes with a default haptic feedback without
        //  providing a native option to turn it off. Thus we manually disable it here until there
        //  is a way to disable `.refreshable` haptic feedback.
        break
      case .loaded:
        SimpleHaptics.generateTask(.success)
      case .error:
        SimpleHaptics.generateTask(.error)
      }
    }
  }

  /// Will never be in `.loading` state after catalog is first loaded.
  @Published private(set) var loadResultStatus: LoadStatus = .loading

  // MARK: Auto-Load related

  enum AutoLoadStatus: Equatable {
    case autoLoading
    case autoLoaded(AutoLoadedStatus)
    case idle

    enum AutoLoadedStatus {
      case success
      case failure
    }
  }

  @Published private(set) var autoLoadStatus: AutoLoadStatus = .idle
  {
    willSet {
      guard newValue != autoLoadStatus else { return }

      switch newValue {
      case .autoLoading:
        SimpleHaptics.generateTask(.selection)
      case .autoLoaded:
        SimpleHaptics.generateTask(.selection)
      case .idle:
        break
      }
    }
  }

  /// Its `.idle` state will be delayed after the `.idle` state of the `autoLoadStatus` after first auto-load.
  @Published private(set) var autoLoadDelayedIdleStatus: AutoLoadStatus = .idle

  private var cancellables = Set<AnyCancellable>()

  private var ifShouldAutoLoad: Bool {
    loadStatus != .loading &&
      autoLoadStatus == .idle &&
      battleRotationDict.isOutdated
  }

  private var ifShouldAutoLoadSalmon: Bool {
    guard let firstRotation = salmonRotations.first else { return true }
    return
      firstRotation.isExpired ||
      (firstRotation.isCurrent && firstRotation.rewardApparel == nil)
  }

  // MARK: Lifecycle

  private init() {
    setUpLoadResultStatusSubscription()
    setUpAutoLoadNonIdleStatusSubscription()
    Task {
      await loadCatalog()
      setUpAutoLoadCheckSubscription()
    }
  }

  deinit {
    cancellables.removeAll()
  }

  // MARK: Internal

  func refresh()
    async
  {
    await loadCatalog()
  }

  // MARK: Private

  private func setUpLoadResultStatusSubscription() {
    $loadStatus
      .filter { $0 != .loading }
      .removeDuplicates()
      .sink { [weak self] newStatus in
        self?.loadResultStatus = newStatus
      }
      .store(in: &cancellables)
  }

  private func setUpAutoLoadNonIdleStatusSubscription() {
    $autoLoadStatus
      .filter { $0 != .idle }
      .removeDuplicates()
      .sink { [weak self] newStatus in
        self?.autoLoadDelayedIdleStatus = newStatus
      }
      .store(in: &cancellables)
  }

  private func setUpAutoLoadCheckSubscription() {
    IkaTimePublisher.shared.autoLoadCheckPublisher
      .sink { [weak self] _ in
        self?.handleAutoLoadCheck()
      }
      .store(in: &cancellables)
  }

  private func handleAutoLoadCheck() {
    guard ifShouldAutoLoad else { return }
    Task { await autoLoadCatalog() }
  }

  // MARK: - LOAD

  private func loadCatalog()
    async
  {
    await setLoadStatus(.loading)
    do {
      try await loadData()
      await setLoadStatus(.loaded)
    }
    catch let error as IkaError {
      await setLoadStatus(.error(error))
    }
    catch {
      await setLoadStatus(.error(.unknownError))
    }
  }

  private func loadData()
    async throws
  {
    async let taskBattleRotationDict = IkaNetworkManager.shared.getBattleRotationDict()
    async let taskSalmonRotations = IkaNetworkManager.shared.getSalmonRotations()
    async let taskSalmonRewardApparelInfo = IkaNetworkManager.shared.getSalmonRewardApparelInfo()

    let loadedBattleRotationDict = try await taskBattleRotationDict
    var loadedSalmonRotations = try await taskSalmonRotations
    let loadedSalmonRewardApparelInfo = try await taskSalmonRewardApparelInfo

    // add reward apparel to corresponding salmon rotation
    for (index, rotation) in loadedSalmonRotations.enumerated()
      where rotation.startTime == loadedSalmonRewardApparelInfo.availableTime
    {
      loadedSalmonRotations[index].rewardApparel = loadedSalmonRewardApparelInfo.apparel
    }

    battleRotationDict = loadedBattleRotationDict
    salmonRotations = loadedSalmonRotations
  }

  private func setLoadStatus(_ newVal: LoadStatus)
    async
  {
    switch newVal {
    case .loading:
      loadStatus = .loading
    case .loaded:
      try? await Task.sleep(nanoseconds: UInt64(Scoped.loadStatusLoadedDelay * 1_000_000_000))
      loadStatus = .loaded
    case .error(let ikaError):
      try? await Task.sleep(nanoseconds: UInt64(Scoped.loadStatusErrorDelay * 1_000_000_000))
      loadStatus = .error(ikaError)
    }
  }

  // MARK: - AUTO-LOAD

  private func autoLoadCatalog()
    async
  {
    guard autoLoadStatus == .idle else { return }
    await setAutoLoadStatus(.autoLoading)

    do {
      try await autoLoadData()

      // success
      if loadStatus != .loaded { await setLoadStatus(.loaded) } // show rotations if prev loading error
      await setAutoLoadStatus(.autoLoaded(.success))
    }

    // auto-load timeout error
    catch IkaError.maxAttemptsExceeded {
      if loadStatus != .loaded { await setLoadStatus(.loaded) } // show rotations if prev loading error
      await setAutoLoadStatus(.autoLoaded(.failure))
    }

    // loading error
    catch let error as IkaError {
      await setLoadStatus(.error(error))
      await setAutoLoadStatus(.autoLoaded(.failure))
    }

    // unknown error
    catch {
      await setLoadStatus(.error(.unknownError))
      await setAutoLoadStatus(.autoLoaded(.failure))
    }
  }

  private func autoLoadData()
    async throws
  {
    try await withThrowingTaskGroup(of: Void.self) { group in
      // always auto-load BattleRotationDict
      group.addTask {
        try await self.autoLoadBattleRotationDict()
      }

      // only auto-load SalmonRotations if needed
      if ifShouldAutoLoadSalmon {
        group.addTask {
          try await self.autoLoadSalmonRotations()
        }
      }

      // wait for all tasks to finish
      for try await _ in group { }
    }
  }

  private func autoLoadBattleRotationDict()
    async throws
  {
    var autoLoadAttempts = 0

    while autoLoadAttempts < Scoped.autoLoadBattleMaxAttempts {
      // new attempt
      autoLoadAttempts += 1
      let loadedBattleRotationDict = try await IkaNetworkManager.shared.getBattleRotationDict()

      // found updates from server - success and return
      if loadedBattleRotationDict != battleRotationDict {
        battleRotationDict = loadedBattleRotationDict
        return
      }

      // wait and retry
      try await Task.sleep(
        nanoseconds: UInt64(Constants.Config.Catalog.autoLoadAttemptInterval * 1_000_000_000))
    }

    // timeout - fail and throw timeout error
    throw IkaError.maxAttemptsExceeded
  }

  private func autoLoadSalmonRotations()
    async throws
  {
    var autoLoadAttempts = 0

    while autoLoadAttempts < Scoped.autoLoadSalmonMaxAttempts {
      // new attempt
      autoLoadAttempts += 1
      var loadedSalmonRotations = try await IkaNetworkManager.shared.getSalmonRotations()
      let loadedSalmonRewardApparelInfo = try await IkaNetworkManager.shared.getSalmonRewardApparelInfo()
      for (index, rotation) in loadedSalmonRotations.enumerated()
        where rotation.startTime == loadedSalmonRewardApparelInfo.availableTime
      {
        loadedSalmonRotations[index].rewardApparel = loadedSalmonRewardApparelInfo.apparel
      }

      // found updates from server - success and return
      if loadedSalmonRotations != salmonRotations {
        salmonRotations = loadedSalmonRotations
        return
      }

      // wait and retry
      try await Task.sleep(
        nanoseconds: UInt64(Constants.Config.Catalog.autoLoadAttemptInterval * 1_000_000_000))
    }

    // timeout - fail and throw timeout error
    throw IkaError.maxAttemptsExceeded
  }

  private func setAutoLoadStatus(_ newVal: AutoLoadStatus)
    async
  {
    switch newVal {
    case .autoLoading:
      autoLoadStatus = .autoLoading
    case .autoLoaded(let result):
      autoLoadStatus = .autoLoaded(result)
      // automatically fall back to idle after a while
      Task {
        // blocked if app is in background - to make sure autoLoaded can be seen when switched back
        while UIApplication.shared.applicationState != .active {
          try? await Task.sleep(nanoseconds: UInt64(Scoped.appActiveStateCheckInterval * 1_000_000_000))
        }
        try? await Task.sleep(nanoseconds: UInt64(Scoped.autoLoadedLingerLength * 1_000_000_000))
        autoLoadStatus = .idle
        try? await Task.sleep(nanoseconds: UInt64(Scoped.idleAndNonIdleStatusUpdateInterval * 1_000_000_000))
        autoLoadDelayedIdleStatus = .idle
      }
    case .idle:
      autoLoadStatus = .idle
    }
  }
}
