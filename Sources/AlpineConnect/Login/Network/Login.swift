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
                self.checkPasswordChangeRequirement() { isRequred, error in
                    if let error = error {
                        completionHandler(self.checkError(error as! PostgresError))
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
    
    static func checkPasswordChangeRequirement(completionHandler: @escaping (Bool, Error?) -> ()) {
        NetworkManager.shared.pool?.withConnection { connectionRequestResponse in
            switch connectionRequestResponse {
            case .failure(let error):
                completionHandler(false, error)
            case .success:
                completionHandler(true, nil)
            }
        }
    }
    
    static func changePassword(with password: String, completionHandler: @escaping (Bool, Error?) -> ()) {
        NetworkManager.shared.pool?.withConnection { connectionRequestResponse in
            switch connectionRequestResponse {
            case .success:
                do {
                    let connection = try connectionRequestResponse.get()
                    let text = """
                    ALTER ROLE \(UserAuthenticationManager.shared.userName) PASSWORD '\(password)'
                    """
                    
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
