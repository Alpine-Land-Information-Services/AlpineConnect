//
//  LocalUserProtocol.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 7/18/22.
//

import Foundation

public protocol LocalUserProtocol {
    
    associatedtype LocalUserInfo
    
    static var user: LocalUserInfo! { get set }
    
    static func getApplicationUser(completionHandler: @escaping (LoginResponse) -> ())
    static func saveUserToUserDefaults(_ info: LocalUserInfo)
    static func getUserFromUserDefaults() -> Bool
}
