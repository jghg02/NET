//
//  RequestInterceptor.swift
//  NET
//
//  Created by SOLID Principles Enhancement
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Protocol for intercepting and modifying requests before execution
/// Addresses Open/Closed Principle by allowing extension without modification
public protocol RequestInterceptor {
    /// Intercept and potentially modify a request
    /// - Parameter request: Original URL request
    /// - Returns: Modified URL request
    func intercept(_ request: URLRequest) async -> URLRequest
}

/// Protocol for intercepting and modifying responses after execution
/// Addresses Open/Closed Principle by allowing extension without modification
public protocol ResponseInterceptor {
    /// Intercept and potentially modify a response
    /// - Parameters:
    ///   - response: Original URL response
    ///   - data: Response data
    /// - Returns: Modified response and data
    func intercept(_ response: URLResponse, data: Data) async -> (URLResponse, Data)
}

/// Authentication interceptor for adding authentication headers
public struct AuthenticationInterceptor: RequestInterceptor {
    private let authenticationProvider: AuthenticationProvider
    
    public init(authenticationProvider: AuthenticationProvider) {
        self.authenticationProvider = authenticationProvider
    }
    
    public func intercept(_ request: URLRequest) async -> URLRequest {
        return await authenticationProvider.authenticate(request)
    }
}

/// Logging interceptor for debugging purposes
public struct LoggingInterceptor: RequestInterceptor, ResponseInterceptor {
    private let shouldLogRequests: Bool
    private let shouldLogResponses: Bool
    
    public init(logRequests: Bool = true, logResponses: Bool = true) {
        self.shouldLogRequests = logRequests
        self.shouldLogResponses = logResponses
    }
    
    public func intercept(_ request: URLRequest) async -> URLRequest {
        if shouldLogRequests {
            print("🌐 [NET] Request: \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "Unknown")")
            if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
                print("🌐 [NET] Headers: \(headers)")
            }
        }
        return request
    }
    
    public func intercept(_ response: URLResponse, data: Data) async -> (URLResponse, Data) {
        if shouldLogResponses {
            if let httpResponse = response as? HTTPURLResponse {
                print("🌐 [NET] Response: \(httpResponse.statusCode) from \(httpResponse.url?.absoluteString ?? "Unknown")")
            }
            print("🌐 [NET] Data size: \(data.count) bytes")
        }
        return (response, data)
    }
}