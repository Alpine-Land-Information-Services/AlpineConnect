//
//  AppInfo.swift
//
//
//  Created by Vladislav on 7/19/24.
//

import Foundation

public struct AppInfo {
    
    public var storageToken: String?
    var url: String
    var token: String
    var userTableConnect: () async -> ConnectionResponse
    
    public init(url: String, token: String, storageToken: String? = nil, userTableConnect: @escaping () async -> ConnectionResponse) {
        self.url = url
        self.token = token
        self.userTableConnect = userTableConnect
        self.storageToken = storageToken
    }
}
