//
//  Dictionary.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 3/28/23.
//

import Foundation

public extension Dictionary {
    
    static func getFromDefaults(key: String) -> Self? {
        UserDefaults.standard.value(forKey: key) as? Dictionary
    }
    
    func saveToDefaults(key: String) {
        UserDefaults.standard.set(self, forKey: key)
        UserDefaults.standard.synchronize()
    }
}
