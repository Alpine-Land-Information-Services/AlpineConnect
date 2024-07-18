//
//  Check.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 7/13/22.
//

import Foundation
import PostgresClientKit

public class Check {
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailPred.evaluate(with: email)
    }
    
    public static func checkPostgresError(_ error: Error) -> LoginResponse {
        Login.loginResponse = "\(error)"
        guard let error = error as? PostgresError else {
//            assertionFailure("Not a Postgres Error")
            return .unknownError
        }
        switch error {
        case .sqlError(notice: let notice):
            switch notice.code {
            case "28P01":
                return .invalidCredentials
            case "42501":
                return .noAccess
            default:
                assertionFailure("Postgres SQL Login Error: \(notice)")
                return .unknownError
            }
        default:
            assertionFailure("Unknown Postgres Login Error: \(error)")
            return .unknownError
        }
    }
}
