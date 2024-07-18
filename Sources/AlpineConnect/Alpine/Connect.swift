//
//  Connect.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 1/18/24.
//

import Foundation

public typealias Connect = ConnectManager

public extension ConnectManager {
    
    static var user: ConnectUser? {
        ConnectManager.shared.user
    }
    
    static var hasUser: Bool {
        ConnectManager.shared.user != nil
    }
}
