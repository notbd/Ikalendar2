//
//  IkaError.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

// MARK: - IkaError

/// A custom error type for the Ikalendar2 app.
enum IkaError: Error, Equatable {
  typealias Scoped = Constants.Keys.Error

  case serverError(IkaServerErrorType)
  case connectionError
  case unknownError(Error)

  static func == (lhs: IkaError, rhs: IkaError) -> Bool {
    lhs.message == rhs.message
  }
}

extension IkaError {
  var title: String {
    switch self {
    case .serverError:
      return Scoped.Title.SERVER_ERROR
    case .connectionError:
      return Scoped.Title.CONNECTION_ERROR
    case .unknownError:
      return Scoped.Title.UNKNOWN_ERROR
    }
  }
}

extension IkaError {
  var message: String {
    switch self {
    case .serverError(let serverErrorType):
      return Scoped.Message.SERVER_ERROR(serverErrorType.title)
    case .connectionError:
      return Scoped.Message.CONNECTION_ERROR
    case .unknownError(let error):
      return Scoped.Message.UNKNOWN_ERROR(error.localizedDescription)
    }
  }
}

// MARK: - IkaServerErrorType

/// A sub-type for IkaError.serverError
enum IkaServerErrorType: String {
  typealias Scoped = Constants.Keys.Error

  case badResponse
  case badData
}

extension IkaServerErrorType {
  var title: String {
    switch self {
    case .badResponse:
      return Scoped.Title.BAD_RESPONSE
    case .badData:
      return Scoped.Title.BAD_DATA
    }
  }
}
