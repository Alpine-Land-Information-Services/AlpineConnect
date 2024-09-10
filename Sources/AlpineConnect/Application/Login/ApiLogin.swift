//
//  ApiLogin.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 8/6/24.
//

import Foundation

public final class ApiLogin {
    
    public struct Response: Decodable {
        public let sessionToken: String
    }
    
    var info: LoginConnectionInfo
    var data: CredentialsData
    
    var appURL: String {
        info.appInfo.url
    }
    
    init(_ info: LoginConnectionInfo, data: CredentialsData) {
        self.info = info
        self.data = data
    }
    
    func attemptLogin() async throws -> ConnectionResponse {
        let (data, httpResponse) = try await performRequest()
        
        switch httpResponse.statusCode {
        case 200...299:
            return try await decodeLoginResponse(from: data)
        case 400...599:
            return makeConnectionProblem(with: httpResponse.statusCode)
        default:
            throw ConnectError("Unrecognized HTTP response code: \(httpResponse.statusCode)", type: .login)
        }
    }
    
    func refreshToken() async throws -> String {
        let (data, httpResponse) = try await performRequest()
        
        switch httpResponse.statusCode {
        case 200...299:
            return try decodeTokenResponse(from: data)
        case 400...599:
            throw ConnectError("Failed to refresh token. Status Code: \(httpResponse.statusCode)", type: .login)
        default:
            throw ConnectError("Unrecognized HTTP response code: \(httpResponse.statusCode)", type: .login)
        }
    }
    
    private func performRequest() async throws -> (Data, HTTPURLResponse) {
        guard let url = URL(string: appURL) else {
            throw ConnectError("Could not create application url.", type: .login)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Basic \(data.encoded)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.upload(for: request, from: Data())
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
    
    private func decodeLoginResponse(from data: Data) async throws -> ConnectionResponse {
        let response = try ConnectManager.decoder.decode(Response.self, from: data)
        let decodedToken = try decodeToken(jwtToken: response.sessionToken)
        try await initializeUserWithToken(decodedToken)
        return ConnectionResponse(result: .success, data: response, problem: nil)
    }
    
    private func decodeTokenResponse(from data: Data) throws -> String {
        let response = try ConnectManager.decoder.decode(Response.self, from: data)
        let decodedData = try decodeToken(jwtToken: response.sessionToken)
        return response.sessionToken
    }
    
    private func initializeUserWithToken<T: JWTData>(_ tokenData: T) async throws {
        _ = ConnectManager.shared.createToken(from: tokenData.sessionToken)
        
//        ConnectManager.shared.user = ConnectUser(for: tokenData, token: tokenData.sessionToken)
        ConnectManager.shared.didSignInOnline = true
    }
    
    private func decodeToken(jwtToken jwt: String) throws -> JWTData {
        return try info.appTokenActions(jwt)
    }
}
