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
    
    static private let serverMode = "default" // "default" - use regular url, "test" - use testing url
    
    static var serverURL: String {
        switch serverMode {
        case "test":
            return "https://alpinebackyard20220722084741-testing.azurewebsites.net/"
        default:
            return "https://alpine-seedtree.azurewebsites.net/"
            //return "https://alpinebackyard20220722084741.azurewebsites.net/"
        }
    }
    /*
     
     public struct BackendUser: Codable {
     public var id: UUID
     public var email: String
     public var firstName: String
     public var lastName: String
     
     var isActive: Bool
     var forceChangePassword: Bool
     }
     */
    struct UserLoginUpdate: Codable {
        public var email: String
        public var password: String
        
        var appName: String
        var appVersion: String
        var machineName: String
        
        var lat: Double?
        var lng: Double?
        
        var info: String
    }
    
    public static var user: User!
    
    static func loginUser(info: UserLoginUpdate, completionHandler: @escaping (LoginResponse) -> ()) {
        Task {
            do {
                await loginUserOnline(info: info) { res in
                    completionHandler(res)
                }
            }
        }
        
        /*
         NetworkMonitor.shared.canConnectToServer { connection in
         switch connection {
         case true:
         loginUserOnline(info: info, completionHandler: completionHandler)
         case false:
         completionHandler(.timeout)
         }
         }
         */
    }
    
    public struct UserResponse: Decodable {
        let sessionToken: String
        let user: User
    }
    
    public struct ProblemDetails : Decodable {
        /// <summary>
        /// Gets or sets the unique identifier for the request.
        /// </summary>
        let requestId: String?
        /// <summary>
        /// Gets or sets the type of the problem.
        /// </summary>
        let type: String?
        /// <summary>
        /// Gets or sets the title of the problem.
        /// </summary>
        let title: String?
        /// <summary>
        /// Gets or sets the HTTP status code associated with the problem.
        /// </summary>
        let status: Int?
        /// <summary>
        /// Gets or sets a detailed description of the problem.
        /// </summary>
        let detail: String?
        /// <summary>
        /// Gets or sets the URI of the specific instance of the problem.
        /// </summary>
        let instance: String?
    }
    
    public struct User: Decodable {
        public let email: String
        public let firstName: String
        public let lastName: String
        let phoneNumber: String?
        let created: Date
        let passwordChangeRequired: Bool
        let timeZoneId: String
        let roles: [String]
    }
    
    
    static func loginUserOnline(info: UserLoginUpdate, completionHandler: @escaping (LoginResponse) -> ()) async {
        
        guard let url = URL(string: "\(serverURL)login") else {
            fatalError()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let myUserInfo = "\(info.email):\(info.password)"
        let encodedUserInfo = myUserInfo.data(using: .utf8)!.base64EncodedString()
        request.addValue("Basic \(encodedUserInfo)", forHTTPHeaderField: "Authorization")
        request.addValue("LCaie7G1yOnABg65HWqetAtw31ZWc4Ihpxm5UB7Y6lJugvbV1AHvKJdAgdZEoyGc?c=2023-04-10T21:14:36?e=2023-10-07T21:14:36", forHTTPHeaderField: "ApiKey")
        do {
            let (data, response) = try await URLSession.shared.upload(for: request, from: Data())
            guard let httpResponse = response as? HTTPURLResponse else {
                completionHandler(.unknownError)
                return
            }
            if httpResponse.statusCode == 200 {
                do {
                    let decoder = JSONDecoder()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    decoder.dateDecodingStrategy = .formatted(dateFormatter)
                    let jsonString = String(data: data, encoding: .utf8)
                    print(jsonString ?? "")
                    let userResponce = try decoder.decode(UserResponse.self, from: data)
                    print(userResponce)
                    TokenManager.saveLoginToken(userResponce.sessionToken)
                    CurrentUser.makeUserData(email: userResponce.user.email, name: "\(userResponce.user.firstName) \(userResponce.user.lastName)", id: UUID())
                    completionHandler(.successfulLogin)
                } catch {
                    Login.loginResponse = error.localizedDescription
                    completionHandler(.unknownError)
                }
            }
            else if httpResponse.statusCode == 401 {
                let decoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                let jsonString = String(data: data, encoding: .utf8)
                print(jsonString ?? "")
                let userResponce = try decoder.decode(ProblemDetails.self, from: data)
                print(userResponce)
                completionHandler(.wrongPassword)
            }
            else {
                Login.loginResponse = httpResponse.debugDescription
                completionHandler(.unknownError)
            }
        }
        catch {
            Login.loginResponse = error.localizedDescription
            completionHandler(.unknownError)
        }
    }
    /*
     guard let url = URL(string: "\(serverURL)login") else {
     AppControl.makeError(onAction: "Login", error: AlpineError.unknown, customDescription: "Cannot make URL to get user info.")
     //     return .unknownError
     }
     */
    /*
     NetworkManager.sharedWithTimeOut.pool?.withConnection { connectionRequestResponse in
     switch connectionRequestResponse {
     case .failure(let error):
     Task {
     await completionHandler(checkError(error: error))
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
     */
    
    
    /*
     static func checkError(error: Error) async -> LoginResponse {
     switch error.localizedDescription {
     case "The operation couldn’t be completed. (PostgresClientKit.PostgresError error 18.)":
     return .timeout
     case "The operation couldn’t be completed. (PostgresClientKit.PostgresError error 3.)":
     return await getBackendStatus(email: UserManager.shared.userName, DBConnected: false)
     default:
     return .timeout
     }
     }
     */
    /*
     static func getBackendUser(email: String) async throws -> (BackendUser, HTTPURLResponse)? {
     guard let url = URL(string: "\(serverURL)user?email=\(email)") else {
     AppControl.makeError(onAction: "Login", error: AlpineError.unknown, customDescription: "Cannot make URL")
     loginResponse = "Cannot make backend URL"
     return nil
     }
     
     var request = URLRequest(url: url)
     request.timeoutInterval = 10
     request.addValue("application/json", forHTTPHeaderField: "Content-Type")
     let (body, response) = try await URLSession.shared.data(for: request)
     
     let user = try JSONDecoder().decode(BackendUser.self, from: body)
     
     guard let httpResponse = response as? HTTPURLResponse else {
     AppControl.makeError(onAction: "Login", error: AlpineError.unknown, customDescription: "Cannot get HTTP URL response")
     loginResponse = "Cannot get HTTP URL response"
     return nil
     }
     
     return (user, httpResponse)
     }
     */
    /*
     static func getBackendStatus(email: String, DBConnected: Bool) async -> (LoginResponse) {
     do {
     guard let (user, response) = try await getBackendUser(email: email) else {
     return .unknownError
     }
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
     */
    /*
     static func updateUserLogin(info: UserLoginUpdate) async -> UserResponse? {
     /*
      guard let url = URL(string: "\(serverURL)user/credentials") else {
      AppControl.makeError(onAction: "Login", error: AlpineError.unknown, customDescription: "Cannot make URL to get user info.")
      return .unknownError
      }
      */
     guard let url = URL(string: "\(serverURL)login") else {
     AppControl.makeError(onAction: "Login", error: AlpineError.unknown, customDescription: "Cannot make URL to get user info.")
     return nil
     }
     var request = URLRequest(url: url)
     request.httpMethod = "POST"
     let myUserInfo = "\(info.email):\(info.password)"
     let encodedUserInfo = myUserInfo.data(using: .utf8)!.base64EncodedString()
     request.addValue("Basic \(encodedUserInfo)", forHTTPHeaderField: "Authorization")
     request.addValue("LCaie7G1yOnABg65HWqetAtw31ZWc4Ihpxm5UB7Y6lJugvbV1AHvKJdAgdZEoyGc?c=2023-04-10T21:14:36?e=2023-10-07T21:14:36", forHTTPHeaderField: "ApiKey")
     // request.addValue("application/json", forHTTPHeaderField: "Content-Type")
     
     do {
     //      let data = try JSONEncoder().encode(info)
     let (body, response) = try await URLSession.shared.upload(for: request, from: Data())
     
     guard let httpResponse = response as? HTTPURLResponse else {
     AppControl.makeError(onAction: "Login", error: AlpineError.unknown, customDescription: "Cannot get HHTP response.")
     loginResponse = "Cannot get HHTP response."
     return .unknownError
     }
     
     TokenManager.saveLoginToken(try JSONDecoder().decode(String.self, from: body))
     
     switch httpResponse.statusCode {
     case 200:
     return .successfulLogin
     default:
     return .unknownError
     }
     }
     catch {
     AppControl.makeError(onAction: "Getting Server User", error: error, showToUser: false)
     return Check.checkPostgresError(error)
     }
     }
     */
    /*
     static func fillUserInfo(user: BackendUser) {
     CurrentUser.makeUserData(email: user.email, name: user.firstName + " " + user.lastName, id: user.id)
     }
     */
}
