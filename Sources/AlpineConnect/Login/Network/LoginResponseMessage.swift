//
//  LoginResponseMessage.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 6/27/22.
//

import Foundation

enum LoginResponseMessage {
    case invalidCredentials
    case inactiveUser
    case networkError
    case successfulLogin
    case passwordChangeRequired
    case unknownError
}

extension LoginResponseMessage: RawRepresentable {
    
    init?(rawValue: (String, String)) {
        switch rawValue {
        case ("Error", "Network Error"): self = .networkError
        case ("Invalid Credentials", "The login credentials you entered does not exist in our system"): self = .invalidCredentials
        case ("Inactive User", "Your account is inactive. Please check your user status with an administrator"): self = .inactiveUser
        case ("Success", "Successfully signed"): self = .successfulLogin
        default:
            return nil
        }
    }
    var rawValue: (String, String) {
        switch self {
        case .inactiveUser:
            return ("Inactive User", "Your account is inactive. Please check your user status with an administrator")
        case .invalidCredentials:
            return ("Invalid Credentials", "The login credentials you entered are invalid.")
        case .networkError:
            return ("Error", "Network Error")
        case .successfulLogin:
            return ("Success", "Successfully signed")
        case .passwordChangeRequired:
            return ("Change Password", "Password change is required for your account.")
        case .unknownError:
            return ("Unknown Error", "Please contact development team for support.")

        }
    }
}
