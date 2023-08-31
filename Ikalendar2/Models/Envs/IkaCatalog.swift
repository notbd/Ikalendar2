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

  typealias Scoped = Constants.Configs.Catalog

  static let shared = IkaCatalog()

  @Published private(set) var battleRotationDict = BattleRotationDict()
  @Published private(set) var salmonRotations = [SalmonRotation]()

  enum LoadStatus: Equatable {
    case loading
    case loaded
    case error(IkaError)
  }

  enum AutoLoadStatus: Equatable {
    case autoLoading
    case autoLoaded(AutoLoadedStatus)
    case idle

    enum AutoLoadedStatus {
      case success
      case failure
    }
  }

  @Published private(set) var loadStatus: LoadStatus = .loading
  @Published private(set) var autoLoadStatus = AutoLoadStatus.idle
  @Published private(set) var loadStatusWithLoadingIgnored: LoadStatus = .loading
  var loadStatusWithLoadingIgnoredPublisher: AnyPublisher<LoadStatus, Never> {
    $loadStatus
      .removeDuplicates()
      .filter { $0 != .loading }
      .eraseToAnyPublisher()
  }

  private var subscriptionTask: Task<Void, Never>?
  private var checkAutoLoadNecessityTask: Task<Void, Error>?

  // MARK: Lifecycle

  private init() {
    subscribeToLoadStatusWithLoadingIgnoredPublisher()
    Task {
      await loadCatalog()
      startCheckAutoLoadNecessityTask()
    }
  }

  deinit {
    subscriptionTask?.cancel()
    checkAutoLoadNecessityTask?.cancel()
  }

  // MARK: Internal

  func refresh()
    async
  {
    await loadCatalog()
  }

  // MARK: Private

  private func subscribeToLoadStatusWithLoadingIgnoredPublisher() {
    subscriptionTask = Task {
      for await newValue in loadStatusWithLoadingIgnoredPublisher.values {
        self.loadStatusWithLoadingIgnored = newValue
      }
    }
  }

  private func startCheckAutoLoadNecessityTask() {
    checkAutoLoadNecessityTask =
      Task { [weak self] in
        guard let self else { return }

        while true {
          try? await Task.sleep(nanoseconds: UInt64(Scoped.autoLoadCheckInterval * 1_000_000_000))
          if ifShouldAutoLoad() { await autoLoadCatalog() }
        }
      }
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
    async let taskRewardApparel = IkaNetworkManager.shared.getRewardApparel()

    let (loadedBattleRotationDict, loadedSalmonRotations, loadedRewardApparel) =
      try await (taskBattleRotationDict, taskSalmonRotations, taskRewardApparel)

    battleRotationDict = loadedBattleRotationDict
    salmonRotations = loadedSalmonRotations
    salmonRotations[0].rewardApparel = loadedRewardApparel
  }

  private func setLoadStatus(_ newVal: LoadStatus)
    async
  {
    switch newVal {
    case .loading:
      await SimpleHaptics.generate(.selection)
      loadStatus = .loading
    case .loaded:
      try? await Task.sleep(nanoseconds: UInt64(Scoped.loadStatusLoadedDelay * 1_000_000_000))
      await SimpleHaptics.generate(.success)
      loadStatus = .loaded
    case .error(let ikaError):
      try? await Task.sleep(nanoseconds: UInt64(Scoped.loadStatusErrorDelay * 1_000_000_000))
      await SimpleHaptics.generate(.error)
      loadStatus = .error(ikaError)
    }
  }

  // MARK: - AUTO-LOAD

  private func ifShouldAutoLoad() -> Bool {
    loadStatus != .loading &&
      autoLoadStatus == .idle &&
      battleRotationDict.isOutdated
  }

  private func autoLoadCatalog()
    async
  {
    guard autoLoadStatus == .idle else { return }
    await setAutoLoadStatus(.autoLoading)

    let ifNeedAutoLoadSalmon = salmonRotations[0].isExpired(currentTime: IkaTimePublisher.shared.currentTime)

    do {
      try await autoLoadData(includingSalmon: ifNeedAutoLoadSalmon)

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

  private func autoLoadData(includingSalmon: Bool)
    async throws
  {
    try await withThrowingTaskGroup(of: Void.self) { group in
      // always auto-load BattleRotationDict
      group.addTask {
        try await self.autoLoadBattleRotationDict()
      }

      // only auto-load SalmonRotations if needed
      if includingSalmon {
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
        nanoseconds: UInt64(Constants.Configs.Catalog.autoLoadAttemptInterval * 1_000_000_000))
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
      let loadedRewardApparel = try await IkaNetworkManager.shared.getRewardApparel()
      loadedSalmonRotations[0].rewardApparel = loadedRewardApparel

      // found updates from server - success and return
      if loadedSalmonRotations != salmonRotations {
        salmonRotations = loadedSalmonRotations
        return
      }

      // wait and retry
      try await Task.sleep(
        nanoseconds: UInt64(Constants.Configs.Catalog.autoLoadAttemptInterval * 1_000_000_000))
    }

    // timeout - fail and throw timeout error
    throw IkaError.maxAttemptsExceeded
  }

  private func setAutoLoadStatus(_ newVal: AutoLoadStatus)
    async
  {
    switch newVal {
    case .autoLoading:
      await SimpleHaptics.generate(.selection)
      autoLoadStatus = .autoLoading
    case .autoLoaded(let result):
      await SimpleHaptics.generate(.selection)
      autoLoadStatus = .autoLoaded(result)
      // automatically fall back to idle after a while
      Task {
        // blocked if app is in background - to make sure autoLoaded can be seen when switched back
        while UIApplication.shared.applicationState != .active {
          try? await Task.sleep(nanoseconds: UInt64(Scoped.activeStateCheckInterval * 1_000_000_000))
        }

        try? await Task.sleep(nanoseconds: UInt64(Scoped.autoLoadedLingerLength * 1_000_000_000))
        autoLoadStatus = .idle
      }
    case .idle:
      autoLoadStatus = .idle
    }
  }
}
