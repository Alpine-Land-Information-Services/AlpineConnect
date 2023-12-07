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
        case requestSent
        case newUser
        case userExists
        case emailsDiffer
        case notConnected
        case unknownError
    }
    
    struct RegistrationInfo: Codable {
        var email: String
        var firstName: String
        var lastName: String
    }
    
    static func register(info: RegistrationInfo) async throws -> (String, HTTPURLResponse) {
        guard let url = URL(string: "\(Login.serverURL)user/register") else {
            fatalError("Registration URL Error")
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
    
    static func registerUser(info: RegistrationInfo) async -> (RegisterResponse, String) {
        do {
            let (body, response) = try await register(info: info)
            let prefix = body.prefix(20)
            
            switch response.statusCode {
            case 200:
                switch prefix {
                case "\"Email sent to Admin":
                    return (.requestSent, body)
                default:
                    return (.registerSuccess, body)
                }
            case 400:
                return (.userExists, body)
            default:
                return (.unknownError, String(response.statusCode))
            }
        }
        catch {
            Login.loginResponse = "\(error)"
        }
        return (.unknownError, Login.loginResponse)
    }
}
