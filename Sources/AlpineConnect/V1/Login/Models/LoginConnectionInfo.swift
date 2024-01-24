//
//  LoginConnectionInfo.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 6/23/22.
//

import Foundation

public struct LoginConnectionInfo {
    
    public init(appInfo: AppInfo, loginPageInfo: LoginPageInfo, postgresInfo: PostgresInfo?, trackingInfo: TrackingInfo?) {
        self.appInfo = appInfo
        self.loginPageInfo = loginPageInfo
        self.postgresInfo = postgresInfo
        self.trackingInfo = trackingInfo
    }
    
    public var appInfo: AppInfo
    public var loginPageInfo: LoginPageInfo
    public var postgresInfo: PostgresInfo?
    public var trackingInfo: TrackingInfo?
}

public struct PostgresInfo {
    
    public init(host: String, databaseType: DatabaseType? = nil, dbNames: DBNames, timeout: Int?) {
        self.host = host
        self.databaseType = databaseType ?? .production
        self.timeout = timeout
        self.dbNames = dbNames
    }
    
    var host: String
    var dbNames: DBNames
    var databaseType: DatabaseType
    var databaseName: String {
        dbNames.getName(from: databaseType)
    }
    var timeout: Int?
}

public struct DBNames {
    
    public init(productionName: String, sandboxName: String) {
        self.productionName = productionName
        self.sandboxName = sandboxName
    }
    
    private var productionName: String
    private var sandboxName: String
    
    func getName(from type: DatabaseType) -> String {
        switch type {
        case .production:
            return productionName
        case .sandbox:
            return sandboxName
        }
    }
}

public struct LoginPageInfo {
    
    public init(appName: String, companyName: String, logoImageName: String) {
        self.appName = appName
        self.companyName = companyName
        self.logoImageName = logoImageName
    }
    
    var appName: String
    var companyName: String
    var logoImageName: String
}

public struct TrackingInfo {
    
    public init(password: String) {
        self.password = password
    }
    
    var password: String
}

public struct AppInfo {
    
    public init(url: String, token: String, userTableConnect: @escaping () async -> ConnectionResponse) {
        self.url = url
        self.token = token
        self.userTableConnect = userTableConnect
    }
    
    var url: String
    var token: String
    var userTableConnect: () async -> ConnectionResponse
}
