//
//  IkaError.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

// MARK: - IkaError

/// A custom error type for the Ikalendar2 app.
enum IkaError: Error, Equatable {
  typealias Scoped = Constants.Key.Error

  case serverError(IkaServerErrorType)
  case connectionError
  case unknownError
  case maxAttemptsExceeded
}

extension IkaError {
  var title: String {
    switch self {
      case .serverError:
        Scoped.Title.serverError
      case .connectionError:
        Scoped.Title.connectionError
      case .unknownError:
        Scoped.Title.unknownError
      case .maxAttemptsExceeded:
        Scoped.Title.maxAttemptsExceeded
    }
  }
}

extension IkaError {
  var message: String {
    switch self {
      case .serverError(let serverErrorType):
        switch serverErrorType {
          case .badResponse:
            Scoped.Message.serverErrorBadResponse
          case .badData:
            Scoped.Message.serverErrorBadData
        }

      case .connectionError:
        Scoped.Message.connectionError

      case .unknownError:
        Scoped.Message.unknownError

      case .maxAttemptsExceeded:
        Scoped.Message.maxAttemptsExceeded
    }
  }
}

// MARK: - IkaServerErrorType

/// A sub-type for IkaError.serverError
enum IkaServerErrorType: String, Equatable {
  typealias Scoped = Constants.Key.Error

  case badResponse
  case badData
}
