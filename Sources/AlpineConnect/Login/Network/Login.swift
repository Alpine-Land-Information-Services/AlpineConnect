//
//  File.swift
//  
//
//  Created by Jenya Lebid on 6/23/22.
//

import Foundation
import PostgresClientKit

class Login {
    
    static func checkError(_ error: PostgresError) -> LoginResponseMessage {
        switch error {
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
                completionHandler(self.checkError(error as! PostgresError))
            case .success:
                self.getApplicationUser() { isRequred, response, error in
                    if let error = error {
                        completionHandler(self.checkError(error as! PostgresError))
                    }
                    if let response = response {
                        completionHandler(response)
                    }
                    else if isRequred {
                        completionHandler(.passwordChangeRequired)
                    }
                    else {
                        completionHandler(.successfulLogin)
                    }
                }
            }
        }
    }
    
    static func getApplicationUser(completionHandler: @escaping (Bool, LoginResponseMessage?, Error?) -> ()) {
        NetworkManager.shared.pool?.withConnection { connectionRequestResponse in
            switch connectionRequestResponse {
            case .failure(let error):
                completionHandler(false, nil, error)
            case .success:
                do {
                    let connection = try connectionRequestResponse.get()
                    
                    let text = """
                    SELECT
                    id,
                    is_application_administrator,
                    first_name,
                    last_name,
                    require_password_change
                    FROM application_users WHERE login = '\(UserManager.shared.userName)'
                    """
                    
                    let statement = try connection.prepareStatement(text: text)
                    let cursor = try statement.execute()
                    
                    if cursor.rowCount == 0 {
                        completionHandler(false, .inactiveUser, nil)
                    }
                    
                    defer { statement.close() }
                    defer { cursor.close() }
                    
                    for row in cursor {
                        let columns = try row.get().columns
                        
                        var info = UserManager.shared.userInfo

                        info.id = UUID(uuidString: try columns[0].string())
                        info.isAdmin = try columns[1].bool()
                        info.firstName = try columns[2].optionalString() ?? ""
                        info.firstName = try columns[3].optionalString() ?? ""
                        
                        saveUserToUserDefaults(info)
                        
                        if try columns[4].bool() {
                            completionHandler(true, nil, nil)
                        }
                        else {
                            completionHandler(false, nil, nil)
                        }
                    }
                }
                catch {
                    completionHandler(false, nil, error)
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
    
    static func changePassword(with password: String, completionHandler: @escaping (Bool, Error?) -> ()) {
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
                    completionHandler(false, error)
                }
            case .failure(let error):
                completionHandler(false, error)
            }
        }
    }
}
