//
//  Login.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 6/23/22.
//

import Foundation
import PostgresClientKit

public class Login {
    
    enum ConnectionDetail {
        case timeout
        case overrideKeychain
        case keychainSaveFail
        case biometrics
    }

    enum ConnectionResult {
        case success
        case fail
        case moreDetail
    }
    
    public struct Response: Decodable {
        let sessionToken: String
        let user: ServerUserResponse
    }
    
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
        var password: String
        var appName: String
        var appVersion: String
        var machineName: String
        var lat: Double?
        var lng: Double?
        var info: String
    }

    struct ConnectionResponse {
        public init(result: ConnectionResult, detail: ConnectionDetail? = nil, data: Login.Response? = nil,problem: ConnectionProblem? = nil) {
            self.result = result
            self.backyardData = data
            self.problem = problem
        }
        
        public var result: ConnectionResult
        public var backyardData: Login.Response?
        public var problem: ConnectionProblem?
        
        var detail: ConnectionDetail?
    }

    struct ServerUserResponse: Codable {
        public let email: String
        public let firstName: String
        public let lastName: String
        public let isAdmin: Bool
    }

    struct ConnectionProblem: Decodable {
        enum CodingKeys: CodingKey {
            case type
            case title
            case status
            case detail
        }
        
        public let type: String?
        public let title: String?
        public let status: Int?
        public let detail: String?
        
        public init(type: String? = nil, title: String? = nil, status: Int? = nil, detail: String? = nil) {
            self.type = type
            self.title = title
            self.status = status
            self.detail = detail
        }
    }
    
    public static var loginResponse = ""
    public static var responseBody: String?
    
    static private let serverMode = "default" // "default" - use regular url, "test" - use testing url
    static var serverURL: String {
        switch serverMode {
        case "test":
            return "https://alpinebackyard20220722084741-testing.azurewebsites.net/"
        default:
            return "https://alpinebackyard20220722084741.azurewebsites.net/"
        }
    }

    public static var user: BackendUser!
    
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        return decoder
    }
    
    static func loginUser(info: UserLoginUpdate, completionHandler: @escaping (LoginResponse) -> Void) {
        Task {
            guard await NetworkMonitor.shared.canConnectToServer() else {
                completionHandler(.timeout)
                return
            }

            guard let response = await loginUserOnlineNew(info: info) else {
                completionHandler(.unknownError)
                return
            }

            if response.result != .success {
                completionHandler(.customError(title: response.problem?.title ?? "Unknown Error", detail: response.problem?.detail ?? "No further information available"))
            } else {
                completionHandler(.successfulLogin)
            }
        }
    }
    
    static private func loginUserOnlineNew(info: UserLoginUpdate) async -> ConnectionResponse? {
        let appURL = "https://alpine-legacy.azurewebsites.net/login"
        let dataRequest = "\(info.email):\(info.password)".data(using: .utf8)!.base64EncodedString()
        let appToken = "FHUb7mT6yLP4QVb0Gra8hBNe37EcaIHBaEHxsGnyCRU2FgkQUFAPRQRDJbY80hxd?c=2024-05-16T14:39:26?e=2024-11-12T14:39:26"
        
        guard let url = URL(string: appURL) else {
            print("Could not create application URL.")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Basic \(dataRequest)", forHTTPHeaderField: "Authorization")
        request.addValue(appToken, forHTTPHeaderField: "ApiKey")
        
        do {
            let (data, response) = try await URLSession.shared.upload(for: request, from: Data())
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Could not get HTTP response.")
                return nil
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                return await decodeSuccessfulResponse(from: data)
            } else {
                return await decodeErrorResponse(from: data)
            }
        } catch {
            print("Network request failed: \(error.localizedDescription)")
            return nil
        }
    }

    static private func decodeSuccessfulResponse(from data: Data) async -> ConnectionResponse? {
        do {
            let response = try decoder.decode(Response.self, from: data)
            return ConnectionResponse(result: .success, data: response, problem: nil)
        } catch {
            print("Failed to decode a successful response: \(error)")
            return nil
        }
    }

    static private func decodeErrorResponse(from data: Data) async -> ConnectionResponse? {
        do {
            let problem = try decoder.decode(ConnectionProblem.self, from: data)
            return ConnectionResponse(result: .fail, data: nil, problem: problem)
        } catch {
            print("Failed to decode an error response: \(error)")
            return nil
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
    
    static func updateUserLogin(info: UserLoginUpdate) async -> LoginResponse {
        guard let url = URL(string: "\(serverURL)user/credentials") else {
            AppControl.makeError(onAction: "Login", error: AlpineError.unknown, customDescription: "Cannot make URL to get user info.")
            return .unknownError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let data = try JSONEncoder().encode(info)
            let (body, response) = try await URLSession.shared.upload(for: request, from: data)
                        
            guard let httpResponse = response as? HTTPURLResponse else {
                AppControl.makeError(onAction: "Login", error: AlpineError.unknown, customDescription: "Cannot get HHTP response.")
                loginResponse = "Cannot get HHTP response."
                return .unknownError
            }
            responseBody = String(data: body, encoding: .utf8)
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
    
    static func fillUserInfo(user: BackendUser) {
        CurrentUser.makeUserData(email: user.email, name: user.firstName + " " + user.lastName, id: user.id)
    }
}
