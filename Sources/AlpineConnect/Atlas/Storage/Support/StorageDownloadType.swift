//
//  StorageDownloadType.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/12/23.
//

import Foundation
import AlpineCore

public enum ReferenceLocation: String {
    case myFolder
    case cloud
    case shared
    case project
    case community
    
    public var coreURL: URL {
        switch self {
        case .myFolder, .cloud, .shared, .community:
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
        case .community:
            "Community"
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
        case .community:
            return "figure.2"
        }
    }
    
    static var groupURL: URL {
        FS.atlasGroupURL
    }
    static var documentsURL: URL {
        FS.appDocumentsURL
    }
    
    /// Used to determine file location based on soley its connectionString
    public var textualFolderRepresentation: String {
        switch self {
        case .myFolder:
            "Users"
        case .cloud:
            "Alpine Cloud"
        case .shared:
            "Shared"
        case .project:
            "Layers"
        case .community:
            "Alpine Cloud/Community"
        }
    }
        
    public func getBasePath(projectID: String? = nil, sharedUserID: String? = nil) throws -> String {
        let userID = ConnectManager.shared.userID
        
        switch self {
        case .myFolder:
            return "Users/\(userID)/"
        case .shared:
            guard let sharedUserID = sharedUserID else {
                throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing sharedUserID in shared location"])
            }
            return "Shared/\(userID)/\(sharedUserID)/"
            
        case .project:
            guard let finalProjectID = projectID else {
                throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing projectID for project"])
            }
            return "Atlas/\(userID)/\(finalProjectID)/Layers/"
            
        case .community:
            return "Alpine Cloud/Community/"
            
        case .cloud:
            return "Alpine Cloud/"
        }
    }
    
    
    public func baseURL(projectID: String, sharedUserID: String) throws -> URL {
        coreURL.appending(path: try getBasePath(projectID: projectID, sharedUserID: sharedUserID))
    }
}
