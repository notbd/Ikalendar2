//
//  IkaCatalog.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import OSLog
import SimpleHaptics
import SwiftUI

// MARK: - IkaCatalog

/// An observable data store shared across views.
/// Contains the rotation data and its loading status.
@MainActor
@Observable
final class IkaCatalog {
  typealias Scoped = Constants.Config.Catalog

  private(set) var battleRotationDict: BattleRotationDict = .init()
  private(set) var salmonRotations: [SalmonRotation] = .init()

  @ObservationIgnored private let ikaNetworkService: any IkaNetworkService
  @ObservationIgnored private let ikaClock: IkaClock

  @ObservationIgnored private var autoLoadCheckTask: Task<Void, Never>?

  init(
    ikaNetworkService: any IkaNetworkService,
    ikaClock: IkaClock)
  {
    self.ikaNetworkService = ikaNetworkService
    self.ikaClock = ikaClock
    startAutoLoadChecks()
  }

  deinit {
    // Legal in a nonisolated deinit: Task is Sendable and cancel() is nonisolated.
    autoLoadCheckTask?.cancel()
  }

  // MARK: Exposed

  func refresh(silently shouldEnableSilentLoading: Bool = false)
    async
  {
    await loadCatalog(shouldEnableSilentLoading)
  }

  // MARK: Init Setup

  private func startAutoLoadChecks() {
    // Weak self is re-acquired each lap so short-lived instances can deinit.
    autoLoadCheckTask = Task { [weak self] in
      while !Task.isCancelled {
        try? await Task.sleep(for: .seconds(Constants.Config.Timer.autoLoadCheckSignalInterval))
        guard !Task.isCancelled else { return }
        guard let self else { return }

        handleAutoLoadCheck()
      }
    }
  }

  // MARK: Load related

  enum LoadStatus: Equatable {
    case loading
    case loaded
    case error(IkaError)
  }

  @ObservationIgnored private var isSilentLoadingEnabled: Bool = false

  private(set) var loadStatus: LoadStatus = .loading
  {
    willSet {
      guard newValue != loadStatus else { return }
      guard !isSilentLoadingEnabled else { return }

      switch newValue {
        case .loading:
          // Note: As of iOS 26 SDK, `.refreshable` comes with a default haptic feedback without
          //  providing a native option to turn it off. Thus we manually disable it here until there
          //  is a way to disable `.refreshable` haptic feedback.
          break
        case .loaded:
          SimpleHaptics.generateTask(.medium)
        case .error:
          SimpleHaptics.generateTask(.error)
      }
    }

    didSet {
      // Keep loadResultStatus at the last non-loading status. The dedupe check
      // matters: duplicate updates used to cause UI glitches.
      if loadStatus != .loading, loadResultStatus != loadStatus {
        loadResultStatus = loadStatus
      }
    }
  }

  /// Will never be in `.loading` state after catalog is first loaded.
  private(set) var loadResultStatus: LoadStatus = .loading

  private func loadCatalog(_ shouldEnableSilentLoading: Bool = false)
    async
  {
    isSilentLoadingEnabled = shouldEnableSilentLoading
    await setLoadStatus(.loading)
    do {
      try await loadData()
      await setLoadStatus(.loaded)
    }
    catch is CancellationError {
      // Task was cancelled (e.g. owning view disappeared) - no error UI
      return
    }
    catch let error as IkaError {
      await setLoadStatus(.error(error))
    }
    catch {
      Logger.store.error("catalog load failed with unexpected error: \(error, privacy: .public)")
      await setLoadStatus(.error(.unknownError))
    }
  }

  private func loadData()
    async throws
  {
    let (loadedBattleRotationDict, loadedSalmonRotations) = try await
      AsyncUtils.withTimeout(
        seconds: 5,
        timeoutError: IkaError.connectionError)
      { [ikaNetworkService] in
        async let taskBattleRotationDict = ikaNetworkService.getBattleRotationDict()
        async let taskSalmonRotations = ikaNetworkService.getSalmonRotations()
        async let taskSalmonRewardApparelInfo = ikaNetworkService.getSalmonRewardApparelInfo()

        let battleRotationDict = try await taskBattleRotationDict
        var salmonRotations = try await taskSalmonRotations
        let rewardInfo = try await taskSalmonRewardApparelInfo

        for (index, rotation) in salmonRotations.enumerated()
          where rotation.startTime == rewardInfo.availableTime
        {
          salmonRotations[index].rewardApparel = rewardInfo.apparel
        }

        return (battleRotationDict, salmonRotations)
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

  private(set) var autoLoadStatus: AutoLoadStatus = .idle
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

    didSet {
      // Same idea as loadResultStatus: track the last non-idle status, deduped.
      if autoLoadStatus != .idle, autoLoadDelayedIdleStatus != autoLoadStatus {
        autoLoadDelayedIdleStatus = autoLoadStatus
      }
    }
  }

  /// Its `.idle` state will be delayed after the `.idle` state of the `autoLoadStatus` after first auto-load.
  private(set) var autoLoadDelayedIdleStatus: AutoLoadStatus = .idle

  private func handleAutoLoadCheck() {
    guard shouldAutoLoad else { return }

    Task { await autoLoadCatalog() }
  }

  private var shouldAutoLoad: Bool {
    loadStatus != .loading &&
      autoLoadStatus == .idle &&
      battleRotationDict.isOutdated(ikaClock.currentTime)
  }

  private var shouldAutoLoadSalmon: Bool {
    guard let firstRotation = salmonRotations.first else { return true }

    return
      firstRotation.isExpired(ikaClock.currentTime) ||
      (firstRotation.isCurrent(ikaClock.currentTime) && firstRotation.rewardApparel == nil)
  }

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
      Logger.store.error("catalog auto-load failed with unexpected error: \(error, privacy: .public)")
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
      if shouldAutoLoadSalmon {
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
      let loadedBattleRotationDict = try await ikaNetworkService.getBattleRotationDict()

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
      var loadedSalmonRotations = try await ikaNetworkService.getSalmonRotations()
      let loadedSalmonRewardApparelInfo = try await ikaNetworkService.getSalmonRewardApparelInfo()
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

// MARK: - Preview Support

#if DEBUG
extension IkaCatalog {
  /// A catalog preloaded with mock rotations in the `.loaded` state, so previews
  /// render real content without waiting on a refresh pass. Defined in this file
  /// because preloading writes through `private(set)` properties.
  @MainActor
  static func preview(
    ikaNetworkService: any IkaNetworkService,
    ikaClock: IkaClock)
    -> IkaCatalog
  {
    let catalog: IkaCatalog = .init(ikaNetworkService: ikaNetworkService, ikaClock: ikaClock)
    catalog.battleRotationDict = IkaMockData.getBattleRotations()
    catalog.salmonRotations = IkaMockData.getSalmonRotations()
    catalog.loadStatus = .loaded
    return catalog
  }
}
#endif
