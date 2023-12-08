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
}

public struct AlertButton {
    var label: String
    var role: ButtonRole?
    var action: () -> Void
}

