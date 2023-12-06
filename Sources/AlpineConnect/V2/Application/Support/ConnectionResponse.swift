//
//  ConnectionResponse.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/6/23.
//

import Foundation

public struct ConnectionResponse {
    
    public init(result: ConnectionResult, data: BackyardLogin.Response? = nil, problem: ConnectionProblem? = nil) {
        self.result = result
        self.backyardData = data
        self.problem = problem
    }
    
    public var result: ConnectionResult
    public var backyardData: BackyardLogin.Response?
    public var problem: ConnectionProblem?
}

public enum ConnectionResult {
    case success
    case fail
    case timeout
}
