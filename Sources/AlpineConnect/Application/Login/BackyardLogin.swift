//
//  BackyardLogin.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/6/23.
//

import Foundation

public class BackyardLogin {
    
    public struct Response: Decodable {
        let sessionToken: String
        let user: ServerUserResponse
    }

    var info: LoginConnectionInfo
    var data: CredentialsData
    
    var appURL: String {
        info.appInfo.url
    }
    
    var appToken: String {
        info.appInfo.token
    }
    
    init(_ info: LoginConnectionInfo, data: CredentialsData) {
        self.info = info
        self.data = data
    }
    
    func attemptLogin() async throws -> ConnectionResponse {
        guard let url = URL(string: "\(appURL)") else {
            throw ConnectError("Could not create application url.", type: .login)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Basic \(data.encoded)", forHTTPHeaderField: "Authorization")
        request.addValue(appToken, forHTTPHeaderField: "ApiKey")
        
        let (data, response) = try await URLSession.shared.upload(for: request, from: Data())
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ConnectError("Could not get HTTP response back.", type: .login)
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return try await decodeSuccessfulResponse(from: data)
        case 400...599:
            return try await decodeErrorResponse(from: data)
        default:
            throw ConnectError("Unregognized HTTP response code: \(httpResponse.statusCode)", type: .login)
        }
    }
    
    func decodeSuccessfulResponse(from data: Data) async throws -> ConnectionResponse {
        let response = try ConnectManager.decoder.decode(Response.self, from: data)
        return ConnectionResponse(result: .success, data: response, problem: nil)
    }
    
    func decodeErrorResponse(from data: Data) async throws -> ConnectionResponse {
        let problem = try ConnectManager.decoder.decode(ConnectionProblem.self, from: data)
        return ConnectionResponse(result: .fail, problem: problem)
    }
}
