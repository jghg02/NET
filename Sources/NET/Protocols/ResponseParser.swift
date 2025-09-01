//
//  ResponseParser.swift
//  NET
//
//  Created by SOLID Principles Enhancement
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Protocol for parsing HTTP response data
/// Addresses Single Responsibility Principle by separating parsing logic
public protocol ResponseParser {
    /// Parse successful response data into expected type
    /// - Parameters:
    ///   - data: Raw response data
    ///   - type: Expected return type
    /// - Returns: Parsed object or nil if parsing fails
    func parseSuccess<T: Decodable>(_ data: Data, type: T.Type) -> T?
    
    /// Parse error response data into error type
    /// - Parameters:
    ///   - data: Raw response data
    ///   - type: Expected error type
    /// - Returns: Parsed error or nil if parsing fails
    func parseError<E: LocalizedError & Decodable>(_ data: Data, type: E.Type) -> E?
}

/// Default JSON implementation of ResponseParser
public struct DefaultJSONParser: ResponseParser {
    private let successDecoder: JSONDecoder
    private let errorDecoder: JSONDecoder
    
    public init(
        successKeyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase,
        errorKeyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase
    ) {
        self.successDecoder = JSONDecoder()
        self.successDecoder.keyDecodingStrategy = successKeyDecodingStrategy
        
        self.errorDecoder = JSONDecoder()
        self.errorDecoder.keyDecodingStrategy = errorKeyDecodingStrategy
    }
    
    public func parseSuccess<T: Decodable>(_ data: Data, type: T.Type) -> T? {
        return try? successDecoder.decode(type, from: data)
    }
    
    public func parseError<E: LocalizedError & Decodable>(_ data: Data, type: E.Type) -> E? {
        return try? errorDecoder.decode(type, from: data)
    }
}