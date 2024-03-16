//
//  URLHelper.swift
//  
//
//  Created by Josue Hernandez on 10-10-22.
//

import Foundation

extension URL {
    // swiftlint:disable force_unwrapping
    static var test = Self(string: "https://jghg02.com")!
}

extension URLRequest {
    static var test = Self(url: URL.test)
    static var testWithExtraProperties = Self(
        url: URL.test,
        cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
        timeoutInterval: 42.0
    )
}
