//
//  ConnectUser.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/6/23.
//

import Foundation

public struct ConnectUser: Codable {
    public let email: String
    
    public let firstName: String
    public let lastName: String
    
    public let isAdmin: Bool
}
