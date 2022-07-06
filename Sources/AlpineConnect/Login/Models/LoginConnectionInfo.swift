//
//  LoginConnectionInfo.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 6/23/22.
//

import Foundation

public struct LoginConnectionInfo {
    
    static var shared = LoginConnectionInfo(host: "", database: "", application: "", connectDBPassword: "")
    
    public init(host: String, database: String, application: String, connectDBPassword: String) {
        self.host = host
        self.database = database
        self.application = application
        self.connectDBPassword = connectDBPassword
    }
    
    var host: String
    var database: String
    var connectDBPassword: String
    var application: String
}
