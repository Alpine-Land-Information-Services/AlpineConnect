//
//  Data.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/21/23.
//

import Foundation

public extension Data {
    
    func decode(as type: Decodable.Type) -> Decodable? {
        try? JSONDecoder().decode(type, from: self)
    }
}
