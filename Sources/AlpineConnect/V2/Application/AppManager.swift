//
//  AppManager.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/6/23.
//

import Foundation

public class AppManager: ObservableObject {
    
    static public var shared = AppManager()
    
    var isConnected: Bool {
        NetworkMonitor.shared.connected
    }
    
    @Published public var user: ConnectUser?
    @Published public var token: Token?
    
    private var loginData: CredentialsData?
    
    init() {
        NetworkMonitor.shared.start()
    }
}

extension AppManager {
    
    func attemptLogin(email: String, password: String) async -> ConnectionResponse {
        loginData = CredentialsData(email: email, password: password)
        
        if isConnected {
            return await attemptOnlineLogin()
        }
        else {
            return await attemptOfflineLogin()
        }
    }
    
    func attemptOnlineLogin() async -> ConnectionResponse {
        guard await NetworkMonitor.shared.canConnectToServer() else {
            return ConnectionResponse(result: .timeout, problem: nil)
        }
        guard let loginData else {
            return ConnectionResponse(result: .fail, problem: ConnectionProblem.missingInfo())
        }

//        let response = await BackyardLogin(, data: data)
    
        fatalError()
    }
    
    func attemptOfflineLogin() async -> ConnectionResponse {
        guard let loginData else {
            return ConnectionResponse(result: .fail, problem: ConnectionProblem.missingInfo())
        }
        fatalError()
    }
}
