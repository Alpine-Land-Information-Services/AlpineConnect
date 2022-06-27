//
//  File.swift
//  
//
//  Created by Jenya Lebid on 6/23/22.
//

import Foundation
import PostgresClientKit

class Login {
    
    static let shared = Login()
    
    func loginUser(completionHandler: @escaping(LoginResponseMessage) -> ()) {
        NetworkManager.shared.pool?.withConnection { connectionRequestResponse in
            switch connectionRequestResponse {
            case .failure(let error):
                switch error as! PostgresError {
                case .sqlError(notice: let notice):
                    switch notice.code {
                    case "28P01":
                        completionHandler(.invalidCredentials)
                    default:
                        assertionFailure("Postgres SQL Login Error: \(notice)")
                    }
                default:
                    assertionFailure("Unknown Postgres Login Error: \(error)")
                }
            case .success:
                completionHandler(.successfulLogin)
            }
        }
    }
    
    func checkPasswordChangeRequirement(completionHandler: @escaping(LoginResponseMessage) -> ()) {
        NetworkManager.shared.pool?.withConnection { connectionRequestResponse in
            switch connectionRequestResponse {
            case .failure(let error):
                print(error)
                completionHandler(.networkError)
            case .success(let connection):
                print(connection)
            }
        }
    }
}
