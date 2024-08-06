//
//  ConnectionResponse.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/6/23.
//

import Foundation


public enum ConnectionDetail {
    case timeout
    case overrideKeychain
    case keychainSaveFail
    case biometrics
}

public enum ConnectionResult {
    case success
    case fail
    case moreDetail
}


public struct ConnectionResponse {
    
    public var result: ConnectionResult
    public var backyardData: BackyardLogin.Response?
    public var problem: ConnectionProblem?
    
    public var apiResponse: ApiLogin.Response?
    
    var detail: ConnectionDetail?
    
    public init(result: ConnectionResult) {
        self.result = result
    }
    
    public init(result: ConnectionResult, detail: ConnectionDetail) {
        self.result = result
        self.detail = detail
    }
    
    public init(result: ConnectionResult, detail: ConnectionDetail? = nil, data: BackyardLogin.Response? = nil, problem: ConnectionProblem? = nil) {
        self.result = result
        self.backyardData = data
        self.problem = problem
    }
    
    public init(result: ConnectionResult, data: ApiLogin.Response? = nil, problem: ConnectionProblem? = nil) {
        self.result = result
        self.apiResponse = data
        self.problem = problem
    }
}


extension ConnectionResponse {
    static func success() -> ConnectionResponse {
        return ConnectionResponse(result: .success)
    }
    static func failDueToMissingInfo() -> ConnectionResponse {
        return ConnectionResponse(result: .fail, problem: ConnectionProblem.missingInfo())
    }
    
    static func timeout() -> ConnectionResponse {
        return ConnectionResponse(result: .moreDetail, detail: .timeout)
    }
    
    static func noUsersFound() -> ConnectionResponse {
        return ConnectionResponse(result: .fail, problem: ConnectionProblem(customAlert: ConnectAlert(title: "No Users Found", message: "To perform an offline sign in, an online sign in is required at least once.")))
    }
    
    static func incorrectUser(lastLogin: String) -> ConnectionResponse {
        return ConnectionResponse(result: .fail, problem: ConnectionProblem(customAlert: ConnectAlert(title: "Incorrect User", message: "Only \(lastLogin) is able to sign in while offline.")))
    }
    
    static func noStoredCredentials(lastLogin: String) -> ConnectionResponse {
        return ConnectionResponse(result: .fail, problem: ConnectionProblem(customAlert: ConnectAlert(title: "No Stored Credentials", message: "Unable verify \(lastLogin) sign in data.")))
    }
    
    static func incorrectPassword() -> ConnectionResponse {
        return ConnectionResponse(result: .fail, problem: ConnectionProblem(customAlert: ConnectAlert(title: "Incorrect Password", message: "Your password is incorrect.")))
    }
    
    static func userRecordNotFound(lastLogin: String) -> ConnectionResponse {
        return ConnectionResponse(result: .fail, problem: ConnectionProblem(customAlert: ConnectAlert(title: "User Record Not Found", message: "Could not find existing record for \(lastLogin)")))
    }
    
    static func overrideKeychain() -> ConnectionResponse {
        return ConnectionResponse(result: .moreDetail, detail: .overrideKeychain)
    }
    
    static func setupBiometrics() -> ConnectionResponse {
        return ConnectionResponse(result: .moreDetail, detail: ConnectionDetail.biometrics)
    }
}
