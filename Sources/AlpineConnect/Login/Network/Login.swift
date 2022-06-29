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
                    
                    let text = "SELECT * FROM application_users WHERE login = '\(UserManager.shared.userName)'"
                    
                    let statement = try connection.prepareStatement(text: text)
                    let cursor = try statement.execute()
                    
                    if cursor.rowCount == 0 {
                        completionHandler(false, .inactiveUser, nil)
                    }
                    
                    defer { statement.close() }
                    defer { cursor.close() }
                    
                    for row in cursor {
                        let columns = try row.get().columns

                        UserManager.shared.userInfo.id = UUID(uuidString: try columns[6].string())
                        UserManager.shared.userInfo.isAdmin = try columns[4].bool()
                        UserManager.shared.userInfo.firstName = try columns[3].optionalString() ?? ""
                        UserManager.shared.userInfo.firstName = try columns[5].optionalString() ?? ""
                        
                        if try columns[2].bool() {
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
    
    static func changePassword(with password: String, completionHandler: @escaping (Bool, Error?) -> ()) {
        NetworkManager.shared.pool?.withConnection { connectionRequestResponse in
            switch connectionRequestResponse {
            case .success:
                do {
                    let connection = try connectionRequestResponse.get()
                    let text = "ALTER ROLE \(UserManager.shared.userName) PASSWORD '\(password)'"
                    
                    let statement = try connection.prepareStatement(text: text)
                    let cursor = try statement.execute()
                    
                    cursor.close()
                    statement.close()
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
