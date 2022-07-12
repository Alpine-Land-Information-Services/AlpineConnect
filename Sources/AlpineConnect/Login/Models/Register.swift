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
        case updateSuccess
        case newUser
        case userExists
        case emailsDiffer
        case unknownError
    }
    
    struct RegistrationInfo: Codable {
        
        var email: String
        var firstName: String
        var lastName: String
    }
    
    static func register(info: RegistrationInfo) async throws -> (HTTPURLResponse) {
        guard let url = URL(string: "https://alpinebackyard.azurewebsites.net/user/register?email=\(info.email)&firstName=\(info.firstName)&lastName=\(info.lastName)") else {
            fatalError("Registration URL Error")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let data = try JSONEncoder().encode(info)
        
        let (_, response) = try await URLSession.shared.upload(for: request, from: data)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            fatalError("Cannot get HTTP URL Response")
        }
        
        return httpResponse
    }
    
    static func registerUser(info: RegistrationInfo) async -> RegisterResponse {
        do {
            let resposnse = try await register(info: info)
            
            switch resposnse.statusCode {
            case 200:
                return .registerSuccess
            case 409:
                return .userExists
            default:
                return .unknownError
            }
        }
        catch {
            fatalError("\(error)")
        }
    }
    

//    static func registerUser(existingDBUser: Bool, info: RegistrationInfo, handler: @escaping (RegisterResponse) -> ()) {
//        TrackingManager.shared.pool?.withConnection { response in
//            switch response {
//            case .failure(let error):
//                fatalError("Error connecting to Alpine Server: \(error)")
//            case .success:
//                do {
//                    let connection = try response.get()
//                    var text = """
//                        INSERT INTO alpine_users(email, first_name, last_name, last_online) VALUES ($1, $2, $3, $4)
//                    """
//                    var statement = try connection.prepareStatement(text: text)
//                    var cursor = try statement.execute(parameterValues: [info.email, info.firstName, info.lastName, Date().postgresTimestampWithTimeZone])
//
//                    statement.close()
//                    cursor.close()
//
//                    text = """
//                    INSERT INTO user_authentication(email, existing_db_user) VALUES ($1, $2)
//                    """
//
//                    statement = try connection.prepareStatement(text: text)
//                    cursor = try statement.execute(parameterValues: [info.email, existingDBUser])
//
//                    defer { statement.close() }
//                    defer { cursor.close() }
//
//                    if existingDBUser {
//                        handler(.updateSuccess)
//                    }
//                    else {
//                        handler(.registerSuccess)
//                    }
//                }
//                catch {
//                    if let error = error as? PostgresError {
//                        switch error {
//                        case .sqlError(let notice):
//                            switch notice.code {
//                            case "23505":
//                                handler(.userExists)
//                            default:
//                                handler(.unknownError)
//                            }
//                        default:
//                            handler(.unknownError)
//                        }
//                    }
//                    else {
//                        fatalError("Error updating user: \(error)")
//                    }
//                }
//            }
//        }
//    }
}
