//
//  Register.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 7/11/22.
//

import Foundation
import PostgresClientKit

class Register {
    
    enum RegisterResponse {
        
        case invalidEmail
        case missingFields
        case registerSuccess
        case newUser
        case userExists
        case emailsDiffer
        case none
    }
    
    struct RegistrationInfo {

        var email: String
        var firstName: String
        var lastName: String
    }
    
    static func registerUser(info: RegistrationInfo, handler: @escaping (RegisterResponse) -> ()) {
        checkUserRegistration { registrationCheckHandler in
            if registrationCheckHandler == .newUser {
                doRegistration(info: info) { registerHandler in
                    handler(registerHandler)
                }
            }
            else {
                handler(registrationCheckHandler)
            }
        }
    }
    
    
    static func checkUserRegistration(handler: @escaping (RegisterResponse) -> ()) {
        TrackingManager.shared.pool?.withConnection { response in
            switch response {
            case .success:
                do {
                    let connection = try response.get()
                    
                    let text = """
                    SELECT COUNT (*)
                    FROM user_authentication WHERE email = '\(UserManager.shared.userName)'
                    """
                    let statement = try connection.prepareStatement(text: text)
                    let cursor = try statement.execute()
                    
                    defer { statement.close() }
                    defer { cursor.close() }

                    for row in cursor {
                        let columns = try row.get().columns
                        if try columns[0].int() == 0 {
                            handler(.userExists)
                        }
                        else {
                            handler(.newUser)
                        }
                    }
                }
                catch {
                    fatalError("Error updating user: \(error)")
                }
            case .failure(let error):
                fatalError("Error updating user: \(error)")
            }
        }
    }
    
    static func doRegistration(info: RegistrationInfo, handler: @escaping (RegisterResponse) -> ()) {
        TrackingManager.shared.pool?.withConnection { response in
            switch response {
            case .failure(let error):
                fatalError("Error connecting to Alpine Server: \(error)")
            case .success:
                do {
                    let connection = try response.get()
                    var text = """
                        INSERT INTO alpine_users(email, first_name, last_name, last_online) VALUES ($1, $2, $3, $4)
                    """
                    var statement = try connection.prepareStatement(text: text)
                    var cursor = try statement.execute(parameterValues: [info.email, info.firstName, info.lastName, Date().postgresTimestampWithTimeZone])
                    
                    statement.close()
                    cursor.close()
                    
                    text = """
                    INSERT INTO user_authentication(email) VALUES ($1)
                    """
                    
                    statement = try connection.prepareStatement(text: text)
                    cursor = try statement.execute(parameterValues: [info.email])
                    
                    defer { statement.close() }
                    defer { cursor.close() }
                    
                    handler(.registerSuccess)
                }
                catch {
                    fatalError("Error updating user: \(error)")
                }
            }
        }
    }
}
