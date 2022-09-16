//
//  Login.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 6/23/22.
//

import Foundation
import PostgresClientKit

public class Login {
    
    public static var loginResponse = ""
    
    public struct BackendUser: Codable {
        
        public var id: UUID
        public var email: String
        public var firstName: String
        public var lastName: String
        
        var isActive: Bool
        var forceChangePassword: Bool
    }
    
    struct UserLoginUpdate: Codable {
        
        var email: String
        var lat: Double?
        var lng: Double?
        var appName: String
        var info: String
    }
    
    public static var user: BackendUser!
    
    static func loginUser(info: UserLoginUpdate, completionHandler: @escaping (LoginResponse) -> ()) {
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
                    completionHandler(await updateUserLogin(info: info))
                }
            }
        }
    }
    
    static func getBackendUser(email: String) async throws -> (BackendUser, HTTPURLResponse) {
        guard let url = URL(string: "https://alpinebackyard20220722084741.azurewebsites.net/user?email=\(email)") else {
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
    
    static func getBackendStatus(email: String, DBConnected: Bool) async -> (LoginResponse) {
        do {
            let (user, response) = try await getBackendUser(email: email)
            self.user = user
            
            loginResponse = "\(response)"
            
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
    
    static func updateUserLogin(info: UserLoginUpdate) async -> LoginResponse {
        guard let url = URL(string: "https://alpinebackyard20220722084741.azurewebsites.net/user/logged") else {
            fatalError("Registration URL Error")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let data = try JSONEncoder().encode(info)
            let (body, response) = try await URLSession.shared.upload(for: request, from: data)
                        
            guard let httpResponse = response as? HTTPURLResponse else {
                fatalError("Cannot get HTTP URL Response")
            }
            
            loginResponse = "\(httpResponse)"
            
            switch httpResponse.statusCode {
            case 200:
                  return .successfulLogin
            default:
                return .unknownError
            }
        }
        catch {
            return Check.checkPostgresError(error)
        }
    }
    
//    static func createApplicationUser(user: BackendUser, completionHandler: @escaping (LoginResponse, Error?) -> ()) {
//        NetworkManager.shared.pool?.withConnection { response in
//            switch response {
//            case .success:
//                do {
//                    let connection = try response.get()
//
//                    let text = """
//                    INSERT INTO public.application_users("\(GlobalNames.shared.applicationUserIDName)", login, user_name) VALUES ($1, $2, $3)
//                    """
//                    print(text)
//                    let statement = try connection.prepareStatement(text: text)
//                    let cursor = try statement.execute(parameterValues: [user.id, user.email, user.firstName + " " + user.lastName])
//
//                    defer { statement.close() }
//                    defer { cursor.close() }
//
//                    fillPrimaryUserInfo(id: user.id, isAdmin: false)
//
//                    completionHandler(.successfulLogin, nil)
//                }
//                catch {
//                    completionHandler(Check.checkPostgresError(error), error)
//                }
//            case .failure(let error):
//                completionHandler(Check.checkPostgresError(error), error)
//            }
//        }
//    }
    
//    static func fillPrimaryUserInfo(id: UUID, isAdmin: Bool) {
//        UserManager.shared.userInfo.id = id
//        UserManager.shared.userInfo.isAdmin = isAdmin
//        saveUserToUserDefaults(UserManager.shared.userInfo)
//    }
    
    static func fillUserInfo(user: BackendUser) {
        UserManager.shared.userInfo.firstName = user.firstName
        UserManager.shared.userInfo.lastName = user.lastName
        saveUserToUserDefaults(UserManager.shared.userInfo)
    }
    
    static func saveUserToUserDefaults(_ info: UserManager.UserInfo) {
        UserManager.shared.userInfo = info
        
        if let encoded = try? JSONEncoder().encode(info) {
            UserDefaults.standard.set(encoded, forKey: "LoginUserInfo")
        }
    }
    
    static func getUserFromUserDefaults() -> Bool {
        if let info = UserDefaults.standard.object(forKey: "LoginUserInfo") as? Data {
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
