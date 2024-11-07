//
//  Check.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 7/13/22.
//

import Foundation
import PostgresNIO

public class Check {
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailPred.evaluate(with: email)
    }
    
    public static func checkPostgresError(_ error: Error) -> LoginResponse {

        Login.loginResponse = "\(error)"
        
        guard let postgresError = error as? PostgresNIO.PostgresError else {
            return .unknownError
        }
        
        switch postgresError.code {
        case "28P01":
            return .invalidCredentials
        case "42501":
            return .noAccess
        default:
            #if DEBUG
            assertionFailure("Unhandled Postgres error code: \(postgresError)")
            #else
            print("Warning: Unhandled Postgres error code: \(postgresError)")
            #endif
            return .unknownError
        }
    }
}
