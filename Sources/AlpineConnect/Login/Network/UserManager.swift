//
//  UserManager.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 5/6/22.
//

import Foundation

public class UserManager: ObservableObject {
    
    public struct UserInfo: Codable {
        
        public init() {}
        
        public var id: UUID!
        public var firstName: String = ""
        public var lastName: String = ""
        public var isAdmin: Bool = false
    }
    
    public static let shared = UserManager()
    
    public var userInfo = UserInfo()
    
    var storedPassword: String? = nil
    var storedUserName: String? = nil
    var password: String = ""
    
    @Published public var userName: String = ""
    @Published var inputPassword: String = ""
    
    @Published public var userLoggedIn: Bool = false
    @Published public var lastSync: Date? = nil
}
