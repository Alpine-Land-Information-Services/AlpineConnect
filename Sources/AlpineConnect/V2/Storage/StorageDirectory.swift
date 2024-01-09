//
//  StorageDirectory.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/14/23.
//

import Foundation

public struct StorageDirectory: Codable {
    
    public var type: String
    public var path: String
    public var relativePath: String?
    public var contents: [StorageItemKind]
}
