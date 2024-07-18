//
//  User.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 6/23/22.
//

import Foundation

public struct User: Codable, Identifiable {
    
    public init(id: UUID, name: String, password: String) {
        self.id = id
        self.name = name
        self.password = password
    }
    
    public var id: UUID
    
    public var name: String
    public var password: String
    
}
