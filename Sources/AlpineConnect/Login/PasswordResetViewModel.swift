//
//  PasswordResetViewModel.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 7/13/22.
//

import SwiftUI

class PasswordResetViewModel: ObservableObject {
    
    @Published var email = ""
    
    @Published var showSpinner = false
    @Published var showAlert = false
    @Published var open: Bool
    
    var resetStatus: PasswordReset.Status = .unknownError
    var message = ""
    
    init(open: Bool) {
        self.open = open
    }
    
    func reset() {
        guard Check.isValidEmail(email) else {
            resetStatus = .invalidEmail
            showAlert.toggle()
            return
        }
        
        showSpinner.toggle()
        
        Task {
            (resetStatus, message) = await PasswordReset.resetPassword(email: email)
            DispatchQueue.main.async {
                self.showSpinner.toggle()
                self.showAlert.toggle()
            }
        }
    }
    
    func alert() -> (String, String, String , () -> ()) {
        switch resetStatus {
        case .invalidEmail:
            return ("Invalid Email", "Enter a valid email address, with @ symbol and domain.", "Try Again", {})
        case .requestSent:
            return ("Reset Successful", "A new temporary password will be sent to your email shortly.", "OK", {self.open.toggle()})
        case .noUser:
            return ("Invalid User", "No user with provided email address exists.", "OK", {})
        default:
            return ("Unknown Error", "Error Code: \(message)", "OK", {})
        }
    }
}
