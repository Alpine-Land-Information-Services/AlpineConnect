//
//  StorageDirectory.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/14/23.
//

import Foundation

public struct StorageDirectory: Codable {
    
    var type: String
    var path: String
    var contents: [StorageItemKind]
}
