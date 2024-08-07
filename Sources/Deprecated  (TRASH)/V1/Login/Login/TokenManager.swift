//
//  TokenManager.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 1/27/23.
//

import Foundation
import AlpineUI
import AlpineCore

class TokenManager {
    
    static var currentToken: UserManager.LoginToken? {
        UserManager.shared.token
    }
    
    static func saveLoginToken(_ token: String) {
        let token = UserManager.LoginToken(token)
        UserManager.shared.token = token
        
        if let encoded = try? JSONEncoder().encode(token) {
            UserDefaults.standard.set(encoded, forKey: "LoginUserToken")
        }
    }
    
    static func checkToken() {
        guard NetworkMonitor.shared.connected else {
            return
        }
        guard let currentToken else {
            getNewToken()
            return
        }
        if let diff = Calendar.current.dateComponents([.hour], from: currentToken.date, to: Date()).hour, diff >= 24 {
            getNewToken()
        }
    }
    
    static func getNewToken() {
        guard let loginUpdate = UserManager.shared.loginUpdate else {
            return
        }
        Task {
            switch await Login.updateUserLogin(info: loginUpdate) {
            case .successfulLogin:
                return
            default:
                noTokenAlert()
            }
        }
    }
    
    static func noTokenAlert() {
        let alert = CoreAlert(title: headerText, message:  "Login token is missing, to perform any actions that require connection to server - relogin is required while connected to network.",
                              buttons: [CoreAlertButton(title: "Log Out Now", style: .default, action: {
            UserManager.shared.userLoggedIn = false
        })])
        
        Core.makeAlert(alert: alert)
    }
}
