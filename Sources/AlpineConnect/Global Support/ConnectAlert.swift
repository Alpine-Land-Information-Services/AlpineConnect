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
    public var isSecureField: Bool
    
    public static var empty: ConnectAlert {
        ConnectAlert(title: "Empty Alert", message: "This is an error if presented.")
    }
    
    public init(title: String, message: String? = nil, buttons: [ConnectAlertButton]? = nil, dismissButton: ConnectAlertButton? = nil, textFieldBinding: Binding<String>? = nil, textFieldPlaceholder: String? = nil, isSecureField: Bool =  false) {
        self.title = title
        self.message = message
        self.buttons = buttons
        self.dismissButton = dismissButton
        self.textFieldBinding = textFieldBinding
        self.textFieldPlaceholder = textFieldPlaceholder
        self.isSecureField = isSecureField
    }
}
