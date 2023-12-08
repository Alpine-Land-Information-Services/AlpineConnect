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
    case fetched
    
    case offline
    case missingToken
    
    case issue(_ description: String)
}
