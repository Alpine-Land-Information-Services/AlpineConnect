//
//  HasSessionToken.swift
//  AlpineConnect
//
//  Created by Vladislav on 8/19/24.
//

import Foundation

public protocol JWTData {
    
    var id: UUID { get }
    var sessionToken: String { get }
    
    var login: String { get }
    var userName: String? { get }
    var firstName: String? { get }
    var lastName: String? { get }
}
