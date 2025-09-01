//
//  AuthenticationProvider.swift
//  NET
//
//  Created by SOLID Principles Enhancement
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Protocol for providing authentication to requests
/// Addresses Interface Segregation Principle by separating authentication concerns
public protocol AuthenticationProvider {
    /// Authenticate a request by adding necessary headers or modifying the request
    /// - Parameter request: Original URL request
    /// - Returns: Authenticated URL request
    func authenticate(_ request: URLRequest) async -> URLRequest
}

/// Bearer token authentication provider
public struct BearerTokenAuthProvider: AuthenticationProvider {
    private let token: String
    
    public init(token: String) {
        self.token = token
    }
    
    public func authenticate(_ request: URLRequest) async -> URLRequest {
        var authenticatedRequest = request
        authenticatedRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return authenticatedRequest
    }
}

/// Basic authentication provider
public struct BasicAuthProvider: AuthenticationProvider {
    private let username: String
    private let password: String
    
    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    public func authenticate(_ request: URLRequest) async -> URLRequest {
        let credentials = "\(username):\(password)"
        guard let credentialsData = credentials.data(using: .utf8) else {
            return request
        }
        
        let base64Credentials = credentialsData.base64EncodedString()
        var authenticatedRequest = request
        authenticatedRequest.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        return authenticatedRequest
    }
}

/// API key authentication provider
public struct APIKeyAuthProvider: AuthenticationProvider {
    private let apiKey: String
    private let headerName: String
    
    public init(apiKey: String, headerName: String = "X-API-Key") {
        self.apiKey = apiKey
        self.headerName = headerName
    }
    
    public func authenticate(_ request: URLRequest) async -> URLRequest {
        var authenticatedRequest = request
        authenticatedRequest.setValue(apiKey, forHTTPHeaderField: headerName)
        return authenticatedRequest
    }
}

/// No authentication provider (pass-through)
public struct NoAuthProvider: AuthenticationProvider {
    public init() {}
    
    public func authenticate(_ request: URLRequest) async -> URLRequest {
        return request
    }
}