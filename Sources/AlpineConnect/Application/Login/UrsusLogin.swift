//
//  UrsusLogin.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 10/7/24.
//

import Foundation

public final class UrsusLogin {
    
    static var claimKeys = ["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier": "guid",
                            "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name": "name",
                            "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress" :"email" ]
    
    static var refreshURLString: String {
        "https://apiservice.orangeisland-ef29f349.westus3.azurecontainerapps.io/refresh"
    }
    
    public struct Response: Decodable {
        public let accessToken: String
        public let refreshToken: String
    }
    
    public struct UserClaim: Codable {
        var type: String
        var value: String
    }
    
    public struct UserIdentity: Codable {
        var claims: [UserClaim]
    }
    
    var info: LoginConnectionInfo
    
    var appURL: String {
        info.appInfo.url
    }
    
    init(_ info: LoginConnectionInfo) {
        self.info = info
    }
    
    func attemptLogin(with data: CredentialsData) async throws -> ConnectionResponse {
        guard let url = URL(string: appURL) else {
            throw ConnectError("Could not create application url.", type: .login)
        }
        
        let encodedData = try JSONEncoder().encode(data)
        let (data, httpResponse) = try await performRequest(with: url, for: encodedData)
        
        switch httpResponse.statusCode {
        case 200...299:
            return try await decodeTokenResponse(from: data)
        case 400...599:
            return makeConnectionProblem(with: httpResponse.statusCode)
        default:
            throw ConnectError("Unrecognized HTTP response code: \(httpResponse.statusCode)", type: .login)
        }
    }
    
    func getUserClaims(with token: String) async throws {
        guard let url = URL(string: "https://apiservice.orangeisland-ef29f349.westus3.azurecontainerapps.io/api/identity") else {
            throw ConnectError("Could not create application url.", type: .login)
        }
        
        let encodedValue = "Bearer " + token
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        request.addValue(encodedValue, forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ConnectError("Could not get HTTP response back.", type: .login)
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return try await fillUserDetails(from: data)
        case 400...599:
            throw ConnectError("Could not get user details, error code: \(httpResponse.statusCode)", type: .login)
        default:
            throw ConnectError("Unrecognized HTTP response code: \(httpResponse.statusCode)", type: .login)
        }
    }
    
    private func fillUserDetails(from data: Data) async throws {
        let result = try JSONDecoder().decode(UserIdentity.self, from: data)
        
        await MainActor.run {
            for claim in result.claims {
                if let key = Self.claimKeys[claim.type] {
                    Connect.user?.setValue(key, for: claim.value)
                }
            }
        }
    }
    
    func refreshToken() async throws {
        guard let user = Connect.user else {
            throw ConnectError("Cannot refresh user access token, user is missing.", type: .login)
        }
        guard let accessToken = user.accessToken else {
            throw ConnectError("Cannot refresh user access token, required token record is missing.", type: .login)
        }
        
        guard let url = URL(string: Self.refreshURLString) else {
            throw ConnectError("Could not create application url.", type: .login)
        }
        
        let encodedData = try JSONEncoder().encode(accessToken)
        let (data, httpResponse) = try await performRequest(with: url, for: encodedData)
        
        switch httpResponse.statusCode {
        case 200...299:
            try await decodeTokenResponse(from: data)
        case 400...599:
            throw ConnectError("Failed to refresh token. Status Code: \(httpResponse.statusCode)", type: .login)
        default:
            throw ConnectError("Unrecognized HTTP response code: \(httpResponse.statusCode)", type: .login)
        }
    }
    
    @discardableResult
    private func decodeTokenResponse(from data: Data) async throws -> ConnectionResponse {
        let response = try ConnectManager.decoder.decode(Response.self, from: data)
        await MainActor.run {
            Connect.user?.accessToken = response.accessToken
            Connect.user?.refreshToken = response.refreshToken
            Connect.user?.lastAccessTokenRefresh = Date()
        }
        
        return ConnectionResponse(result: .success, response: response, problem: nil)
    }
    
    private func performRequest(with url: URL, for data: Data) async throws -> (Data, HTTPURLResponse) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, response) = try await URLSession.shared.upload(for: request, from: data)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ConnectError("Could not get HTTP response back.", type: .login)
        }
        
        return (data, httpResponse)
    }
    
    private func makeConnectionProblem(with status: Int) -> ConnectionResponse {
        let alert = ConnectAlert(title: "Login Failed", message: "Could not perform login. Try again later or contact support.\n\n Status Code: \(status)")
        let problem = ConnectionProblem(status: status, detail: nil, customAlert: alert)
        return ConnectionResponse(result: .fail, data: nil, problem: problem)
    }
}
