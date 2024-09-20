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
    
    public var stackName: String {
        switch self {
        case .myFolder:
            "My Folder"
        case .cloud:
            "Alpine Cloud"
        case .shared:
            "Shared With Me"
        case .project:
            "Project"
        }
    }
    
    public var icon: String {
        switch self {
        case .myFolder:
            return "folder.badge.person.crop"
        case .cloud:
            return "cloud"
        case .shared:
            return "folder.badge.gearshape"
        case .project:
            return "folder"
        }
    }
    
    static var groupURL: URL {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.alpinelis.atlas")!
    }
    static var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
