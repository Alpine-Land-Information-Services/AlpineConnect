//
//  UserAuthenticationManager.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 5/6/22.
//

import Foundation
import CryptoKit
import CommonCrypto

public enum ConnectionState {
    case online
    case offline
}

public class UserAuthenticationManager: ObservableObject {

    public static let shared = UserAuthenticationManager()
    
    @Published public var userName: String = "Tyler D. Suran"
    @Published public var password: String = " "
    @Published public var connectionState: ConnectionState = .offline
    @Published public var userLoggedIn: Bool = false
    @Published public var user: User? = nil
    @Published public var storedPassword: String? = nil
    @Published public var storedUserName: String? = nil
    @Published public var lastSync: Date? = nil

    func loginUser(completionHandler: @escaping(LoginResponseMessage) -> Void) {
        guard !userName.isEmpty && !password.isEmpty else {return}
        Login.shared.loginUser(_ : userName, _: password) { loginResponse in
            if loginResponse == .successfulLogin {
                DispatchQueue.main.async {
                    self.connectionState = .online
                    self.userLoggedIn = true
                    completionHandler(loginResponse)
                }
            } else {
                DispatchQueue.main.async {
                    self.connectionState = .online
                    self.userLoggedIn = false
                    completionHandler(loginResponse)
                }
            }
        }
    }
}

enum LoginResponseMessage {
    case networkError
    case invalidCredentials
    case inactiveUser
    case successfulLogin
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
        }
    }
}

extension String {
    
    
    func hashString() -> String {
        let stringData = Data(self.utf8)
        let hashedData = SHA256.hash(data: stringData)
        let hashedPassword = hashedData.compactMap {String(format: "%02X", $0)}.joined()
        return hashedPassword.lowercased()
    }
    
    func sha1(_ uppercase:Bool = false) -> String {
        /* 128 bit SHA1 sum hex string */
        let fmt = uppercase ? "%02hhX" : "%02hhx" // "%02hhx" -- "hh" for char/UInt8, "h" for short/UInt16, "" for int/Int32, "l" for long/Int/Int64
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        var sha = ""
        digest.forEach({
            sha += String(format: fmt, $0)
        })
        #if DEBUG
        assert(digest.map({ String(format: fmt, $0) }).joined() == sha )
        #endif
        return sha

    }
}
