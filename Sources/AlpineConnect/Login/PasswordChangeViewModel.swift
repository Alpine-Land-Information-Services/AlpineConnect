//
//  PasswordChangeViewModel.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 6/27/22.
//

import SwiftUI

class PasswordChangeViewModel: ObservableObject {
    
    var required: Bool
    
    @Published var newPassword: String = ""
    @Published var repeatedNewPassword: String = ""
    
    init(required: Bool) {
        self.required = required
    }
}
