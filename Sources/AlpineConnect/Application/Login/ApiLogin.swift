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
    
    func attemptLogin() async throws -> ConnectionResponse {
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
        
        switch httpResponse.statusCode {
        case 200...299:
            return try decodeSuccessfulResponse(from: data)
        case 400...599:
            return makeConnectionProblem(with: httpResponse.statusCode)
        default:
            throw ConnectError("Unregognized HTTP response code: \(httpResponse.statusCode)", type: .login)
        }
    }
    
    private func makeConnectionProblem(with status: Int) -> ConnectionResponse {
        let alert = ConnectAlert(title: "Login Failed", message: "Could not perform login. Try again later or contact support.\n\n Status Code: \(status)")
        let problem = ConnectionProblem(status: status, detail: nil, customAlert: alert)
        return ConnectionResponse(result: .fail, data: nil, problem: problem)
    }
    
    func decodeSuccessfulResponse(from data: Data) throws -> ConnectionResponse {
        let response = try ConnectManager.decoder.decode(Response.self, from: data)
        try decodeToken(response.sessionToken)
        
        return ConnectionResponse(result: .success, data: response, problem: nil)
    }
    
    func decodeToken(_ token: String) throws {
        let data = try! decode(jwtToken: token)
        _ = ConnectManager.shared.createToken(from: data.SessionToken)

        DispatchQueue.main.sync {
            ConnectManager.shared.user = ConnectUser(for: data)
            ConnectManager.shared.didSignInOnline = true
        }
    }
}

extension ApiLogin {
    
    func decode(jwtToken jwt: String) throws -> FMS_JWTData {

        enum DecodeErrors: Error {
            case badToken
            case other
        }

        func base64Decode(_ base64: String) throws -> Data {
            let base64 = base64
                .replacingOccurrences(of: "-", with: "+")
                .replacingOccurrences(of: "_", with: "/")
            let padded = base64.padding(toLength: ((base64.count + 3) / 4) * 4, withPad: "=", startingAt: 0)
            guard let decoded = Data(base64Encoded: padded) else {
                throw DecodeErrors.badToken
            }
            return decoded
        }

        func decodeJWTPart<T: Decodable>(_ value: String, to type: T.Type) throws -> T {
            let bodyData = try base64Decode(value)
            let decoder = JSONDecoder()
            let payload = try decoder.decode(T.self, from: bodyData)
            return payload
        }

        let segments = jwt.components(separatedBy: ".")
        guard segments.count > 1 else {
            throw DecodeErrors.badToken
        }
        return try decodeJWTPart(segments[1], to: FMS_JWTData.self)
    }
}

struct FMS_JWTData: Codable {
    var Id: UUID
    var Login: String
    var FirstName: String?
    var LastName: String?
//    var IsApplicationAdministrator: Bool
//    var AllowResubmit: Bool
    var UserName: String?
//    var IsActive: Bool
    var SessionToken: String
}
