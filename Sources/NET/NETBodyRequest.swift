//
//  NETBodyRequest.swift
//  
//
//  Created by Josue Hernandez on 08-10-22.
//

import Foundation

public class NETBodyRequest<N: Encodable>: NETRequest {
    public init(url: URL, method: NETMethod  = .GET, body: N, headers: NETHeaders = [:]) {
        self.body = body
        super.init(url: url, method: method, headers: headers)
    }
    
    override func addToRequest(_ request: inout URLRequest) {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = NETConfig.keyEncodingStrategy
        request.httpBody = try? encoder.encode(body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
    private let body: N
    
}
