//
//  Alert.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 10/14/22.
//

import SwiftUI

public struct AppAlert {
    
    public var title: String
    public var message: String
    public var dismiss: AlertAction
    public var actions: [AlertAction] = []
    
    public init(title: String, message: String, dismiss: AlertAction = AlertAction(text: "Okay"), actions: [AlertAction] = []) {
        self.title = title
        self.message = message
        self.dismiss = dismiss
        self.actions = actions
    }
}

public struct AlertAction {
    
    public enum AlertButtonRole {
        case dismiss
        case destructive
        case alert
        case regular
    }
    
    public var text: String
    public var role: AlertButtonRole
    public var action: () -> ()
    
    public init(text: String, role: AlertButtonRole = .regular, action: @escaping (() -> ()) = {}) {
        self.text = text
        self.role = role
        self.action = {
            AlertAction.actionMaker {
                action()
            }
        }
    }
    
    static func actionMaker(action: () -> ()) {
        action()
        NotificationCenter.default.post(name: Notification.Name("AlertCancel"), object: nil)
    }
}
