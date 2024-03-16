//
//  NETConfig.swift
//  
//
//  Created by Josue Hernandez on 08-10-22.
//

import Foundation

public enum NETConfig {
    public static var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase
    public static var keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .convertToSnakeCase
    @available(iOS 15.0, *)
    public static var requestLoader: NETRequestLoader = URLSession.shared

    @available(iOS 15.0, *)
    static func resetToDefaults() {
        keyDecodingStrategy = .convertFromSnakeCase
        keyEncodingStrategy = .convertToSnakeCase
        requestLoader = URLSession.shared
    }
}
