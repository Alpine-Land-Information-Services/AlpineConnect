//
//  LoginConnectionInfo.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 6/23/22.
//

import Foundation

public struct LoginConnectionInfo {
    
    static var shared = LoginConnectionInfo(host: "", database: "", application: "", user: "", password: "")
    
    public init(host: String, database: String, application: String, user: String, password: String) {
        self.host = host
        self.database = database
        self.application = application
        self.user = user
        self.password = password
    }
    
    var host: String
    var database: String
    
    var application: String
    var user: String
    var password: String
}
