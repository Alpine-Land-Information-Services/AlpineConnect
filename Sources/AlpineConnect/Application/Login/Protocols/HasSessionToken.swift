//
//  HasSessionToken.swift
//  
//
//  Created by Vladislav on 8/19/24.
//

import Foundation

public protocol HasSessionToken {
    var Id: UUID { get }
    var SessionToken: String { get }
    var Login: String { get }
    var UserName: String? { get }
    var FirstName: String? { get }
    var LastName: String? { get }
    
    var AllowResubmit: Bool? { get }
    var IsApplicationAdministrator: Bool? { get }
    var IsActive: Bool? { get }
}
