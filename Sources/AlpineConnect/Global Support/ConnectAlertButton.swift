//
//  ConnectAlertButton.swift
//  
//
//  Created by Vladislav on 7/19/24.
//

import SwiftUI

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
