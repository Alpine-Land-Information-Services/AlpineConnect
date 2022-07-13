//
//  PasswordChange.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 7/13/22.
//

import Foundation


class PasswordChange {
    
    static func changeDBPassword(with password: String, completionHandler: @escaping (Bool, LoginResponseMessage?) -> ()) {
        NetworkManager.shared.pool?.withConnection { connectionRequestResponse in
            switch connectionRequestResponse {
            case .success:
                do {
                    let connection = try connectionRequestResponse.get()
                    let text = "ALTER ROLE \(UserManager.shared.userName) PASSWORD '\(password)'"
                    
                    let statement = try connection.prepareStatement(text: text)
                    let cursor = try statement.execute()
                    
                    defer { cursor.close() }
                    defer { statement.close() }
            
                    completionHandler(true, nil)
                }
                catch {
                    completionHandler(false, Check.checkPostgresError(error))
                }
            case .failure(let error):
                completionHandler(false, Check.checkPostgresError(error))
            }
        }
    }
}

