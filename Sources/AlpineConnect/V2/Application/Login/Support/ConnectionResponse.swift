//
//  ConnectionResponse.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/6/23.
//

import Foundation

public struct ConnectionResponse {
    
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
    
    public var result: ConnectionResult
    public var backyardData: BackyardLogin.Response?
    public var problem: ConnectionProblem?
    
    var detail: ConnectionDetail?
}

public enum ConnectionDetail {
    case timeout
    case enableKeychain
    case overrideKeychain
    case keychainSaveFail
}

public enum ConnectionResult {
    case success
    case fail
    case moreDetail
}
