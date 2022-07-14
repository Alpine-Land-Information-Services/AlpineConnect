//
//  PasswordChange.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 7/13/22.
//

import Foundation

class PasswordChange {
    
    enum Status {
        case notMatchedPasswords
        case passwordChanged
        case oldPasswordMatch
        case invalidCredentials
        case notConnected
        case unknownError
    }
    
    
    struct PasswordInfo: Codable {
        
        var email: String
        var currentPassword: String
        var newPassword: String
    }
    
    
    static func change(info: PasswordInfo) async throws -> (String, HTTPURLResponse) {
        guard let url = URL(string: "https://alpinebackyard.azurewebsites.net/user/changepassword") else {
            fatalError("Reset Password URL Error")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
        let data = try JSONEncoder().encode(info)
        
        let (body, response) = try await URLSession.shared.upload(for: request, from: data)
        
        let stringBody = String(decoding: body, as: UTF8.self)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            fatalError("Cannot get HTTP URL Response")
        }
        
        return (stringBody, httpResponse)
    }
    
    static func changePassword(info: PasswordInfo) async -> (Status, String) {
        do {
            let (body, response) = try await change(info: info)
            
            switch response.statusCode {
            case 200:
                return(.passwordChanged, body)
            default:
                return(.unknownError, String(response.statusCode) + " - " + body)
            }
        }
        catch {
            fatalError("\(error)")
        }
    }
    
//    static func changeDBPassword(with password: String, completionHandler: @escaping (Bool, LoginResponseMessage?) -> ()) {
//        NetworkManager.shared.pool?.withConnection { connectionRequestResponse in
//            switch connectionRequestResponse {
//            case .success:
//                do {
//                    let connection = try connectionRequestResponse.get()
//                    let text = "ALTER ROLE \(UserManager.shared.userName) PASSWORD '\(password)'"
//
//                    let statement = try connection.prepareStatement(text: text)
//                    let cursor = try statement.execute()
//
//                    defer { cursor.close() }
//                    defer { statement.close() }
//
//                    completionHandler(true, nil)
//                }
//                catch {
//                    completionHandler(false, Check.checkPostgresError(error))
//                }
//            case .failure(let error):
//                completionHandler(false, Check.checkPostgresError(error))
//            }
//        }
//    }
}

