//
//  LoginConnectionInfo.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 6/23/22.
//

import Foundation

public struct LoginConnectionInfo {
    
    static var shared = LoginConnectionInfo(host: "", database: "", appFullName: "", appDBName: "", connectDBPassword: "", appToken: "", appLoginURL: "", appUserFunction: {_ in })
    
    var host: String
    var database: String
    var appFullName: String
    var appDBName: String
    var connectDBPassword: String
    var appToken: String
    var appLoginURL: String
    var appUserFunction: (@escaping (LoginResponse) -> ()) -> ()
    
    public init(host: String, database: String, appFullName: String, appDBName: String, connectDBPassword: String, appToken: String, appLoginURL: String,
                appUserFunction: @escaping (@escaping (LoginResponse) -> ()) -> ()) {
        self.host = host
        self.database = database
        self.appFullName = appFullName
        self.appDBName = appDBName
        self.connectDBPassword = connectDBPassword
        self.appUserFunction = appUserFunction
        self.appToken = appToken
        self.appLoginURL = appLoginURL
    }
}
