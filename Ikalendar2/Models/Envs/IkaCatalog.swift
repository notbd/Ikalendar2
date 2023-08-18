//
//  IkaCatalog.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import Combine
import SwiftUI

// MARK: - IkaCatalog

/// An EnvObj class that is shared among all the views.
/// Contains the rotation data and its loading status.
@MainActor
final class IkaCatalog: ObservableObject {

  typealias Scoped = Constants.Configs.Catalog

  static let shared = IkaCatalog()

  private let ikaNetworkManager = IkaNetworkManager.shared

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
    let (loadedBattleRotationDict, loadedSalmonRotations, loadedRewardApparel) =
      try await (
        ikaNetworkManager.getBattleRotationDict(),
        ikaNetworkManager.getSalmonRotationArray(),
        ikaNetworkManager.getRewardApparel())

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
          if ifShouldAutoLoad() { await autoLoadBattleRotationDict() }
        }
      }
  }

  private func autoLoadBattleRotationDict()
    async
  {
    guard autoLoadStatus == .idle else { return }
    await setAutoLoadStatus(.autoLoading)

    var autoLoadAttempts = 0

    do {
      while true {
        let loadedBattleRotationDict = try await ikaNetworkManager.getBattleRotationDict()
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
        await setAutoLoadStatus(.autoLoaded(.success))
//        if loadStatus != .loaded {
//          await setLoadStatus(.loaded)
//        }
        break
      }
    }
    catch let error as IkaError {
      await setLoadStatus(.error(error))
    }
    catch {
      await setLoadStatus(.error(.unknownError))
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
//      Task {
          // automatically fall back to idle after a while
          try? await Task.sleep(nanoseconds: UInt64(Scoped.autoLoadedLingerLength * 1_000_000_000))
          autoLoadStatus = .idle
//      }
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
