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
    
    public init(appInfo: AppInfo, loginPageInfo: LoginPageInfo, postgresInfo: PostgresInfo?, trackingInfo: TrackingInfo) {
        self.appInfo = appInfo
        self.loginPageInfo = loginPageInfo
        self.postgresInfo = postgresInfo
        self.trackingInfo = trackingInfo
    }
}
