//
//  File.swift
//  
//
//  Created by Vladislav on 7/18/24.
//

import Foundation

public enum ConnectErrorType: String {
    case login = "Login Error"
    case storage = "Storage Error"
    case upload = "Upload Error"
    case other = "Error"
    case missingParameter = "Missing Parameter"
}
