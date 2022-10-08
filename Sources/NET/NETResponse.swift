//
//  NETResponse.swift
//  
//
//  Created by Josue Hernandez on 08-10-22.
//

import Foundation

public struct NETResponse<N> {
    public let headers: [AnyHashable: Any]
    public let value: N
}
