//
//  LoginConnectionInfo.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 6/23/22.
//

import Foundation

public struct LoginConnectionInfo {
    
    static var shared = LoginConnectionInfo(host: "", database: "", application: "")
    
    public init(host: String, database: String, application: String) {
        self.host = host
        self.database = database
        self.application = application
    }
    
    var host: String
    var database: String
    
    var application: String
}
