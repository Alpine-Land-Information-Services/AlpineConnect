//
//  Codable.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/21/23.
//

import Foundation

public extension Decodable {
    
    static func getFromDefaults(key: String) -> Data? {
        UserDefaults.standard.object(forKey: key) as? Data
    }
}

public extension Encodable {
    
    func saveToDefaults(key: String) {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}


