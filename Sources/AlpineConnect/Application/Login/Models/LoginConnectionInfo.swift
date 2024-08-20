//
//  LoginConnectionInfo.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 6/23/22.
//

import Foundation

public struct LoginConnectionInfo {
    
    public var appInfo: AppInfo
    public var loginPageInfo: LoginPageInfo
    public var postgresInfo: PostgresInfo?
    public var trackingInfo: TrackingInfo
    
    public var appTokenActions: (_: String) throws -> JWTData

    public init(appInfo: AppInfo,
                loginPageInfo: LoginPageInfo,
                postgresInfo: PostgresInfo?,
                trackingInfo: TrackingInfo, _ appTokenActions: @escaping (_: String) throws -> JWTData = { _ in DefaultSessionToken() }) {
        self.appInfo = appInfo
        self.loginPageInfo = loginPageInfo
        self.postgresInfo = postgresInfo
        self.trackingInfo = trackingInfo
        self.appTokenActions = appTokenActions
    }
}


public struct DefaultSessionToken: JWTData {
    
    public var id: UUID
    public var sessionToken: String
    public var login: String
    public var userName: String?
    public var firstName: String?
    public var lastName: String?

    public init() {
        self.id = UUID()
        self.sessionToken = ""
        self.login = ""
    }
}
