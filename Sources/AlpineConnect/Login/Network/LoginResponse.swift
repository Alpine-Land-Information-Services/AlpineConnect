//
//  LoginResponse.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 6/27/22.
//

import Foundation

public enum LoginResponse: Hashable {

    case successfulLogin
    case invalidCredentials
    case wrongPassword
    case invalidEmail
    case userNotInApplicationTable
    
    case passwordChangeRequired
    case registrationRequired
    
    case offlineDiffirentUser
    case noAccess
    case inactiveUser
    case userExists
    case emptyFields
    case networkError
    case timeout
    case unknownError
    
    case authenticationAlert
    case enableBiometricsAlert
    case updateKeychainAlert
    
    case debug
    
    // Biometric errors
    
    case passcodeNotSet
    case bioNotSet
    case bioNotAvailable
    case unknownBioError
    
    case customError(title: String, detail: String)
}

extension LoginResponse: RawRepresentable {
    
    public init?(rawValue: (String, String)) {
        switch rawValue {
        case ("Error", "Network Error"): self = .networkError
        case ("Invalid Credentials", "The login credentials you entered does not exist in our system"): self = .invalidCredentials
        case ("Inactive User", "Your account is inactive. Please check your user status with an administrator"): self = .noAccess
        case ("Success", "Successfully signed"): self = .successfulLogin
        default:
            return nil
        }
    }
    public var rawValue: (String, String) {
        switch self {
        case .noAccess:
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
        default:
            return ("Not Done", "Not Done")
        }
    }
}
