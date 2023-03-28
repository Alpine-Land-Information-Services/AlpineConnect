//
//  NotificationCenter.swift
//  AlpineConnect
//
//  Created by mkv on 3/28/23.
//

import Foundation

public extension NotificationCenter {
    static func post(_ name: NSNotification.Name, _ userInfo: [AnyHashable : Any]? = nil) {
        NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo)
    }
    
    static func postMainAsync(_ name: NSNotification.Name, _ userInfo: [AnyHashable : Any]? = nil) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo)
        }
    }
}
