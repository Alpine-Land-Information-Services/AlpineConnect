//
//  Login.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 6/23/22.
//

import Foundation
import PostgresClientKit

class Login {
    
    static func checkError(_ error: Error) -> LoginResponseMessage {
        switch error as! PostgresError {
        case .sqlError(notice: let notice):
            switch notice.code {
            case "28P01":
                return .invalidCredentials
            case "42501":
                return .inactiveUser
            default:
                assertionFailure("Postgres SQL Login Error: \(notice)")
                return .unknownError
            }
        default:
            assertionFailure("Unknown Postgres Login Error: \(error)")
            return .unknownError
        }
    }
    
    static func loginUser(checkPasswordChange: Bool = true, completionHandler: @escaping (LoginResponseMessage) -> ()) {
        NetworkManager.shared.pool?.withConnection { connectionRequestResponse in
            switch connectionRequestResponse {
            case .failure(let error):
                checkConnectUser(isConnectedToDBUser: false) { connectResponse in
                    if connectResponse == .successfulLogin && checkError(error) == .invalidCredentials {
                        completionHandler(.wrongPassword)
                    }
                    else {
                        completionHandler(connectResponse)
                    }
                }
            case .success:
                self.getApplicationUser() { response, error in
                    if let error = error {
                        completionHandler(self.checkError(error))
                    }
                    else if let response = response {
                        completionHandler(response)
                    }
                    else {
                        checkConnectUser(isConnectedToDBUser: true) { connectResponse in
                            completionHandler(connectResponse)
                        }
                    }
                }
            }
        }
    }
    
    static func checkConnectUser(isConnectedToDBUser: Bool, handler: @escaping (LoginResponseMessage) -> ()) {
        TrackingManager.shared.pool?.withConnection { response in
            switch response {
            case .success:
                do {
                    let connection = try response.get()

                    let text = """
                    SELECT password_change_required
                    FROM user_authentication WHERE email = '\(UserManager.shared.userName)'
                    """
                    let statement = try connection.prepareStatement(text: text)
                    let cursor = try statement.execute()

                    defer { statement.close() }
                    defer { cursor.close() }

                    
                    if cursor.rowCount == 0 {
                        if isConnectedToDBUser {
                            handler(.infoChangeRequired)
                        }
                        else {
                            handler(.registrationRequired)
                        }
                    }
                    else {
                        for row in cursor {
                            let columns = try row.get().columns
                            if try columns[0].bool() {
                                handler(.passwordChangeRequired)
                            }
                            else {
                                handler(.successfulLogin)
                            }
                        }
                    }
                }
                catch {
                    handler(checkError(error))
                }
            case .failure(let error):
                handler(checkError(error))
            }
        }
    }
    
    static func getApplicationUser(completionHandler: @escaping (LoginResponseMessage?, Error?) -> ()) {
        NetworkManager.shared.pool?.withConnection { connectionRequestResponse in
            switch connectionRequestResponse {
            case .failure(let error):
                completionHandler(nil, error)
            case .success:
                do {
                    let connection = try connectionRequestResponse.get()
                    
                    let text = """
                    SELECT
                    id,
                    is_application_administrator,
                    require_password_change
                    
                    FROM application_users WHERE login = '\(UserManager.shared.userName)'
                    """
                    
                    let statement = try connection.prepareStatement(text: text)
                    let cursor = try statement.execute()
                    
                    if cursor.rowCount == 0 {
                        completionHandler(.inactiveUser, nil)
                    }
                    
                    defer { statement.close() }
                    defer { cursor.close() }
                    
                    for row in cursor {
                        let columns = try row.get().columns
                                                
                        UserManager.shared.userInfo.id = UUID(uuidString: try columns[0].string())
                        UserManager.shared.userInfo.isAdmin = try columns[1].bool()
                        
                        if try columns[2].bool() {
                            completionHandler(.passwordChangeRequired, nil)
                        }
                        else {
                            completionHandler(nil, nil)
                        }
                    }
                }
                catch {
                    completionHandler(nil, error)
                }
            }
        }
    }
    
    static func saveUserToUserDefaults(_ info: UserManager.UserInfo) {
        UserManager.shared.userInfo = info
        
        if let encoded = try? JSONEncoder().encode(info) {
            UserDefaults.standard.set(encoded, forKey: "UserInfo")
        }
    }
    
    static func getUserFromUserDefaults() -> Bool {
        if let info = UserDefaults.standard.object(forKey: "UserInfo") as? Data {
            if let loadedInfo = try? JSONDecoder().decode(UserManager.UserInfo.self, from: info) {
                UserManager.shared.userInfo = loadedInfo
                return true
            }
        }
        return false
    }
    
    static func changePassword(with password: String, completionHandler: @escaping (Bool, LoginResponseMessage?) -> ()) {
        NetworkManager.shared.pool?.withConnection { connectionRequestResponse in
            switch connectionRequestResponse {
            case .success:
                do {
                    let connection = try connectionRequestResponse.get()
                    var text = "ALTER ROLE \(UserManager.shared.userName) PASSWORD '\(password)'"
                    
                    let statement = try connection.prepareStatement(text: text)
                    let cursor = try statement.execute()
                    
                    defer { cursor.close() }
                    defer { statement.close() }
                    
                    text = "UPDATE application_users SET require_password_change = FALSE WHERE login = '\(UserManager.shared.userName)'"
                    
                    let u_statement = try connection.prepareStatement(text: text)
                    let u_cursor = try u_statement.execute()
                    
                    defer { u_cursor.close() }
                    defer { u_statement.close() }
                    
                    
                    completionHandler(true, nil)
                }
                catch {
                    completionHandler(false, checkError(error))
                }
            case .failure(let error):
                completionHandler(false, checkError(error))
            }
        }
    }
}
