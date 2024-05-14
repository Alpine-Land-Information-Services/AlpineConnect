//
//  StorageItem.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/7/23.
//

import Foundation

public struct StorageItem: Codable, Hashable, Equatable, Identifiable {

    public var id: String {
        name
    }
    
    public var name: String
    public var type: String
    public var size: Int

    public var hash: String
    public var path: String
    public var contentType: String
        
    public var relativePath: String?

    public var created: Date
    public var lastModified: Date
    
    public var isShortcut: Bool?
        
    public static var demo: StorageItem {
        StorageItem(name: "county.fgb", type: "File", size: 52087, hash: "23423424", path: "234", contentType: "", created: Date(), lastModified: Date(), isShortcut: false)
    }
    
    public var isPack: Bool {
        let components = name.components(separatedBy: ".")
        if let ext = components.last {
            if ext == "zip" {
                return true
            }
            return false
        }
        return false
    }
    
    public var fileName: String {
        name.components(separatedBy: ".").first ?? name
    }
}
