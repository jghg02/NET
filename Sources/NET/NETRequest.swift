//
//  NETRequest.swift
//  
//
//  Created by Josue Hernandez on 08-10-22.
//

import Foundation

public class NETRequest {
    public typealias NETHeaders = [String: String]

    public init(url: URL, method: NETMethod = .GET, headers: NETHeaders = [:]) {
        self.url = url
        self.method = method
        self.headers = headers
    }

    // MARK: Internal

    var asURLRequest: URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        addToRequest(&request)
        return request
    }

    func addToRequest(_ request: inout URLRequest) {}

    // MARK: Private

    private let headers: NETHeaders
    private let method: NETMethod
    private let url: URL
}
