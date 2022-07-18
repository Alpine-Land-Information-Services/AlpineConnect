//
//  LoginConnectionInfo.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 6/23/22.
//

import Foundation

public struct LoginConnectionInfo {
    
    static var shared = LoginConnectionInfo(host: "", database: "", appFullName: "", appDBName: "", connectDBPassword: "", appUserFunction: {_ in })
    
    public init(host: String, database: String, appFullName: String, appDBName: String, connectDBPassword: String,
                appUserFunction: @escaping (@escaping (LoginResponse) -> ()) -> ()) {
        self.host = host
        self.database = database
        self.appFullName = appFullName
        self.appDBName = appDBName
        self.connectDBPassword = connectDBPassword
        self.appUserFunction = appUserFunction
    }
    
    var host: String
    var database: String
    var appFullName: String
    var appDBName: String
    var connectDBPassword: String
    var appUserFunction: (@escaping (LoginResponse) -> ()) -> ()
}
