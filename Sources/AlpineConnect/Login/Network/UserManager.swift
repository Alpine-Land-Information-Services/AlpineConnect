//
//  UserManager.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 5/6/22.
//

import Foundation

public class UserManager: ObservableObject {
    
    struct UserInfo: Codable {
        
        var login: String = ""
        
        var id: UUID!
        var firstName: String = ""
        var lastName: String = ""
        var isAdmin: Bool = false
    }
    
    public static let shared = UserManager()
    
    var userInfo = UserInfo()
    
    public var storedPassword: String? = nil
    public var storedUserName: String? = nil
    public var password: String = ""
    
    @Published public var userName: String = ""
    @Published public var inputPassword: String = ""
    
    @Published public var userLoggedIn: Bool = false
    @Published public var lastSync: Date? = nil
}
