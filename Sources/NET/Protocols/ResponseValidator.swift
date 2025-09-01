//
//  ResponseValidator.swift
//  NET
//
//  Created by SOLID Principles Enhancement
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Protocol for validating HTTP responses
/// Addresses Interface Segregation Principle by separating validation concerns
public protocol ResponseValidator {
    /// Validate an HTTP response
    /// - Parameter response: URL response to validate
    /// - Returns: True if response is valid, false otherwise
    func isValid(_ response: URLResponse) -> Bool
}

/// Default HTTP status code validator
public struct HTTPStatusValidator: ResponseValidator {
    private let validStatusCodes: ClosedRange<Int>
    
    public init(validStatusCodes: ClosedRange<Int> = 200...299) {
        self.validStatusCodes = validStatusCodes
    }
    
    public func isValid(_ response: URLResponse) -> Bool {
        guard let httpResponse = response as? HTTPURLResponse else {
            return false
        }
        return validStatusCodes.contains(httpResponse.statusCode)
    }
}

/// Content type validator
public struct ContentTypeValidator: ResponseValidator {
    private let expectedContentTypes: Set<String>
    
    public init(expectedContentTypes: [String]) {
        self.expectedContentTypes = Set(expectedContentTypes)
    }
    
    public init(expectedContentType: String) {
        self.expectedContentTypes = Set([expectedContentType])
    }
    
    public func isValid(_ response: URLResponse) -> Bool {
        guard let httpResponse = response as? HTTPURLResponse,
              let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type") else {
            return false
        }
        
        // Extract main content type (before semicolon if present)
        let mainContentType = contentType.components(separatedBy: ";").first?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
        return expectedContentTypes.contains(mainContentType)
    }
}

/// Composite validator that combines multiple validators
public struct CompositeValidator: ResponseValidator {
    private let validators: [ResponseValidator]
    private let requireAll: Bool
    
    public init(validators: [ResponseValidator], requireAll: Bool = true) {
        self.validators = validators
        self.requireAll = requireAll
    }
    
    public func isValid(_ response: URLResponse) -> Bool {
        if requireAll {
            return validators.allSatisfy { $0.isValid(response) }
        } else {
            return validators.contains { $0.isValid(response) }
        }
    }
}

/// Always valid validator (for testing or bypassing validation)
public struct AlwaysValidValidator: ResponseValidator {
    public init() {}
    
    public func isValid(_ response: URLResponse) -> Bool {
        return true
    }
}