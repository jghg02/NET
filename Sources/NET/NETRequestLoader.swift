//
//  NETRequestLoader.swift
//  
//
//  Created by Josue Hernandez on 08-10-22.
//

import Foundation

/// Protocol
@available(iOS 13.0.0, *)
public protocol NETRequestLoader {
    func request(_ request: URLRequest) async throws -> (Data, URLResponse)
}

/// Helper class to prepare request(adding headers & clubbing base URL) & perform API request.
@available(macOS 12.0, *)
@available(iOS 15.0, *)
extension URLSession: NETRequestLoader {
    public func request(_ request: URLRequest) async throws -> (Data, URLResponse) {
        try await data(for: request)
    }
}

@available(macOS, deprecated: 12.0, message: "Use the built-in API instead")
@available(iOS, deprecated: 15.0, message: "Use the built-in API instead")
extension URLSession {

    /// Performs a API request which is called by any service request class.
    /// It also performs an additional task of validating the auth token and refreshing if necessary
    ///
    /// - Parameters:
    ///   - URL: URL
    @available(iOS 13.0.0, *)
    func data(from url: URL) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: url) { data, response, error in
                guard let data, let response else {
                    let error = error ?? URLError(.badServerResponse)
                    return continuation.resume(throwing: error)
                }

                continuation.resume(returning: (data, response))
            }

            task.resume()
        }
    }
}
