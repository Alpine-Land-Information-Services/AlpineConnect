//
//  TokenResponse.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/7/23.
//

import Foundation

public enum TokenResponse {
    case success
    case notConnected
    case noStoredCredentials
    case serverIssue(_ description: String)
    
    case unknownIssue
}
