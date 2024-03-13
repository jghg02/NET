//
//  NETHTTPError.swift
//
//
//  Created by Josue Hernandez on 08-10-22.
//

import Foundation

public enum NETHTTPError<N: LocalizedError>: LocalizedError {
    case failedRequest(URLError?)
    case invalidRequest(N)
    case invalidResponse(Int)
    case responseTypeMismatch

    public var errorDescription: String? {
        switch self {
        case .failedRequest:
            return "The request failed."
        case let .invalidRequest(error):
            return error.localizedDescription
        case let .invalidResponse(statusCode):
            return "The response was invalid (\(statusCode))."
        case .responseTypeMismatch:
            return "The response did not match the expected type."
        }
    }

    public var failureReason: String? {
        switch self {
        case let .failedRequest(error):
            return error?.localizedDescription
        case let .invalidRequest(error):
            return error.localizedDescription
        case let .invalidResponse(statusCode):
            return "The server returned a \(statusCode) status code."
        case .responseTypeMismatch:
            return "The response did not match the expected error type."
        }
    }
}

extension NETHTTPError: Equatable where N: Equatable {}
