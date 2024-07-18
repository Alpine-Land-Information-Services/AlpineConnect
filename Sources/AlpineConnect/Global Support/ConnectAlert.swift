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
    public var buttons: [ConnectAlertButton]?
    public var dismissButton: ConnectAlertButton?
    public var textFieldBinding: Binding<String>?
    public var textFieldPlaceholder: String?
    
    public static var empty: ConnectAlert {
        ConnectAlert(title: "Empty Alert", message: "This is an error if presented.")
    }
    
    public init(title: String, message: String? = nil, buttons: [ConnectAlertButton]? = nil, dismissButton: ConnectAlertButton? = nil, textFieldBinding: Binding<String>? = nil, textFieldPlaceholder: String? = nil) {
        self.title = title
        self.message = message
        self.buttons = buttons
        self.dismissButton = dismissButton
        self.textFieldBinding = textFieldBinding
        self.textFieldPlaceholder = textFieldPlaceholder
    }
}

public struct ConnectAlertButton {
    
    var label: String
    var role: ButtonRole?
    var action: () -> Void
    
    public init(label: String, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.label = label
        self.role = role
        self.action = action
    }
}
