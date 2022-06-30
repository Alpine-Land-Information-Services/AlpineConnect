//
//  PasswordChangeViewModel.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 6/27/22.
//

import SwiftUI

class PasswordChangeViewModel: ObservableObject {
    
    enum PasswordAlertType {
        case notMatchedPasswords
        case passwordChanged
        case oldPasswordMatch
        case invalidCredentials
        case unknownError
    }
    
    var required: Bool
    var alertType: PasswordAlertType = .notMatchedPasswords
    var unknownErrorMessage = ""
    
    let userManager = UserManager.shared
    
    @Published var oldPassword: String = ""
    @Published var newPassword: String = ""
    @Published var repeatedNewPassword: String = ""
    
    @Published var showAlert = false
    @Published var showSpinner = false
    @Published var dismiss = false
    
    init(required: Bool) {
        self.required = required
    }
    
    func allFieldsFilled() -> Bool {
        return oldPassword == "" || newPassword == "" || repeatedNewPassword == ""
    }
    
    func backToLogin() {
        UserManager.shared.inputPassword = ""
        dismiss.toggle()
    }
    
    func sendAlert(alert: PasswordAlertType) {
        alertType = alert
        DispatchQueue.main.async {
            self.showAlert.toggle()
        }
    }
    
    func asyncSpinnerChange() {
        DispatchQueue.main.async {
            self.showSpinner.toggle()
        }
    }
    
    func changePassword() {
        guard newPassword == repeatedNewPassword else {
            sendAlert(alert: .notMatchedPasswords)
            return
        }
        guard oldPassword == UserManager.shared.password else {
            sendAlert(alert: .invalidCredentials)
            return
        }
        guard newPassword != UserManager.shared.password else {
            sendAlert(alert: .oldPasswordMatch)
            return
        }
        
        showSpinner.toggle()
        
        Login.changePassword(with: newPassword, completionHandler: { changed, errorResponse in
            if changed {
                self.sendAlert(alert: .passwordChanged)
                self.asyncSpinnerChange()
                self.userManager.password = self.newPassword
                KeychainAuthentication.shared.updateCredentialsOnKeyChain { _ in }
            }
            if let errorResponse = errorResponse {
                self.unknownErrorMessage = String(describing: errorResponse)
                self.sendAlert(alert: .unknownError)
                self.asyncSpinnerChange()
            }
        })
    }
    
    func alert() -> (String, String, String, () -> Void) {
        switch alertType {
        case .notMatchedPasswords:
            return ("Mismatched Fields", "Try Again", "New password fields do not match.", {})
        case .passwordChanged:
            return ("Password Changed", "Back to Login", "Your password has been changed. Use new password at Login.", backToLogin)
        case .invalidCredentials:
            return ("Incorrect Password", "Try Again", "Your old password is incorrect.", {})
        case .unknownError:
            return ("Unknown Error", "OK", "Report this error to the development team: \(unknownErrorMessage)", {})
        case .oldPasswordMatch:
            return ("Same Password", "Try Again", "Your old password cannot be the same as the new password.", {})
        }
    }
}
