//
//  IkaNetworkManagerTests.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import Synchronization
import Testing
@testable import Ikalendar2

// MARK: - IkaNetworkManagerTests

/// Error mapping of the networking layer against canned responses, never the real network.
/// Serialized because the stubbed response is static, shared by every session using the stub.
@Suite("IkaNetworkManager", .serialized)
struct IkaNetworkManagerTests {
  private func makeManager(stubbing response: StubURLProtocol.Response) -> IkaNetworkManager {
    StubURLProtocol.stubbedResponse.withLock { $0 = response }
    let configuration: URLSessionConfiguration = .ephemeral
    configuration.protocolClasses = [StubURLProtocol.self]
    return IkaNetworkManager(configuration: configuration)
  }

  @Test
  func `Status 200 with a valid payload decodes`() async throws {
    let manager = makeManager(stubbing: .http(statusCode: 200, body: Fixtures.data(Fixtures.battleRotationsValid)))

    let dict: BattleRotationDict = try await manager.fetchBattleRotationDict()

    #expect(!dict.hasEmptyMode)
  }

  @Test
  func `Status 200 with an undecodable payload throws badData`() async {
    let manager = makeManager(stubbing: .http(statusCode: 200, body: Data("not json".utf8)))

    await #expect(throws: IkaError.serverError(.badData)) {
      try await manager.fetchBattleRotationDict()
    }
  }

  @Test
  func `Status 500 throws badResponse`() async {
    let manager = makeManager(stubbing: .http(statusCode: 500, body: Data()))

    await #expect(throws: IkaError.serverError(.badResponse)) {
      try await manager.fetchBattleRotationDict()
    }
  }

  @Test
  func `Transport failure throws connectionError`() async {
    let manager = makeManager(stubbing: .failure(URLError(.notConnectedToInternet)))

    await #expect(throws: IkaError.connectionError) {
      try await manager.fetchBattleRotationDict()
    }
  }

  @Test
  func `Cancelled request surfaces as CancellationError instead of an IkaError`() async {
    // The catalog relies on this to show no error UI for a cancelled refresh.
    let manager = makeManager(stubbing: .failure(URLError(.cancelled)))

    await #expect(throws: CancellationError.self) {
      try await manager.fetchBattleRotationDict()
    }
  }
}

// MARK: - StubURLProtocol

/// Answers every request with `stubbedResponse` instead of going to the network.
final private class StubURLProtocol: URLProtocol {
  enum Response {
    case http(statusCode: Int, body: Data)
    case failure(URLError)
  }

  static let stubbedResponse: Mutex<Response?> = .init(nil)

  override static func canInit(with _: URLRequest) -> Bool {
    true
  }

  override static func canonicalRequest(for request: URLRequest) -> URLRequest {
    request
  }

  override func startLoading() {
    let stub: Response? = Self.stubbedResponse.withLock { $0 }
    switch stub {
      case .http(let statusCode, let body):
        if
          let url = request.url,
          let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        {
          client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        client?.urlProtocol(self, didLoad: body)
        client?.urlProtocolDidFinishLoading(self)

      case .failure(let error):
        client?.urlProtocol(self, didFailWithError: error)

      case nil:
        client?.urlProtocol(self, didFailWithError: URLError(.unknown))
    }
  }

  override func stopLoading() { }
}
