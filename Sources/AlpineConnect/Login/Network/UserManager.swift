//
//  UserManager.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 5/6/22.
//

import Foundation

public class UserManager: ObservableObject {
    
    struct LoginInfo: Codable {
        var email: String
        var password: String
    }
    
    public struct UserInfo: Codable {
        public init() {}
        
        public var firstName: String = ""
        public var lastName: String = ""
    }
    
    public struct LoginToken: Codable {
        public init(_ token: String) {
            self.key = token
        }
        
        public var key: String
        public var date = Date()
    }
    
    public static let shared = UserManager()
    
    public var userInfo = UserInfo()
    public var token: LoginToken?
    
    
    var storedPassword: String? = nil
    var storedUserName: String? = nil
    var password: String = ""
    
    var loginUpdate: Login.UserLoginUpdate?
    
    @Published public var userName: String = ""
    @Published var inputPassword: String = ""
    
    @Published public var userLoggedIn: Bool = false
    @Published public var lastSync: Date? = nil
}
