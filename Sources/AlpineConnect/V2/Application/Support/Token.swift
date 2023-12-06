//
//  Token.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/6/23.
//

import Foundation

public struct Token: Codable {
    var rawValue: String
    var expirationDate: Date
}
