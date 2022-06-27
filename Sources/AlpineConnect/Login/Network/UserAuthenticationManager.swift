//
//  UserAuthenticationManager.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 5/6/22.
//

import Foundation

public enum ConnectionState {
    case online
    case offline
}

public class UserAuthenticationManager: ObservableObject {
    
    public static let shared = UserAuthenticationManager()
    
    @Published public var userName: String = ""
    @Published public var password: String = ""
    @Published public var storedPassword: String? = nil
    @Published public var storedUserName: String? = nil
    
    @Published public var passwordChangeRequired = false
    @Published public var connectionState: ConnectionState = .offline
    @Published public var userLoggedIn: Bool = false
    
    @Published public var lastSync: Date? = nil
    
    func loginUser(completionHandler: @escaping(LoginResponseMessage) -> Void) {
        guard !userName.isEmpty && !password.isEmpty else {return}
        Login.shared.loginUser { loginResponse in
            if loginResponse == .successfulLogin {
                DispatchQueue.main.async {
                    self.connectionState = .online
                    completionHandler(loginResponse)
                }
            } else {
                DispatchQueue.main.async {
                    self.connectionState = .online
                    completionHandler(loginResponse)
                }
            }
        }
    }
}
