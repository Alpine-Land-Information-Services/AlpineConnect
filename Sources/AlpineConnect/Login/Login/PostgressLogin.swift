//
//  PostgressLogin.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/6/23.
//

import Foundation

public class PostgressLogin {
    
    public static var loginResponse = ""
    public static var responseBody: String?
    
    struct UserLoginUpdate: Codable {
        var email: String
        var password: String
        
        var appName: String
        var appVersion: String
        var machineName: String
        
        var lat: Double?
        var lng: Double?

        var info: String
    }
    
    
    static func loginUser(info: UserLoginUpdate, completionHandler: @escaping (LoginResponse) -> ()) {
        NetworkMonitor.shared.canConnectToServer { connection in
            switch connection {
            case true:
               loginUserOnline(info: info, completionHandler: completionHandler)
            case false:
                completionHandler(.timeout)
            }
        }
    }
    
    static func loginUserOnline(info: UserLoginUpdate, completionHandler: @escaping (LoginResponse) -> ()) {
        NetworkManager.sharedWithTimeOut.pool?.withConnection { connectionRequestResponse in
            switch connectionRequestResponse {
            case .failure(let error):
                Task {
                    await completionHandler(checkError(error: error))
                }
            case .success:
                completionHandler(.successfulLogin)
            }
        }
    }
    
    static func checkError(error: Error) async -> LoginResponse {
        switch error.localizedDescription {
        case "The operation couldn’t be completed. (PostgresClientKit.PostgresError error 18.)":
            return .timeout
        default:
            return .timeout
        }
    }
}
