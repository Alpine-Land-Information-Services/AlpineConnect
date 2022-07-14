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
    
    static var user: BackendUser?
    
    static func loginUser(checkPasswordChange: Bool = true, completionHandler: @escaping (LoginResponseMessage) -> ()) {
        NetworkManager.shared.pool?.withConnection { connectionRequestResponse in
            switch connectionRequestResponse {
            case .failure:
                Task {
                    completionHandler(await getBackendStatus(email: UserManager.shared.userName, DBConnected: false))
                }
            case .success:
                Task {
                    let backendResponse = await getBackendStatus(email: UserManager.shared.userName, DBConnected: true)
                    
                    if backendResponse != .successfulLogin {
                        completionHandler(backendResponse)
                        return
                    }
                    
                    self.getApplicationUser() { response, error in
                        completionHandler(response)
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
    
    static func getBackendStatus(email: String, DBConnected: Bool) async -> (LoginResponseMessage) {
        do {
            let (user, response) = try await getBackendUser(email: email)
            self.user = user
            
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
    
    static func getApplicationUser(completionHandler: @escaping (LoginResponseMessage, Error?) -> ()) {
        NetworkManager.shared.pool?.withConnection { connectionRequestResponse in
            switch connectionRequestResponse {
            case .failure(let error):
                completionHandler(Check.checkPostgresError(error), error)
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
                    
                    defer { statement.close() }
                    defer { cursor.close() }
                    
                    if cursor.rowCount == 0 {
                        createApplicationUser(user: self.user!) { response, error in
                            completionHandler(response, error)
                            return
                        }
                    }
                    
                    for row in cursor {
                        let columns = try row.get().columns
                                                
                        let id = UUID(uuidString: try columns[0].string())
                        let isAdmin = try columns[1].bool()
                        
                        fillPrimaryUserInfo(id: id!.uuidString, isAdmin: isAdmin)
                        
                        completionHandler(.successfulLogin, nil)
                    }
                }
                catch {
                    completionHandler(Check.checkPostgresError(error), error)
                }
            }
        }
    }
    
    static func createApplicationUser(user: BackendUser, completionHandler: @escaping (LoginResponseMessage, Error?) -> ()) {
        NetworkManager.shared.pool?.withConnection { response in
            switch response {
            case .success:
                do {
                    let connection = try response.get()
                    
                    let text = """
                    INSERT INTO public.application_users("\(GlobalNames.shared.applicationUserIDName)", login, user_name) VALUES ($1, $2, $3)
                    """
                    print(text)
                    let statement = try connection.prepareStatement(text: text)
                    let cursor = try statement.execute(parameterValues: [user.id, user.email, user.firstName + " " + user.lastName])

                    defer { statement.close() }
                    defer { cursor.close() }
                    
                    fillPrimaryUserInfo(id: user.id, isAdmin: false)
                    
                    completionHandler(.successfulLogin, nil)
                }
                catch {
                    completionHandler(Check.checkPostgresError(error), error)
                }
            case .failure(let error):
                completionHandler(Check.checkPostgresError(error), error)
            }
        }
    }
    
    static func fillPrimaryUserInfo(id: String, isAdmin: Bool) {
        UserManager.shared.userInfo.id = UUID(uuidString: id)
        UserManager.shared.userInfo.isAdmin = isAdmin
        saveUserToUserDefaults(UserManager.shared.userInfo)
    }
    
    static func fillUserInfo(user: BackendUser) {
        UserManager.shared.userInfo.firstName = user.firstName
        UserManager.shared.userInfo.lastName = user.lastName
        saveUserToUserDefaults(UserManager.shared.userInfo)
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
