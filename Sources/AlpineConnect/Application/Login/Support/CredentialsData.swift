//
//  CredentialsData.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/6/23.
//

import Foundation

struct CredentialsData: Codable {
    let email: String
    let password: String
    
    var encoded: String {
        "\(email):\(password)".data(using: .utf8)!.base64EncodedString()
    }
    
    var encodedData: Data? {
        "\(email):\(password)".data(using: .utf8)
    }
}
