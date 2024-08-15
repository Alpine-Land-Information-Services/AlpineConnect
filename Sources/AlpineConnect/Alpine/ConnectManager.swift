//
//  ConnectManager.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/6/23.
//

import Foundation
import AlpineCore
import SwiftData

public class ConnectManager: ObservableObject {
    
    @Published public var isSignedIn: Bool = false
    @Published public var inOfflineMode: Bool = false
    @Published public var id: UUID = UUID()
    @Published public var user: ConnectUser?

    public static var shared = ConnectManager()
    public static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }
    static var isAbleToGetToken: Bool {
        ConnectManager.shared.credentialsExist
    }
    
    static var lastSavedLogin: String? {
        CoreAppControl.shared.defaults.lastUser
    }
    
    public var postgres: PostgresManager?
    public var token: Token?
    public var jwtToken: Token?
    public var didSignInOnline: Bool = false
    
    private var loginData: CredentialsData!
    private var loginInfo: LoginConnectionInfo!
    private var postgresInfo: PostgresInfo?
    
    public var loginType: AppInfo.LoginType {
        loginInfo.appInfo.loginType
    }

    var authManager: AuthManager = AuthManager()

    public var core: CoreAppControl {
        CoreAppControl.shared
    }

    public var userID: String {
        guard let user else { return "_USER_NOT_SET_" }
        return user.databaseType == .production ? loginData.email : "\(loginData.email)-Sandbox"
    }

    var isConnected: Bool {
        NetworkTracker.shared.isConnected
    }

    var isPostgresEnabled: Bool {
        postgresInfo != nil
    }
 
    var credentialsExist: Bool {
        core.defaults.lastUser != nil
    }
    
    init() {
        NetworkTracker.shared.start()
    }
    
    static func reset() {
        shared.isSignedIn = false
        shared.inOfflineMode = false
        shared.id = UUID()
        shared.user = nil
        shared.token = nil
        shared.loginData = nil
        shared.loginInfo = nil
        shared.postgresInfo = nil
        shared.postgres = nil
        shared.didSignInOnline = false
    }
}

extension ConnectManager {
    
    func fillData(email: String, password: String, and info: LoginConnectionInfo) {
        loginData = CredentialsData(email: email, password: password)
        loginInfo = info
        postgresInfo = info.postgresInfo
    }
    
    func attemptLogin(offline: Bool) async throws -> ConnectionResponse {
        guard hasValidLoginData() else {
            return .failDueToMissingInfo()
        }
        
        var response: ConnectionResponse
        
        if isConnected && !offline {
            response = try await handleOnlineLogin()
        } else {
            response = await handleOfflineLogin()
        }
        
        if response.result == .success {
            response = await handleBiometricSetup(response: response)
        }
        return response
    }
    
    func attemptSyncOnlineLogin() async throws -> ConnectionResponse? {
        guard hasValidLoginData() else {
            return .failDueToMissingInfo()
        }
        return try await attemptA3TOnlineLogin()
    }
    
    private func hasValidLoginData() -> Bool {
        return loginData != nil && loginInfo != nil
    }

    private func handleOnlineLogin() async throws -> ConnectionResponse {
        guard await NetworkTracker.shared.canConnectToServer() else {
            return .timeout()
        }
        
        switch loginType {
        case .a3t:
            return try await attemptA3TOnlineLogin()
        case .api:
            return try await attemptApiOnlineLogin()
        }
    }
    
    private func attemptApiOnlineLogin() async throws -> ConnectionResponse {
        let response = try await ApiLogin(loginInfo, data: loginData).attemptLogin()
        guard let data = response.apiResponse else {
            return response
        }
        
        return try await processApiData(data)
    }
    
    private func processApiData(_ data: ApiLogin.Response) async throws -> ConnectionResponse {
        _ = createJWTToken(from: data.sessionToken)
        
        if let lastLogin = Connect.lastSavedLogin, lastLogin != loginData.email {
            return .overrideKeychain()
        }
        return authManager.saveUser(with: loginData)
    }
    
    private func attemptA3TOnlineLogin() async throws -> ConnectionResponse {
        let response = try await BackyardLogin(loginInfo, data: loginData).attemptLogin()
        guard let data = response.backyardData else {
            return response
        }
        
        DispatchQueue.main.sync {
            ConnectManager.shared.user = ConnectUser(for: data.user)
            ConnectManager.shared.didSignInOnline = true
        }
        
        guard postgresInfo != nil else {
            return try await processBackyardData(data)
        }
        
        self.postgresInfo?.databaseType = try unwrap(user?.databaseType)
        
        let postgresResponse = try await attemptPostgresLogin(with: try unwrap(self.postgresInfo))
        guard postgresResponse.result == .success else {
            return postgresResponse
        }
        
        return try await processBackyardData(data)
    }
    
    private func handleOfflineLogin() async -> ConnectionResponse {
        guard let lastLogin = ConnectManager.lastSavedLogin else {
            return .noUsersFound()
        }
        return await attemptOfflineLogin(for: lastLogin)
    }
    
    private func attemptOfflineLogin(for lastLogin: String) async -> ConnectionResponse {
        guard loginData.email == lastLogin else {
            return .incorrectUser(lastLogin: lastLogin)
        }
        guard let storedPassword = AuthManager.retrieveFromKeychain(account: lastLogin) else {
            return .noStoredCredentials(lastLogin: lastLogin)
        }
        guard storedPassword == loginData.password else {
            return .incorrectPassword()
        }
        guard let user = ConnectUser(for: lastLogin) else {
            return .userRecordNotFound(lastLogin: lastLogin)
        }
        
        DispatchQueue.main.sync { [weak self] in
            self?.user = user
            self?.inOfflineMode = true
        }
        
        return .success()
    }
    
    private func attemptPostgresLogin(with info: PostgresInfo) async throws -> ConnectionResponse {
        postgres = PostgresManager(info, credentials: loginData)
        return await loginInfo.appInfo.userTableConnect()
    }
    
    private func processBackyardData(_ data: BackyardLogin.Response) async throws -> ConnectionResponse {
        _ = createToken(from: data.sessionToken)
        
        if let lastLogin = Connect.lastSavedLogin, lastLogin != loginData.email {
            return .overrideKeychain()
        }
        return authManager.saveUser(with: loginData)
    }
    
    private func handleBiometricSetup(response: ConnectionResponse) async -> ConnectionResponse {
        if await authManager.askForBioMetricAuthenticationSetup() {
            return .setupBiometrics()
        }
        return response
    }
}

public extension ConnectManager {
    
    func attemptOnlineConnection() async {
        guard isConnected else {
            Core.makeSimpleAlert(title: "Offline", message: "Cannot attempt online connection, you are offline.")
            return
        }
        guard await NetworkTracker.shared.canConnectToServer() else {
            Core.makeSimpleAlert(title: "Server Connection Failed", message: "Could not establish connection with server, you might be in an area with poor connection.")
            return
        }
        
        do {
            let response = try await attemptA3TOnlineLogin()
            switch response.result {
            case .success:
                Core.makeSimpleAlert(title: "Connection Successful", message: "You are now connected to Alpine Server.")
            case .fail, .moreDetail:
                if let problem = response.problem {
                    let message = """
                    Details:\n\n
                    \(problem.title ?? "Unknown")\n\n
                    \(problem.detail ?? "Unknown")
                    """
                    Core.makeSimpleAlert(title: "Connection Problem", message: message)
                }
            }
        } catch {
            Core.makeError(error: error)
        }
    }
}

extension ConnectManager {
    
    public func getStoredToken() -> Token? {
        if let tokenData = core.defaults.backyardToken {
            return try? JSONDecoder().decode(Token.self, from: tokenData)
        }
        
        return nil
    }
    
    func requestNewToken(with info: LoginConnectionInfo, and credentials: CredentialsData) async throws -> (response: TokenResponse, token: Token?) {
        guard credentialsExist else { return (TokenResponse.noStoredCredentials, nil) }
        guard await NetworkTracker.shared.canConnectToServer() else { return (TokenResponse.notConnected, nil) }
        
        let response = try await BackyardLogin(info, data: credentials).attemptLogin()
        if let data = response.backyardData {
            let token = createToken(from: data.sessionToken)
            return (TokenResponse.success, token)
        }
        if let problem = response.problem {
            return (TokenResponse.serverIssue(problem.detail ?? "No details provided."), nil)
        }
        
        return (TokenResponse.unknownIssue, nil)
    }
    
    func createToken(from value: String) -> Token {
        let expDate = Calendar.current.date(byAdding: .hour, value: 8, to: Date())!
        let token = Token(rawValue: value, expirationDate: expDate)
        DispatchQueue.main.async { [weak self] in
            self?.token = token
            self?.core.defaults.backyardToken = token.encoded
        }
        return token
    }
    
    func createJWTToken(from value: String) -> Token {
        let expDate = Calendar.current.date(byAdding: .hour, value: 8, to: Date())!
        let token = Token(rawValue: value, expirationDate: expDate)
        DispatchQueue.main.async { [weak self] in
            self?.jwtToken = token
            self?.core.defaults.jwtToken = token.encoded
        }
        return token
    }
}

extension ConnectManager {

    func overrideCredentials() -> ConnectionResponse {
        authManager.saveUser(with: loginData)
    }
}


public extension ConnectManager {
    
    static func signingOutReset() {
        ConnectManager.reset()
        CoreAppControl.reset()
    }
    
    static func getValidToken(with info: LoginConnectionInfo) async throws -> (TokenResponse, Token?) {
        if let token = ConnectManager.shared.token ?? ConnectManager.shared.getStoredToken() {
            if NetworkTracker.shared.isConnected, await NetworkTracker.shared.canConnectToServer() {
                if token.expirationDate.add(.hour, value: -1) > Date() {
                    return (TokenResponse.success, token)
                }
            } else {
                return (TokenResponse.notConnected, token)
            }
        }
        return try await fetchNewToken(with: info)
    }
    
    static func fetchNewToken(with info: LoginConnectionInfo) async throws -> (TokenResponse, Token?) {
        guard let email = lastSavedLogin, let password = AuthManager.retrieveFromKeychain(account: email) else {
            return (TokenResponse.noStoredCredentials, nil)
        }
        
        let credentials = CredentialsData(email: email, password: password)
        return try await ConnectManager.shared.requestNewToken(with: info, and: credentials)
    }
    
    func signingOut() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) { [weak self] in
            self?.isSignedIn = false
            self?.core.defaults.backyardToken = nil
        }
    }
}
