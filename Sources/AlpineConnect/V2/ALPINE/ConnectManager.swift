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
    
    public static var shared = ConnectManager()
    
    public var core: CoreAppControl {
        CoreAppControl.shared
    }
    
    var isConnected: Bool {
        NetworkTracker.shared.isConnected
    }
        
    @Published public var user: ConnectUser!    
    public var token: Token?
    
    @Published var isSignedIn = false
    @Published public var inOfflineMode = false

    @Published public var id = UUID()
    
    private var loginData: CredentialsData!
    private var loginInfo: LoginConnectionInfo!
    var authManager: AuthManager = AuthManager()
    
    public var didSignInOnline = false
    
    private var postgresInfo: PostgresInfo?
    var isPostgresEnabled: Bool {
        postgresInfo != nil
    }
    
    public var postgres: PostgresManager?
    
    public var userID: String {
        user.databaseType == .production ?
        loginData.email : "\(loginData.email)-Sandbox"
    }
    
    init() {
        NetworkMonitor.shared.start()
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
        guard loginData != nil, loginInfo != nil else {
            return ConnectionResponse(result: .fail, problem: ConnectionProblem.missingInfo())
        }
        
        var response: ConnectionResponse
        
        if isConnected && !offline {
            guard await NetworkMonitor.shared.canConnectToServer() else {
                return ConnectionResponse(result: .moreDetail, detail: .timeout)
            }
            
            response = try await attemptOnlineLogin()
        }
        else {
            response = await attemptOfflineLogin()
        }
        
        if response.result == .success {
            if await authManager.askForBioMetricAuthenticationSetup() {
                response = ConnectionResponse(result: .moreDetail, detail: ConnectionDetail.biometrics)
            }
        }
        
        return response
    }
    
    func attemptOnlineLogin() async throws -> ConnectionResponse {
        let response = try await BackyardLogin(loginInfo, data: loginData).attemptLogin()
        guard let data = response.backyardData else {
            return response
        }
        
        DispatchQueue.main.sync {
            ConnectManager.shared.user = ConnectUser(for: data.user)
            ConnectManager.shared.didSignInOnline = true
        }
        
        //MARK: Connect user is initiated.
        
        guard postgresInfo != nil else {
            return try await processBackyardData(data)
        }
        
        self.postgresInfo!.databaseType = user.databaseType
        
        let postgresResponse = try await attemptPostgresLogin(with: self.postgresInfo!)
        guard postgresResponse.result == .success else {
            return postgresResponse
        }
        
        return try await processBackyardData(data)
    }
    
    private func attemptPostgresLogin(with info: PostgresInfo) async throws -> ConnectionResponse {
        postgres = PostgresManager(info, credentials: loginData)
        return await loginInfo.appInfo.userTableConnect()
    }
    
    private func processBackyardData(_ data: BackyardLogin.Response) async throws -> ConnectionResponse {
        createToken(from: data.sessionToken)
        
        if let lastLogin = Connect.lastSavedLogin {
            if lastLogin != loginData.email {
                return ConnectionResponse(result: .moreDetail, detail: .overrideKeychain)
            }
        }
        
        return authManager.saveUser(with: loginData) //MARK: Connect user is init here
    }
    
    func attemptOfflineLogin() async -> ConnectionResponse {
        guard let lastLogin = ConnectManager.lastSavedLogin else {
            return ConnectionResponse(result: .fail, problem: ConnectionProblem(customAlert: ConnectAlert(title: "No Users Found", message: "To perform an offline sign in, an online sign in is required at least once.")))
        }
        guard loginData.email == lastLogin else {
            return ConnectionResponse(result: .fail, problem: ConnectionProblem(customAlert: ConnectAlert(title: "Incorrect User", message: "Only \(lastLogin) is able to sign in while offline.")))
        }
        guard let storedPassword = AuthManager.retrieveFromKeychain(account: lastLogin) else {
            return ConnectionResponse(result: .fail, problem: ConnectionProblem(customAlert: ConnectAlert(title: "No Stored Credentials", message: "Unable verify \(lastLogin) sign in data.")))
        }
        guard storedPassword == loginData.password else {
            return ConnectionResponse(result: .fail, problem: ConnectionProblem(customAlert: ConnectAlert(title: "Incorrect Password", message: "Your password is incorrect.")))
        }
        guard let user = ConnectUser(for: lastLogin) else {
            return ConnectionResponse(result: .fail, problem: ConnectionProblem(customAlert: ConnectAlert(title: "User Record Not Found", message: "Could not find existing record for \(lastLogin)")))
        }
        
        DispatchQueue.main.sync {
            self.user = user
            inOfflineMode = true
        }

        return ConnectionResponse(result: .success)
    }
}

public extension ConnectManager {
    
    func attemptOnlineConnection() async {
        guard isConnected else {
            Core.makeSimpleAlert(title: "Offline", message: "Cannot attempt online connection, you are offline.")
            return
        }
        guard await NetworkMonitor.shared.canConnectToServer() else {
            Core.makeSimpleAlert(title: "Server Connection Failed", message: "Could not establish connection with server, you might be in an area with poor connection.")
            return
        }
        
        do {
            let response = try await attemptOnlineLogin()
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
        }
        catch {
            Core.shared.makeError(error: error)
        }
    }
}

extension ConnectManager {
    
    var credentialsExist: Bool {
        core.defaults.lastUser != nil
    }
    
    public func getStoredToken() -> Token? {
        if let tokenData = core.defaults.backyardToken {
            return try? JSONDecoder().decode(Token.self, from: tokenData)
        }
        
        return nil
    }
    
    func requestNewToken(with info: LoginConnectionInfo, and credentials: CredentialsData) async throws -> (response: TokenResponse, token: Token?) {
        guard credentialsExist else { return (TokenResponse.noStoredCredentials, nil) }
        guard isConnected, await NetworkMonitor.shared.canConnectToServer() else { return (TokenResponse.notConnected, nil) }
        
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
        DispatchQueue.main.async { [self] in
            self.token = token
            core.defaults.backyardToken = token.encoded
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
    
    static var isAbleToGetToken: Bool {
        ConnectManager.shared.credentialsExist
    }
    
    static var lastSavedLogin: String? {
        CoreAppControl.shared.defaults.lastUser
    }
    
    func signout() {
        Core.makeEvent("signing out", type: .userAction)
        isSignedIn = false
        core.defaults.backyardToken = nil
    }
    
    static func signout() {
        ConnectManager.reset()
        CoreAppControl.reset()
    }
    
    static func getValidToken(with info: LoginConnectionInfo) async throws -> (TokenResponse, Token?) {
        if let token = ConnectManager.shared.token ?? ConnectManager.shared.getStoredToken() {
            if NetworkMonitor.shared.connected, await NetworkMonitor.shared.canConnectToServer() {
                if token.expirationDate.add(.hour, value: -1) > Date() {
                    return (TokenResponse.success, token)
                }
            }
            else {
                return (TokenResponse.notConnected, token)
            }
        }

        return try await fetchNewToken(with: info)
    }
    
    static func fetchNewToken(with info: LoginConnectionInfo) async throws -> (TokenResponse, Token?) {
        guard let email = lastSavedLogin,
              let password = AuthManager.retrieveFromKeychain(account: email)
        else {
            return (TokenResponse.noStoredCredentials, nil)
        }
        
        let credentials = CredentialsData(email: email, password: password)
        return try await ConnectManager.shared.requestNewToken(with: info, and: credentials)

    }
    
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        return decoder
    }
}
