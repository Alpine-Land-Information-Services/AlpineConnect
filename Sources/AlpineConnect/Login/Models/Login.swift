//
//  Login.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 6/23/22.
//

import Foundation
import PostgresClientKit

class Login {
    
    struct BackendUser: Codable {
        
        var id: String
        var email: String
        var isActive: Bool
        var forceChangePassword: Bool
        var firstName: String
        var lastName: String
    }
    
    static func loginUser(checkPasswordChange: Bool = true, completionHandler: @escaping (LoginResponseMessage) -> ()) {
        NetworkManager.shared.pool?.withConnection { connectionRequestResponse in
            switch connectionRequestResponse {
            case .failure:
                Task {
                    completionHandler(await getBackendStatus(email: UserManager.shared.userName, DBConnected: false))
                }
            case .success:
                self.getApplicationUser() { response, error in
                    if let error = error {
                        completionHandler(Check.checkPostgresError(error))
                    }
                    else if let response = response {
                        completionHandler(response)
                    }
                    else {
                        Task {
                            completionHandler(await getBackendStatus(email: UserManager.shared.userName, DBConnected: true))
                        }
                    }
                }
            }
        }
    }
    
    static func getBackendUser(email: String) async throws -> (BackendUser, HTTPURLResponse) {
        guard let url = URL(string: "https://alpinebackyard.azurewebsites.net/user?email=\(email)") else {
            fatalError("Reset Password URL Error")
        }
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
        let (body, response) = try await URLSession.shared.data(for: request)
        
        let user = try JSONDecoder().decode(BackendUser.self, from: body)
                
        guard let httpResponse = response as? HTTPURLResponse else {
            fatalError("Cannot get HTTP URL Response")
        }
        
        return (user, httpResponse)
    }
    
    static func getBackendStatus(email: String, DBConnected: Bool) async -> LoginResponseMessage {
        do {
            let (user, response) = try await getBackendUser(email: email)
            
            switch response.statusCode {
            case 200:
                if DBConnected {
                    if !user.isActive {
                        return .inactiveUser
                    }
                    if user.forceChangePassword {
                        return .passwordChangeRequired
                    }
                    fillUserInfo(user: user)
                    return .successfulLogin
                }
                return .wrongPassword
            default:
                return .unknownError
            }
        }
        catch {
            switch error.localizedDescription {
            case "The data couldn’t be read because it is missing.":
                return .registrationRequired
            default:
                return .unknownError
            }
        }
    }
    
    static func fillUserInfo(user: BackendUser) {
        UserManager.shared.userInfo.firstName = user.firstName
        UserManager.shared.userInfo.lastName = user.lastName
        saveUserToUserDefaults(UserManager.shared.userInfo)
    }
    
    static func getApplicationUser(completionHandler: @escaping (LoginResponseMessage?, Error?) -> ()) {
        NetworkManager.shared.pool?.withConnection { connectionRequestResponse in
            switch connectionRequestResponse {
            case .failure(let error):
                completionHandler(nil, error)
            case .success:
                do {
                    let connection = try connectionRequestResponse.get()
                    
                    let text = """
                    SELECT
                    id,
                    is_application_administrator
                    FROM application_users WHERE login = '\(UserManager.shared.userName)'
                    """
                    
                    let statement = try connection.prepareStatement(text: text)
                    let cursor = try statement.execute()
                    
                    if cursor.rowCount == 0 {
                        completionHandler(.noAccess, nil)
                    }
                    
                    defer { statement.close() }
                    defer { cursor.close() }
                    
                    for row in cursor {
                        let columns = try row.get().columns
                                                
                        UserManager.shared.userInfo.id = UUID(uuidString: try columns[0].string())
                        UserManager.shared.userInfo.isAdmin = try columns[1].bool()
                        
                        completionHandler(nil, nil)
                    }
                }
                catch {
                    completionHandler(nil, error)
                }
            }
        }
    }
    
    static func saveUserToUserDefaults(_ info: UserManager.UserInfo) {
        UserManager.shared.userInfo = info
        
        if let encoded = try? JSONEncoder().encode(info) {
            UserDefaults.standard.set(encoded, forKey: "UserInfo")
        }
    }
    
    static func getUserFromUserDefaults() -> Bool {
        if let info = UserDefaults.standard.object(forKey: "UserInfo") as? Data {
            if let loadedInfo = try? JSONDecoder().decode(UserManager.UserInfo.self, from: info) {
                UserManager.shared.userInfo = loadedInfo
                return true
            }
        }
        return false
    }
    
    //    static func checkConnectUser(isConnectedToDBUser: Bool, handler: @escaping (LoginResponseMessage) -> ()) {
    //        TrackingManager.shared.pool?.withConnection { response in
    //            switch response {
    //            case .success:
    //                do {
    //                    let connection = try response.get()
    //
    //                    let text = """
    //                    SELECT password_change_required
    //                    FROM user_authentication WHERE email = '\(UserManager.shared.userName)'
    //                    """
    //                    let statement = try connection.prepareStatement(text: text)
    //                    let cursor = try statement.execute()
    //
    //                    defer { statement.close() }
    //                    defer { cursor.close() }
    //
    //
    //                    if cursor.rowCount == 0 {
    //                        if isConnectedToDBUser {
    //                            handler(.infoChangeRequired)
    //                        }
    //                        else {
    //                            handler(.registrationRequired)
    //                        }
    //                    }
    //                    else {
    //                        for row in cursor {
    //                            let columns = try row.get().columns
    //                            if try columns[0].bool() {
    //                                handler(.passwordChangeRequired)
    //                            }
    //                            else {
    //                                handler(.successfulLogin)
    //                            }
    //                        }
    //                    }
    //                }
    //                catch {
    //                    handler(checkError(error))
    //                }
    //            case .failure(let error):
    //                handler(checkError(error))
    //            }
    //        }
    //    }
}
