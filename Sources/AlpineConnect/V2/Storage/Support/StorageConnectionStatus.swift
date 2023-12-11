//
//  StorageConnectionStatus.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/8/23.
//

import Foundation

public enum StorageConnectionStatus: Equatable {
    case readyToFetch
    case fetching
    
    case offline
    case missingToken
    
    case issue(_ description: String)
    
    public var summary: String {
        switch self {
        case .readyToFetch:
            return "OK"
        case .fetching:
            return "Fetching"
        case .offline:
            return "No Network"
        case .missingToken:
            return "Missing Token"
        case .issue:
            return "Issue"
        }
    }
}
