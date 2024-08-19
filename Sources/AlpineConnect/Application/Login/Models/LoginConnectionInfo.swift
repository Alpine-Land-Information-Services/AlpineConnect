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
    
    public var appTokenActions: (_: HasSessionToken) -> Void

    public init(appInfo: AppInfo,
                loginPageInfo: LoginPageInfo,
                postgresInfo: PostgresInfo?,
                trackingInfo: TrackingInfo, _ appTokenActions: @escaping (_: HasSessionToken) -> Void = {_ in }) {
        self.appInfo = appInfo
        self.loginPageInfo = loginPageInfo
        self.postgresInfo = postgresInfo
        self.trackingInfo = trackingInfo
        self.appTokenActions = appTokenActions
    }
}
