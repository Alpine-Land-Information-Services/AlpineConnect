//
//  StorageDownloadType.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/12/23.
//

import Foundation

public enum ReferenceLocation: String {
    case myFolder
    case cloud
    case shared
    case project
    
    public var baseURL: URL {
        switch self {
        case .myFolder, .cloud, .shared:
            Self.groupURL
        case .project:
            Self.documentsURL
        }
    }
    
    static var groupURL: URL {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.alpinelis.atlas")!
    }
    static var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
