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

  func loadCatalog()
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

  // MARK: Private

  private func subscribeToLoadStatusWithLoadingIgnoredPublisher() {
    subscriptionTask = Task {
      for await newValue in loadStatusWithLoadingIgnoredPublisher.values {
        self.loadStatusWithLoadingIgnored = newValue
      }
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

  private func startCheckAutoLoadNecessityTask() {
    checkAutoLoadNecessityTask =
      Task { [weak self] in
        guard let self else { return }

        while true {
          try? await Task.sleep(nanoseconds: UInt64(Scoped.autoLoadCheckInterval * 1_000_000_000))
          if ifShouldAutoLoad() { await autoLoadData() }
        }
      }
  }

  private func autoLoadData()
    async
  {
    guard autoLoadStatus == .idle else { return }
    await setAutoLoadStatus(.autoLoading)

    let ifNeedAutoLoadSalmon = salmonRotations[0].isExpired(currentTime: IkaTimePublisher.shared.currentTime)

    do {
      try await withThrowingTaskGroup(of: Void.self) { group in
        // always auto-load BattleRotationDict
        group.addTask {
          try await self.autoLoadBattleRotationDict()
        }

        // only auto-load SalmonRotations if needed
        if ifNeedAutoLoadSalmon {
          group.addTask {
            try await self.autoLoadSalmonRotations()
          }
        }

        // wait for all tasks to finish
        for try await _ in group { }
      }

//      // ALTERNATIVE: use async let
//      async let taskBattleRotationDict: () = autoLoadBattleRotationDict()
//
//      var taskSalmonRotations: Task<Void, Error>?
//      if ifNeedAutoLoadSalmon {
//        taskSalmonRotations = Task {
//          try await autoLoadSalmonRotations()
//        }
//      }
//
//      try await taskBattleRotationDict
//      if let taskSalmonRotations {
//        try await taskSalmonRotations.value
//      }

      // success
      await setAutoLoadStatus(.autoLoaded(.success))
      if loadStatus != .loaded {
        await setLoadStatus(.loaded)
      }
    }
    catch let error as IkaError {
      // error
      await setLoadStatus(.error(error))
    }
    catch {
      // unknown error
      await setLoadStatus(.error(.unknownError))
    }
  }

  private func autoLoadBattleRotationDict()
    async throws
  {
    var autoLoadAttempts = 0

    while true {
      let loadedBattleRotationDict = try await IkaNetworkManager.shared.getBattleRotationDict()
      autoLoadAttempts += 1

      if loadedBattleRotationDict == battleRotationDict {
        if autoLoadAttempts >= Scoped.autoLoadMaxAttempts {
          await setAutoLoadStatus(.autoLoaded(.failure))
          break
        }

        try await Task.sleep(
          nanoseconds: UInt64(Constants.Configs.Catalog.autoLoadAttemptInterval * 1_000_000_000))
        continue
      }

      battleRotationDict = loadedBattleRotationDict
      break
    }
  }

  private func autoLoadSalmonRotations()
    async throws
  {
    var autoLoadAttempts = 0

    while true {
      let loadedSalmonRotations = try await IkaNetworkManager.shared.getSalmonRotations()
      autoLoadAttempts += 1

      if loadedSalmonRotations == salmonRotations {
        if autoLoadAttempts >= Scoped.autoLoadMaxAttempts {
          await setAutoLoadStatus(.autoLoaded(.failure))
          break
        }

        try await Task.sleep(
          nanoseconds: UInt64(Constants.Configs.Catalog.autoLoadAttemptInterval * 1_000_000_000))
        continue
      }

      // success
      let loadedRewardApparel = try await IkaNetworkManager.shared.getRewardApparel()
      salmonRotations = loadedSalmonRotations
      salmonRotations[0].rewardApparel = loadedRewardApparel

      break
    }
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

  private func setAutoLoadStatus(_ newVal: AutoLoadStatus)
    async
  {
    switch newVal {
    case .autoLoading:
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

  private func ifShouldAutoLoad() -> Bool {
    loadStatus != .loading &&
      autoLoadStatus == .idle &&
      battleRotationDict.isOutdated
  }
}
