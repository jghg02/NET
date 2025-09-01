//
//  NetworkConfiguration.swift
//  NET
//
//  Created by SOLID Principles Enhancement
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Protocol for network configuration
/// Addresses Dependency Inversion Principle by abstracting configuration
public protocol NetworkConfiguration {
    /// JSON key decoding strategy for successful responses
    var successKeyDecodingStrategy: JSONDecoder.KeyDecodingStrategy { get }
    
    /// JSON key decoding strategy for error responses
    var errorKeyDecodingStrategy: JSONDecoder.KeyDecodingStrategy { get }
    
    /// JSON key encoding strategy for request bodies
    var keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy { get }
    
    /// Request timeout interval
    var requestTimeoutInterval: TimeInterval { get }
    
    /// Default request headers
    var defaultHeaders: [String: String] { get }
}

/// Default implementation maintaining backward compatibility
public struct DefaultNetworkConfiguration: NetworkConfiguration {
    public let successKeyDecodingStrategy: JSONDecoder.KeyDecodingStrategy
    public let errorKeyDecodingStrategy: JSONDecoder.KeyDecodingStrategy
    public let keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy
    public let requestTimeoutInterval: TimeInterval
    public let defaultHeaders: [String: String]
    
    public init(
        successKeyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase,
        errorKeyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase,
        keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .convertToSnakeCase,
        requestTimeoutInterval: TimeInterval = 60.0,
        defaultHeaders: [String: String] = [:]
    ) {
        self.successKeyDecodingStrategy = successKeyDecodingStrategy
        self.errorKeyDecodingStrategy = errorKeyDecodingStrategy
        self.keyEncodingStrategy = keyEncodingStrategy
        self.requestTimeoutInterval = requestTimeoutInterval
        self.defaultHeaders = defaultHeaders
    }
}

/// Legacy compatibility wrapper for existing NETConfig
extension DefaultNetworkConfiguration {
    /// Creates configuration from existing NETConfig values
    /// Maintains backward compatibility
    public static var fromLegacyConfig: DefaultNetworkConfiguration {
        return DefaultNetworkConfiguration(
            successKeyDecodingStrategy: NETConfig.keyDecodingStrategy,
            errorKeyDecodingStrategy: NETConfig.keyDecodingStrategy,
            keyEncodingStrategy: NETConfig.keyEncodingStrategy
        )
    }
}