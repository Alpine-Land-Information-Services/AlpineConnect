//
//  PasswordReset.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 7/13/22.
//

import Foundation

class PasswordReset {
    
    enum Status {
        case invalidEmail
        case requestSent
        case noUser
        case notConnected
        case unknownError
    }
    
    static func reset(email: String) async throws -> (String, HTTPURLResponse) {
        guard let url = URL(string: "https://alpinebackyard20220722084741.azurewebsites.net/user/resetpassword?email=\(email)") else {
            fatalError("Reset Password URL Error")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
        let (body, response) = try await URLSession.shared.data(for: request)
        
        let stringBody = String(decoding: body, as: UTF8.self)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            fatalError("Cannot get HTTP URL Response")
        }
        
        return (stringBody, httpResponse)
    }
    
    static func resetPassword(email: String) async -> (Status, String) {
        do {
            let (body, response) = try await reset(email: email)
            
            switch response.statusCode {
            case 200:
                return (.requestSent, body)
            case 404:
                return (.noUser, body)
            default:
                return(.unknownError, String(response.statusCode) + " - " + body)
            }
        }
        catch {
            fatalError("\(error)")
        }
    }
}
