//
//  ConnectAlert.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/6/23.
//

import SwiftUI

public struct ConnectAlert {
    public var title: String
    public var message: String?
    public var buttons: [AlertButton]?
    
    public var dismissButton: AlertButton?
    
    public static var empty: ConnectAlert {
        ConnectAlert(title: "Empty Alert", message: "This is an error if presented.")
    }
    
    public init(title: String, message: String? = nil, buttons: [AlertButton]? = nil, dismissButton: AlertButton? = nil) {
        self.title = title
        self.message = message
        self.buttons = buttons
        self.dismissButton = dismissButton
    }
}

public struct AlertButton {
    
    var label: String
    var role: ButtonRole?
    var action: () -> Void
    
    public init(label: String, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.label = label
        self.role = role
        self.action = action
    }
}

