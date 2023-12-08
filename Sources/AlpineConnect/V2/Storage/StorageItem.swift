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

    public var created: Date
    public var lastModified: Date
    
 
    public static var demo: StorageItem {
        StorageItem(name: "county.fgb", type: "File", size: 52087, hash: "23423424", path: "234", contentType: "", created: Date(), lastModified: Date())
    }
}
