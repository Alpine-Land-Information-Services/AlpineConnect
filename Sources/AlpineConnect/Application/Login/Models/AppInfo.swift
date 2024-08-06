//
//  AppInfo.swift
//
//
//  Created by Vladislav on 7/19/24.
//

import Foundation

public struct AppInfo {
    
    public enum LoginType {
        case a3t
        case api
    }
    
    var loginType: LoginType
    
    public var storageToken: String?
    var url: String
    var token: String
    var userTableConnect: () async -> ConnectionResponse
    
    public init(url: String, token: String, storageToken: String? = nil, loginType: LoginType = .a3t, userTableConnect: @escaping () async -> ConnectionResponse) {
        self.url = url
        self.token = token
        self.storageToken = storageToken
        self.loginType = loginType
        self.userTableConnect = userTableConnect
    }
}
