//
//  ConnectAlert.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/6/23.
//

import SwiftUI

public struct ConnectAlert {
    var title: String
    var message: String?
    var buttons: [AlertButton]?
    
    var dismissButton: AlertButton?
    
    static var empty: ConnectAlert {
        ConnectAlert(title: "Empty Alert", message: "This should not be presented.")
    }
}

public struct AlertButton {
    var label: String
    var role: ButtonRole?
    var action: () -> Void
}

