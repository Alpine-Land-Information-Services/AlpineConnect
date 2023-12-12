//
//  Token.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/6/23.
//

import Foundation

public struct Token: Codable {
    public var rawValue: String
    public var expirationDate: Date
    
    var encoded: Data? {
        try? JSONEncoder().encode(self)
    }
}
