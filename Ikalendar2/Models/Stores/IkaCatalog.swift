//
//  IkaCatalog.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import OSLog
import SimpleHaptics
import UIKit

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
      autoLoadCheckInterval: Scoped.autoLoadCheckInterval,
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

  // MARK: - Loading

  enum LoadStatus: Equatable {
    case loading
    case loaded
    case error(IkaError)
  }

  /// True only for the duration of one `refresh` call (and the cancellation restore);
  /// never carries across loads.
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
          // No haptic for .loading: as of the iOS 26 SDK, .refreshable plays its own on pull
          // and offers no way to turn it off; ours would double it.
          break
        case .loaded:
          SimpleHaptics.generateTask(.medium)
        case .error:
          SimpleHaptics.generateTask(.error)
      }
    }

    didSet {
      // Keep loadResultStatus at the last non-loading status. The dedupe check
      // matters: duplicate updates used to cause UI glitches (fbc49af).
      if loadStatus != .loading, loadResultStatus != loadStatus {
        loadResultStatus = loadStatus
      }
    }
  }

  /// The last settled status: never `.loading` once the first load has finished.
  /// RotationsTabView and RotationsCarouselView switch on this, so a refresh keeps the current
  /// list or ErrorView on screen instead of swapping in a loading state.
  private(set) var loadResultStatus: LoadStatus = .loading

  /// Reloads every rotation feed. `silently` mutes the haptics of this one load's status
  /// changes (used by the onboarding launch load).
  func refresh(silently shouldEnableSilentLoading: Bool = false)
    async
  {
    // Scoped to this call: a silent onboarding load must not also silence the
    // status changes of later auto-loads (9695432).
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
      // else clears it. The load still in flight settles the status when it finishes
      // (649aa03, 834ef44; pinned by the cancellation tests in IkaCatalogTests).
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
        let salmonRotations = try await taskSalmonRotations
        let rewardInfo = try await taskSalmonRewardApparelInfo

        return (battleRotationDict, salmonRotations.attaching(rewardInfo))
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

    // A cancelled load is a non-event: no haptic. `refresh` resets the flag on exit.
    isSilentLoadingEnabled = true
    loadStatus = loadResultStatus
  }

  // MARK: - Auto-load

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
      if autoLoadStatus != .idle, autoLoadDisplayStatus != autoLoadStatus {
        autoLoadDisplayStatus = autoLoadStatus
      }
    }
  }

  /// What the auto-load toast shows. Follows `autoLoadStatus`, except that it returns to `.idle`
  /// one `idleAndNonIdleStatusUpdateInterval` later, so the icon keeps its final symbol while
  /// the toast fades out.
  private(set) var autoLoadDisplayStatus: AutoLoadStatus = .idle

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

    // After a successful auto-load, or one that ran out of attempts, show the rotations
    // again if the last full load had errored.
    do {
      try await autoLoadData()

      if loadStatus != .loaded { await setLoadStatus(.loaded) }
      await setAutoLoadStatus(.autoLoaded(.success))
    }
    catch IkaError.maxAttemptsExceeded {
      if loadStatus != .loaded { await setLoadStatus(.loaded) }
      await setAutoLoadStatus(.autoLoaded(.failure))
    }
    catch let error as IkaError {
      // A loaded list stays on screen and only the toast reports the failure; a list the
      // last full load left as ErrorView takes the new error.
      if loadResultStatus != .loaded { await setLoadStatus(.error(error)) }
      await setAutoLoadStatus(.autoLoaded(.failure))
    }
    catch {
      Logger.store.error("catalog auto-load failed with unexpected error: \(error, privacy: .public)")
      await setLoadStatus(.error(.unknownError))
      await setAutoLoadStatus(.autoLoaded(.failure))
    }
  }

  /// Auto-loads the battle feed and, when it is due, the salmon feed concurrently. The result
  /// follows the battle feed, which gates the auto-load: the salmon feed can update later than
  /// the battle feed at a shared boundary, and its failure must not report a refreshed battle
  /// feed as failed, so it is only logged.
  private func autoLoadData()
    async throws
  {
    let isSalmonDue = shouldAutoLoadSalmon
    async let battle: Void = autoLoadBattleRotationDict()
    async let salmon: Void = isSalmonDue ? autoLoadSalmonRotations() : ()

    // A battle error leaves the scope while salmon still runs, which cancels it.
    try await battle
    do {
      try await salmon
    }
    catch {
      Logger.store.notice("salmon auto-load did not refresh: \(error, privacy: .public)")
    }
  }

  private func autoLoadBattleRotationDict()
    async throws
  {
    battleRotationDict = try await fetchUntilChanged(
      maxAttempts: timing.autoLoadBattleMaxAttempts,
      current: { battleRotationDict },
      fetch: { try await ikaNetworkService.fetchBattleRotationDict() })
  }

  private func autoLoadSalmonRotations()
    async throws
  {
    salmonRotations = try await fetchUntilChanged(
      maxAttempts: timing.autoLoadSalmonMaxAttempts,
      current: { salmonRotations },
      fetch: {
        let loadedSalmonRotations = try await ikaNetworkService.fetchSalmonRotations()
        let loadedSalmonRewardApparelInfo = try await ikaNetworkService.fetchSalmonRewardApparelInfo()
        return loadedSalmonRotations.attaching(loadedSalmonRewardApparelInfo)
      })
  }

  /// Fetches until the result differs from `current()`, which is read again after every fetch.
  /// Sleeps `autoLoadAttemptInterval` between unchanged results and throws `maxAttemptsExceeded`
  /// as soon as the last of `maxAttempts` fetches comes back unchanged.
  private func fetchUntilChanged<T: Equatable>(
    maxAttempts: Int,
    current: () -> T,
    fetch: () async throws -> T)
    async throws -> T
  {
    var attempts = 0

    while attempts < maxAttempts {
      attempts += 1
      let fetched = try await fetch()

      if fetched != current() { return fetched }
      guard attempts < maxAttempts else { break }

      try await Task.sleep(for: .seconds(timing.autoLoadAttemptInterval))
    }

    throw IkaError.maxAttemptsExceeded
  }

  private func setAutoLoadStatus(_ newVal: AutoLoadStatus)
    async
  {
    switch newVal {
      case .autoLoading:
        // A linger left over from the previous cycle must not reset this one
        // (11b7b79; pinned by IkaCatalogAutoLoadTests).
        autoLoadLingerTask?.cancel()
        autoLoadStatus = .autoLoading

      case .autoLoaded(let result):
        autoLoadStatus = .autoLoaded(result)
        scheduleIdleFallback()

      case .idle:
        autoLoadStatus = .idle
    }
  }

  /// Returns `autoLoadStatus` to `.idle` once the result has lingered for
  /// `autoLoadedLingerLength`, and `autoLoadDisplayStatus` one
  /// `idleAndNonIdleStatusUpdateInterval` after that.
  private func scheduleIdleFallback() {
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

      autoLoadDisplayStatus = .idle
    }
  }
}

// MARK: - Reward apparel

extension [SalmonRotation] {
  /// A copy with `info`'s reward apparel set on the rotations that start at its available time.
  fileprivate func attaching(_ info: SalmonApparelInfo) -> [SalmonRotation] {
    var rotations = self
    for (index, rotation) in rotations.enumerated()
      where rotation.startTime == info.availableTime
    {
      rotations[index].rewardApparel = info.apparel
    }
    return rotations
  }
}

// MARK: - Preview Support

extension IkaCatalog {
  /// A catalog preloaded with mock rotations in the `.loaded` state, so previews
  /// render real content without waiting on a refresh pass. Defined in this file
  /// because preloading writes through `private(set)` properties. Compiled in Release too,
  /// since `#Preview` bodies are type-checked there (49b7031).
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
