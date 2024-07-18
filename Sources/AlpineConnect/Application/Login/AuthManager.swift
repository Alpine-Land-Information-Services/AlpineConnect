//
//  AuthManager.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/7/23.
//

import Foundation
import LocalAuthentication
import AlpineCore

class AuthManager {
    
    var supportBiometricAuthType: LABiometryType = .none
    
    var bioType: String {
        switch supportBiometricAuthType {
        case .touchID:
            return "Touch ID"
        case .faceID:
            return "Face ID"
        default:
            return "Unknown"
        }
    }
    
    var biometricsAuthorized: Bool {
        UserDefaults().bool(forKey: "AC_is_biometrics_authorized")
    }

//    func attemptToSave(for serverUser: ServerUserResponse, with credentials: CredentialsData) -> ConnectionResponse {
////        DispatchQueue.main.sync {
////            ConnectManager.shared.user = ConnectUser(for: serverUser)
////        }
//        
//
//        
//        return saveUser(with: credentials.email)
//    }
    
    func saveUser(with credentials: CredentialsData) -> ConnectionResponse {
        
        guard saveToKeychain(account: credentials.email, password: credentials.password) else {
            return ConnectionResponse(result: .moreDetail, detail: .keychainSaveFail)
        }
        
        CoreAppControl.shared.defaults.lastUser = credentials.email
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

extension AuthManager {
    
    func authorizeBiometrics() {
        UserDefaults().setValue(true, forKey: "AC_is_biometrics_authorized")
    }
    
    func setRemindLaterForBiometrics() {
        UserDefaults().setValue(Date(), forKey: "AC_last_biometrics_ask_date")
    }
    
    func isBiometricEnabledOnDevice() async -> Bool {
        await withCheckedContinuation { continuation in
            let context = LAContext()
            var contextError: NSError?
            
            if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &contextError) {
                self.supportBiometricAuthType = context.biometryType
                continuation.resume(returning: true)
            }
            else {
                continuation.resume(returning: false)
            }
        }
    }
    
    func askForBioMetricAuthenticationSetup() async -> Bool {
        guard !biometricsAuthorized else { return false }
        guard await checkIfPromptForBioSetUp() else { return false }
        
        if await isBiometricEnabledOnDevice() {
            return true
        }
        else {
            return false
        }
    }
    
    func checkIfPromptForBioSetUp() async -> Bool {
        if let lastAskedDate = fetchLastBioAskDate() {
            let numberOfDays = Date().daysBetweenDates(startDate: lastAskedDate)
            if numberOfDays < 3 {
                return false
            } else {
                return true
            }
        } else {
            return true
        }
    }
    
    func fetchLastBioAskDate() -> Date? {
        if let date = UserDefaults().value(forKey: "AC_last_biometrics_ask_date") as? Date {
            return date
        } else {
            return nil
        }
    }
}

extension AuthManager {
    
    func runBioAuth(completionHandler: @escaping(Bool) -> ()) {
        let context = LAContext()
        var contextError: NSError?
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &contextError) {
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Confirm To Sign In") { result, error in
                if result {
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            }
        }
    }
}
