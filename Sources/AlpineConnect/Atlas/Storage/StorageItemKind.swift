//
//  StorageItemKind.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/14/23.
//

import Foundation

public enum StorageItemKind: Codable {
    
    case file(StorageItem)
    case directory(StorageDirectory)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let file = try? container.decode(StorageItem.self) {
            self = .file(file)
            return
        }
        if let directory = try? container.decode(StorageDirectory.self) {
            self = .directory(directory)
            return
        }
        throw DecodingError.typeMismatch(StorageItemKind.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Not a file or directory"))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .file(let file):
            try container.encode(file)
        case .directory(let directory):
            try container.encode(directory)
        }
    }
}
