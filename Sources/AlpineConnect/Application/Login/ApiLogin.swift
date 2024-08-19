//
//  ApiLogin.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 8/6/24.
//

import Foundation

public final class ApiLogin {
    
    public struct Response: Decodable {
        let sessionToken: String
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
    
    func attemptLogin<T: HasSessionToken & Decodable>(tokenType: T.Type) async throws -> ConnectionResponse {
            let (data, httpResponse) = try await performRequest()
            
            switch httpResponse.statusCode {
            case 200...299:
                return try decodeLoginResponse(from: data, tokenType: tokenType)
            case 400...599:
                return makeConnectionProblem(with: httpResponse.statusCode)
            default:
                throw ConnectError("Unrecognized HTTP response code: \(httpResponse.statusCode)", type: .login)
            }
        }
        
        func refreshToken<T: HasSessionToken & Decodable>(tokenType: T.Type) async throws -> String {
            let (data, httpResponse) = try await performRequest()
            
            switch httpResponse.statusCode {
            case 200...299:
                return try decodeTokenResponse(from: data, tokenType: tokenType)
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
    
    private func decodeLoginResponse<T: HasSessionToken & Decodable>(from data: Data, tokenType: T.Type) throws -> ConnectionResponse {
        let response = try ConnectManager.decoder.decode(Response.self, from: data)
        let decodedToken = try decode(jwtToken: response.sessionToken, as: tokenType)
        try initializeUserWithToken(decodedToken)
        return ConnectionResponse(result: .success, data: response, problem: nil)
    }
    
    private func decodeTokenResponse<T: HasSessionToken & Decodable>(from data: Data, tokenType: T.Type) throws -> String {
        let response = try ConnectManager.decoder.decode(Response.self, from: data)
        let decodedData = try decode(jwtToken: response.sessionToken, as: tokenType)
        return decodedData.SessionToken
    }
    
    func initializeUserWithToken<T: HasSessionToken>(_ tokenData: T) throws {
        _ = ConnectManager.shared.createToken(from: tokenData.SessionToken)
        
        DispatchQueue.main.sync {
            ConnectManager.shared.user = ConnectUser(for: tokenData, token: tokenData.SessionToken)
            ConnectManager.shared.didSignInOnline = true
            info.appTokenActions(tokenData)
        }
    }
    
}

extension ApiLogin {
    
    enum DecodeErrors: Error {
        case badToken
        case other
    }
    
    func decode<T: HasSessionToken & Decodable>(jwtToken jwt: String, as type: T.Type) throws -> T {
        let segments = jwt.components(separatedBy: ".")
        guard segments.count > 1 else {
            throw DecodeErrors.badToken
        }
        
        return try decodeJWTPart(segments[1], as: type)
    }
    
    private func base64Decode(_ base64: String) throws -> Data {
        let base64 = base64
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let padded = base64.padding(toLength: ((base64.count + 3) / 4) * 4, withPad: "=", startingAt: 0)
        guard let decoded = Data(base64Encoded: padded) else {
            throw DecodeErrors.badToken
        }
        return decoded
    }
    
    private func decodeJWTPart<T: Decodable>(_ value: String, as type: T.Type) throws -> T {
        let bodyData = try base64Decode(value)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: bodyData)
    }
}

public struct FMS_JWTData: Codable, HasSessionToken{

    public var Id: UUID
    public var Login: String
    public var FirstName: String?
    public var LastName: String?
    public var AllowResubmit: Bool?
    public var UserName: String?
    public var SessionToken: String
    
    public var IsApplicationAdministrator: Bool?
    public var IsActive: Bool?
}
