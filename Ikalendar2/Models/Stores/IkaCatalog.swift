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

  /// The intervals (in seconds) and attempt limits the catalog runs on. Injectable so tests
  /// can drive the load and auto-load state machines on short intervals without racing
  /// wall-clock deadlines; the app uses `.standard`.
  struct Timing {
    /// Upper bound for a full catalog load.
    var loadTimeout: TimeInterval
    var loadStatusLoadedDelay: TimeInterval
    var loadStatusErrorDelay: TimeInterval
    var autoLoadCheckInterval: TimeInterval
    var autoLoadAttemptInterval: TimeInterval
    var autoLoadBattleMaxAttempts: Int
    var autoLoadSalmonMaxAttempts: Int
    var appActiveStateCheckInterval: TimeInterval
    var autoLoadedLingerLength: TimeInterval
    var idleAndNonIdleStatusUpdateInterval: TimeInterval

    /// The production values from `Constants.Config`.
    static let standard: Timing = .init(
      loadTimeout: Scoped.loadTimeout,
      loadStatusLoadedDelay: Scoped.loadStatusLoadedDelay,
      loadStatusErrorDelay: Scoped.loadStatusErrorDelay,
      autoLoadCheckInterval: Constants.Config.Timer.autoLoadCheckSignalInterval,
      autoLoadAttemptInterval: Scoped.autoLoadAttemptInterval,
      autoLoadBattleMaxAttempts: Scoped.autoLoadBattleMaxAttempts,
      autoLoadSalmonMaxAttempts: Scoped.autoLoadSalmonMaxAttempts,
      appActiveStateCheckInterval: Scoped.appActiveStateCheckInterval,
      autoLoadedLingerLength: Scoped.autoLoadedLingerLength,
      idleAndNonIdleStatusUpdateInterval: Scoped.idleAndNonIdleStatusUpdateInterval)
  }

  private(set) var battleRotationDict: BattleRotationDict = .init()
  private(set) var salmonRotations: [SalmonRotation] = .init()

  @ObservationIgnored private let ikaNetworkService: any IkaNetworkService
  @ObservationIgnored private let ikaClock: IkaClock
  @ObservationIgnored private let timing: Timing
  /// Whether the app is foreground-active. Injectable so tests do not depend on the
  /// lifecycle state of the hosting app.
  @ObservationIgnored private let isAppActive: @MainActor () -> Bool

  @ObservationIgnored private var autoLoadCheckTask: Task<Void, Never>?
  @ObservationIgnored private var autoLoadLingerTask: Task<Void, Never>?

  init(
    ikaNetworkService: any IkaNetworkService,
    ikaClock: IkaClock,
    timing: Timing = .standard,
    isAppActive: @escaping @MainActor () -> Bool = { UIApplication.shared.applicationState == .active })
  {
    self.ikaNetworkService = ikaNetworkService
    self.ikaClock = ikaClock
    self.timing = timing
    self.isAppActive = isAppActive
    startAutoLoadChecks()
  }

  deinit {
    // Legal in a nonisolated deinit: Task is Sendable and cancel() is nonisolated.
    autoLoadCheckTask?.cancel()
    autoLoadLingerTask?.cancel()
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
    autoLoadCheckTask = Task { [weak self, timing] in
      while !Task.isCancelled {
        try? await Task.sleep(for: .seconds(timing.autoLoadCheckInterval))
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
  /// The number of loads in flight, so a cancelled load can tell whether another load
  /// (newer or older) still owns the `.loading` status.
  @ObservationIgnored private var inFlightLoadCount: Int = 0

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
    // Scoped to this call: a silent onboarding load must not also silence the
    // status changes of later auto-loads.
    isSilentLoadingEnabled = shouldEnableSilentLoading
    inFlightLoadCount += 1
    defer {
      isSilentLoadingEnabled = false
      inFlightLoadCount -= 1
    }

    await setLoadStatus(.loading)
    do {
      try await loadData()
      await setLoadStatus(.loaded)
    }
    catch is CancellationError {
      // Task was cancelled (e.g. owning view disappeared) - no error UI. Unless another
      // load is still in flight, put the last result back: a catalog parked in `.loading`
      // keeps the lists, the refresh button and the auto-load gate disabled, and nothing
      // else clears it. The load still in flight settles the status when it finishes.
      if inFlightLoadCount == 1 { restoreLoadResultStatus() }
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
        seconds: timing.loadTimeout,
        timeoutError: IkaError.connectionError)
      { [ikaNetworkService] in
        async let taskBattleRotationDict = ikaNetworkService.fetchBattleRotationDict()
        async let taskSalmonRotations = ikaNetworkService.fetchSalmonRotations()
        async let taskSalmonRewardApparelInfo = ikaNetworkService.fetchSalmonRewardApparelInfo()

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
        try? await Task.sleep(for: .seconds(timing.loadStatusLoadedDelay))
        loadStatus = .loaded

      case .error(let ikaError):
        try? await Task.sleep(for: .seconds(timing.loadStatusErrorDelay))
        loadStatus = .error(ikaError)
    }
  }

  /// Silently puts `loadStatus` back to the last result after a cancelled load. A load
  /// cancelled before any result exists has nothing to restore: the launch `.task` that
  /// issued it runs again with its recreated view.
  private func restoreLoadResultStatus() {
    guard loadResultStatus != .loading else { return }

    // A cancelled load is a non-event: no haptic. `loadCatalog` resets the flag on exit.
    isSilentLoadingEnabled = true
    loadStatus = loadResultStatus
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

    while autoLoadAttempts < timing.autoLoadBattleMaxAttempts {
      // new attempt
      autoLoadAttempts += 1
      let loadedBattleRotationDict = try await ikaNetworkService.fetchBattleRotationDict()

      // found updates from server - success and return
      if loadedBattleRotationDict != battleRotationDict {
        battleRotationDict = loadedBattleRotationDict
        return
      }

      // wait and retry
      try await Task.sleep(for: .seconds(timing.autoLoadAttemptInterval))
    }

    // timeout - fail and throw timeout error
    throw IkaError.maxAttemptsExceeded
  }

  private func autoLoadSalmonRotations()
    async throws
  {
    var autoLoadAttempts = 0

    while autoLoadAttempts < timing.autoLoadSalmonMaxAttempts {
      // new attempt
      autoLoadAttempts += 1
      var loadedSalmonRotations = try await ikaNetworkService.fetchSalmonRotations()
      let loadedSalmonRewardApparelInfo = try await ikaNetworkService.fetchSalmonRewardApparelInfo()
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
      try await Task.sleep(for: .seconds(timing.autoLoadAttemptInterval))
    }

    // timeout - fail and throw timeout error
    throw IkaError.maxAttemptsExceeded
  }

  private func setAutoLoadStatus(_ newVal: AutoLoadStatus)
    async
  {
    switch newVal {
      case .autoLoading:
        // A linger left over from the previous cycle must not reset this one.
        autoLoadLingerTask?.cancel()
        autoLoadStatus = .autoLoading

      case .autoLoaded(let result):
        autoLoadStatus = .autoLoaded(result)
        // automatically fall back to idle after a while
        autoLoadLingerTask?.cancel()
        autoLoadLingerTask = Task { [weak self, timing] in
          // blocked if app is in background - to make sure autoLoaded can be seen when switched back
          while !Task.isCancelled, self?.isAppActive() == false {
            try? await Task.sleep(for: .seconds(timing.appActiveStateCheckInterval))
          }
          try? await Task.sleep(for: .seconds(timing.autoLoadedLingerLength))
          // `try?` swallows cancellation, so check for it before every write.
          guard !Task.isCancelled, let self else { return }

          autoLoadStatus = .idle
          try? await Task.sleep(for: .seconds(timing.idleAndNonIdleStatusUpdateInterval))
          guard !Task.isCancelled else { return }

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
    catalog.battleRotationDict = IkaMockData.makeBattleRotations()
    catalog.salmonRotations = IkaMockData.makeSalmonRotations()
    catalog.loadStatus = .loaded
    return catalog
  }
}
#endif
