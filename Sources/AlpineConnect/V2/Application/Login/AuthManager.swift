//
//  AuthManager.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/7/23.
//

import Foundation

class AuthManager {
    
    var credentials: CredentialsData
    
    init(credentials: CredentialsData) {
        self.credentials = credentials
    }
    
    func attemptToSave() -> ConnectionResponse {
        guard saveToKeychain(account: credentials.email, password: credentials.password) else {
            return ConnectionResponse(result: .moreDetail, detail: .keychainSaveFail)
        }
        
        UserDefaults.standard.setValue(credentials.email, forKey: "AC_last_login")
        
        return ConnectionResponse(result: .success)
    }
    
    func saveToKeychain(account: String, password: String) -> Bool {
        let passwordData = password.data(using: .utf8)!
        
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: account,
                                    kSecValueData as String: passwordData]
        
        // Delete any existing items
        SecItemDelete(query as CFDictionary)

        // Add the new keychain item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        return status == errSecSuccess
    }
    
    static func retrieveFromKeychain(account: String) -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: account,
                                    kSecReturnData as String: kCFBooleanTrue!,
                                    kSecMatchLimit as String: kSecMatchLimitOne]

        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess else { return nil }
        
        if let passwordData = item as? Data {
            return String(data: passwordData, encoding: .utf8)
        }
        
        return nil
    }
}
